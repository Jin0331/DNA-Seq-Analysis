#!/bin/bash
#docker run --rm -dit -v ${PWD}:/gatk/work --name gatk broadinstitute/gatk:4.1.8.1 bash

while getopts b:w:r:d:i:o:t: flag
do
    case "${flag}" in
        b) bamFolder=${OPTARG};;
        w) workPath=${OPTARG};;
        r) ref=${OPTARG};;
        d) dbsnp=${OPTARG};;
        i) interval=${OPTARG};;
        o) finalPath=${OPTARG};;
        t) type=${OPTARG};;
    esac
done

# word dir create
mkdir -p ${workPath}

# Using GATK
for mapFile in ${bamFolder}/*_bwa_dedup.bam
do  
    # BaseRecalibrator
    for i in `seq -f %04g 0 14`
    do  
        filename=$(basename $mapFile _dedup.bam)
        outfile=${filename}_dedup_recal_data_${i}.table
        gatk --java-options "-Xmx4G -XX:+UseParallelGC \
                            -XX:ParallelGCThreads=4" BaseRecalibrator \
                            -L ${interval}/${i}-scattered.interval_list \
                            -R $ref \
                            -I ${mapFile} \
                            --known-sites $dbsnp \
                            -O ${workPath}/${outfile} &
    done
    wait

    # ApplyBQSR
    for i in `seq -f %04g 0 14`
    do
        filename=$(basename $mapFile _dedup.bam)       
        bqfile=${workPath}/${filename}_dedup_recal_data_$i.table
        output=${filename}_dedup_recal_$i.bam

        # file list
        if [ ${i} = 1 ]
        then
            echo ${workPath}/${output} > ${workPath}/${filename}_file.list
        else
            echo ${workPath}/${output} >> ${workPath}/${filename}_file.list
        fi

        gatk --java-options "-Xmx4G -Xmx4G -XX:+UseParallelGC \
             -XX:ParallelGCThreads=4" ApplyBQSR -R $ref \
                            -I ${mapFile} \
                            -L ${interval}/${i}-scattered.interval_list \
                            -bqsr $bqfile \
                            --static-quantized-quals 10 \
                            --static-quantized-quals 20 \
                            --static-quantized-quals 30  \
                            -O ${workPath}/${output} &
    done
    wait

    # file list
    if [ ${type} = "somatic" ]
    then
        # GatherBamfile & Sortsam
        mkdir -p ${finalPath}

        filename=$(basename $mapFile _dedup.bam)
        gatk GatherBamFiles -I ${workPath}/${filename}_file.list \
                            -O ${workPath}/${filename}_unsorted.bam \
                            -R ${ref}

        gatk SortSam -I ${workPath}/${filename}_unsorted.bam \
                    -O ${finalPath}/${filename}_final.bam \
                    --SORT_ORDER coordinate -VALIDATION_STRINGENCY LENIENT

        gatk BuildBamIndex -I ${finalPath}/${filename}_final.bam \
                        -O ${finalPath}/${filename}_final.bai \
                        -VALIDATION_STRINGENCY LENIENT
    fi



done

if [ ${type} = "somatic" ]
then
    # remove work path
    rm -rf ${workPath}
fi

