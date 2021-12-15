# DNA-Seq-Analysis

## **ExomeSeq Short Variant Discovery Pipeline (Germline / Somatic)**

```
# sempre813/bioconda:1.1 Container 
docker run -dit -v ${PWD}:/root/work --name bioconda --user root sempre813/bioconda:1.1 bash
docker exec -it bioconda bash
```

# Somatic / Germline Variant Discovery(WES) Pipeline

---

# 🤫 🤮 NGS analysis PipeLine

- **Github**
    
    [https://github.com/Jin0331/DNA-Seq-Analysis](https://github.com/Jin0331/DNA-Seq-Analysis)
    
- **Somatic vs Germline**
    
    [pathway분석) GO (Gene ontologgy) 란 ?](https://m.blog.naver.com/PostView.naver?blogId=gieyoung0226&logNo=222119758311&targetKeyword=&targetRecommendationCode=1)
    
    [Best practices for variant calling in clinical sequencing - Genome Medicine](https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00791-w)
    
    [[유전학 중요개념 정리] Germline vs. Somatic mutation](https://2wordspm.com/2017/10/27/%EC%9C%A0%EC%A0%84%ED%95%99-%EC%A4%91%EC%9A%94%EA%B0%9C%EB%85%90-%EC%A0%95%EB%A6%AC-germline-vs-somatic-mutation/)
    

![Untitled](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/Untitled.png)

- **Key componenets of NGS analysis and a list of exemplar tools**

![Untitled](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/Untitled%201.png)

---

# 🤔 Pipeline ☠️

- 💥 **Bioconda**
    
    ```bash
    # **sempre813/bioconda:1.1 Container** 
    **docker run -dit -v ${PWD}:/root/work --name bioconda --user root sempre813/bioconda:1.1 bash
    docker exec -it bioconda bash**
    ```
    
    ---
    
- 1️⃣  **Data preparation**
    - **Resource bundle**
        
        [Resource bundle](https://gatk.broadinstitute.org/hc/en-us/articles/360035890811-Resource-bundle)
        
        [bioinfotools/resource_bundle.md at master · bahlolab/bioinfotools](https://github.com/bahlolab/bioinfotools/blob/master/GATK/resource_bundle.md)
        
    - **Reference Split Interval**
        
        [Intervals and interval lists](https://gatk.broadinstitute.org/hc/en-us/articles/360035531852)
        
        [ScatterIntervalsByNs (Picard)](https://gatk.broadinstitute.org/hc/en-us/articles/360042477892-ScatterIntervalsByNs-Picard-)
        
        [SplitIntervals](https://gatk.broadinstitute.org/hc/en-us/articles/360042478592-SplitIntervals)
        
        ```bash
        gatk ScatterIntervalsByNs -R b37/human_g1k_v37.fasta -OT ACGT -O hg19_ge.interval_list
        
        # ScatterIntervalsByNs [Picard type]
        gatk ScatterIntervalsByNs -R b37/human_g1k_v37.fasta -OT ACGT -O hg19_ge.interval_list
        
        # Splitintervals --> 가용 Core에 맞춰 짜를 것.
        gatk SplitIntervals -R b37/human_g1k_v37.fasta -L hg19_ge.interval_list --scatter-count 15 -O intervals_hg19/
        ```
        
        [VcfToIntervalList (Picard)](https://gatk.broadinstitute.org/hc/en-us/articles/360042913331-VcfToIntervalList-Picard-)
        
        ```
        gatk VcfToIntervalList -I resource_bundle/somatic-hg38/af-only-gnomad.hg38.vcf.gz -O resource_bundle/somatic-hg38/af-only-gnomad.hg38.interval_list
        ```
        
    - **Source code Github & Docker image**
        
        [https://github.com/Jin0331/DNA-Seq-Analysis](https://github.com/Jin0331/DNA-Seq-Analysis)
        
        - **Official GATK Docker image**
            
            [](https://gatk.broadinstitute.org/hc/en-us/articles/360035531772-Docker-container-image-registry)
            
            [](https://gatk.broadinstitute.org/hc/en-us/articles/360035889991--How-to-Run-GATK-in-a-Docker-container)
            
            ```bash
            # ubuntu 18.04 or 20.04 기준 (root 모드)
            docker pull broadinstitute/gatk:4.1.3.0
            mkdir ~/gatk_working
            
            docker run -dit -v ~/gatk_working:/gatk/my_data -p 2122:22 --name gatk_4.1.3 broadinstitute/gatk:4.1.3.0
            # 공유폴더 설정 -v local_folder:container_folder 공유
            ```
            
            ```bash
            # container 접속
            docker exec -it gatk_4.1.3 bash
            
            # ssh, ncftp, nano setting
            apt-get update
            apt-get install nano openssh-server ncftp screen vcftools git curl libcurl4-openssl-dev -y
            ```
            
            ```bash
            nano /etc/ssh/sshd_config # 파일 가운데의 PermitRootLogin을 yes로 바꿈
            passwd root # 비밀번호 변경
            service ssh start
            ```
            
            - **외부접속**
                
                ```bash
                # other machine
                ssh -l root -p 2122 'ip address' # ex) ssh -l root -p 2122 210.115.229.96
                ```
                
            - **BCFtools 설치**
                
                ```bash
                git clone git://github.com/samtools/htslib.git htslib
                git clone git://github.com/samtools/bcftools.git bcftools
                cd htslib; git pull; cd ..
                cd bcftools; git pull; cd ..
                
                # Compile
                cd bcftools; make; make test
                # Run
                ./bcftools stats file.vcf.gz
                ```
                
            - **Container List**
                
                [Docker Hub](https://hub.docker.com/r/staphb/samtools)
                
- 2️⃣  **Data pre-processing for variant discovery (Germline / Somatic 공통 Pipeline)**
    - **Important Ref and Images**
        
        [Data pre-processing for variant discovery](https://gatk.broadinstitute.org/hc/en-us/articles/360035535912-Data-pre-processing-for-variant-discovery)
        
        [How to pass multiple "argument value" pair using variable in GATK command?](https://www.biostars.org/p/234378/)
        
        ![Untitled](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/Untitled%202.png)
        
    - **Map to Reference and MarkDuplicates (Time cost :  9176 seconds(2.54 hours) , 3 sample)**
        
        <aside>
        💡 **samtool env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        
        START=$(date +%s)
        
        # docker run -dit -v ${PWD}:/data --name samtool staphb/samtools:1.11 bash
        # apt update && apt install bwa curl git
        
        while getopts f:w:r: flag
        do
            case "${flag}" in
                f) fastqFolder=${OPTARG};;
                w) workPath=${OPTARG};;
                r) ref=${OPTARG};;
            esac
        done
        
        mkdir -p ${workPath}
        
        for i in ${fastqFolder}/*_1.fq.gz
        do
            filename=$(basename $i _1.fq.gz)
            mapFile=${filename}_bwa.bam
            mapped[${#mapped[*]}]=${mapFile}
            bwa mem -t 15 -Ma -R "@RG\\tID:${filename}\\tSM:${filename}\\tPL:ILM\\tLB:${filename}" ${ref} ${i} ${i%1.fq.gz}2.fq.gz \
            | samtools sort - -@ 6 -n -m 7G -T ${i%R1.fq.gz} -o ${workPath}/${mapFile}
        done
        
        # # MarkDuplicates using SAMtools
        for mapFile in ${mapped[*]}
        do
            samtools fixmate -m -@ 25 ${workPath}/${mapFile} ${workPath}/fixmate.bam
            samtools sort -@ 6 -m 7G -o ${workPath}/sorted.bam ${workPath}/fixmate.bam
            samtools markdup -s -@ 25 ${workPath}/sorted.bam ${workPath}/${mapFile%.bam}_dedup.bam
            samtools index -@ 25 ${workPath}/${mapFile%.bam}_dedup.bam
        done
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Map to Reference && MarkDuplicates Done $DIFF seconds"
        ```
        
        [How to pass multiple "argument value" pair using variable in GATK command?](https://www.biostars.org/p/234378/)
        
        - **run**
            
            ```bash
            # Somatic hg38
            bash DNA-Seq-Analysis/Pre-Alignment/MaptoRef.sh -f /data/Exome/raw -w /data/somatic/umap -r /data/resource_bundle/hg38/Homo_sapiens_assembly38.fasta
            
            # Germline hg19
            bash DNA-Seq-Analysis/Pre-Alignment/MaptoRef.sh -f /data/Exome/raw -w /data/germline/umap -r /data/resource_bundle/b37/human_g1k_v37.fasta
            ```
            
        - **Output**
            
            <aside>
            💡 ***_bwa_dedup.bam
            *_bwa_dedup.bam.bai**
            
            </aside>
            
    - **Base quality score recalibration (BQSR) and Apply BQSR ( sample 당 40~50 min 소요, 데이터 사이즈 영향받음)**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        #docker run --rm -dit -v ${PWD}:/gatk/work --name gatk broadinstitute/gatk:4.1.8.1 bash
        
        START=$(date +%s)
        
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
                filename=$(basename ${mapFile} _dedup.bam)
                outfile=${filename}_dedup_recal_data_${i}.table
                gatk --java-options "-Xmx8G -Xmx8G -XX:+UseParallelGC \
                                    -XX:ParallelGCThreads=4" BaseRecalibrator \
                                    -L ${interval}/${i}-scattered.interval_list \
                                    -R ${ref} \
                                    -I ${mapFile} \
                                    --known-sites ${dbsnp} \
                                    -O ${workPath}/${outfile} &
            done
            wait
        
            # ApplyBQSR
            for i in `seq -f %04g 0 14`
            do
                filename=$(basename ${mapFile} _dedup.bam)       
                bqfile=${workPath}/${filename}_dedup_recal_data_${i}.table
                output=${filename}_dedup_recal_${i}.bam
        
                # file list
                if [ ${i} = 1 ]
                then
                    echo ${workPath}/${output} > ${workPath}/${filename}_file.list
                else
                    echo ${workPath}/${output} >> ${workPath}/${filename}_file.list
                fi
        
                gatk --java-options "-Xmx8G -Xmx8G -XX:+UseParallelGC \
                     -XX:ParallelGCThreads=4" ApplyBQSR -R ${ref} \
                                    -I ${mapFile} \
                                    -L ${interval}/${i}-scattered.interval_list \
                                    -bqsr ${bqfile} \
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
        
                filename=$(basename ${mapFile} _dedup.bam)
                gatk GatherBamFiles -I ${workPath}/${filename}_file.list \
                                    -O ${workPath}/${filename}_unsorted.bam \
                                    -R ${ref}
        
                gatk SortSam -I ${workPath}/${filename}_unsorted.bam \
                            -O ${workPath}/${filename}_final.bam \
                            --SORT_ORDER coordinate -VALIDATION_STRINGENCY LENIENT
                
                gatk BuildBamIndex -I ${workPath}/${filename}_final.bam \
                                -O ${workPath}/${filename}_final.bai \
                                -VALIDATION_STRINGENCY LENIENT
            fi
        done
        
        if [ ${type} = "somatic" ]
        then
            bamlist=$(for f in ${workPath}/*_final.bam; do echo -n "-I $f " ;done)
        
            # multiple bam merge
            gatk MergeSamFiles \
                ${bamlist} \
                -O ${finalPath}/merged_sample.bam \
                -AS false --CREATE_INDEX true --MERGE_SEQUENCE_DICTIONARIES false \
                -SO coordinate --USE_THREADING true --VALIDATION_STRINGENCY STRICT
        fi
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Base quality score recalibration (BQSR) and Apply BQSR $DIFF seconds"
        ```
        
        [Base Quality Score Recalibration (BQSR)](https://gatk.broadinstitute.org/hc/en-us/articles/360035890531-Base-Quality-Score-Recalibration-BQSR-)
        
        [MergeSamFiles (Picard)](https://gatk.broadinstitute.org/hc/en-us/articles/360037053552-MergeSamFiles-Picard-)
        
        - **run**
            
            ```bash
            # Somatic
            bash DNA-Seq-Analysis/Pre-Alignment/BQSR_apply.sh -b /gatk/work/somatic/umap -w /gatk/work/somatic/work_bam/ -o /gatk/work/somatic/final_bam/ -r resource_bundle/hg38/Homo_sapiens_assembly38.fasta -d resource_bundle/hg38/Homo_sapiens_assembly38.dbsnp138.vcf -i resource_bundle/intervals_hg38 -t somatic
            
            # Germline
            bash DNA-Seq-Analysis/Pre-Alignment/BQSR_apply.sh -b /gatk/work/germline/umap -w /gatk/work/germline/work_bam/ -r resource_bundle/b37/human_g1k_v37.fasta -d resource_bundle/b37/dbsnp_138.b37.vcf -i resource_bundle/intervals_hg19 -t germline
            ```
            
        - **Output**
            
            <aside>
            💡 **<Germline>**
            ****_bwa_dedup_recal_data_000*.table
            *_bwa_dedup_recal_000*.bam*
            **_bwa_dedup_recal_000*.bai
            
            <Somatic>
            merged_sample.bam
            merged_sample.bai***
            
            </aside>
            
- 3️⃣ -1️⃣  **Germline short variant discovery (SNPs + Indels)**
    - **Important Ref and Images**
        
        [(How to) Run germline single sample short variant discovery in DRAGEN mode](https://gatk.broadinstitute.org/hc/en-us/articles/4407897446939--How-to-Run-germline-single-sample-short-variant-discovery-in-DRAGEN-mode)
        
        [StrandBiasBySample error Haplotypecaller](https://gatk.broadinstitute.org/hc/en-us/community/posts/360062876332-StrandBiasBySample-error-Haplotypecaller)
        
        [Chapter 6 GenomicsDBImport (replaces CombineGVCFs) | A practical introduction to GATK 4 on Biowulf (NIH HPC)](https://hpc.nih.gov/training/gatk_tutorial/genomics-db-import.html)
        
        [Germline short variant discovery (SNPs + Indels)](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-)
        
        [](https://www.ibm.com/downloads/cas/ZJQD0QAL)
        
        ![Untitled](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/Untitled%203.png)
        
    - **Variant calling using GATK HaplotypeCaller (HC) && GatherVCF- ( sample 당 50~60 min 소요, 데이터 사이즈 영향받음)**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        START=$(date +%s)
        
        while getopts b:g:r:d:i:o: flag
        do
            case "${flag}" in
                b) scatterbamFolder=${OPTARG};; # scatter bam
                g) scattergvcfFolder=${OPTARG};; # scatter gvcf
                r) ref=${OPTARG};;
                d) dbsnp=${OPTARG};;
                i) interval=${OPTARG};;
                o) finalPath=${OPTARG};;
            esac
        done
        
        # gvcf dir
        mkdir -p ${finalPath}
        mkdir -p ${scattergvcfFolder}
        
        # HaplotypeCaller
        for mapFile in ${scatterbamFolder}/*_bwa_dedup_recal_0001.bam
        do  
        
            for i in `seq -f %04g 0 14`
            do
                filename=$(basename $mapFile _dedup_recal_0001.bam)        
                infile=${filename}_dedup_recal_${i}.bam
                outfile=${filename}_dedup_recal_${i}.g.vcf
                
        
                # file list
                if [ ${i} = 1 ]
                then
                    echo ${scattergvcfFolder}/${outfile} > ${scattergvcfFolder}/${filename}_gvcf_file.list
                else
                    echo ${scattergvcfFolder}/${outfile} >> ${scattergvcfFolder}/${filename}_gvcf_file.list
                fi
        
                gatk --java-options "-Xmx5G -XX:+UseParallelGC -XX:ParallelGCThreads=5" HaplotypeCaller \
                                -ERC GVCF \
                                -R ${ref} \
                                -D ${dbsnp} \
                                -I ${scatterbamFolder}/${infile} \
                                -L ${interval}/${i}-scattered.interval_list \
                                -O ${scattergvcfFolder}/${outfile} \
                                -stand-call-conf 10 &
            done
            wait
        
            # # merge scattered phenotype vcf files
            filename=$(basename $mapFile _dedup_recal_0001.bam)
            combine=${filename}_dedup_recal.g.vcf
        
            gatk --java-options "-Xmx20G" GatherVcfs -R ${ref} \
                    -I ${scattergvcfFolder}/${filename}_gvcf_file.list \
                    -O ${finalPath}/${combine}
        done
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Step1 - Map to Reference && MarkDuplicates Done!! : $DIFF seconds"
        ```
        
        - **run**
        
        ```bash
        bash DNA-Seq-Analysis/Germline_variant_discovery/Haplotype_Gather.sh -b /gatk/work/germline/work_bam/ -g /gatk/work/germline/work_gvcf -r /gatk/work/resource_bundle/b37/human_g1k_v37.fasta -d /gatk/work/resource_bundle/b37/dbsnp_138.b37.vcf -i /gatk/work/resource_bundle/intervals_hg19/ -o /gatk/work/germline/gvcf/
        ```
        
        - **Output**
            
            <aside>
            💡 ***_bwa_dedup_recal_${i}.g.vcf
            *_bwa_dedup_recal_${i}.g.vcf.idx**
            
            </aside>
            
    - **GenomicDBImport & GenotyepGVCFs (20~30min)**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        #docker run --rm -dit -v ${PWD}:/gatk/work --name gatk broadinstitute/gatk:4.1.8.1 bash
        START=$(date +%s)
        
        while getopts w:b:r:d:i:o: flag
        do
            case "${flag}" in
                w) gvcfPath=${OPTARG};;
                b) genomicPath=${OPTARG};;
                r) ref=${OPTARG};;
                d) dbsnp=${OPTARG};;
                i) interval=${OPTARG};;
                o) finalPath=${OPTARG};;
        
            esac
        done
        
        # sample map make
        for i in ${gvcfPath}/*.g.vcf
        do 
           echo `bcftools query -l $i`;echo $i
        done | paste - - > ${gvcfPath}/sample.map
        
        # GenomicDBImport
        mkdir -p ${genomicPath}
        for i in `seq -f %04g 0 14`
        do
            gatk --java-options "-Xmx5G -XX:+UseParallelGC -XX:ParallelGCThreads=5" GenomicsDBImport \
                    -R ${ref} \
                    --genomicsdb-workspace-path ${genomicPath}/${i} \
                    --sample-name-map ${gvcfPath}/sample.map \
                    -L ${interval}/${i}-scattered.interval_list \
                    --tmp-dir "/gatk/temp" &
        done
        wait
        
        # GenotypeGVCFs
        cd /gatk/work
        mkdir -p ${finalPath}
        for i in `seq -f %04g 0 14`
        do
            if [ ${i} = 1 ]
            then
                echo ${finalPath}/scatter-vcf-${i}.vcf > ${finalPath}/vcf_file.list
            else
                echo ${finalPath}/scatter-vcf-${i}.vcf >> ${finalPath}/vcf_file.list
            fi
            
            #PATH confirm
            gatk --java-options "-Xmx5G -XX:+UseParallelGC -XX:ParallelGCThreads=5" GenotypeGVCFs \
                    -R ${ref} \
                    -V gendb://germline/genomicDB/${i} \
                    -D ${dbsnp} \
                    -O ${finalPath}/scatter-vcf-${i}.vcf &
        done
        wait
        
        # GatherVCF
        gatk --java-options "-Xms15G -Xmx15G" GatherVcfs \
                    -R ${ref} \
                    -I ${finalPath}/vcf_file.list \
                    -O ${finalPath}/raw_merged.vcf
        
        # Sort
        gatk --java-options "-Xms25G -Xmx25G" SortVcf \
                    -I ${finalPath}/raw_merged.vcf \
                    -O ${finalPath}/raw_merged.sort.vcf
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "GenomicDBImport & GenotyepGVCFs $DIFF seconds"
        ```
        
        - **run**
            
            ```bash
            bash DNA-Seq-Analysis/Germline_variant_discovery/GenomicDBImport_GenotypeGVCF.sh -w /gatk/work/germline/gvcf/ -b /gatk/work/germline/genomicDB -r resource_bundle/b37/human_g1k_v37.fasta -t resource_bundle/b37/human_g1k_v37.dict -d resource_bundle/b37/dbsnp_138.b37.vcf -i resource_bundle/intervals_hg19/ -o /gatk/work/germline/raw_vcf
            ```
            
        - **Output**
            
            <aside>
            💡 **scatter-vcf-${i}.vcf
            scatter-vcf-${i}.vcf.idx
            raw_merged.vcf
            raw_merged.vcf.idx
            raw_merged.sort.vcf
            raw_merged.sort.vcf.idx**
            
            </aside>
            
    - **Variant-quality score recalibration (VQSR) and filtering**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        
        START=$(date +%s)
        
        while getopts v:r:b:h:n:k:d:m:o: flag
        do
            case "${flag}" in
                v) mergevcf=${OPTARG};;
                r) ref=${OPTARG};;
                b) workvqsr=${OPTARG};;
                h) hapmap=${OPTARG};;
                n) omni=${OPTARG};;
                k) kg1000=${OPTARG};;
                d) dbsnp=${OPTARG};;
                m) mills=${OPTARG};;
                o) finalPath=${OPTARG};;
            esac
        done
        
        # directory
        mkdir -p ${workvqsr}
        mkdir -p ${finalPath}
        
        # Variant quality score recalibration - SNPs
        gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=5" VariantRecalibrator \
          -mode SNP \
          -R ${ref} \
          -V ${mergevcf} \
          -O ${workvqsr}/recalibrate_SNP.recal \
          -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
          -tranche 100.0 -tranche 99.95 -tranche 99.9 \
          -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
          -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 \
          -tranche 92.0 -tranche 91.0 -tranche 90.0 \
          --tranches-file ${workvqsr}/recalibrate_SNP.tranches \
          --resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${hapmap} \
          --resource:omni,known=false,training=true,truth=false,prior=12.0 ${omni} \
          --resource:1000G,known=false,training=true,truth=false,prior=10.0 ${kg1000} \
          --resource:dbsnp,known=true,training=false,truth=false,prior=7.0 ${dbsnp} \
          --rscript-file ${workvqsr}/output_SNP1.plots.R
        
        # Variant quality score recalibration - INDELs
        gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=5" VariantRecalibrator \
          -mode INDEL \
          -R ${ref} \
          -V ${mergevcf} \
          -O ${workvqsr}/recalibrate_INDEL.recal \
          -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP \
          -tranche 100.0 -tranche 99.95 -tranche 99.9 \
          -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
          -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 \
          -tranche 92.0 -tranche 91.0 -tranche 90.0 \
          --tranches-file ${workvqsr}/recalibrate_INDEL.tranches \
          --resource:mills,known=false,training=true,truth=true,prior=12.0 ${mills} \
          --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${dbsnp} \
          --rscript-file ${workvqsr}/output_indel1.plots.R
        
          # Apply recalibration to SNPs
        gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=5" ApplyVQSR \
          -V ${mergevcf} \
          -O ${workvqsr}/recalibrated_snps_raw_indels.vcf \
          --recal-file ${workvqsr}/recalibrate_SNP.recal \
          --tranches-file ${workvqsr}/recalibrate_SNP.tranches \
          -truth-sensitivity-filter-level 99.9 \
          --create-output-variant-index true \
          -mode SNP
        
          # Apply recalibration to Indels
        gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=5" ApplyVQSR \
          -V ${workvqsr}/recalibrated_snps_raw_indels.vcf \
          -O ${finalPath}/merged_snp_indel.recal.vcf \
          --recal-file ${workvqsr}/recalibrate_INDEL.recal \
          --tranches-file ${workvqsr}/recalibrate_INDEL.tranches \
          -truth-sensitivity-filter-level 99.9 \
          --create-output-variant-index true \
          -mode INDEL
        
          # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "VQSR $DIFF seconds"
        ```
        
        - **run**
            
            ```bash
            bash DNA-Seq-Analysis/Germline_variant_discovery/Variant_Recalibration.sh \
            -v /gatk/work/germline/raw_vcf/raw_merged.sort.vcf \
            -r resource_bundle/b37/human_g1k_v37.fasta \
            -b /gatk/work/germline/work_vqsr -h resource_bundle/b37/hapmap_3.3.b37.vcf \
            -n resource_bundle/b37/1000G_omni2.5.b37.vcf \
            -k resource_bundle/b37/1000G_phase1.snps.high_confidence.b37.vcf \
            -d resource_bundle/b37/dbsnp_138.b37.vcf \
            -m resource_bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf \ 
            -o /gatk/work/germline/vqsr
            ```
            
        - **output**
            
            <aside>
            💡 **<Final VCF>
            recalibrated_VQSR.filtered.PASS.vcf**
            
            </aside>
            
    - **Hard-Filtering**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        [(How to) Filter variants either with VQSR or by hard-filtering](https://gatk.broadinstitute.org/hc/en-us/articles/360035531112--How-to-Filter-variants-either-with-VQSR-or-by-hard-filtering)
        
        ```bash
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
        
        # directory
        mkdir -p ${finalPath}
        mkdir -p ${workhard}
        
        # SPLIT SNP
        gatk --java-options '-Xmx25g' SelectVariants \
         -R ${ref} \
         -V ${mergevcf} \
         -select-type SNP \
         -O ${workhard}/Exome_Norm_HC_calls.snps.vcf
        
        # SPLIT INDEL
        gatk --java-options '-Xmx25g' SelectVariants \
         -R ${ref} \
         -V ${mergevcf} \
         -select-type INDEL \
         -O ${workhard}/Exome_Norm_HC_calls.indels.vcf
        
        # FILTER SNP 
        # GATK hard filter recommend
        # https://gatk.broadinstitute.org/hc/en-us/articles/360035531112--How-to-Filter-variants-either-with-VQSR-or-by-hard-filtering
        gatk --java-options '-Xmx25g' VariantFiltration \
         -R ${ref} \
         -V ${workhard}/Exome_Norm_HC_calls.snps.vcf \
         --missing-values-evaluate-as-failing true \
         --filter-expression "QD < 2.0" \
         --filter-name "QD2" \
         --filter-expression "QUAL < 30.0" \
         --filter-name "QUAL30" \
         --filter-expression "SOR > 3.0" \
         --filter-name "SOR3" \
         --filter-expression "FS > 60.0" \
         --filter-name "FS60" \
         --filter-expression "MQ < 40.0" \
         --filter-name "MQ40" \
         --filter-expression "MQRankSum < -12.5" \
         --filter-name "MQRankSum-12.5" \
         --filter-expression "ReadPosRankSum < -8.0" \
         --filter-name "ReadPosRankSum-8" \
         -O ${workhard}/HardFilter.snps.filtered.vcf
        
        gatk --java-options '-Xmx25g' VariantFiltration \
         -R ${ref} \
         -V ${workhard}/Exome_Norm_HC_calls.indels.vcf \
         --missing-values-evaluate-as-failing true \
         --filter-expression "QD < 2.0" \
         --filter-name "QD2" \
         --filter-expression "QUAL < 30.0" \
         --filter-name "QUAL30" \
         --filter-expression "FS > 200.0" \
         --filter-name "FS200" \
         --filter-expression "ReadPosRankSum < -20.0" \
         --filter-name "ReadPosRankSum-20" \
         -O ${workhard}/HardFilter.indels.filtered.vcf
        
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
        ```
        
        - **run**
            
            ```bash
            bash DNA-Seq-Analysis/Germline_variant_discovery/Hard-filtering.sh -v /gatk/work/germline/raw_vcf/raw_merged.sort.vcf -r resource_bundle/b37/human_g1k_v37.fasta -b germline/work_hard -o germline/hardFiltering
            ```
            
        - **output**
            
            <aside>
            💡 **<Final VCF>**
            **HardFilter.filtered.PASS.vcf**
            
            </aside>
            
    - 💥  **Variant Quality Control(QC) for Visualization**
        - **VariantQC**
            - **DISCVRSeq**
                
                [https://github.com/BimberLab/DISCVRSeq](https://github.com/BimberLab/DISCVRSeq)
                
                ```bash
                docker pull sempre813/discvrseq:1.0
                docker run -dit -v ${PWD}:/data --name discvrseq bash
                ```
                
                ```bash
                # VariantQC for HTML
                mkdir -p germline/VariantQC
                java -jar /DISCVRSeq.jar VariantQC -R resource_bundle/b37/human_g1k_v37.fasta \ 
                																	 -V germline/hardFiltering/HardFilter.filtered.vcf \
                																	 -O germline/VariantQC/HardFilter.germline.html
                ```
                
                [HardFilter.germline_V2.html](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/HardFilter.germline_V2.html)
                
                [VQSR.germline.html](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/VQSR.germline.html)
                
        - **Ref**
            
            [VariantQC: a visual quality control report for variant evaluation](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7963085/)
            
            [](https://ressources.france-bioinformatique.fr/sites/default/files/V04_FiltrageVariantNLapaluRoscoff2016_0.pdf)
            
            [](https://repository.kisti.re.kr/bitstream/10580/6331/1/2016-072%20%EC%95%94%EC%9C%A0%EC%A0%84%EC%B2%B4%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%B6%84%EC%84%9D.pdf)
            
    - 💥  **Annotation**
        - **ANNOVAR**
            
            ![Untitled](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/Untitled%204.png)
            
            - **Related DB download**
                
                ```bash
                ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar ensGene humandb/ #Ensembl
                ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp42c humandb/ #Multiple DataBase
                ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp150 humandb/ #dbSNP150
                ```
                
            - **RUN**
                
                ```bash
                annovar/table_annovar.pl input/HardFilter.filtered.PASS.vcf annovar/humandb/ -buildver hg19 -out output/HardFilter -remove -protocol refGene,ensGene,avsnp150,dbnsfp42c -operation g,g,f,f -nastring . -vcfinput -polish --thread 20
                ```
                
            - **Output**
                
                <aside>
                💡 ***.avinput
                *_multianno.txt
                *_multianno.vcf**
                
                </aside>
                
        - **Ref**
            
            [Annovar: Population frequency, in-silico prediction tool 및 기타 database 활용](https://2wordspm.com/2019/09/10/annovar-population-frequency-in-silico-prediction-tool-%EB%B0%8F-%EA%B8%B0%ED%83%80-database-%ED%99%9C%EC%9A%A9/)
            
            [Good annotation databases for a VCF file (somatic variants)](https://www.biostars.org/p/9472730/)
            
        
    
    ---
    
    - **Ref**
        
        [NGS 분석 파이프 라인의 이해: GATK Best Practice](https://2wordspm.com/2019/03/08/ngs-%EB%B6%84%EC%84%9D-%ED%8C%8C%EC%9D%B4%ED%94%84-%EB%9D%BC%EC%9D%B8%EC%9D%98-%EC%9D%B4%ED%95%B4-gatk-best-practice/)
        
        [FASTQ AND BAM PROCESSING OVERVIEW - Clara Parabricks Pipelines 3.2 documentation](https://docs.nvidia.com/clara/parabricks/v3.2/text/fastq_and_bam_processing.html)
        
        [Germline SNV/Indel Filtering/Annotation/Review](https://pmbio.org/module-04-germline/0004/02/02/Germline_SnvIndel_FilteringAnnotationReview/)
        
- 3️⃣ -2️⃣  **Somatic  short variant discovery (SNPs + Indels, Tumor-only)**
    - **Important Ref and Images**
        
        [Somatic short variant discovery (SNVs + Indels)](https://gatk.broadinstitute.org/hc/en-us/articles/360035894731-Somatic-short-variant-discovery-SNVs-Indels-)
        
        [Panel of Normals Documentation](https://gatk.broadinstitute.org/hc/en-us/community/posts/360061543792-Panel-of-Normals-Documentation)
        
        [](https://www.nature.com/articles/s42003-020-01460-9.pdf?proof=tr)
        
        [Mutect2 (tumor & matched normal) - Exception in thread "main" java.lang.OutOfMemoryError: Java heap space](https://gatk.broadinstitute.org/hc/en-us/community/posts/360072844392-Mutect2-tumor-matched-normal-Exception-in-thread-main-java-lang-OutOfMemoryError-Java-heap-space)
        
        ![Untitled](Somatic%20Germline%20Variant%20Discovery(WES)%20Pipeline%203a50a67cf1c14285bb8f7a361d81c969/Untitled%205.png)
        
    - **Preprocessing for Mutect2 and FilterVariant**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        #!/bin/bash
        
        START=$(date +%s)
        
        while getopts v:r:g:i:b: flag
        do
            case "${flag}" in
                v) bamFolder=${OPTARG};;
                r) ref=${OPTARG};;
                g) gnomad=${OPTARG};;
                i) interval=${OPTARG};;
                b) workvariant=${OPTARG};;
            esac
        done
        
        # directory
        mkdir -p ${workvariant}
        
        # Tumor-only somatic variant call pipeline
        for mapFile in ${bamFolder}/*_final.bam
        do  
            filename=$(basename ${mapFile} _bwa_final.bam)
        
            # 1. Generate OXOG metrics:
            gatk --java-options "-Xmx25G -Xmx25G" CollectSequencingArtifactMetrics \
                -I ${mapFile} \
                -O ${workvariant}/${filename} --FILE_EXTENSION .txt \
                -R ${ref}
        
            # 2. Generate pileup summaries on tumor sample
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
            done
            wait
        
            # 3. Merge pileup summaries merge
            head -2 ${workvariant}${filename}_targeted_sequencing_0000.table > ${workvariant}${filename}_targeted_sequencing.table
            tail -n +3 -q ${workvariant}${filename}_targeted_sequencing_00* >> ${workvariant}${filename}_targeted_sequencing.table
        
            ## 4. Calculate contamination on tumor sample
            infile=${filename}_targeted_sequencing.table
            outfile=${filename}_targeted_sequencing.contamination.table
        
            gatk CalculateContamination \
                -I ${workvariant}/${infile} \
                -O ${workvariant}/${outfile}
        
            ## 5. Find tumor sample name from BAM
            gatk GetSampleName \
                -I ${mapFile} \
                -O ${workvariant}/${filename}.targeted_sequencing.sample_name
        
        done
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Preprocessing SomaticVariant Calling $DIFF seconds"
        ```
        
        [Concatenate multiple files with same header](https://unix.stackexchange.com/questions/60577/concatenate-multiple-files-with-same-header)
        
        - **run**
            
            ```bash
            bash DNA-Seq-Analysis/Somatic_variant_discovery/Preprocessing_Mutect2.sh \
            	-v somatic/final_bam/ \
            	-r resource_bundle/hg38/Homo_sapiens_assembly38.fasta \
            	-g resource_bundle/somatic-hg38/af-only-gnomad.hg38.vcf.gz \
            	-i resource_bundle/intervals_hg38/ \
            	-b somatic/work_variant
            ```
            
        - **Output**
            
            <aside>
            💡 ***.pre_adapter_detail_metrics.txt
            *_targeted_sequencing_${i}.table
            *_targeted_sequencing.contamination_${i}.table
            *.targeted_sequencing.sample_name**
            
            </aside>
            
    - **Mutect2-Merge-Sort before FilterVariant**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        ```bash
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
                o) workVCF=${OPTARG};;
            esac
        done
            
        mkdir -p ${workVCF}
        
        ## Run MuTect2 using only tumor sample on chromosome level (25 commands with different intervals)    
        for mapFile in ${bamFolder}/*_final.bam
        do
            for i in `seq -f %04g 0 14`
            do  
        
            filename=$(basename $mapFile _bwa_final.bam)
            output=${filename}.mt2_${i}.vcf
            flr2_output=${filename}.flr2_${i}.tar.gz
        
            # file list
            if [ ${i} = 1 ]
            then
                echo ${workVCF}/${output} > ${workVCF}/${filename}_m2_vcf_file.list
        
            else
                echo ${workVCF}/${output} >> ${workVCF}/${filename}_m2_vcf_file.list
            fi
        
            gatk --java-options "-Xmx33G -XX:ConcGCThreads=1" Mutect2 \
                -R ${ref} \
                -L ${interval}/${i}-scattered.interval_list \
                -I ${mapFile} \
                --native-pair-hmm-threads 2 \
                -tumor ${workvariant}/${filename}.targeted_sequencing.sample_name \
                --af-of-alleles-not-in-resource 2.5e-06 \
                --germline-resource ${gnomad} \
                --f1r2-tar-gz ${workVCF}/${flr2_output} \
                -pon ${pon} \
                --tmp-dir /root \
                -O ${workVCF}/${output} &
            done
            wait
        
            # merge scattered phenotype vcf files & filter
            filename=$(basename $mapFile _bwa_final.bam)
            combine=${filename}.mt2_merged.vcf
            sort=${filename}.mt2_merged_sort.vcf
        
            # Merge
            gatk --java-options "-Xmx20G" GatherVcfs \
                    -R ${ref} \
                    -I ${workVCF}/${filename}_m2_vcf_file.list \
                    -O ${workVCF}/${combine}
        
            # Sort
            gatk --java-options "-Xmx20G" SortVcf \
                    --SEQUENCE_DICTIONARY ${refDict} \
                    --CREATE_INDEX true \
                    -I ${workVCF}/${combine} \
                    -O ${workVCF}/${sort}
        
            # Stats Merge
            statslist=$(for f in ${workVCF}/${filename}*.mt2_*.vcf.stats; do echo -n "--stats $f " ;done)
            gatk MergeMutectStats \
                ${statslist} \
                -O ${workVCF}/${sort}.stats
        
            # Flr2 Merge
            flr2list=$(for f in ${workVCF}/${filename}*.flr2_*.tar.gz; do echo -n "-I $f " ;done)
            gatk LearnReadOrientationModel \
                ${flr2list} \
                -O ${workVCF}/${filename}_read-orientation-model.tar.gz
        
        done
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Mutect2 Merge $DIFF seconds"
        ```
        
        - **run**
            
            ```bash
            bash DNA-Seq-Analysis/Somatic_variant_discovery/Mutect2_Merge_Sort.sh -v somatic/final_bam/ -r resource_bundle/hg38/Homo_sapiens_assembly38.fasta -d resource_bundle/hg38/Homo_sapiens_assembly38.dict -g resource_bundle/somatic-hg38/af-only-gnomad.hg38.vcf.gz -p resource_bundle/somatic-hg38/1000g_pon.hg38.vcf.gz -i resource_bundle/intervals_hg38/ -b somatic/work_variant/ -o somatic/work_vcf/
            ```
            
        - **Output**
            
            <aside>
            💡 ***.mt2_merged.vcf
            *.mt2_merged.vcf.idx
            *.mt2_merged_sort.vcf
            *.mt2_merged_sort.vcf.idx
            *.flr2_${i}.tar.gz
            *_read-orientation-model.tar.gz**
            
            </aside>
            
    - **Filter variant calls from MuTect and Filter variants and Annotation by Funcotator**
        
        <aside>
        💡 **gatk4 env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        
        START=$(date +%s)
        
        while getopts v:c:r:d:f:i:b:o: flag
        do
            case "${flag}" in
                v) variantFolder=${OPTARG};;
                c) vcfFolder=${OPTARG};;
                r) ref=${OPTARG};;
                d) refDict=${OPTARG};;
                f) funco=${OPTARG};;
                i) intervalList=${OPTARG};;
                b) workvariant=${OPTARG};;
                o) finalPath=${OPTARG};;
            esac
        done
        
        mkdir -p ${workvariant}
        mkdir -p ${finalPath}
        
        # Filter variant calls from MuTect
        for mapFile in ${vcfFolder}/*.mt2_merged_sort.vcf
        do
        
            filename=$(basename $mapFile .mt2_merged_sort.vcf)
            output=${filename}.mt2_contFiltered.vcf
            sort=${filename}.mt2_filtered_sort.vcf
            filterPass=${filename}.mt2_filtered_sort_pass.vcf
            funcoOutput1=${filename}.mt2_filtered.anno.vcf
            funcoOutput2=${filename}.mt2_filtered.anno.maf
        
            # Filter Mutect Calls
            gatk --java-options "-Xmx30G" FilterMutectCalls \
                -R ${ref} \
                -V ${mapFile} \
                -L ${intervalList} \
                --contamination-table ${variantFolder}/${filename}_targeted_sequencing.contamination.table \
                --ob-priors ${vcfFolder}/${filename}_read-orientation-model.tar.gz \
                -O ${workvariant}/${output}
        
            # Sort
            gatk --java-options "-Xmx20G" SortVcf \
                -I ${workvariant}/${output} \
                --SEQUENCE_DICTIONARY ${refDict} \
                --CREATE_INDEX true \
                -O ${finalPath}/${sort}
            
            # FILTER == PASS only
            gatk --java-options "-Xmx25g" SelectVariants \
                -R ${ref} \
                -V ${finalPath}/${sort} \
                -O ${finalPath}/${filterPass} \
                --exclude-filtered
        
            # Funcotator for VCF
            gatk --java-options "-Xmx30G" Funcotator \
                -R ${ref} \
                -V ${finalPath}/${filterPass} \
                --ref-version hg38 \
                --remove-filtered-variants \
                --data-sources-path ${funco} \
                --output-file-format VCF \
                -O ${finalPath}/${funcoOutput1}
        
            # Funcotator for MAF
            gatk --java-options "-Xmx30G" Funcotator \
                -R ${ref} \
                -V ${finalPath}/${filterPass} \
                --ref-version hg38 \
                --remove-filtered-variants \
                --data-sources-path ${funco} \
                --output-file-format MAF \
                -O ${finalPath}/${funcoOutput2} \
                --annotation-default Center:WMBIO.co \
                --annotation-default Tumor_Sample_Barcode:${filename}
            
        done
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Filter_Annotation Using Funcotation $DIFF seconds"
        ```
        
        - **run**
            
            ```bash
            bash DNA-Seq-Analysis/Somatic_variant_discovery/Filter_Annotation.sh -v somatic/work_variant/ -c somatic/work_vcf/ -r resource_bundle/hg38/Homo_sapiens_assembly38.fasta -d resource_bundle/hg38/Homo_sapiens_assembly38.dict -f funcotator_resource/somatic/ -i resource_bundle/hg38/Homo_sapiens_assembly38.interval_list -b somatic/work_filter/ -o somatic/final_vcf
            ```
            
        - **Output**
            
            <aside>
            💡 ***.mt2_filtered_sort.vcf
            *.mt2_filtered_sort.vcf.idx
            *.mt2_filtered_sort_pass.vcf
            *.mt2_filtered_sort_pass.vcf.idx
            *.mt2_filtered.anno.vcf
            *.mt2_filtered.anno.vcf.idx
            *.mt2_filtered.anno.maf**
            
            </aside>
            
    - **VCF to MAF using vcf2maf and maftools**
        
        <aside>
        💡 **vep env**
        
        </aside>
        
        ```bash
        #!/bin/bash
        
        START=$(date +%s)
        
        while getopts c:r:o: flag
        do
            case "${flag}" in
                c) vcfFolder=${OPTARG};;
                r) ref=${OPTARG};;
                o) finalPath=${OPTARG};;
            esac
        done
        
        source /opt/conda/etc/profile.d/conda.sh
        conda activate vep
        
        mkdir -p ${finalPath}
        
        # VEP and VCF2MAF
        for mapFile in ${vcfFolder}/*.mt2_filtered_sort_pass.vcf
        do
        
            filename=$(basename $mapFile .mt2_merged_sort.vcf)
            output=${filename}.vep.maf
        
            perl vcf2maf-1.6.21/vcf2maf.pl \
                --input-vcf ${mapFile} \
        		--output-maf ${finalPath}/ \
        		--vep-path /opt/vep/src/ensembl-vep \
        		--vep-data /root/work/vep_resource/ \
                --vep-overwrite \
        		--ref-fasta ${ref} \
        		--ncbi-build GRCh38
        done
        
        # Time stemp
        END=$(date +%s)
        DIFF=$(( $END - $START ))
        echo "Filter_Annotation Using Funcotation $DIFF seconds"
        ```
        
        - **run**
            
            ```
            bash DNA-Seq-Analysis/Somatic_variant_discovery/VEP_Annotation.sh -c somatic/final_vcf/ -r resource_bundle/hg38/Homo_sapiens_assembly38.fasta -o somatic/final_vcf/
            ```
            
    
    ---
    
    - **Ref**
        
        [DNA-Seq Analysis Pipeline](https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/DNA_Seq_Variant_Calling_Pipeline/#pre-alignment)
        
        [Panel of Normals (PON)](https://gatk.broadinstitute.org/hc/en-us/articles/360035890631-Panel-of-Normals-PON-)
        
        [PDX-PanCanAtlas/data_process/somatic.Mutect2_tumorOnly at master · ding-lab/PDX-PanCanAtlas](https://github.com/ding-lab/PDX-PanCanAtlas/tree/master/data_process/somatic.Mutect2_tumorOnly)
        
        [Panel of Normals Documentation](https://gatk.broadinstitute.org/hc/en-us/community/posts/360061543792-Panel-of-Normals-Documentation)
        
        [(How to) Call somatic mutations using GATK4 Mutect2](https://gatk.broadinstitute.org/hc/en-us/articles/360035531132--How-to-Call-somatic-mutations-using-GATK4-Mutect2)