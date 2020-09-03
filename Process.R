####################################################################################
########################### Author: kaushik, Abhinav ###############################
#### The script was written for Samusik data extraction from public domain #########
################ and prepare ready-to-submit files for CyAnno #######################
####################################################################################
library(HDCytoData)
library(dplyr)
samusikDF = as.data.frame(assay(Samusik_all_SE())) ### getting the marker expression matrix ## Raw files ## ;not transformed 
labels = as.data.frame(rowData(Samusik_all_SE()))
samusikDF$labels  = labels$population_id
samusikDF$labels = gsub("unassigned","Unknown", samusikDF$labels)
samusikDF$labels = gsub("\\(", "_", gsub("\\)", "", gsub(" ", "_", samusikDF$labels))) ## clean name of the cell type

samusikDF$SampleID  = labels$sample_id
#### Writing one file for each sampleID ####
dir.create("Samusik")
setwd("Samusik")
dir.create("LiveCells")
dir.create("HandGatedCells")

samples = levels(factor(samusikDF$SampleID))


#### Lets create one CSV file for each sample having all the cells, their expression and handgated celllabels #####
livecellAnnotation = data.frame() ## this will be the meta-data file for live cell csv : Input file 1 for CyAnno
HandGatedAnnotation = data.frame() ## this will be the meta-data file for live cell csv : Input file 2 for CyAnno

for (s in samples){
  fileName1 = paste("LiveCells/Sample_",s,".csv",sep="")
  message(fileName1)
  df = dplyr::filter(samusikDF,SampleID == s)
  write.csv(df,quote = F, file = fileName1,row.names = F) ## one CSV file for each sample 
  tmp = data.frame(paste("Samusik/",fileName1,sep=""),paste("Sample_",s,sep="")) ## preparing annotation file for this sample
  livecellAnnotation = rbind(livecellAnnotation,tmp) ## appending to create a single file 
  ### we write a separate file for each handgated cell type from each sample ###
  cellTypes = levels(factor(df$labels))
  for (ct in cellTypes)
  {
    CTname = gsub("\\(", "_", gsub("\\)", "", gsub(" ", "_", ct))) ## clean name of the cell type 
    ctfilename = paste(paste("HandGatedCells/Sample_",s,sep=""), "_",CTname,".csv",sep="") ## filename for each handgated cell type in each sample 
    message("writing..",ctfilename)
    CTdf = dplyr::filter(df,labels == ct) ## extracting the expression of markers belong to a given in each sample 
    tmp = data.frame(paste("Samusik/",ctfilename,sep=""),CTname,paste("Sample_",s,sep="")) ## preparing annotation file for this handgated cell type in this sample 
    HandGatedAnnotation = rbind(HandGatedAnnotation,tmp) ## appending to create a single file 
    write.csv(CTdf,quote = F, file = ctfilename,row.names = F) ## one CSV file for each cell type in each sample 
  }
}
colnames(livecellAnnotation) = c("fpath","SampleID")
colnames(HandGatedAnnotation) = c("fpath","Cell_Type","SampleID")
print(colnames(df))

#### Will Randonly select 3 samples for training and remainaing seven samples for testing ####
trainingSample = as.character(sample(livecellAnnotation$SampleID, 3)) ## randomly selected three samples for training 
testingSample = setdiff(livecellAnnotation$SampleID,trainingSample)
## 
trainingLiveDataset = dplyr::filter(livecellAnnotation,SampleID %in% trainingSample)
TestingLiveDataset = dplyr::filter(livecellAnnotation,SampleID %in% testingSample)
TrainingHandagted  = dplyr::filter(HandGatedAnnotation,SampleID %in% trainingSample)
write.csv(file ="TrainingHandgatedInput.csv",TrainingHandagted, quote = F, row.names = F) ## CyAnno: Training dataset 
write.csv(file = "TrainingLiveCellInput.csv",trainingLiveDataset, quote = F, row.names = F) ### CyAnno: Live Training cell dataset
write.csv(file = "TestingLiveCellInput.csv",TestingLiveDataset, quote = F, row.names = F) ### CyAnno: Live Testing cell dataset


