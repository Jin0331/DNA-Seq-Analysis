#!/bin/bash

while getopts v:r:b:h:o:d:i:o:t: flag
do
    case "${flag}" in
        v) mergevcf=${OPTARG};;
        r) ref=${OPTARG};;
        b) workvqsr=${OPTARG};;
        h) hapmap=${OPTARG};;
        o) omni=${OPTARG};;
        d) dbsnp=${OPTARG};;
        i) interval=${OPTARG};;
        o) finalPath=${OPTARG};;
        t) type=${OPTARG};;
    esac
done

mkdir -p ${workvqsr}

# Variant quality score recalibration - SNPs
gatk --java-options " -Xms4G -Xmx4G -XX:ParallelGCThreads=5" VariantRecalibrator \
  -mode SNP \
  -R ${ref} \
  -V ${mergevcf} \
  -O ${workvqsr}/merged_SNP1.recal \
  -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR  \
  --tranches-file output_SNP1.tranches \
  -tranche 100.0 -tranche 99.95 -tranche 99.9 \
  -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
  -tranche 95.0 -tranche 94.0 \
  -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \

  --resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${hapmap} \
  --resource:omni,known=false,training=true,truth=false,prior=12.0 ${omni} \
  --resource:1000G,known=false,training=true,truth=false,prior=10.0 \
  /fdb/GATK_resource_bundle/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz \

  --rscript-file output_SNP1.plots.R

# Variant quality score recalibration - INDELs
gatk --java-options "-Djava.io.tmpdir=/lscratch/$SLURM_JOBID -Xms4G -Xmx4G -XX:ParallelGCThreads=2" VariantRecalibrator \
  -tranche 100.0 -tranche 99.95 -tranche 99.9 \
  -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
  -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 \
  -tranche 92.0 -tranche 91.0 -tranche 90.0 \
  -R /fdb/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa \
  -V merged.vcf.gz \
  --resource:mills,known=false,training=true,truth=true,prior=12.0 \
  /fdb/GATK_resource_bundle/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
  --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 \
  /fdb/GATK_resource_bundle/hg38/dbsnp_146.hg38.vcf.gz \
  -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP \
  -mode INDEL -O merged_indel1.recal --tranches-file output_indel1.tranches \
  --rscript-file output_indel1.plots.R