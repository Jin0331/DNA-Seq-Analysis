#!/bin/bash

while getopts b:g:r:i:o: flag
do
    case "${flag}" in
        b) scatterbamFolder=${OPTARG};; # scatter bam
        g) scattergvcfFolder=${OPTARG};; # scatter gvcf
        r) ref=${OPTARG};;
        i) interval=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done

# gvcf dir
mkdir -p ${finalPath}
mkdir -p ${scattergvcfFolder}

for mapFile in ${scatterbamFolder}/*_bwa_dedup_recal_0001.bam
do  

    # for i in `seq -f %04g 0 14`
    # do
    #     filename=$(basename $mapFile _dedup_recal_0001.bam)
    #     echo ${filename}  
    #     infile=${filename}_dedup_recal_${i}.bam
    #     outfile=${filename}_dedup_recal_${i}.g.vcf
        

    #     # file list
    #     if [ ${i} = 1 ]
    #     then
    #         echo ${scattergvcfFolder}/${outfile} > ${scattergvcfFolder}/${filename}_gvcf_file.list
    #     else
    #         echo ${scattergvcfFolder}/${outfile} >> ${scattergvcfFolder}/${filename}_gvcf_file.list
    #     fi

    #     gatk --java-options "-Xmx5G -XX:+UseParallelGC -XX:ParallelGCThreads=5" HaplotypeCaller \
    #                     -ERC GVCF \
    #                     -R ${ref} \
    #                     -I ${scatterbamFolder}/${infile} \
    #                     -L ${interval}/${i}-scattered.interval_list \
    #                     -O ${scattergvcfFolder}/${outfile} \
    #                     -stand-call-conf 10 &
    # done
    # wait

    # # merge scattered phenotype vcf files
    filename=$(basename $mapFile _dedup_recal_0001.bam)
    combine=${filename}_dedup_recal.g.vcf

    gatk --java-options "-Xmx20G" GatherVcfs -R ${ref} \
            -I ${scattergvcfFolder}/${filename}_gvcf_file.list \
            -O ${finalPath}/${combine}

done