import argparse
import json
from pathlib import Path


def case_table(path):
    lines = [
        "-- SPDX-License-Identifier: Unicode-3.0",
        "-- Generated from UnicodeData.txt by scripts/generate.py",
        "return {",
        "\tentries = {",
    ]
    for line in path.read_text(encoding="utf-8").splitlines():
        fields = line.split(";")
        codepoint, kind = int(fields[0], 16), fields[2]
        properties = []
        if kind in {"Lu", "Ll", "Lt"}:
            properties.append(f'kind = "{kind}"')
        for name, field in (("lower", 13), ("upper", 12)):
            if fields[field]:
                properties.append(f"{name} = 0x{int(fields[field], 16):X}")
        if properties:
            lines.append(f"\t\t[0x{codepoint:X}] = {{ {', '.join(properties)} }},")
    lines.append("\t},")
    lines.append("}")
    return "\n".join(lines) + "\n"


def translit_table(directory):
    lines = ["-- Generated from translit/ by scripts/generate.py", "return {"]
    for path in sorted(directory.glob("*.json")):
        table = json.loads(path.read_text(encoding="utf-8"))
        lines.append(f"\t[{json.dumps(path.stem)}] = {{")
        for letter, latin in sorted(table.items()):
            key = json.dumps(letter, ensure_ascii=False)
            lines.append(f"\t\t[{key}] = {json.dumps(latin)},")
        lines.append("\t},")
    lines.append("}")
    return "\n".join(lines) + "\n"


def main():
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(
        description="Generate Lua case and transliteration tables"
    )
    parser.add_argument("unicode_data", type=Path)
    parser.add_argument("-o", "--output-dir", type=Path, default=root)
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    (args.output_dir / "case.lua").write_text(
        case_table(args.unicode_data), encoding="utf-8"
    )
    (args.output_dir / "translit.lua").write_text(
        translit_table(root / "translit"), encoding="utf-8"
    )


if __name__ == "__main__":
    main()
