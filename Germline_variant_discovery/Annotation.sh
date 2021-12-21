#!/bin/bash

START=$(date +%s)

while getopts v:r:o: flag
do
    case "${flag}" in
        v) vcfPath=${OPTARG};;
        r) ref=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done

source /opt/conda/etc/profile.d/conda.sh
conda activate gatk4

mkdir -p ${finalPath}

# Using ANNOVAR
perl /root/annovar/table_annovar.pl ${vcfPath} \
    /root/annovar/humandb/ \
    -buildver ${ref} \
    -out ${finalPath}/annovarAnnotation \
    -remove \
    -protocol ensGene,avsnp150,clinvar_20210501 -operation g,f,f \
    -nastring . \
    -vcfinput -polish \
    --thread 15

# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "ANNOVAR Annotation $DIFF seconds"