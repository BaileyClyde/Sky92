The real copy of this GIT has been re-created under the group.  Don't update this one


######  ##      ##      ####     
######  ####  ####    ### ###    
##      ## #### ##   ##
##      ##  ##  ##  ##
####    ##      ##  ##
##      ##      ##  ## 
##      ##      ##   ##
######  ##      ##   ### ###
######  ##      ##    ##### 92

#######
################
#############################


#######
Purpose:
This script provides a wrapper to the signatures used in the manuscript:  "A High-Risk Survival Signature for Multiple Myeloma". It is used in the statistical environment R.

It contains two files:
(1) batchCorrectedData.R
(2) sourcescript.txt


Important: The wrapper function can only be run if the current working directory is the same as the path to the script.
Working directory in the R commandline can be set with the 'setwd' command. E.g.: setwd("C:/mydir1/mydir2")


#######
Data:

The file 'batchCorrectedData.R' contains the combat batch corrected data for the H65/GMMG-HD4 and the APEX datasets. Only probe sets necessary for running this script are included. The data can be loaded by typing the command:
load("batchCorrectedData.R")
Combat was run twice. The first with the APEX set included, the second without APEX. Both sets can be shown in the R environment by typing:


batchCorrectedData$gepall
or
batchCorrectedData$gepwoapex

To extract a specific batch (like "H65") out of the data use the following command:

batchCorrectedData$gepall[, batchCorrectedData$batchesall["H65",]]
or
batchCorrectedData$gepwoapex[, batchCorrectedData$batcheswoapex["H65",]]

Own data can be read into R by using the standard R commands. To use these data in combination with this script the data must meet the following criteria:
- Numeric matrix
- Affy Probeset ids (without spaces) as rownnames
- Samplenames as columnnames

See examples in directory 'dataAsTextFile'


#######
Functions in script:

helpWrapper()

wrapperForArticle(testset,classifier)

EMC92Classifier(testlogdata,trainlogdata)
UAMS17Classifier(testlogdata,trainlogdata)
IFM15Classifier(testlogdata,trainlogdata)
MILLENNIUM100Classifier(testlogdata,trainlogdata)

UAMS70Classifier(testlogdata)
UAMS80Classifier(testlogdata)
MRCIX6Classifier(testlogdata)


To load the functions mentioned above, type:
source("sourcescript.txt")

use function helpWrapper() for help reference

#######
Simple use (after starting R, setting the right working directory and functions loaded):

A convenience wrapper function 'wrapperForArticle' is provided to calculate the prediction scores as mentioned in the manuscript based on the combat batch corrected datasets (file:batchCorrectedData.R). It can be called by typing the function name and passing the right arguments for 'testset' and 'classifier'. 
Possible values for testset are: "H65" or "APEX". 
Possible values for classifier are: "EMC92","UAMS70","UAMS80","MRCIX6","MILLENNIUM100" or "IFM15"
The function returns a matrix with two columns: (1) raw prediction score, (2) is patient high risk (1=Yes, 0=No)

Example:
wrapperForArticle(testset="H65",classifier="EMC92")


#######
Use of raw classifier script. 
If using custom data, the raw classifier scripts may be used. For the required format of custom data see section "Data"

Example:
EMC92Classifier(testlogdata="<My batchcorrected testdata>",trainlogdata="<My batchcorrected HOVON-65/GMMG-HD4 DATA>")

#######
Threshold:

All of the above functions allow the setting of the cut-off threshold that is used to classify a patient as high-risk or standard-risk

Example:
wrapperForArticle(testset="APEX",classifier="EMC92",threshold=1.1)

#######
General examples:

#Always first load functions
source("sourcescript.txt") 

#Get predictions for the APEX set using the EMC92 signature
# using the wrapper function
result<-wrapperForArticle(testset="APEX",classifier="EMC92")
#show result
result
#show proportion high-risk patients (manuscript table S2)
sum(result[,"isHighRisk"])/length(result[,"isHighRisk"])


#Get predictions for the APEX set using the EMC92 signature
# using the raw function with default threshold of 0.827
#load the data
load("batchCorrectedData.R")
testset<-batchCorrectedData$gepall[ ,batchCorrectedData$batchesall["APEX",]]
trainset<-batchCorrectedData$gepall[, batchCorrectedData$batchesall["H65",]]
result<-EMC92Classifier(trainlogdata=trainset,testlogdata=testset)
#show result
result












