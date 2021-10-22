# GetTEBed  

De-Kayne 2021  

This script `Get.TE.Bed.sh` will calculate TE content (from the .out from a RepeatMasker run) in windows along specific contig/scaffold/chromosome.  

The output will give you the total TE content in each window in addition to the output by family in each window.  

Prior to running `Get.TE.Bed.sh` you should run repeat masking e.g. as follows:  

```
#build repeat library
/ceph/software/repeatmodeler/RepeatModeler.v2.0.1/BuildDatabase -name your_lib -engine ncbi your_genome.fa
/ceph/software/repeatmodeler/RepeatModeler.v2.0.1/RepeatModeler -database your_lib.2 -pa 50 -LTRStruct

#get broad taxon repeats e.g. lepidoptera
perl /ceph/software/repeatmasker/RepeatMasker-4.1.0/util/queryRepeatDatabase.pl -species Lepidoptera | grep -v "Species:" > Lepidoptera.Repbase.repeatmasker

#combine to form main repeat lib
cat Lepidoptera.Repbase.repeatmasker your_lib-families.fa > Lepidoptera_and_your_lib.repeatmasker

#make sure your genome is all uppercase
awk 'BEGIN{FS=" "}{if(!/>/){print toupper($0)}else{print $1}}' your_genome.fasta > your_genome.uppercase.fasta

#do repeat masking
/ceph/software/repeatmasker/RepeatMasker-4.1.0/RepeatMasker -e rmblast -pa 48 -s -a -xsmall -gccalc -lib ./Lepidoptera_and_your_lib.repeatmasker ./your_genome.uppercase.fa

```

If this runs successfully you will end up with a `.out` file e.g. `your_genome.uppercase.fasta.out` containing locations of all repeat elements in your genome.  

Additionally you will probably want to look in the `.tbl` output which breaks down the content by TE family.  

At this point I recommend assessing which families are present in your genome e.g. with:
```
awk '{print $11}' your_genome.uppercase.fasta.out | tail -n+4 | sort | uniq > TE.fams
```

By default `Get.TE.Bed.sh` will return total TE content and that belonging to the specific families:  
`DNA,LINE,LTR,Helitron,Retroposon,rRNA,Satellite,SINE,tRNA,Unknown`  

If important famlies present in your genome are not currently included you can add them to the script by appending line 72 with your specific family/group.  

To use `Get.TE.Bed.sh` please make sure you have installed/can run Bedtools  
Before running you can test this e.g. with:
```
bedtools merge -h
```
Which should return the `help` script for `bedtools merge`  

Now it's time to run `Get.TE.Bed.sh` which will (variables you specify are in plain text):   
-take a `contig/scaffold/chromosome` you are interested in from your `genome` and produce a bed of `windows of a specified size`  
-calculate the proportion of each window that comprises TEs from a `RepeatMasker.out file`  
-calculate the proportion of each window that comprises each specific TE family from a `RepeatMasker.out file`. 
-write the output to your specified `output directory`  

After making the script executible with `chmod +x Get.TE.Bed.sh` you can run the script as follows:
```
./Get.TE.Bed.sh genome contig_name RepeatMasker.out window_size output_dir
```
e.g.
```
./Get.TE.Bed.sh /path/to/your_genome.uppercase.fasta contig1 /path/to/your_genome.uppercase.fasta.out 10000 /path/to/output_dir/
```
The output is as follows:  
Each output file has the format: `window_end_bp TE_sum`  

The full TE content of each window along the specified contig/scaffold/chromosome is given in `contigXXX.window.te.tab.sum`  

And then the TE content split by family/group - e.g.
```
contigXXX.DNA.window.te.tab.sum
contigXXX.Helitron.window.te.tab.sum
contigXXX.LINE.window.te.tab.sum
contigXXX.LTR.window.te.tab.sum
contigXXX.Retroposon.window.te.tab.sum
contigXXX.rRNA.window.te.tab.sum
contigXXX.Satellite.window.te.tab.sum
contigXXX.SINE.window.te.tab.sum
contigXXX.tRNA.window.te.tab.sum
contigXXX.Unknown.window.te.tab.sum
```

You can then do a simple plot for the produced output using the R script `analyse.Get.TE.Bed.output.R`
