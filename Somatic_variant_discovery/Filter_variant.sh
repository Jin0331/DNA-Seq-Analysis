#!/bin/bash

START=$(date +%s)

while getopts v:c:r:d:i:b:o: flag
do
    case "${flag}" in
        v) variantFolder=${OPTARG};;
        c) vcfFolder=${OPTARG};;
        r) ref=${OPTARG};;
        d) refDict=${OPTARG};;
        i) intervalList=${OPTARG};;
        b) workvariant=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done

mkdir -p ${workvariant}
mkdir -p ${finalPath}

# Filter variant calls from MuTect
for mapFile in ${vcfFolder}/*.mt2_merged_sort.vcf
do

    filename=$(basename $mapFile .mt2_merged_sort.vcf)
    output=${filename}.mt2_contFiltered.vcf
    sort=${filename}.mt2_filtered_sort.vcf

    # Filter Mutect Calls
    gatk --java-options "-Xmx30G" FilterMutectCalls \
        -R ${ref} \
        -V ${mapFile} \
        -L ${intervalList} \
        --contamination-table ${variantFolder}/${filename}_targeted_sequencing.contamination.table \
        --ob-priors ${vcfFolder}/${filename}_read-orientation-model.tar.gz \
        -O ${workvariant}/${output}

    # Sort
    gatk --java-options "-Xmx20G" SortVcf \
        -I ${workvariant}/${output} \
        --SEQUENCE_DICTIONARY ${refDict} \
        --CREATE_INDEX true \
        -O ${finalPath}/${sort}
done

# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Filter Variant $DIFF seconds"