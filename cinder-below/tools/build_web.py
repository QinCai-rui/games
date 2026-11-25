"""Export the committed game and website with matching build versions."""

import argparse
import re
import shutil
import subprocess
import tarfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def replace_once(path, pattern, replacement):
    text = path.read_text()
    text, count = re.subn(pattern, replacement, text)
    if count != 1:
        raise ValueError(f"Expected one match for {pattern!r} in {path}, found {count}")
    path.write_text(text)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="New directory for the build and staged site.")
    parser.add_argument("--runtime", required=True, type=Path)
    parser.add_argument("--license-dir", required=True, type=Path)
    parser.add_argument("--project-tool", required=True, type=Path)
    parser.add_argument("--prefabs", required=True, type=Path)
    args = parser.parse_args()

    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    output = args.output.resolve()
    output.mkdir(parents=True)
    archive = output / "source.tar"
    subprocess.run(
        ["git", "archive", "-o", archive, commit, "cinder-below", "index.html", "cinder-below-cover.png"],
        cwd=ROOT, check=True,
    )
    source = output / "source"
    with tarfile.open(archive) as tar:
        tar.extractall(source, filter="data")
    archive.unlink()

    version_file = source / "cinder-below/scripts/lk_run/lk_run.gml"
    version_pattern = r'(?m)^#macro LK_VERSION "(\d+\.\d+\.\d+)\+dev"$'
    base = re.search(version_pattern, version_file.read_text())
    if base is None:
        raise ValueError("Set LK_VERSION to a numeric release version ending in +dev")
    version = f"{base[1]}+{commit[:7]}"
    replace_once(version_file, version_pattern, f'#macro LK_VERSION "{version}"')

    compiled = output / "compiled"
    for directory in (compiled, output / "cache", output / "temp", output / "export"):
        directory.mkdir()
    log = output / "build.log"
    with log.open("w") as handle:
        subprocess.run(
            [args.runtime / "bin/igor/linux/x64/Igor", "-rp", args.runtime, "-runtime", "VM",
             "-project", source / "cinder-below/CinderBelow.yyp", "-cache", output / "cache",
             "-temp", output / "temp", "-of", compiled / "out", "-tf", output / "export",
             "-lf", args.license_dir / "licence.plist", "-uf", args.license_dir,
             "-projectool", args.project_tool, "-prefabs", args.prefabs, "--", "HTML5", "folder"],
            check=True, stdout=handle, stderr=subprocess.STDOUT,
        )

    site = output / "site"
    game = site / "cinder-below"
    game.mkdir(parents=True)
    for name in ("index.html", "cinder-below-cover.png"):
        shutil.copy2(source / name, site / name)
    for name in ("index.html", "favicon.ico"):
        shutil.copy2(compiled / name, game / name)
    shutil.copytree(compiled / "html5game", game / "html5game")
    replace_once(site / "index.html", r"(?<=data-build-version>)[^<]+", version)
    replace_once(game / "index.html", r"<title>[^<]*</title>",
                 f'<title>Cinder Below {version}</title>\n'
                 f'        <meta name="application-version" content="{version}">\n'
                 '        <link rel="icon" href="favicon.ico">')
    replace_once(game / "index.html", r'html5game/CinderBelow\.js(?:\?[^"]*)?',
                 f"html5game/CinderBelow.js?cachebust={commit[:7]}")
    replace_once(game / "index.html", r"(?m)^(\s*)background: #[^;]+;", r"\g<1>background: #110d16;")
    print(f"{version}  {site}")


if __name__ == "__main__":
    main()
