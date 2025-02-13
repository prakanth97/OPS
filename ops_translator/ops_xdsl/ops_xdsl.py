import os
from argparse import ArgumentParser, ArgumentTypeError, Namespace
from pathlib import Path

import cpp
import fortran
from language import Lang
from ops import OpsError, Type

from store import Application, ParseError

def main(argv=None) -> None:
    parser = ArgumentParser(prog="ops-translator")

    parser.add_argument("-v", "--verbose", help="Verbose", action="store_true")
    parser.add_argument("-o", "--out", help="Output directory", type=isDirPath)
    parser.add_argument("-soa", "--force_soa", help="Force structs of arrays", action="store_true")

    parser.add_argument("--suffix", help="Add a suffix to genreated program translations", default="_xdsl")

    parser.add_argument("-I", help="Add to include directories", type=isDirPath, action="append", nargs=1, default=[])
    parser.add_argument("-i", help="Add to include files", type=isFilePath, action="append", nargs=1, default=[])
    parser.add_argument("-D", help="Add to preprocessor defines", action="append", nargs=1, default=[])

    parser.add_argument("--file_paths", help="Input OPS sources", type=isFilePath, nargs="+")

    #invoking arg parser
    print("Invoking arg parser")
    args = parser.parse_args(argv)

    if os.environ.get("OPS_AUTO_SOA") is not None:
        args.force_soa = True

    file_parents = [Path(file_path).parent for file_path in args.file_paths]

    if args.out is None:
        args.out = file_parents[0]

    args.I = [[str(file_parent)] for file_parent in file_parents] + args.I

    # Collect the set of file extensions 
    extensions = {str(Path(file_path).suffix)[1:] for file_path in args.file_paths}
    print(extensions)

    if not extensions:
        exit("Missing file extensions, unable to determine target language.")
    elif len(extensions) > 1:
        exit("Varying file extensions, unable to determine target language.")
    else:
        [extension] = extensions

    lang = Lang.find(extension)

    if lang is None:
        exit(f"Unknown file extension: {extension}")

    Type.set_formatter(lang.formatType)

    try:
        print("Parsing began......")
        app = parse(args, lang)
        # Remove after the conversion
        x = 1
    except ParseError as e:
        exit(e)

def parse(args: Namespace, lang: Lang) -> Application:
    app = Application()

    # Collect the include directories
    include_dirs = set([Path(dir) for [dir] in args.I])
    defines = [define for [define] in args.D]

    # Parse the input files
    for i, raw_path in enumerate(args.file_paths, 1):
        if args.verbose:
            print(f"Parsing file {i} of {len(args.file_paths)}: {raw_path}")

        # Parse the program
        program = lang.parseProgram(Path(raw_path), include_dirs, defines)
        app.programs.append(program)

    return app
        
def isDirPath(path):
    if os.path.isdir(path):
        return path
    else:
        raise ArgumentTypeError("Invalid directory path: {path}")

def isFilePath(path):
    if os.path.isfile(path):
        return path
    else:
        raise ArgumentTypeError("Invalid file: {path}")
    
# Entry
main()