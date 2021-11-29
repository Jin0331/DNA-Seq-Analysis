#!/bin/bash

while getopts f:w:r: flag
do
    case "${flag}" in
        f) fastqFolder=${OPTARG};;
        w) workPath=${OPTARG};;
        r) ref=${OPTARG};;
    esac
done

# Using GATK
for mapFile in ${mapped[*]}
do
 for i in `seq -f ‘%04g’ 0 39`
 do
 outfile=${mapFile%.bam}_dedup_recal_data_$i.table
 gatk --java-options “-Xmx4G -XX:+UseParallelGC \
 -XX:ParallelGCThreads=4” BaseRecalibrator \
 -L $i-scattered.interval_list -R $ref \
 -I ${mapFile%.bam}_dedup.bam $knownSiteArg -O $outfile &
 done
 wait
 for i in `seq -f ‘%04g’ 0 39`
 do
 bqfile=${mapFile%.bam}_dedup_recal_data_$i.table
 output=${mapFile%.bam}_dedup_recal_$i.bam
 gatk --java-options “-Xmx4G -Xmx4G -XX:+UseParallelGC \
 -XX:ParallelGCThreads=4” ApplyBQSR -R $ref \
 -I ${mapFile%.bam}_dedup.bam \
 -L $i-scattered.interval_list -bqsr $bqfile \
 --static-quantized-quals 10 --static-quantized-quals 20 \
 --static-quantized-quals 30 -O $output &
 done
 wait