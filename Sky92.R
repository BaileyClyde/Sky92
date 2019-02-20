setwd('L:\\ACRC\\MMDB\\R\\Sky92\\')

library(RODBC)
con <- odbcConnect("MMDB3") #3 possibly for me only, 64 bit DSN

source("sourcescript.txt")

EMCScore<-c(0.0594273379801556,-0.110491572253885,-0.108832301005201,-0.062550086484268,-0.0418164824703641,0.0174897923948543,0.00668584689209701,0.0423154071076169,-0.0493203905211073,0.0164925076573208,-0.0344544706411548,0.00866233731636807,0.00455819600852017,-0.0644105573058562,-0.00414107711721288,-0.0183994540236258,-0.0520135932088583,-0.0767532974279582,-0.00063407777663618,0.0489558593887832,-0.0163691988848842,0.0420452994583269,0.0870276088358123,0.0406887458334764,-0.05606504920594,0.0529972408575157,0.0112796922615379,0.0140109440864371,0.00078080860374577,0.075000229909631,0.009265826714752,0.0860546977563988,-0.0996944005531858,0.0558748936987772,0.073011096187736,0.00538232634785429,0.055611094941233,-0.0520445402963303,0.0125985686829356,0.005608194716564,0.0163467078063,-0.0319185908460475,0.0773361612870129,-0.00900009551662273,-0.0575829465263513,0.022119958576764,0.0396248830654306,0.0524561174360331,0.0476703103071683,-0.0422745546301539,-0.0341783399437912,-0.0251675596648738,0.0495596844465701,0.0547508890118559,0.0437224907573062,-0.0371869820707693,0.0205354349665636,0.0445923111233813,-0.0069962048640006,0.025498590737044,0.0208131193381807,0.0685640666167821,-0.0330380997958823,-0.0105781969037762,-0.0585102612125953,0.0128945938676131,-0.0333628118834898,-0.0349253487676344,0.0660971817524709,-0.0617575340318364,-0.0210452256979565,-0.0389953930227488,-0.0873912090180467,-0.0176248165093743,0.0302900524131141,-0.0051520032747514,0.0745893468079515,-0.0322581999457566,0.0200333568025016,0.0115861932788841,-0.00969926642147875,0.00345861530256628,0.0277930303183715,0.0153863421114279,-0.0777964537268526,0.0349480953839344,-0.00022873908620183,-0.0529393125922244,0.0713507977617356,-0.0253569213540041,0.0384170565171902,0.0225490655109955)
	names(EMCScore)<-c('204379_s_at','202728_s_at','239054_at','202842_s_at','213002_at','210334_x_at','201795_at','38158_at','208232_x_at','201307_at','226742_at','205046_at','204026_s_at','226218_at','217824_at','233399_x_at','224009_x_at','215177_s_at','202532_s_at','238662_at','212788_x_at','220351_at','202542_s_at','243018_at','209683_at','212282_at','208967_s_at','225366_at','217852_s_at','225601_at','231210_at','214482_at','208942_s_at','219550_at','231989_s_at','202553_s_at','223811_s_at','221041_s_at','221677_s_at','213350_at','200775_s_at','226217_at','217728_at','201930_at','216473_x_at','211714_x_at','221755_at','AFFX-HUMISGF3A/M97935_MA_at','206204_at','217548_at','215181_at','217732_s_at','214612_x_at','202813_at','200875_s_at','201292_at','222680_s_at','233437_at','223381_at','209026_x_at','221606_s_at','231738_at','230034_x_at','213007_at','242180_at','202322_s_at','208904_s_at','214150_x_at','238116_at','208732_at','200701_at','208667_s_at','208747_s_at','218662_s_at','211963_s_at','201555_at','207618_s_at','200933_x_at','221826_at','218355_at','219510_at','218365_s_at','222713_s_at','222154_s_at','228416_at','201102_s_at','203145_at','238780_s_at','202884_s_at','201398_s_at','212055_at','202107_s_at')

#traindata<-batchCorrectedData$gepall[, batchCorrectedData$batchesall["H65",]];
# alt
sql.t <- paste ("select * from dbo.CGB_SkyTrainData")
traindata <- sqlQuery( con , sql.t)
rownames(traindata)<-traindata$Array_No 
traindata<-traindata[-1]
# alt end
trainlogdata<-t(traindata)   #???

# pull an eventID through rODBC into testlogdata xid from tblgc where sky92 hasn't been calculated yet and this is an aspirate.
#sql.xid <- paste("select top 1 g.xid from VueGC g where g.Sorting = 'CD138(+)' and g.FLChip = '3704' and g.FYImported = 1 and g.fnsky92 is null order by g.xid desc") # Production
sql.xid <- paste("select top 1 g.xid from VueGC g where g.xid in (select EventID FROM [BDM].[dbo].[CGB_GEO_TT23_BL] where EventID <> 0) and g.fnsky92 is null order by g.xid desc") # for TT2, one at a time
# sql.xid <- paste("select * from  dbo.CGB_SkyTestTT2") # all of TT2 for testing
xid <- sqlQuery( con , sql.xid)

# while you got something, try limiting it to 10 times
i <- 1 
while (nrow(xid)!= 0 & i < 100) {
	#i <- i + 1
	
	#pull necessary  probes and QNLogConverted for that event
	sql.d <- paste("select t.Array_No, e.QNLogConverted s, e.QNLogConverted t from bdm.dbo.Probes92 r inner join genechip.dbo.TblGeneChipTemplate t on t.Array_No = r.ProbeSet and t.Array_IdX = 'U133Plus' inner join genechip.dbo.VueExpression e on e.FNLoc = t.ID and e.FNEvent = ")
	sql.d <- paste(sql.d,xid)
	testdata <- sqlQuery( con , sql.d)
	rownames(testdata)<-testdata$Array_No
	testdata<-testdata[-1]
	testlogdata <- t(testdata)
	testlogdata<-testlogdata[,intersect(colnames(testlogdata),names(EMCScore))]
	testlogdata<-meanvarstandardize(testdata=testlogdata,traindata=trainlogdata)
	score<-testlogdata%*%EMCScore[colnames(testlogdata)] #except score is a column, not a single number
	
	#push update sky92 for this xid in TblGC using Rodbc
	sql.up = paste("update genechip.dbo.tblgc set FNSky92 = ",score[1]," where xid = ",xid,"; select 1 success")
	success <- sqlQuery(con,sql.up)
	xid <- sqlQuery( con , sql.xid)
}
#Done