#!/bin/bash

START=$(date +%s)

# docker run -dit -v ${PWD}:/data --name samtool staphb/samtools:1.11 bash
# apt update && apt install bwa

while getopts f:w:r: flag
do
    case "${flag}" in
        f) fastqFolder=${OPTARG};;
        w) workPath=${OPTARG};;
        r) ref=${OPTARG};;
    esac
done

mkdir -p ${workPath}

for i in ${fastqFolder}/*_1.fq.gz
do
    filename=$(basename $i _1.fq.gz)
    mapFile=${filename}_bwa.bam
    mapped[${#mapped[*]}]=${mapFile}
    bwa mem -t 15 -Ma -R "@RG\\tID:${filename}\\tSM:${filename}\\tPL:ILM\\tLB:${filename}" ${ref} ${i} ${i%1.fq.gz}2.fq.gz \
    | samtools sort - -@ 6 -n -m 7G -T ${i%R1.fq.gz} -o ${workPath}/${mapFile}
done

# # MarkDuplicates using SAMtools
for mapFile in ${mapped[*]}
do
    samtools fixmate -m -@ 25 ${workPath}/${mapFile} ${workPath}/fixmate.bam
    samtools sort -@ 6 -m 7G -o ${workPath}/sorted.bam ${workPath}/fixmate.bam
    samtools markdup -s -@ 25 ${workPath}/sorted.bam ${workPath}/${mapFile%.bam}_dedup.bam
    samtools index -@ 25 ${workPath}/${mapFile%.bam}_dedup.bam
done

# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Map to Reference && MarkDuplicates Done $DIFF seconds"