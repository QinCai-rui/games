# /// script
# requires-python = ">=3.10"
# dependencies = ["numpy>=2,<3"]
# ///
"""Render Cinder Below's seven music loops.

Run `uv run tools/render_score.py --cache <sample-cache> --output <directory>`.
FFmpeg must be on PATH. The output mirrors GameMaker's sounds directory.

Piano samples: University of Iowa Electronic Music Studios, Steinway B,
performed by Evan Mazunik and recorded by Michael Cash.
https://theremin.music.uiowa.edu/MISpiano.html
https://theremin.music.uiowa.edu/MIS.html (unrestricted project use)
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


def load_piano(cache):
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
        onset = max(0, int(np.argmax(front > front.max() * .026)) - 170)
        signal = signal[onset:].copy()
        signal -= signal.mean(axis=0)
        signal /= max(.001, np.sqrt(np.mean(signal[:RATE // 5] ** 2)))
        return midi, signal

    with ThreadPoolExecutor(max_workers=5) as workers:
        return dict(workers.map(load, PIANO_KEYS.items()))


def envelope(t, attack, release):
    return (
        np.sin(np.pi * .5 * np.clip(t / attack, 0, 1)) ** 2
        * np.sin(np.pi * .5 * np.clip((t[-1] - t) / release, 0, 1)) ** 2
    )


class Score:
    def __init__(self, bars, bpm, piano):
        self.beat = 60 / bpm
        self.dry = np.zeros((round(bars * 4 * self.beat * RATE), 2), dtype="f4")
        self.send = np.zeros_like(self.dry)
        self.piano = piano

    @lru_cache(maxsize=192)
    def voice(self, kind, note, gate):
        tail = {"piano": .82, "bow": .66, "glass": .68, "pluck": .26, "bass": .11}[kind]
        t = np.arange(round((gate + tail) * RATE)) / RATE
        if kind == "piano":
            key = min(self.piano, key=lambda pitch: abs(pitch - note))
            sample = self.piano[key]
            index = t * RATE * 2 ** ((note - key) / 12)
            signal = np.column_stack([
                np.interp(index, np.arange(len(sample)), channel, right=0)
                for channel in sample.T
            ])
            damper = np.exp(-np.maximum(0, t - gate) * 6.2)
            return signal * (damper * envelope(t, .004, .19))[:, None]

        p = TAU * 440 * 2 ** ((note - 69) / 12) * t
        off = np.maximum(0, t - gate)
        if kind == "bow":
            q = .13 * np.sin(TAU * 4.2 * t)
            signal = .55 * np.sin(p + q) + .24 * np.sin(p * 1.002 - q)
            signal += .17 * np.sin(2 * p + q) + .065 * np.sin(3 * p)
            return signal * envelope(t, min(.65, gate * .55), tail) * np.exp(-off * 2)
        if kind == "glass":
            signal = np.sin(p) + .22 * np.sin(2.002 * p) * np.exp(-t * 6)
            signal += .21 * np.sin(3.01 * p) * np.exp(-t * 12) + .12 * np.sin(5.09 * p) * np.exp(-t * 23)
            return signal * envelope(t, .007, .17) * np.exp(-t * 2.7 - off * 3)
        if kind == "pluck":
            signal = np.sin(p) + .37 * np.sin(2 * p) * np.exp(-t * 8)
            signal += .21 * np.sin(3 * p) * np.exp(-t * 14) + .09 * np.sin(5 * p) * np.exp(-t * 19)
            return signal * envelope(t, .005, .14) * np.exp(-t * 3.5 - off * 6)
        signal = np.sin(p) + .29 * np.sin(p * 2) + .11 * np.sin(p * 3) * np.exp(-t * 12)
        return signal * envelope(t, .012, .11) * np.exp(-t * 1.3 - off * 8)

    def place(self, beat, signal, level, pan=0, send=.25):
        stereo = signal[:, None] if signal.ndim == 1 else signal
        stereo = stereo * level * np.sqrt([1 - pan, 1 + pan])
        start = round(beat * self.beat * RATE) % len(self.dry)
        first = min(len(self.dry) - start, len(stereo))
        # Keep tails through the loop point rather than cutting them at the last bar.
        for bus, gain in ((self.dry, 1), (self.send, send)):
            bus[start:start + first] += stereo[:first] * gain
            bus[:len(stereo) - first] += stereo[first:] * gain

    def note(self, beat, note, beats, level, kind="piano", pan=0, send=.25):
        self.place(beat, self.voice(kind, note, round(beats * self.beat, 3)), level, pan, send)

    def drums(self, bar, pattern, level):
        for off, kind, velocity in pattern:
            t = np.arange(round((.32 if kind == "kick" else .17) * RATE)) / RATE
            rng = np.random.default_rng(round((bar * 4 + off) * 32) + 71)
            noise = rng.standard_normal(len(t))
            if kind == "kick":
                p = TAU * (48 * t + (1 - np.exp(-t * 36)) * 1.3)
                signal = np.sin(p) * np.exp(-t * 15) + .07 * noise * np.exp(-t * 110)
            elif kind == "rim":
                signal = (.26 * noise + .56 * np.sin(TAU * 203 * t)) * np.exp(-t * 34)
            else:
                signal = (noise - np.r_[0, noise[:-1]]) * np.exp(-t * 52) * .16
            self.place(bar * 4 + off, signal * envelope(t, .003, .035), level * velocity,
                       .23 if kind == "hat" else 0, .13)

    def write(self, output, name, stereo, rms):
        for delay, gain, cross in ((.033, .25, False), (.058, .22, True), (.089, .19, True),
                                   (.151, .15, False), (.22, .13, True), (.36, .10, True),
                                   (.53, .072, False), (.76, .049, True), (1.03, .031, False)):
            self.dry += np.roll(self.send[:, ::-1] if cross else self.send, round(delay * RATE), axis=0) * gain
        mix = self.dry if stereo else self.dry.mean(axis=1)
        mix -= mix.mean(axis=0)
        gain = min(10 ** (rms / 20) / np.sqrt(np.mean(mix**2)), .71 / np.max(np.abs(mix)))
        pcm = np.rint(mix * gain * 32767).astype("<i2")
        target = output / f"snd_{name}" / f"snd_{name}.wav"
        target.parent.mkdir(parents=True, exist_ok=True)
        with wave.open(str(target), "wb") as stream:
            stream.setparams((2 if stereo else 1, 2, RATE, 0, "NONE", "not compressed"))
            stream.writeframes(pcm.tobytes())
        print(f"{target.name}: {len(pcm) / RATE:.2f}s")
        self.voice.cache_clear()


# Emberlight: a falling third, a small climb and a long landing.
# Tuple order is beat, MIDI pitch, held beats, and emphasis.
HOOK = ((.04, 76, .64, 1), (.79, 72, .58, .77), (1.53, 74, 1, .88), (2.79, 69, 1.55, .92))
ANSWER = ((.42, 72, .70, .79), (1.25, 74, .67, .83), (2.06, 76, 1.65, 1))
FALL = ((.08, 76, .75, .90), (1.02, 74, .64, .75), (1.78, 72, .72, .78), (2.65, 69, 1.62, .91))
LIFT = ((.06, 79, 1.21, 1), (1.53, 76, .75, .77), (2.52, 74, 1.25, .86))
REST = ()


def phrase(score, bar, line, level, voice="piano", shift=0, stretch=1):
    for beat, midi, gate, accent in line:
        score.note(bar * 4 + beat * stretch, midi + shift, gate * stretch, level * accent, voice,
                   .08, .35 if voice == "piano" else .45)


def title(piano, output):
    score = Score(20, 78, piano)
    # Preserve the old title's A minor / F / C / G home progression.
    am = (45, 52, 57, 60, 64)
    f = (41, 53, 57, 60, 64)
    c = (48, 55, 60, 64, 67)
    g = (43, 50, 55, 59, 62)
    dm = (50, 57, 60, 65, 69)
    e = (40, 52, 56, 59, 62)
    chords = (am, f, c, g, am, f, dm, e, f, c, dm, e, am, f, c, g, am, f, dm, e)
    lines = (
        HOOK, ANSWER, ((.08, 79, 1.55, .88), (2.14, 76, 1.26, .76)), ((.12, 74, 1.65, .76),),
        HOOK, ANSWER, ((.04, 77, .92, .88), (1.29, 76, .64, .79), (2.18, 74, 1.44, .83)),
        ((.17, 71, 1.34, .77), (2.72, 68, .61, .67)),
        ((.06, 81, 1.72, .86), (2.08, 79, 1.25, .80)), LIFT,
        ((.07, 77, 1.46, .83), (1.82, 76, .60, .72), (2.62, 72, 1.04, .73)),
        ((.12, 71, 1.50, .74), (2.60, 68, .67, .66)),
        HOOK, ANSWER, LIFT, ((.10, 71, .84, .77), (1.22, 74, 1.58, .87)),
        FALL, ((.52, 72, 1.08, .71), (2.02, 69, 1.28, .70)),
        ((.31, 65, 1.18, .64), (2.06, 69, 1.13, .65)), ((.17, 68, 1.18, .58),),
    )
    for bar, ((root, low, inner, high, color), line) in enumerate(zip(chords, lines, strict=True)):
        beat = bar * 4
        weight = 1.16 if 8 <= bar < 16 else .81 if bar >= 17 else 1
        score.note(beat, root, 3.42, .083 * weight, pan=-.19, send=.24)
        score.note(beat + .31, low, 2.44, .056 * weight, pan=-.20)
        score.note(beat + 1.16, inner, 2.05, .041 * weight, pan=-.11)
        if bar % 4 != 3 or 8 <= bar <= 15:
            score.note(beat + 2.29, high, 1.62, .035 * weight, pan=-.03)
        if 4 <= bar <= 17:
            score.note(beat - .31, inner, 4.19, .070 * weight, "bow", -.28, .55)
            score.note(beat - .13, color, 4.01, .052 * weight, "bow", .31, .53)
        phrase(score, bar, line, .128 * weight)
        if 12 <= bar <= 15:
            first = line[0]
            score.note(beat + first[0] + .035, first[1] + 12, 1.3, .052, "glass", .28, .52)
    score.write(output, "title", True, -24)


# Six arrangements of the same theme, with different registers and grooves.
# Chords are tonic-relative (root, third above root, fifth above root).
M = (0, 3, 7)
VI = (-4, 4, 7)
III = (3, 4, 7)
VII = (-2, 4, 7)
IV = (5, 3, 7)
V = (-5, 4, 7)
II = (1, 4, 7)
DIM = (0, 3, 6)
MARCH = ((0, "kick", 1), (1, "rim", .56), (2.5, "kick", .78), (3, "rim", .62),
         (.5, "hat", .64), (1.5, "hat", .45), (2, "hat", .55), (3.5, "hat", .59))
FORGE = ((0, "kick", 1), (1.5, "rim", .70), (2, "kick", .77), (3.25, "rim", .58), (3.75, "hat", .67))
HEART = ((0, "kick", .70), (2.75, "kick", .48), (3.5, "hat", .36))
CHASE = ((0, "kick", 1), (.75, "kick", .69), (1, "rim", .86), (2.5, "kick", .86),
         (3, "rim", .96), (.5, "hat", .74), (1.5, "hat", .65), (2, "hat", .62), (3.5, "hat", .78))
MOSS_RIFF = ((0, 74, .95, .95), (1, 69, .43, .75), (1.5, 77, .9, 1),
             (2.5, 76, .45, .85), (3, 74, .9, .89))


def dungeon(piano, output, name, bpm, root, together, opening, bridge, groove, drum_level):
    score = Score(16, bpm, piano)
    lead, backing = together
    chord_chart = opening + opening[:2] + (IV, V) + bridge + opening[:2] + (IV, V)
    shift = root + 24 - 69
    lines = (HOOK, REST, ANSWER, REST, HOOK, REST, LIFT, REST,
             REST, LIFT, REST, FALL, HOOK, REST, ANSWER, REST)
    if name == "music":
        # Quote the old first-floor riff, then answer it with the new title theme.
        lines = (MOSS_RIFF, REST, ANSWER, REST, MOSS_RIFF, REST, LIFT, REST,
                 REST, LIFT, REST, FALL, HOOK, REST, ANSWER, REST)
    elif name in ("hollow", "glassfen"):
        lines = (HOOK, REST, REST, ANSWER, REST, HOOK, REST, REST,
                 LIFT, REST, FALL, REST, HOOK, REST, ANSWER, REST)
    for bar, ((offset, third, fifth), line) in enumerate(zip(chord_chart, lines, strict=True)):
        start = bar * 4
        bass = root + offset
        drop = 8 <= bar < 12
        light = name in ("hollow", "glassfen")
        power = .73 if drop else 1.08 if bar >= 12 else 1
        bass_pattern = ((0, 0, 1.65, 1), (2.65, fifth, .91, .55)) if light else (
            (0, 0, .88, 1), (1.50, 0, .44, .71), (2, fifth, .59, .68), (3.25, 12, .56, .47))
        for beat, interval, gate, strength in bass_pattern:
            score.note(start + beat, bass + interval, gate, .245 * power * strength, "bass", send=.04)
        for i, interval in enumerate((12, 12 + third, 12 + fifth)):
            score.note(start - .13 + i * .1, bass + interval, 3.93, .060 if light or drop else .036,
                       "bow", (i - 1) * .32, .58)
        if not light or bar % 2:
            for beat, pitch, strength in ((.52, fifth, .52), (1.25, third, .64), (2.79, fifth, .84)):
                score.note(start + beat, bass + 24 + pitch, .51, .093 * strength * power, backing, -.20, .36)
        if not drop or light:
            score.drums(bar, groove, drum_level * power)
        if name == "boss" and bar >= 12 and line:
            phrase(score, bar, line, .082, "pluck", shift - 12)
        phrase(score, bar, line, (.100 if lead == "piano" else .207) * power,
               lead, 0 if line is MOSS_RIFF else shift - (12 if name == "hollow" else 0))
    score.write(output, name, name == "music", -26 if name == "music" else -24.5 if name != "boss" else -23)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cache", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    piano = load_piano(args.cache)
    title(piano, args.output)
    for settings in (
        ("music", 120, 38, ("pluck", "glass"), (M, VII, VI, V), (VI, VII, M, III), MARCH, .19),
        ("cinder", 118, 43, ("pluck", "piano"), (M, M, III, VII), (VI, VII, M, V), FORGE, .28),
        ("hollow", 66, 42, ("piano", "glass"), (M, VI, IV, V), (VI, III, IV, V), HEART, .095),
        ("glassfen", 89, 43, ("glass", "piano"), (M, III, VII, IV), (VI, VII, M, V), HEART, .14),
        ("reliquary", 102, 38, ("piano", "pluck"), (M, DIM, II, V), (VI, II, IV, V), FORGE, .19),
        ("boss", 148, 46, ("pluck", "glass"), (M, DIM, VI, V), (II, IV, M, V), CHASE, .32),
    ):
        dungeon(piano, args.output, *settings)


if __name__ == "__main__":
    main()
