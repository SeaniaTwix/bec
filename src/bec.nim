# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import docopt
import os
import encodings

let doc = """
BEC

Usage:
  bec [options] (convert|c) -d <source_dir> -o <output_dir>
  bec [options] (convert|c) -f <source_file> -o <output_file>

Options:
  -h --help             Show this screen.
  --s=<encoding>        Set to CP for Sources. default: UTF-16
  --t=<encoding>        Set to CP for Outputs. default: UTF-8
"""

let args = docopt(doc, version = "BEC 0.1.0")

let sourceEncoding = if ($ args["--s"]) == "nil": "utf-16"
else: $ args["--s"]

let outputEncoding = if ($ args["--t"]) == "nil": "utf-8"
else: $ args["--t"]

proc convertFile(sourcePath, outputPath: string) =
  if sourcePath.existsFile():
    let conv = encodings.open(outputEncoding, sourceEncoding)
    var f = sourcePath.open(fmRead)
    let converted = conv.convert(f.readAll())
    
    outputPath.writeFile(converted)

proc convertDirectory(sourcePath, outputPath: string) =
  if sourcePath.existsDir():
    for pc, fileName in sourcePath.walkDir(true):
      if pc == pcFile or pc == pcLinkToFile:
        let sourceFile = ".".joinPath(sourcePath,fileName)
        let outputFile = outputPath.joinPath(fileName)

        if not outputPath.existsDir():
          createDir(outputPath)
        
        convertFile(sourceFile, outputFile)

proc convert(is_directory: bool) =
  if is_directory:
    let sourcePath = $ args["<source_dir>"]
    let outputPath = $ args["<output_dir>"]
    convertDirectory(sourcePath, outputPath)
  else:
    let sourcePath = $ args["<source_file>"]
    let outputPath = $ args["<output_file>"]
    convertFile(sourcePath, outputPath)

when isMainModule:
  echo ($args["--s"]) == "nil"
  if args["c"] or args["converts"]:
    convert(args["-d"])
