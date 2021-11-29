#!/bin/bash

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

for i in ${fastqFolder}/*_1.fq.gz
do
 filename=$(basename $i _1.fq.gz)
 
 mapFile=${workPath}/${filename}_bwa.bam
 mapped[${#mapped[*]}]=$mapFile
 bwa mem -t 15 -Ma -R @RG\\tID:${filename}\\tSM:${filename}\\tPL:ILM\\tLB:${filename} $ref $i ${i%1.fq.gz}2.fq.gz \
 |samtools sort - -@ 15 -n -m 10G -T ${i%R1.fastq.gz} -o $mapFile
done