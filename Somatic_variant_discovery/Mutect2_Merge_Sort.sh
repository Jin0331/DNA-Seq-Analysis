#!/bin/bash

START=$(date +%s)

while getopts v:r:d:g:p:i:b:o: flag
do
    case "${flag}" in
        v) bamFolder=${OPTARG};;
        r) ref=${OPTARG};;
        d) refDict=${OPTARG};;
        g) gnomad=${OPTARG};;
        p) pon=${OPTARG};;
        i) interval=${OPTARG};;
        b) workvariant=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done
    
## Run MuTect2 using only tumor sample on chromosome level (25 commands with different intervals)    
for mapFile in ${bamFolder}/*_final.bam
do
    for i in `seq -f %04g 0 14`
    do  

    filename=$(basename $mapFile _bwa_final.bam)
    output=${filename}.mt2_${i}.vcf

    # file list
    if [ ${i} = 1 ]
    then
        echo ${workvariant}/${output} > ${workvariant}/${filename}_m2_vcf_file.list
    else
        echo ${workvariant}/${output} >> ${workvariant}/${filename}_m2_vcf_file.list
    fi

    gatk --java-options "-Xmx5G -XX:+UseParallelGC -XX:ParallelGCThreads=5" Mutect2 \
        -R ${ref} \
        -L ${interval}/${i}-scattered.interval_list \
        -I ${mapFile} \
        -tumor ${workvariant}/${filename}.targeted_sequencing.sample_name \
        --af-of-alleles-not-in-resource 2.5e-06 \
        --germline-resource ${gnomad} \
        -pon ${pon} \
        -O ${workvariant}/${output} &
    done
    wait

    # merge scattered phenotype vcf files & filter
    filename=$(basename $mapFile _bwa_final.bam)
    combine=${filename}.mt2_merged.vcf
    sort=${filename}.mt2_merged_sort.vcf

    # Merge
    gatk --java-options "-Xmx20G" GatherVcfs \
            -R ${ref} \
            -I ${workvariant}/${filename}_m2_vcf_file.list \
            -O ${workvariant}/${combine}

    # Sort
    gatk --java-options "-Xmx20G" SortVcf \
            --SEQUENCE_DICTIONARY ${refDict} \
            --CREATE_INDEX true \
            -I ${workvariant}/${combine} \
            -O ${workvariant}/${sort}

done


# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Mutect2 Merge Sort $DIFF seconds"