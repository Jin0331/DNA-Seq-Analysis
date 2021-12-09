#!/bin/bash

START=$(date +%s)

while getopts v:c:r:d:i:b:i:o: flag
do
    case "${flag}" in
        v) variantFolder=${OPTARG};;
        c) vcfFolder=${OPTARG};;
        r) ref=${OPTARG};;
        d) refDict=${OPTARG};;
        i) interval=${OPTARG};;
        b) workvariant=${OPTARG};;
        i) interval=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done

mkdir -p ${workvariant}
mkdir -p ${finalPath}

# Filter variant calls from MuTect
for mapFile in ${vcfFolder}/*.mt2_merged_sort.vcf
do
    for i in `seq -f %04g 0 14`
    do  
        filename=$(basename $mapFile .mt2_merged_sort.vcf)
        output=${filename}.mt2_contFiltered_${i}.vcf

        # file list
        if [ ${i} = 1 ]
        then
            echo ${workvariant}/${output} > ${workvariant}/${filename}_m2_contFiltered_file.list

        else
            echo ${workvariant}/${output} >> ${workvariant}/${filename}_m2_contFiltered_file.list
        fi

        gatk --java-options "-Xmx5G -XX:+UseParallelGC -XX:ParallelGCThreads=5" FilterMutectCalls \
            -R ${ref} \
            -V ${mapFile} \
            -L ${interval}/${i}-scattered.interval_list \
            --contamination-table ${variantFolder}/${filename}_targeted_sequencing.contamination_${i}.table \
            --ob-priors ${vcfFolder}/${filename}_read-orientation-model.tar.gz \
            -O ${workvariant}/${output} &
    done
    wait

    # # merge scattered phenotype vcf files & filter
    filename=$(basename $mapFile .mt2_merged_sort.vcf)
    combine=${filename}.mt2_filtered.vcf
    sort=${filename}.mt2_filtered_sort.vcf


    # Merge
    gatk --java-options "-Xmx20G" GatherVcfs \
            -R ${ref} \
            -I ${workvariant}/${filename}_m2_contFiltered_file.list \
            -O ${finalPath}/${combine}

    # Sort
    gatk --java-options "-Xmx20G" SortVcf \
            --SEQUENCE_DICTIONARY ${refDict} \
            --CREATE_INDEX true \
            -I ${finalPath}/${combine} \
            -O ${finalPath}/${sort}

done

# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Filter Variant $DIFF seconds"