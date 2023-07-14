#!/usr/bin/env python
import argparse
from pathlib import Path
from ruamel.yaml.split import split


def split_yaml_file(input_file: str) -> None:
    for doc, line_nr in split(Path(input_file)):
        # with open("yaml-" + str(line_nr) + ".yaml", "w") as out:
        #     out.write(doc.decode("utf-8"))
        print(doc.decode("utf-8"))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Split multi-document YAML files.")
    parser.add_argument("filename")
    args: str = parser.parse_args()

    split_yaml_file(args.filename)
