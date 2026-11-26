# /// script
# requires-python = ">=3.10"
# dependencies = ["numpy>=2,<3"]
# ///
"""Render the eight music loops for Cinder Below.

Outputs 8 WAV files matching GameMaker's sounds/ layout under --output:
  snd_title, snd_music, snd_cinder, snd_hollow,
  snd_glassfen, snd_reliquary, snd_boss, snd_boss_crown

Run:
  uv run tools/render_score.py --cache .gmcache/piano --output .gmcache/score

Piano samples: University of Iowa Electronic Music Studios, Steinway B
(unrestricted project use).
"""

import argparse
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache
from pathlib import Path
import subprocess
import wave

import numpy as np


RATE = 44100
TAU = 2 * np.pi
PIANO_URL = "https://theremin.music.uiowa.edu/sound%20files/MIS/Piano_Other/piano"
PIANO_KEYS = dict(zip(range(45, 85, 3), (
    "A2", "C3", "Eb3", "Gb3", "A3", "C4", "Eb4", "Gb4",
    "A4", "C5", "Eb5", "Gb5", "A5", "C6",
)))


def load_piano(cache: Path) -> dict[int, np.ndarray]:
    cache.mkdir(parents=True, exist_ok=True)

    def load(item):
        midi, key = item
        source = f"Piano.pp.{key}.aiff"
        pcm = cache / f"{key}.f32"
        if not pcm.exists():
            raw = subprocess.check_output([
                "ffmpeg", "-nostdin", "-v", "error", "-rw_timeout", "15000000",
                "-i", f"{PIANO_URL}/{source}", "-t", "6",
                "-ac", "2", "-ar", str(RATE), "-f", "f32le", "pipe:1",
            ])
            if len(raw) < RATE * 8 * 5:
                raise ValueError(f"Piano sample is too short: {source}")
            pcm.write_bytes(raw)
        signal = np.fromfile(pcm, "<f4").reshape(-1, 2)
        front = np.max(np.abs(signal), axis=1)
        onset = max(0, int(np.argmax(front > front.max() * 0.026)) - 170)
        signal = signal[onset:].copy()
        signal -= signal.mean(axis=0)
        signal /= max(0.001, np.sqrt(np.mean(signal[:RATE // 5] ** 2)))
        return midi, signal

    with ThreadPoolExecutor(max_workers=6) as workers:
        return dict(workers.map(load, PIANO_KEYS.items()))


def envelope(t: np.ndarray, attack: float, release: float) -> np.ndarray:
    return (
        np.sin(np.pi * 0.5 * np.clip(t / max(attack, 1e-4), 0, 1)) ** 2
        * np.sin(np.pi * 0.5 * np.clip((t[-1] - t) / max(release, 1e-4), 0, 1)) ** 2
    )


def lowpass_fft(signal: np.ndarray, cutoff_hz: float, order: float = 1.0) -> np.ndarray:
    """Zero-phase circular low-pass filter (preserves exact loop seamlessness)."""
    freqs = np.fft.rfftfreq(len(signal), 1.0 / RATE)
    response = 1.0 / np.sqrt(1.0 + (freqs / cutoff_hz) ** (2.0 * order))
    if signal.ndim == 2:
        response = response[:, None]
    return np.fft.irfft(np.fft.rfft(signal, axis=0) * response, n=len(signal), axis=0).astype("f4")


def soft_limit(signal: np.ndarray, ceiling: float = 0.66, knee: float = 0.42) -> np.ndarray:
    """Transparent soft-knee peak tamer so transients stay warm without dragging RMS down."""
    mag = np.abs(signal)
    over = np.maximum(0.0, mag - knee)
    headroom = ceiling - knee
    compressed = knee + headroom * np.tanh(over / max(headroom, 1e-6))
    return np.where(mag > knee, np.sign(signal) * compressed, signal).astype("f4")


class Score:
    def __init__(self, bars: int, bpm: float, piano: dict[int, np.ndarray], beats_per_bar: int = 4):
        self.bars = bars
        self.bpm = bpm
        self.beats_per_bar = beats_per_bar
        self.beat = 60.0 / bpm
        self.length = round(bars * beats_per_bar * self.beat * RATE)
        self.dry = np.zeros((self.length, 2), dtype="f4")
        self.send = np.zeros_like(self.dry)
        self.piano = piano

    @lru_cache(maxsize=384)
    def voice(self, kind: str, note: int, gate: float) -> np.ndarray:
        tails = {
            "piano": 1.60,
            "felt": 1.75,
            "bow": 1.35,
            "cello": 1.15,
            "glass": 1.20,
            "wood": 0.42,
            "pluck": 0.36,
            "bass": 0.18,
            "brass": 0.28,
        }
        tail = tails[kind]
        t = np.arange(round((gate + tail) * RATE)) / RATE
        if kind in ("piano", "felt"):
            key = min(self.piano, key=lambda pitch: abs(pitch - note))
            sample = self.piano[key]
            index = t * RATE * 2 ** ((note - key) / 12)
            signal = np.column_stack([
                np.interp(index, np.arange(len(sample)), channel, right=0)
                for channel in sample.T
            ]).astype("f4")
            damper = np.exp(-np.maximum(0, t - gate) * (3.2 if kind == "felt" else 4.6))
            attack = 0.015 if kind == "felt" else 0.005
            out = signal * (damper * envelope(t, attack, 0.34))[:, None]
            if kind == "felt":
                out = lowpass_fft(out, 2100.0, order=1.2)
            return out

        f0 = 440.0 * 2 ** ((note - 69) / 12)
        p = TAU * f0 * t
        off = np.maximum(0, t - gate)

        if kind == "bow":
            vib = 0.10 * np.sin(TAU * 3.6 * t) * np.clip(t / 0.8, 0, 1)
            sig = (
                0.56 * np.sin(p + vib)
                + 0.24 * np.sin(p * 1.0016 - vib)
                + 0.14 * np.sin(2 * p + vib)
                + 0.04 * np.sin(3 * p)
            )
            return (sig * envelope(t, min(0.95, gate * 0.45), tail) * np.exp(-off * 1.6)).astype("f4")

        if kind == "cello":
            vib = 0.08 * np.sin(TAU * 4.4 * t) * np.clip(t / 0.5, 0, 1)
            sig = (
                0.52 * np.sin(p + vib)
                + 0.28 * np.sin(2 * p + vib)
                + 0.14 * np.sin(3 * p)
                + 0.06 * np.sin(4 * p) * np.exp(-t * 1.8)
            )
            return (sig * envelope(t, min(0.45, gate * 0.35), tail) * np.exp(-off * 2.2)).astype("f4")

        if kind == "glass":
            sig = (
                0.85 * np.sin(p)
                + 0.18 * np.sin(2.0008 * p) * np.exp(-t * 4.5)
                + 0.14 * np.sin(3.004 * p) * np.exp(-t * 9.0)
                + 0.05 * np.sin(5.01 * p) * np.exp(-t * 18.0)
            )
            return (sig * envelope(t, 0.012, 0.28) * np.exp(-t * 1.9 - off * 2.4)).astype("f4")

        if kind == "wood":
            # Warm marimba/wood-kalimba tone for Moss exploration
            sig = (
                0.82 * np.sin(p)
                + 0.18 * np.sin(4.0 * p) * np.exp(-t * 22.0)
                + 0.07 * np.sin(2.0 * p) * np.exp(-t * 10.0)
            )
            return (sig * envelope(t, 0.003, 0.12) * np.exp(-t * 5.2 - off * 6.0)).astype("f4")

        if kind == "pluck":
            sig = (
                0.72 * np.sin(p)
                + 0.32 * np.sin(2 * p) * np.exp(-t * 7.0)
                + 0.18 * np.sin(3 * p) * np.exp(-t * 12.5)
                + 0.08 * np.sin(5 * p) * np.exp(-t * 18.0)
            )
            return (sig * envelope(t, 0.004, 0.16) * np.exp(-t * 3.0 - off * 5.5)).astype("f4")

        if kind == "brass":
            # Resonant dark horn/synth lead with slight pitch bloom on attack
            bloom = 1.0 - 0.006 * np.exp(-t * 28.0)
            pb = p * bloom
            sig = (
                0.48 * np.sin(pb)
                + 0.30 * np.sin(2 * pb) * (0.65 + 0.35 * np.exp(-t * 2.5))
                + 0.22 * np.sin(3 * pb) * np.exp(-t * 3.8)
                + 0.14 * np.sin(4 * pb) * np.exp(-t * 6.5)
                + 0.09 * np.sin(5 * pb) * np.exp(-t * 9.5)
            )
            return (sig * envelope(t, 0.020, 0.14) * np.exp(-off * 6.2)).astype("f4")

        # bass: warm sub + gentle harmonic grit
        sig = (
            0.78 * np.sin(p)
            + 0.26 * np.sin(2 * p) * np.exp(-t * 1.4)
            + 0.10 * np.sin(3 * p) * np.exp(-t * 9.0)
        )
        return (sig * envelope(t, 0.009, 0.13) * np.exp(-t * 1.0 - off * 7.0)).astype("f4")

    def place(self, beat: float, signal: np.ndarray, level: float, pan: float = 0.0, send: float = 0.25):
        stereo = signal[:, None] if signal.ndim == 1 else signal
        pan_c = max(-0.95, min(0.95, pan))
        stereo = stereo * level * np.sqrt([1.0 - pan_c, 1.0 + pan_c])
        start = round(beat * self.beat * RATE) % self.length
        first = min(self.length - start, len(stereo))
        for bus, gain in ((self.dry, 1.0), (self.send, send)):
            bus[start:start + first] += stereo[:first] * gain
            rem = len(stereo) - first
            if rem > 0:
                bus[:rem] += stereo[first:first + rem] * gain

    def note(self, beat: float, note: int, beats: float, level: float, kind: str = "piano", pan: float = 0.0, send: float = 0.25):
        self.place(beat, self.voice(kind, note, round(beats * self.beat, 3)), level, pan, send)

    def drums(self, bar: int, pattern, level: float):
        for off, kind, vel in pattern:
            dur = 0.36 if kind in ("kick", "tom") else 0.18
            t = np.arange(round(dur * RATE)) / RATE
            rng = np.random.default_rng(round((bar * self.beats_per_bar + off) * 64) + 197)
            noise = rng.standard_normal(len(t))
            if kind == "kick":
                p = TAU * (45 * t + (1 - np.exp(-t * 44)) * 1.8)
                sig = np.sin(p) * np.exp(-t * 13.5) + 0.08 * noise * np.exp(-t * 105)
            elif kind == "tom":
                p = TAU * (78 * t + (1 - np.exp(-t * 30)) * 1.2)
                sig = np.sin(p) * np.exp(-t * 10.5) + 0.05 * noise * np.exp(-t * 85)
            elif kind == "snare":
                sig = 0.38 * noise * np.exp(-t * 22) + 0.46 * np.sin(TAU * 182 * t) * np.exp(-t * 28)
            elif kind == "rim":
                sig = (0.20 * noise + 0.54 * np.sin(TAU * 235 * t)) * np.exp(-t * 38)
            elif kind == "anvil":
                # Subtle metallic ping for Cinder Halls
                sig = (0.45 * np.sin(TAU * 620 * t) + 0.30 * np.sin(TAU * 1490 * t) + 0.15 * noise) * np.exp(-t * 28)
            else:  # hat / brush
                sig = (noise - np.r_[0, noise[:-1]]) * np.exp(-t * 48) * 0.14
            pan = 0.18 if kind in ("hat", "anvil") else (-0.14 if kind == "tom" else 0.0)
            self.place(
                bar * self.beats_per_bar + off,
                (sig * envelope(t, 0.0025, 0.032)).astype("f4"),
                level * vel,
                pan,
                0.12 if kind == "anvil" else 0.08,
            )

    def write(
        self, output: Path, name: str, stereo: bool, rms_db: float,
        reverb_scale: float = 1.0, reverb_damp_hz: float = 3200.0, warmth_hz: float | None = None,
    ):
        # 16-tap diffused prime-delay circular hall reverb (loop-seamless, lush, no metallic ring)
        taps = (
            (0.029, 0.20, False), (0.043, 0.18, True),  (0.067, 0.16, False), (0.097, 0.15, True),
            (0.131, 0.13, True),  (0.173, 0.12, False), (0.227, 0.10, True),  (0.283, 0.09, False),
            (0.359, 0.08, True),  (0.443, 0.068, False),(0.541, 0.056, True), (0.653, 0.045, False),
            (0.787, 0.036, True), (0.941, 0.028, False),(1.117, 0.021, True), (1.307, 0.015, False),
        )
        wet = np.zeros_like(self.dry)
        for delay, gain, cross in taps:
            src = self.send[:, ::-1] if cross else self.send
            wet += np.roll(src, round(delay * RATE), axis=0) * (gain * reverb_scale)
        wet = lowpass_fft(wet, reverb_damp_hz, order=1.3)
        mix = self.dry + wet
        if warmth_hz is not None:
            mix = lowpass_fft(mix, warmth_hz, order=1.0)
        if not stereo:
            mix = mix.mean(axis=1)
        mix -= mix.mean(axis=0)

        # Normalize to target RMS first, then gently soft-limit peaks above -7.5 dBFS to keep <= -3.6 dBFS
        cur_rms = float(np.sqrt(np.mean(mix ** 2)))
        target_rms = 10.0 ** (rms_db / 20.0)
        mix = mix * (target_rms / max(cur_rms, 1e-9))
        mix = soft_limit(mix, ceiling=0.66, knee=0.42)
        mix -= mix.mean(axis=0)

        # Final safety clamp in case soft_limit shifted RMS slightly
        peak = float(np.max(np.abs(mix)))
        if peak > 0.66:
            mix *= 0.66 / peak

        pcm = np.rint(mix * 32767.0).clip(-32767, 32767).astype("<i2")
        target = output / f"snd_{name}" / f"snd_{name}.wav"
        target.parent.mkdir(parents=True, exist_ok=True)
        with wave.open(str(target), "wb") as stream:
            stream.setparams((2 if stereo else 1, 2, RATE, 0, "NONE", "not compressed"))
            stream.writeframes(pcm.tobytes())
        actual_rms = 20 * np.log10(np.sqrt(np.mean((pcm / 32768.0) ** 2)) + 1e-12)
        actual_peak = 20 * np.log10(np.max(np.abs(pcm / 32768.0)) + 1e-12)
        print(f"{target.name:18s} ch={2 if stereo else 1} dur={len(pcm) / RATE:6.2f}s rms={actual_rms:6.2f}dBFS peak={actual_peak:6.2f}dBFS")
        self.voice.cache_clear()


# ---------------------------------------------------------------------------
# 1. TITLE THEME — "Hearth in the Ash" (D Dorian / D minor, 72 BPM, 4/4, 16 bars)
#    Signature 5-note motif: D5 - A4 - G4 - A4 - C5
#    Improvements: subtle human rubato, warm alto counter-notes in B section,
#    delicate high A5 bell echo, lush low-damped hall reverb, seamless loop pad.
# ---------------------------------------------------------------------------
def render_title(piano, output: Path):
    score = Score(bars=16, bpm=72, piano=piano, beats_per_bar=4)

    chords = [
        # A (bars 0-3): Dm9 -> Csus2 -> Bbmaj7 -> A7sus4
        (50, 57, 64), (48, 55, 62), (46, 53, 62), (45, 52, 60),
        # A' (bars 4-7): Dm9 -> Fmaj7 -> Gm7 -> Dm(add9)
        (50, 57, 64), (41, 53, 60), (43, 50, 58), (50, 57, 62),
        # B (bars 8-11): Bbmaj7 -> C6 -> Dm9 -> Am7
        (46, 53, 62), (48, 55, 64), (50, 57, 64), (45, 52, 60),
        # A'' & exhale (bars 12-15): Bbmaj7 -> Csus2 -> Dm(add9) -> Dm(open)
        (46, 53, 62), (48, 55, 62), (50, 57, 62), (50, 57, 64),
    ]

    melody = [
        # Bar 0-1: Signature 5-note motif (D5 - A4 - G4 - A4 - C5)
        (0, 0.02, 74, 1.5, 0.132), (0, 1.53, 69, 1.0, 0.102), (0, 2.52, 67, 1.4, 0.098),
        (1, 0.03, 69, 1.4, 0.110), (1, 1.52, 72, 2.4, 0.124),
        # Bar 2-3: Gentle answer
        (2, 0.52, 74, 1.3, 0.115), (2, 2.02, 72, 1.7, 0.102),
        (3, 0.03, 69, 3.2, 0.112),

        # Bar 4-5: Motif reaches up to F5 -> E5
        (4, 0.02, 74, 1.5, 0.136), (4, 1.52, 69, 1.0, 0.106), (4, 2.53, 67, 1.4, 0.100),
        (5, 0.02, 77, 1.9, 0.132), (5, 2.04, 76, 1.8, 0.112),
        # Bar 6-7: Warm descent
        (6, 0.02, 74, 1.4, 0.118), (6, 1.53, 70, 1.0, 0.096), (6, 2.52, 69, 1.5, 0.102),
        (7, 0.03, 74, 3.0, 0.114),

        # Bar 8-11: B section — luminous upper register
        (8, 0.02, 77, 1.9, 0.132), (8, 2.03, 79, 1.9, 0.124),
        (9, 0.02, 81, 2.3, 0.138), (9, 2.53, 79, 1.4, 0.110),
        (10, 0.02, 77, 1.4, 0.124), (10, 1.52, 76, 1.1, 0.108), (10, 2.53, 74, 1.5, 0.116),
        (11, 0.03, 72, 2.8, 0.110),

        # Bar 12-15: Return & open exhale
        (12, 0.02, 74, 1.5, 0.126), (12, 1.53, 69, 1.0, 0.098), (12, 2.52, 67, 1.4, 0.094),
        (13, 0.03, 69, 1.4, 0.104), (13, 1.52, 72, 2.3, 0.114),
        (14, 0.02, 74, 3.3, 0.112),
        (15, 1.52, 69, 2.3, 0.084),
    ]

    # Delicate inner alto & high bell echoes for emotional depth in B section
    extras = [
        (8, 1.0, 65, 2.4, 0.042, "felt", -0.05),
        (9, 1.0, 67, 2.4, 0.042, "felt", -0.05),
        (10, 1.5, 81, 2.2, 0.036, "glass", 0.24),
        (11, 2.0, 76, 1.8, 0.032, "glass", -0.20),
    ]

    for bar, (low, mid, high) in enumerate(chords):
        start = bar * 4.0
        swell = 1.08 if 8 <= bar < 12 else (0.88 if bar >= 14 else 1.0)
        score.note(start + 0.01, low, 3.7, 0.072 * swell, kind="felt", pan=-0.18, send=0.34)
        score.note(start + 1.03, mid, 2.8, 0.044 * swell, kind="felt", pan=-0.10, send=0.36)
        score.note(start + 2.52, high, 1.6, 0.030 * swell, kind="felt", pan=-0.05, send=0.40)

        # Whisper of warm cello/bowed strings in B section + subtle glue pad at bar 15->0
        if 8 <= bar < 12:
            score.note(start, low + 12, 4.0, 0.026, kind="bow", pan=0.24, send=0.58)
            score.note(start + 0.2, mid + 12, 3.8, 0.020, kind="bow", pan=-0.24, send=0.58)
        elif bar in (15, 0):
            score.note(start, 62, 3.9, 0.014, kind="bow", pan=0.0, send=0.60)

    for bar, beat, midi, length, vel in melody:
        kind = "piano" if bar < 14 else "felt"
        score.note(bar * 4.0 + beat, midi, length, vel, kind=kind, pan=0.10, send=0.40)

    for bar, beat, midi, length, vel, kind, pan in extras:
        score.note(bar * 4.0 + beat, midi, length, vel, kind=kind, pan=pan, send=0.50)

    score.write(output, "title", stereo=True, rms_db=-23.5, reverb_scale=1.20, reverb_damp_hz=2700.0, warmth_hz=5000.0)


# ---------------------------------------------------------------------------
# 2. EXPLORATION TRACKS — Distinct melodies & textures per biome
#    Continuous warm harmonic bed across bar 15 -> bar 0 eliminates seam RMS jumps.
# ---------------------------------------------------------------------------
M = (0, 3, 7)
VI = (-4, 4, 7)
III = (3, 4, 7)
VII = (-2, 4, 7)
IV = (5, 3, 7)
V = (-5, 4, 7)
II = (1, 4, 7)
DIM = (0, 3, 6)
REST = ()

# Biome-specific melodic vocabularies (beat, semitone_from_root+24, length, vel)
# 1) Moss (warm, wandering, echoes title's 5th-to-4th)
MOSS_A = ((0.5, 12, 1.3, 0.95), (2.0, 7, 1.0, 0.80), (3.0, 9, 1.0, 0.85))
MOSS_B = ((0.5, 10, 1.4, 0.90), (2.0, 7, 1.8, 0.82))
MOSS_C = ((0.0, 14, 1.5, 0.96), (1.75, 12, 1.0, 0.84), (2.75, 10, 1.2, 0.88))
MOSS_D = ((0.5, 9, 1.2, 0.82), (2.0, 7, 1.9, 0.78))

# 2) Cinder (smoldering, syncopated forge-ember cadence)
CIND_A = ((0.0, 12, 0.9, 0.95), (1.0, 10, 0.7, 0.80), (1.75, 7, 1.2, 0.92), (3.0, 10, 0.9, 0.84))
CIND_B = ((0.5, 12, 1.1, 0.90), (2.0, 15, 1.4, 0.96))
CIND_C = ((0.0, 14, 1.0, 0.94), (1.5, 12, 0.9, 0.84), (2.5, 10, 1.3, 0.88))
CIND_D = ((0.5, 7, 1.4, 0.82), (2.5, 5, 1.3, 0.76))

# 3) Hollow (ultra-sparse, cavernous, Minecraft-like lonely piano drops)
HOLL_A = ((0.5, 12, 2.4, 0.92), (3.0, 7, 1.6, 0.74))
HOLL_B = ((1.0, 10, 2.6, 0.86),)
HOLL_C = ((0.5, 15, 2.2, 0.94), (2.75, 14, 1.8, 0.78))
HOLL_D = ((1.0, 7, 2.8, 0.76),)

# 4) Glassfen (crystalline, shimmering descending/ascending reflections)
GLAS_A = ((0.25, 14, 1.2, 0.90), (1.5, 12, 1.2, 0.82), (2.75, 7, 1.3, 0.86))
GLAS_B = ((0.5, 10, 1.4, 0.84), (2.0, 14, 1.8, 0.92))
GLAS_C = ((0.25, 17, 1.5, 0.96), (2.0, 15, 1.0, 0.84), (3.0, 14, 1.1, 0.80))
GLAS_D = ((0.5, 12, 2.2, 0.78),)

# 5) Reliquary (solemn Phrygian b2 tension, foreshadowing Crown of Cinders)
RELI_A = ((0.5, 12, 1.3, 0.96), (2.0, 13, 1.1, 0.88), (3.25, 12, 0.9, 0.82))
RELI_B = ((0.5, 10, 1.4, 0.88), (2.25, 7, 1.6, 0.84))
RELI_C = ((0.0, 15, 1.5, 0.98), (1.75, 13, 1.2, 0.90), (3.0, 12, 1.0, 0.84))
RELI_D = ((0.5, 8, 1.3, 0.84), (2.0, 7, 1.9, 0.80))

PULSE_MOSS      = ((0.0, "kick", 0.50), (2.5, "rim", 0.30), (3.5, "hat", 0.22))
PULSE_CINDER    = ((0.0, "kick", 0.66), (1.5, "anvil", 0.32), (2.5, "kick", 0.48), (3.5, "rim", 0.34))
PULSE_HOLLOW    = ((0.0, "kick", 0.34), (3.0, "hat", 0.16))
PULSE_GLASS     = ((0.0, "kick", 0.42), (2.0, "rim", 0.26), (3.5, "hat", 0.22))
PULSE_RELIQUARY = ((0.0, "kick", 0.60), (1.5, "tom", 0.44), (2.5, "rim", 0.38), (3.5, "hat", 0.26))


def render_exploration(
    piano, output: Path, name: str, bpm: float, root: int,
    voices: tuple[str, str], opening, bridge, motif_set, groove, drum_level: float,
    stereo: bool, rms_db: float, sparse: bool = False,
):
    score = Score(bars=16, bpm=bpm, piano=piano, beats_per_bar=4)
    lead_voice, shimmer_voice = voices
    m_a, m_b, m_c, m_d = motif_set
    chords = list(opening) + list(opening[:2]) + [IV, V] + list(bridge) + list(opening[:2]) + [IV, M]

    if sparse:
        lines = (
            m_a, REST, REST, m_b,
            REST, m_a, REST, REST,
            m_c, REST, m_d, REST,
            m_a, REST, m_d, REST,
        )
    else:
        lines = (
            m_a, REST, m_b, REST,
            m_a, REST, m_c, REST,
            REST, m_c, REST, m_d,
            m_a, REST, m_b, m_d,
        )

    for bar, ((offset, third, fifth), line) in enumerate(zip(chords, lines, strict=True)):
        start = bar * 4.0
        bass = root + offset
        quiet_middle = 8 <= bar < 12
        ending_breath = bar == 15
        dyn = 0.80 if quiet_middle else (0.84 if ending_breath else 1.0)

        # Warm bass (enter slightly softly on bar 0 so loop wrap is buttery smooth)
        b_vel = 0.17 if bar == 0 else 0.19
        score.note(start + 0.02, bass, 2.8, b_vel * dyn, kind="bass", send=0.06)
        if not sparse:
            score.note(start + 2.5, bass + fifth, 1.3, 0.11 * dyn, kind="bass", send=0.06)

        # Continuous breathing pad (overlaps slightly across bar boundaries for zero seam dip)
        pad_kind = "cello" if name == "reliquary" else "bow"
        for i, interval in enumerate((12, 12 + fifth, 12 + third)):
            if i == 2 and ending_breath:
                continue  # open fifth on bar 15 for clean crossfade
            score.note(
                start - 0.10 + i * 0.10, bass + interval, 4.1,
                (0.044 if quiet_middle or sparse else 0.032) * dyn,
                kind=pad_kind, pan=(i - 1) * 0.28, send=0.56,
            )

        # Biome-colored atmospheric shimmer
        if not sparse or bar % 2 == 1:
            score.note(start + 1.02, bass + 24 + fifth, 0.95, 0.050 * dyn, kind=shimmer_voice, pan=-0.24, send=0.46)
            if bar % 2 == 0 and not ending_breath:
                score.note(start + 3.02, bass + 24 + third, 0.85, 0.042 * dyn, kind=shimmer_voice, pan=0.24, send=0.46)

        # Subtle pulse — drops out in the quiet middle; gentle kick-only breath on bar 15
        if not quiet_middle and drum_level > 0:
            bar_groove = ((0.0, "kick", 0.35),) if ending_breath else groove
            score.drums(bar, bar_groove, drum_level * dyn)

        # Distinct biome lead melody
        lead_gain = 0.118 if lead_voice in ("piano", "felt") else 0.155
        for beat, semi, length, accent in line:
            pitch = root + 24 + semi
            score.note(
                start + beat, pitch, length,
                lead_gain * accent * dyn, kind=lead_voice, pan=0.08, send=0.42,
            )

    damp = 2600.0 if name == "hollow" else 3400.0
    score.write(output, name, stereo=stereo, rms_db=rms_db, reverb_scale=1.18 if sparse else 1.05, reverb_damp_hz=damp, warmth_hz=5600.0)


# ---------------------------------------------------------------------------
# 3. GUARDIAN TRACKS — High-contrast combat energy
#    snd_boss: urgent hunting pulse (146 BPM, A minor)
#    snd_boss_crown: regal final-guardian transformation of the title's D-A-G-A-C
#                    motif (154 BPM, D minor / Phrygian) with bar 11 tension break
# ---------------------------------------------------------------------------
GROOVE_BOSS = (
    (0.0, "kick", 1.00), (0.5, "hat", 0.62), (1.0, "snare", 0.88), (1.5, "hat", 0.58),
    (2.0, "kick", 0.78), (2.5, "kick", 0.86), (3.0, "snare", 0.94), (3.5, "hat", 0.74),
)
GROOVE_CROWN = (
    (0.0, "kick", 1.00), (0.5, "tom", 0.64), (0.75, "kick", 0.68), (1.0, "snare", 0.92),
    (1.5, "hat", 0.70), (2.0, "kick", 0.88), (2.5, "tom", 0.76), (3.0, "snare", 0.98),
    (3.5, "hat", 0.82), (3.75, "kick", 0.62),
)
FILL_BREAK = ((0.0, "kick", 0.90), (1.0, "tom", 0.80), (2.0, "tom", 0.88), (2.75, "snare", 0.92), (3.5, "snare", 1.00))

BOSS_A = ((0.0, 12, 0.65, 1.0), (0.75, 7, 0.55, 0.84), (1.5, 8, 0.65, 0.92), (2.25, 7, 0.55, 0.82), (3.0, 10, 0.85, 0.96))
BOSS_B = ((0.0, 13, 0.70, 1.0), (1.0, 12, 0.65, 0.88), (2.0, 10, 0.65, 0.84), (3.0, 7, 0.85, 0.92))
BOSS_C = ((0.0, 15, 0.85, 1.0), (1.0, 14, 0.60, 0.86), (1.75, 12, 0.65, 0.90), (2.75, 10, 0.95, 0.94))
BOSS_TURN = ((0.0, 12, 0.65, 0.92), (1.0, 10, 0.65, 0.86), (2.0, 7, 1.35, 0.96))

# Crown of Cinders quotes the title's D-A-G-A-C motif in fierce, regal combat rhythm
CROWN_A = ((0.0, 12, 0.75, 1.0), (0.75, 7, 0.55, 0.86), (1.5, 5, 0.65, 0.90), (2.25, 7, 0.55, 0.86), (3.0, 10, 0.90, 0.98))
CROWN_B = ((0.0, 15, 0.80, 1.0), (1.0, 14, 0.65, 0.90), (2.0, 12, 0.70, 0.88), (3.0, 13, 0.85, 0.96))
CROWN_C = ((0.0, 17, 0.90, 1.0), (1.0, 15, 0.65, 0.88), (1.75, 14, 0.65, 0.90), (2.75, 12, 1.00, 0.96))
CROWN_TURN = ((0.0, 13, 0.65, 0.94), (1.0, 12, 0.65, 0.90), (2.0, 7, 1.40, 0.98))


def render_guardian(piano, output: Path, name: str, bpm: float, root: int, crown: bool, rms_db: float):
    score = Score(bars=16, bpm=bpm, piano=piano, beats_per_bar=4)
    chords = (
        [M, II, VI, V, M, DIM, IV, V, VI, II, IV, V, M, II, VI, V]
        if crown else
        [M, DIM, VI, V, M, VII, IV, V, VI, IV, II, V, M, DIM, IV, V]
    )
    if crown:
        lines = (
            CROWN_A, REST, CROWN_B, REST,
            CROWN_A, REST, CROWN_C, REST,
            CROWN_B, CROWN_C, CROWN_B, REST,
            CROWN_A, CROWN_B, CROWN_C, CROWN_TURN,
        )
    else:
        lines = (
            BOSS_A, REST, BOSS_B, REST,
            BOSS_A, REST, BOSS_C, REST,
            BOSS_B, BOSS_C, BOSS_B, REST,
            BOSS_A, BOSS_B, BOSS_C, BOSS_TURN,
        )
    groove = GROOVE_CROWN if crown else GROOVE_BOSS

    for bar, ((offset, third, fifth), line) in enumerate(zip(chords, lines, strict=True)):
        start = bar * 4.0
        bass = root + offset
        climax = bar >= 12
        is_break = bar == 11
        power = 1.12 if climax else (0.90 if 8 <= bar < 11 else 1.0)

        # Driving bass ostinato (dramatic half-time hit on bar 11 break)
        if is_break:
            ostinato = ((0.0, 0, 1.4, 1.0), (2.0, fifth, 1.2, 0.88))
        elif climax or crown:
            ostinato = (
                (0.0, 0, 0.42, 1.0), (0.5, 0, 0.35, 0.72), (1.0, fifth, 0.42, 0.82), (1.5, 0, 0.35, 0.70),
                (2.0, 0, 0.45, 0.95), (2.5, 12, 0.35, 0.74), (3.0, fifth, 0.42, 0.84), (3.5, third, 0.35, 0.68),
            )
        else:
            ostinato = (
                (0.0, 0, 0.55, 1.0), (1.0, 0, 0.40, 0.72), (1.5, fifth, 0.40, 0.78),
                (2.0, 0, 0.55, 0.92), (3.0, fifth, 0.45, 0.80), (3.5, 12, 0.38, 0.65),
            )
        for beat, semi, gate, vel in ostinato:
            score.note(start + beat, bass + semi, gate, 0.25 * power * vel, kind="bass", send=0.04)

        # Dark cello/string harmonic bed (overlaps bar 15->0 for smooth loop energy)
        score.note(start - 0.05, bass + 12, 4.0, 0.048 * power, kind="cello", pan=-0.22, send=0.28)
        score.note(start - 0.05, bass + 12 + fifth, 4.0, 0.040 * power, kind="bow", pan=0.22, send=0.28)

        # Rhythmic arpeggio tension (pauses on bar 11 break)
        if not is_break:
            arp = (0, third, fifth, 12, fifth, third) if crown else (0, fifth, third, fifth)
            step = 4.0 / len(arp)
            for idx, semi in enumerate(arp):
                score.note(
                    start + idx * step, bass + 24 + semi, 0.32, 0.076 * power,
                    kind="pluck", pan=-0.18 if idx % 2 == 0 else 0.18, send=0.20,
                )

        # Punchy drums with dramatic tom/snare fill on bar 11 into climax
        bar_groove = FILL_BREAK if is_break else groove
        score.drums(bar, bar_groove, (0.36 if crown else 0.31) * power)

        # Urgent lead: brass + octave pluck reinforcement in climax/crown
        for beat, semi, gate, accent in line:
            pitch = root + 24 + semi
            score.note(start + beat, pitch, gate, 0.195 * accent * power, kind="brass", pan=0.06, send=0.22)
            if climax or crown:
                score.note(start + beat, pitch + 12, gate * 0.75, 0.092 * accent * power, kind="pluck", pan=-0.08, send=0.26)

    score.write(output, name, stereo=False, rms_db=rms_db, reverb_scale=0.62, reverb_damp_hz=3800.0, warmth_hz=7400.0)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cache", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    piano = load_piano(args.cache)
    render_title(piano, args.output)

    explorations = (
        ("music",     94,  38, ("piano", "wood"),  (M, VII, VI, V),  (VI, VII, M, III), (MOSS_A, MOSS_B, MOSS_C, MOSS_D), PULSE_MOSS,      0.10, True,  -25.2, False),
        ("cinder",    104, 43, ("pluck", "felt"),  (M, M, III, VII), (VI, VII, M, V),   (CIND_A, CIND_B, CIND_C, CIND_D), PULSE_CINDER,    0.15, False, -24.5, False),
        ("hollow",    64,  42, ("felt",  "glass"), (M, VI, IV, V),   (VI, III, IV, V),  (HOLL_A, HOLL_B, HOLL_C, HOLL_D), PULSE_HOLLOW,    0.05, False, -25.0, True),
        ("glassfen",  80,  43, ("glass", "felt"),  (M, III, VII, IV),(VI, VII, M, V),   (GLAS_A, GLAS_B, GLAS_C, GLAS_D), PULSE_GLASS,     0.07, False, -24.8, True),
        ("reliquary", 90,  38, ("piano", "pluck"), (M, DIM, II, V),  (VI, II, IV, V),   (RELI_A, RELI_B, RELI_C, RELI_D), PULSE_RELIQUARY, 0.12, False, -24.5, False),
    )
    for cfg in explorations:
        render_exploration(piano, args.output, *cfg)

    render_guardian(piano, args.output, "boss",       bpm=146, root=45, crown=False, rms_db=-22.5)
    render_guardian(piano, args.output, "boss_crown", bpm=154, root=38, crown=True,  rms_db=-22.0)


if __name__ == "__main__":
    main()
