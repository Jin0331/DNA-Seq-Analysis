#!/bin/bash

START=$(date +%s)

while getopts v:i:b:o: flag
do
    case "${flag}" in
        v) variantFolder=${OPTARG};;
        i) interval=${OPTARG};;
        b) workvariant=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done









# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Filter Variant $DIFF seconds"