#!/usr/bin/env bash

input=gtk.gresource
output="$(pwd)"

while [[ $# > 0 ]]; do
  case $1 in
    -h|--help)
      read -r -d '' help <<- EOM
DESCRIPTION
    Extract all files from gresource
USAGE
    $0 [-i <input_gresource>|--input=<input_gresource>]
        [-o <output_dir>|--output=<output_dir>]  [-h|--help]
OPTIONS
    -i <input_gresource>, --input=<input_gresource>
        Specify input gresource for extracting
    -o <output_dir>, --output=<output_dir>
        Output directory to extract files
    -h, --help
        Show this help
AUTHOR
    Andrey Izman (c) 2023 <izmanw@gmail.com>
LICENSE
    LGPL v3
EOM
      echo -e "$help"
      exit 0
    ;;
    -i)
      if [[ $# > 1 ]]; then
        shift
        input="$1"
      else
        echo 'Option value is required' >&2
        exit 1
      fi
    ;;
    --input=*)
      input="${1#*=}"
    ;;
    -o)
      if [[ $# > 1 ]]; then
        shift
        output="$1"
      else
        echo 'Option value is required' >&2
        exit 2
      fi
    ;;
    --output=*)
      output="${1#*=}"
    ;;
  esac
  shift
done

if [[ ! -f "$input" ]]; then
  echo "File $input not found" >&2
  exit 3
fi

if [[ $output == "/" || $output == "" ]]; then
  echo "Output dir can't be /" >&2
  exit 4
fi

if [[ ! -d "$output" ]]; then
  mkdir "$output"
  if [[ ! -d "$output" ]]; then
    echo 'Output dir does not exists' >&2
    exit 5
  fi
fi

tmp=$(mktemp)
files=($(gresource list "$input"))

for f in ${files[@]}; do
  out="${output}$f"
  echo "Extracting $out"
  rsync -a --mkpath $tmp "$out"
  gresource extract "$input" "$f" > "$out"
done

rm $tmp
