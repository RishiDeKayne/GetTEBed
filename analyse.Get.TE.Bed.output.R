#De-Kayne 2021
#This is a basic outline of how you might want to parse the output of Get.TE.Bed.sh in R to produce a very simple landscape plot of TE abundance
#change 'contigXXX' to your file name

#load TE in windows from Get.TE.Bed.sh
all <- read.csv("contigXXX.window.te.tab.sum", header = F, sep = "\t")

DNA <- read.csv("contigXXX.DNA.window.te.tab.sum", header = F, sep = "\t")
Heli <- read.csv("contigXXX.Helitron.window.te.tab.sum", header = F, sep = "\t")
LINE <- read.csv("contigXXX.LINE.window.te.tab.sum", header = F, sep = "\t")
LTR <- read.csv("contigXXX.LTR.window.te.tab.sum", header = F, sep = "\t")
Ret <- read.csv("contigXXX.Retroposon.window.te.tab.sum", header = F, sep = "\t")
rRNA <- read.csv("contigXXX.rRNA.window.te.tab.sum", header = F, sep = "\t")
Sat <- read.csv("contigXXX.Satellite.window.te.tab.sum", header = F, sep = "\t")
tRNA <- read.csv("contigXXX.tRNA.window.te.tab.sum", header = F, sep = "\t")
Un <- read.csv("contigXXX.Unknown.window.te.tab.sum", header = F, sep = "\t")

#set the window size
win <- 10000

#plot midpoint rather than window end which is given
all$bp <- all$V1-(win/2)

#make tiff showing landscapes
tiff(filename="your_genome_contigXXX.tiff", width=1000, height=1200)
par(mfrow=c(10,1))
par(mar=c(1,5,1,3))
plot(all$bp, ((all$V2/win)*100), type = 'l', ylim = c(0,100), col = "red", ylab = "all TEs")
plot(all$bp, ((DNA$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "DNA elements")
plot(all$bp, ((Heli$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Helitron/RCs")
plot(all$bp, ((LINE$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "LINEs")
plot(all$bp, ((LTR$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "LTRs")
plot(all$bp, ((Ret$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Retrotransposons")
plot(all$bp, ((rRNA$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "rRNA")
plot(all$bp, ((Sat$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Satellites")
plot(all$bp, ((tRNA$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "tRNA")
plot(all$bp, ((Un$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Unknown")
dev.off()

###if you have many contigs you can use the following loop:
#give vector of contig names e.g.
tig_name_vec <- c("tig00000001", "tig00000002", "tig00000003")
#speficy window size
win <- 10000

#run loop to go through each contig, extract the info as dfs and make landscape plot for that contig
for (i in 1:length(tig_name_vec)){
  #get names of files
  all <- read.csv(as.character(paste(tig_name_vec[i], ".window.te.tab.sum", sep = "")), header = F, sep = "\t")
  all$bp <- all$V1-(win/2)
  DNA <- read.csv(as.character(paste(tig_name_vec[i], ".DNA.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  Heli <- read.csv(as.character(paste(tig_name_vec[i], ".Helitron.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  LINE <- read.csv(as.character(paste(tig_name_vec[i], ".LINE.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  LTR <- read.csv(as.character(paste(tig_name_vec[i], ".LTR.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  Ret <- read.csv(as.character(paste(tig_name_vec[i], ".Retroposon.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  rRNA <- read.csv(as.character(paste(tig_name_vec[i], ".rRNA.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  Sat <- read.csv(as.character(paste(tig_name_vec[i], ".Satellite.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  tRNA <- read.csv(as.character(paste(tig_name_vec[i], ".tRNA.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  Un <- read.csv(as.character(paste(tig_name_vec[i], ".Unknown.window.te.tab.sum", sep = "")), header = F, sep = "\t")
  
  #make plot - tiff with name of contig
  tiff(filename=as.character(paste(tig_name_vec[i], ".tiff", sep = "")), width=1000, height=1200)
  par(mfrow=c(10,1))
  par(mar=c(1,5,1,3))
  plot(all$bp, ((all$V2/win)*100), type = 'l', ylim = c(0,100), col = "red", ylab = "all TEs")
  plot(all$bp, ((DNA$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "DNA elements")
  plot(all$bp, ((Heli$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Helitron/RCs")
  plot(all$bp, ((LINE$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "LINEs")
  plot(all$bp, ((LTR$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "LTRs")
  plot(all$bp, ((Ret$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Retrotransposons")
  plot(all$bp, ((rRNA$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "rRNA")
  plot(all$bp, ((Sat$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Satellites")
  plot(all$bp, ((tRNA$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "tRNA")
  plot(all$bp, ((Un$V2/win)*100), type = 'l', ylim = c(0,100), ylab = "Unknown")
  dev.off()
}

