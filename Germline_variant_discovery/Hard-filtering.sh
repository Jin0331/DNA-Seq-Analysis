#!/bin/bash

START=$(date +%s)

while getopts v:r:b:o: flag
do
    case "${flag}" in
        v) mergevcf=${OPTARG};;
        r) ref=${OPTARG};;
        b) workhard=${OPTARG};;
        o) finalPath=${OPTARG};;
    esac
done

# # directory
# mkdir -p ${workhard}
# mkdir -p ${finalPath}

# # SPLIT SNP
# gatk --java-options '-Xmx25g' SelectVariants \
#  -R ${ref} \
#  -V ${mergevcf} \
#  -select-type SNP \
#  -O ${workhard}/Exome_Norm_HC_calls.snps.vcf

# # SPLIT INDEL
# gatk --java-options '-Xmx25g' SelectVariants \
#  -R ${ref} \
#  -V ${mergevcf} \
#  -select-type INDEL \
#  -O ${workhard}/Exome_Norm_HC_calls.indels.vcf

# # FILTER SNP 
# gatk --java-options '-Xmx25g' VariantFiltration \
#  -R ${ref} \
#  -V ${workhard}/Exome_Norm_HC_calls.snps.vcf \
#  --missing-values-evaluate-as-failing true \
#  --filter-expression "QD < 2.0" \
#  --filter-name "QD_lt_2" \
#  --filter-expression "FS > 60.0" \
#  --filter-name "FS_gt_60" \
#  --filter-expression "MQ < 40.0" \
#  --filter-name "MQ_lt_40" \
#  --filter-expression "MQRankSum < -12.5" \
#  --filter-name "MQRS_lt_n12.5" \
#  --filter-expression "ReadPosRankSum < -8.0" \
#  --filter-name "RPRS_lt_n8" \
#  -O ${workhard}/HardFilter.snps.filtered.vcf

# gatk --java-options '-Xmx25g' VariantFiltration \
#  -R ${ref} \
#  -V ${workhard}/Exome_Norm_HC_calls.indels.vcf \
#  --missing-values-evaluate-as-failing true \
#  --filter-expression "QD < 2.0" \
#  --filter-name "QD_lt_2" \
#  --filter-expression "FS > 200.0" \
#  --filter-name "FS_gt_200" \
#  --filter-expression "ReadPosRankSum < -20.0" \
#  --filter-name "RPRS_lt_n20" \
#  -O ${workhard}/HardFilter.indels.filtered.vcf

 # MERGE
gatk --java-options '-Xmx25g' MergeVcfs \
 -I ${workhard}/HardFilter.indels.filtered.vcf \
 -I ${workhard}/HardFilter.snps.filtered.vcf \
 -O ${finalPath}/HardFilter.filtered.vcf

# FILTER PASS ONLY
 gatk --java-options "-Xmx25g" SelectVariants \
  -R ${ref} \
  -V ${finalPath}/HardFilter.filtered.vcf \
  -O ${finalPath}/HardFilter.filtered.PASS.vcf \
  --exclude-filtered

# Time stemp
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "HardFilter $DIFF seconds"