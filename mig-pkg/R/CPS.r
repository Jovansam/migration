# documentation of data at http://www.nber.org/cps/cpsmar13.pdf


Clean.CPS <- function(dta="~/datasets/CPS/outdata/selected.dta") {

	d <- data.table(read.dta(dta))
	# adjust data for shift in coding of NXTRES
	d[h_year<2011& nxtres>12, nxtres := nxtres + 1L]
	d[,nxtres.2 := nxtres]
	d[nxtres %in% c(2L,9:14) ,nxtres.2 := 100L]	# housing
	d[nxtres %in% c(1L,3L)    ,nxtres.2 := 200L]	# family 
	d[nxtres %in% 4:8       ,nxtres.2 := 300L]	# work 
	d[nxtres %in% 15:19     ,nxtres.2 := 400L]	# other

	d[, nxtresf := factor(nxtres, labels=c("NIU","change marstat","estab. own household","other fam reason","new job/job transfer","look for job","closer to work","retired","other job reason","want to own","better house","better neighborhood","cheaper housing","foreclosure","other housing","attend/leave college","climate change","health","natural disaster","other"))]

	levels(d$migsame) <- c("NIU","yes (nonmover)","no, different house in US","no, different foreign")

	d[, main.reason := factor(nxtres.2, labels=c("NIU","housing","family","work","other"))]

	# some factor codign
	d[,clswkr := relevel(a_clswkr,ref="Private")]
	d[,tenure := as.numeric(h_tenure)]
	d[tenure>2, tenure := 3]
	d[,tenure := factor(tenure,labels=c("own","rent"))]
	d[,tenure := relevel(tenure,ref="rent")]
	d[,age2 := a_age^2]
	d[,educ := as.numeric(a_hga)]
	d[educ<10,educ := 1]
	d[educ %in% 10:12,educ := 2]
	d[educ>12,educ := 3]
	d[,educ := factor(educ,labels=c("no.HS","some.college","college"))]
	setnames(d,c("a_age","hh5to18"),c("age","numkids"))

	# create a dummy for cross state move
	d[, S2S.move := mig_mtr3 %in% c("Different state, same division","Different division, same region","Different region")]

	# encode race
	d[,race := prdtrace]
	d[race>9,race:=9]
	d[,race := factor(race,labels=c("white","black","american.indian","asian","hawaian","white-black","white-AI","white-asian","other"))]

	return(d)
}


tabfun <- function(yr,des){

	tabs <- list()

	# 1) did move at all?
	# notice that tenure is CURRENT tenure. 
	# those stats tell you how many migrants ended up as owners, not how many owners migrated.
		tabs$mv1 <- data.frame(svytable(formula=~migsame, des$des[[yr]],N=100,exclude="NIU"))
	names(tabs$mv1) <- c("same address last year?","Percent")

	# 2) did move to another state?
	tabs$mv2 <- data.frame(svytable(formula=~mig_mtr3, des$des[[yr]],N=100,exclude="Not in universe (children under"))
	names(tabs$mv2) <- c("where did you move?","Percent")

	tabs$mv2a <- data.frame(svytable(formula=~S2S.move, des$des[[yr]],N=100,exclude="Not in universe (children under"))
	names(tabs$mv2a) <- c("Did you move to another state?","Percent")

	# 3)for all X state movers, what was main reason for moving ?
	tabs$mv3 <- data.frame(round(svytable(~nxtresf, des$desmv.st[[yr]], N=100),1))
	names(tabs$mv3) <- c("main reason for moving","Percent")
	tabs$mv3 <- tabs$mv3[order(tabs$mv3$Percent,decreasing=TRUE),]

	# 4) aggregated up of 3)
	tabs$mv4 <- data.frame(round(svytable(~main.reason, des$desmv.st[[yr]], N=100),1))
	names(tabs$mv4) <- c("main reason for moving","Percent")
	tabs$mv4 <- tabs$mv4[order(tabs$mv4$Percent,decreasing=TRUE),]

	return(tabs)

}

CPS.makeDesign <- function(d){

	yrs <- d[,unique(h_year)]

	# caution here! can only take one year at a time!
	# the weights are wrong if you pool all years together!
	des      <- lapply(d[,unique(h_year)], function(x) svydesign(ids=~1,weights=~fsup_wgt,data=d[h_year==x]))
	names(des) <- paste0("year",d[,unique(h_year)])
	desmv    <- lapply(des,function(x) subset(x,as.numeric(migsame)==3))		# mover sample
	desmv.st <- lapply(des,function(x) subset(x,S2S.move==TRUE))		# mover sample across state

	return(list(des=des,desmv.st=desmv.st))

}

# combine tables in to year by year tables
CPS.makeTabs <- function(tlist){

	tabs <- list()
	tabs$mv1 <- tlist[[1]]$mv1
	tabs$mv2 <- tlist[[1]]$mv2
	tabs$mv3 <- tlist[[1]]$mv2a
	tabs$mv4 <- tlist[[1]]$mv3
	tabs$mv5 <- tlist[[1]]$mv4

	for (i in 2:length(tlist)) {

		tabs$mv1 <- cbind(tabs$mv1,tlist[[i]]$mv1$Percent)
		tabs$mv2 <- cbind(tabs$mv2,tlist[[i]]$mv2$Percent)
		tabs$mv3 <- cbind(tabs$mv3,tlist[[i]]$mv2a$Percent)
		tabs$mv4 <- cbind(tabs$mv4,tlist[[i]]$mv3$Percent)
		tabs$mv5 <- cbind(tabs$mv5,tlist[[i]]$mv4$Percent)

	}
	return(tabs)
}

CPS.print.tabs <- function(tabs,path="~/Dropbox/mobility/output/data/CPS",which.year=2013){
	# which year?
	
	yrs=2003:2013
	names(tabs$mv1)[-1] <- paste0("percent.",yrs)
	names(tabs$mv2)[-1] <- paste0("percent.",yrs)
	names(tabs$mv3)[-1] <- paste0("percent.",yrs)
	names(tabs$mv4)[-1] <- paste0("percent.",yrs)
	names(tabs$mv5)[-1] <- paste0("percent.",yrs)

	for (yr in which.year){
		yrnm <- paste0(which.year,".tex")

		print(xtable(tabs$mv1[,c(1,which(names(tabs$mv1)==paste0("percent.",which.year)))],align=c("rr|r")),file=file.path(path,paste0("mv1_",yrnm)),floating=FALSE,booktabs=TRUE,include.rownames=FALSE)
		print(xtable(tabs$mv2[,c(1,which(names(tabs$mv2)==paste0("percent.",which.year)))],align=c("rr|r")),file=file.path(path,paste0("mv2_",yrnm)),floating=FALSE,booktabs=TRUE,include.rownames=FALSE)
		print(xtable(tabs$mv3[,c(1,which(names(tabs$mv3)==paste0("percent.",which.year)))],align=c("rr|r")),file=file.path(path,paste0("mv3_",yrnm)),floating=FALSE,booktabs=TRUE,include.rownames=FALSE)
		print(xtable(tabs$mv4[,c(1,which(names(tabs$mv4)==paste0("percent.",which.year)))],align=c("rr|r")),file=file.path(path,paste0("mv4_",yrnm)),floating=FALSE,booktabs=TRUE,include.rownames=FALSE)
		print(xtable(tabs$mv5[,c(1,which(names(tabs$mv5)==paste0("percent.",which.year)))],align=c("rr|r")),file=file.path(path,paste0("mv5_",yrnm)),floating=FALSE,booktabs=TRUE,include.rownames=FALSE)
	}

}

# plot over time
CPS.plot.tabs <- function(tabs,path="~/Dropbox/mobility/output/data/CPS"){
	
	yrs=2003:2013
	names(tabs$mv1)[-1] <- yrs
	names(tabs$mv2)[-1] <- yrs
	names(tabs$mv3)[-1] <- yrs
	names(tabs$mv4)[-1] <- yrs
	names(tabs$mv5)[-1] <- yrs

	m <- lapply(tabs,melt)
	names(m[[1]]) <- c("same.address","year","percent")
	names(m[[2]]) <- c("moved.where","year","percent")
	names(m[[3]]) <- c("moved.state","year","percent")
	names(m[[4]]) <- c("moved.reason","year","percent")
	names(m[[5]]) <- c("moved.reason","year","percent")

	p <- list()
	p[[1]] <- ggplot(m[[1]],aes(x=year,y=percent,group=same.address,color=same.address)) + geom_line() 
	p[[2]] <- ggplot(subset(m[[2]],moved.where!="Nonmover"),aes(x=year,y=percent,group=moved.where ,color=moved.where )) + geom_line()
	p[[3]] <- ggplot(subset(m[[3]],moved.state==TRUE),aes(x=year,y=percent,group=moved.state ,color=moved.state )) + geom_line()
	p[[4]] <- ggplot(m[[4]],aes(x=year,y=percent,group=moved.reason,color=moved.reason)) + geom_line()
	p[[5]] <- ggplot(m[[5]],aes(x=year,y=percent,group=moved.reason,color=moved.reason)) + geom_line()

	pdf(file.path(path,"reasons-over-time.pdf"))
	print(p)
	dev.off()

	return(p)

}
