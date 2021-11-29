#!/bin/bash
#docker run --rm -dit -v ${PWD}:/gatk/work --name gatk broadinstitute/gatk:4.1.8.1 bash

while getopts b:w:r:d:i: flag
do
    case "${flag}" in
        b) bamFolder=${OPTARG};;
        w) workPath=${OPTARG};;
        r) ref=${OPTARG};;
        d) dbsnp=${OPTARG};;
        i) interval=${OPTARG};;
    esac
done

# Using GATK
for z in ${bamFolder}/*_bwa_dedup.bam
do
    for i in `seq -f %04g 0 15`
    do
        filename=$(basename $z _dedup.bam)     
        echo $filename
        #outfile=${mapFile%_dedup.bam}_dedup_recal_data_$i.table
        # echo  ${outfile}
        # echo  ${workPath}/${outfile}
        # gatk --java-options "-Xmx4G -XX:+UseParallelGC \
        #                     -XX:ParallelGCThreads=4" BaseRecalibrator \
        #                     -L ${interval}/${i}-scattered.interval_list \
        #                     -R $ref \
        #                     -I ${mapFile%_dedup.bam}_dedup.bam \
        #                     --known-sites $dbsnp \
        #                     -O ${workPath}/${outfile} &
    done
    wait
    for i in `seq -f %04g 0 15`
    do
        bqfile=${mapFile%_dedup.bam}_dedup_recal_data_$i.table
        output=${mapFile%_dedup.bam}_dedup_recal_$i.bam
        # gatk --java-options "-Xmx4G -Xmx4G -XX:+UseParallelGC \
        #      -XX:ParallelGCThreads=4" ApplyBQSR -R $ref \
        # -I ${mapFile%_dedup.bam}_dedup.bam \
        # -L ${interval}/${i}-scattered.interval_list \
        # -bqsr $bqfile \
        # --static-quantized-quals 10 \
        # --static-quantized-quals 20 \
        # --static-quantized-quals 30  \
        # -O $output &
        # echo $output
    done
    wait
done