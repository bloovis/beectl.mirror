#!/bin/sh
# Don't actually run an editor.  Instead,
# write a string to the specified file.

args=""
while [ $# != 0 ] ; do
  case $1 in
  -*)
    args="$args $1"
    ;;
  *)
    filename=$1
    ;;
  esac
  shift
done

echo "This is another test with args$args." >>$filename
