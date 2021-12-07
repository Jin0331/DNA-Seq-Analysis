#!/bin/bash
#!/bin/bash

START=$(date +%s)

while getopts v:r:g:i:b:o: flag
do
    case "${flag}" in
        v) bamFolder=${OPTARG};;
        r) ref=${OPTARG};;
        g) gnomad=${OPTARG};;
        i) interval=${OPTARG};;
        b) workvariant=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done

# directory
mkdir -p ${finalPath}
mkdir -p ${workvariant}

# Tumor-only somatic variant call pipeline
for mapFile in ${bamFolder}/*_final.bam
do  
    filename=$(basename ${mapFile} _dedup.bam)

    # 1. Generate OXOG metrics:
    gatk CollectSequencingArtifactMetrics \
        -I ${mapFile} \
        -O ${workvariant}/${filename} --FILE_EXTENSION .txt \
        -R ${ref}

    ## 2. Generate pileup summaries on tumor sample
    # interval
    for i in `seq -f %04g 0 14`
    do  
        outfile=${filename}_targeted_sequencing_${i}.table

        gatk GetPileupSummaries \
        -I ${mapFile} \
        -V ${gnomad} \
        -L ${interval}/${i}-scattered.interval_list \
        -R ${ref} \
        -O ${workvariant}/${outfile} &

        ## 3. Calculate contamination on tumor sample
        gatk CalculateContamination \
        -I ${workvariant}/${outfile} \
        -O ${workvariant}/${outfile2}
    done
    wait

    ## 3. Calculate contamination on tumor sample
    # interval
    for i in `seq -f %04g 0 14`
    do  
        infile=${filename}_targeted_sequencing_${i}.table
        outfile=${filename}_targeted_sequencing.contamination_${i}.table

        gatk CalculateContamination \
        -I ${workvariant}/${infile} \
        -O ${workvariant}/${outfile} &
    done
    wait

done


# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "SomaticVariant Calling $DIFF seconds"