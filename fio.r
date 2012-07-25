


graphit <- function(m,i_name="undefined",i_users=0,i_bs="undefined") {

  colors <- c(
            "#00007F", # 50u   1 blue
            "#0000BB", # 100u  5
            "#0000F7", # 250u
            "#00ACFF", # 500u  6
            "#00E8FF", # 1ms   7
            "#25FFD9", # 2ms   8
            "#61FF9D", # 4ms   9 
            "#9DFF61", # 10ms  10
            #"#D9FF25", # 10ms  11
            "#FFE800", # 20ms  12 yellow
            "#FFAC00", # 50ms  13 orange
            "#FF7000", # 100ms 14 dark orang
            "#FF3400", # 250ms 15 red 1
            "#F70000", # 500ms 16 red 2
            "#BB0000", # 1s    17 dark red 1
            "#7F0000", # 2s    18 dark red 2
            "#4F0000") # 5s    18 dark red 2

  # transpose input matrix
  tm <- t(m)
  m <-tm

  # add column names to imput matrix
  colnames <- c("name","users","bs","MB","lat","min","max","std","iops",
               "us50","us100","us250","us500","ms1","ms2","ms4","ms10","ms20","ms50","ms100","ms250","ms500","s1","s2","s5")
  colnames(m)=colnames

  #  make the matrix a data.frame
  m <- data.frame(m)

  # rr will be the subset of m that is graphed
  rr <- m ;

  # filter by test name, if no test name make it 8K random read by default
  if ( i_name != "undefined" ) {
    rr <- subset(rr,rr['name'] == i_name )
    cat("rr filtered for name=",i_name,"\n");
    print(rr)
  } else {
    rr <- subset(rr,rr['name'] == "randread" )
    i_bs = "8K"
    cat("no name\n");
  }

  # if i_users > 0 then it's an input value
  # which means users stays constant at I/O sizes, ie i_bs, (block size)
  # changes
  # the title of the different columns will be the different I/O sizes
  if ( i_users > 0 ) {
    rr <- subset(rr,rr['users'] == i_users )
    cat("rr filterd for users=",i_users,"\n");
    print(rr)
  } else {
    cat("no users\n");
  }

  # if i_bs (block size, the I/O request size) is defined then it's an input value
  # which means bs stays constant and the # of users will change
  # the title of the different columns will be the number of users
  if ( i_bs != "undefined" ) {
    rr <- subset(rr,rr['bs'] == i_bs )
    cat("rr filterd for bs=",i_bs,"\n");
    print(rr)
  } else {
    cat("no block sise\n");
  }

  # extract the histogram latency values out of rr
  hist <- cbind(rr['us50'],rr['us100'], rr['us250'],rr['us500'],rr['ms1'],
               rr['ms2'],rr['ms4'],rr['ms10'],rr['ms20'],rr['ms50'],
               rr['ms100'],rr['ms250'],rr['ms500'],rr['s1'],rr['s2'],rr['s5']) 

  # thist is used by the latency graph
  thist  <- t(hist)
  # fhist is used by the MB/s bars
  fhist   <- apply(hist, 1,as.numeric)
  fhist   <- fhist/100
 
  # extract various columns from the data (in rr)
  lat   <- as.numeric(t(rr['lat']))
  users <- as.numeric(t(rr['users']))
  bs    <- as.character(t(rr['bs']))
  min   <- as.numeric(t(rr['min']))
  max   <- as.numeric(t(rr['max']))
  std   <- as.numeric(t(rr['std']))
  MB    <- as.numeric(t(rr['MB']))
  cols  <- 1:length(lat)

  # if users is defined then columns are the block sizes
  if ( i_users > 0 ) {
    titles <- bs 
    cat("users > 0, title are blocksises, titles=",titles,"\n") ;
  }
  # if block size is defined then columns are the user counts
  if ( i_bs != "undefined" ) {
    titles <- users
    cat("bs defined, title are users, title=",titles,"\n") ;
  }

  # create a layout with large squarish graph on top
  # for latency
  # shorter rectangle graph on bottom for MB/s
  nf <- layout(matrix(c(2,1),2,1,byrow = TRUE), widths = 13,
  heights = c(10, 3), respect = TRUE)
  par(mar=c(2, 4, 1, 4))
  layout.show(nf)
  par("pin")
  par(new = FALSE)

  MBbars <- t(t(fhist)*MB)
  colnames(MBbars) = titles

  op <- barplot(MBbars,col=colors,ylab="MB/s",border=NA,space=2)
  text(op, 0,MB,adj=c(0,0),cex=.75)

  par(mar=c(0, 4, 1, 4))

  xmaxwidth <- length(lat)+1
  xminwidth <- .5

  barcol <- "grey90"

  pts <- 1:nrow(thist)
  ylims <-   c(.025,5000)
  for (i in 1:ncol(thist)){
          xmin <-   -i + xminwidth 
          xmax <-   -i + xmaxwidth 
          ser <- as.numeric(thist[, i])
          ser <- ser/100 
          col=ifelse(ser==0,"white","grey") 
          bp <- barplot(ser, horiz = TRUE, axes = FALSE, 
                xlim = c(xmin, xmax), ylim = c(0,nrow(thist)), 
                border = NA, col = colors, space = 0, yaxt = "n")
          par(new = TRUE)
  }

  cat(" --> 1 \n") ;
  
  par(new = TRUE)
  # average latency 
  plot(cols, lat, type = "p", xaxs = "i", lty = 1, col = "black", lwd = 5, bty = "l", ylab = "ms", xlab="size",
       xlim = c(xminwidth,xmaxwidth), ylim = ylims,  log = "y", yaxt = "n" , xaxt ="n") 

  cat(" --> 2 \n") ;
  par(new = TRUE)
  # average latency 
  plot(cols, lat, type = "l", xaxs = "i", lty = 1, col = "black", lwd = 1, bty = "l", 
       xlim = c(xminwidth,xmaxwidth), ylim = ylims, ylab = "" , xlab="",log = "y", yaxt = "n" , xaxt ="n") 
  text(cols,lat,round(lat,1),adj=c(1,2))


  # max latency 
  #par(new = TRUE)
  #plot(cols, max, type = "l", xaxs = "i", lty = 2, col = "red", lwd = 1, bty = "l", 
  #     xlim = c(xminwidth,xmaxwidth), ylim = ylims, ylab = "" , log = "y", xlab="",yaxt = "n" , xaxt ="n") 
  #text(cols,max,round(max,1),adj=c(-1,-1))

  # min latency 
  #par(new = TRUE)
  #plot(cols, pmax(min,0.1), type = "l", xaxs = "i", lty = 2, col = "green", lwd = 1, bty = "l", 
  #     xlim = c(xminwidth,xmaxwidth), ylim = ylims, ylab = "" , log = "y", yaxt = "n" , xlab="",xaxt ="n") 
  #text(cols,min,round(min,1),adj=c(-1,-1))


  ypts  <- c(.05,.100,.250,.500,1,2,4,10,20,50,100,200,500,1000,2000,5000) 
  ylbs=c("us50","us100","us250","us500","ms1","ms2","ms4","ms10","ms20","ms50","ms100","ms200","ms500","s1","s2","s5" )
  axis(4,at=ypts, labels=ylbs,las=1,cex.axis=.75,lty=0,lwd=0)

  ypts  <- c(.05,.250,.500,2,4,20,50,200,500,2000) 
  ylbs=c(".05",".25",".5","2","4","20","50","200","500","s2" )

  ypts  <-  c(0.100,    1,       10,    100,  1000, 5000);
  ylbs  <-  c("100u"   ,"1m",  "10m", "100m",  "1s","5s");
  axis(2,at=ypts, labels=ylbs)


  cat(" --> 3 \n") ;
  for ( i in  c(10)  )  {
     segments(0,   i, xmaxwidth,  i,  col="orange",   lwd=1,lty=2)
  }

  #for ( i in  c(.05,.100,.250,.500,1,2,4,10,20,50,100,200,500,1000,2000,5000)  )  {
  #    segments(0,   i, xmaxwidth,  i,    lwd=1,lty=2, col= "lightpink")
  # }

}


m <- NULL
m <- matrix(c(
    "read",  1,  "8K",   2.501,    3.119, 0.1,      429,   16.6,  320 , 0, 0,66,16, 6, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0, 0
,    "read",  1, "32K",  38.132,    0.815, 0.3,       70,    2.5, 1220 , 0, 0, 0,87, 6, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0
,    "read",  1,"128K",  66.630,    1.871, 0.7,       32,    2.5,  533 , 0, 0, 0, 0,21,62, 4, 8, 2, 0, 0, 0, 0, 0, 0, 0
,    "read",  1,  "1M",  78.090,   12.800, 2.0,      163,   11.5,   78 , 0, 0, 0, 0, 0, 0, 7,56,23,12, 1, 0, 0, 0, 0, 0
,    "read",  8,  "1M",  50.055,   79.700, 3.0,      622,   70.0,   50 , 0, 0, 0, 0, 0, 0, 0, 1, 3,33,37,19, 2, 0, 0, 0
,    "read", 16,  "1M",  52.626,  151.380, 4.0,     1305,  183.6,   52 , 0, 0, 0, 0, 0, 0, 0, 1, 1,20,31,29, 8, 5, 0, 0
,    "read", 32,  "1M",  59.360,  265.810, 4.0,     1465,  364.4,   59 , 0, 0, 0, 0, 0, 0, 0, 7, 3,16,22,23, 9, 8, 8, 0
,    "read", 64,  "1M",  57.549,  548.180, 4.0,     1453,  540.0,   57 , 0, 0, 0, 0, 0, 0, 0, 5, 3,11,15,10,11, 9,32, 0
,"randread",  1,  "8K",   1.721,    4.530, 1.0,       26,    1.8,  220 , 0, 0, 0, 0, 0, 2,36,60, 0, 0, 0, 0, 0, 0, 0, 0
,"randread",  8,  "8K",   3.061,   20.390, 2.0,      260,   20.5,  391 , 0, 0, 0, 0, 0, 0, 1,34,31,26, 5, 0, 0, 0, 0, 0
,"randread", 16,  "8K",   3.434,   36.330, 2.0,      818,   66.1,  439 , 0, 0, 0, 0, 0, 0, 1,28,27,26, 9, 4, 1, 0, 0, 0
,"randread", 32,  "8K",   3.678,   67.660, 1.0,      859,  137.3,  470 , 0, 0, 0, 0, 0, 0, 1,29,22,22,10, 5, 3, 4, 0, 0
,"randread", 64,  "8K",   3.784,  131.150, 2.0,      876,  187.7,  484 , 0, 0, 0, 0, 0, 0, 1,19,17,16,11,15, 8, 9, 0, 0
,   "write",  1,  "1K",   2.956,    0.325, 0.2,       75,    0.8, 3027 , 0, 0,58,29,12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
,   "write",  1,  "8K",  11.582,    0.670, 0.2,      197,    3.8, 1482 , 0, 0, 0,94, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0
,   "write",  1,"128K",  17.163,    7.278, 0.7,      752,   24.4,  137 , 0, 0, 0, 0,55, 8, 2,15, 8, 6, 1, 0, 0, 0, 0, 0
,   "write",  4,  "1K",   3.742,    0.517, 0.2,      185,    2.0, 3832 , 0, 0,26,45,19, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
,   "write",  4,  "8K",   7.912,    1.970, 0.2,      321,    7.4, 1012 , 0, 0, 1,54,30, 0, 0, 9, 1, 1, 0, 0, 0, 0, 0, 0
,   "write",  4,"128K",  19.652,   12.714, 0.6,      148,   18.4,  157 , 0, 0, 0, 0, 3,29,15,18,13,14, 5, 0, 0, 0, 0, 0
,   "write", 16,  "1K",   7.818,    0.995, 0.2,      923,    5.8, 8006 , 0, 0, 0,19,57,19, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0
,   "write", 16,  "8K",  12.764,    4.889, 0.3,      438,   16.8, 1633 , 0, 0, 0, 7,32,36, 1,13, 3, 3, 1, 0, 0, 0, 0, 0
,   "write", 16,"128K",  28.360,   35.184, 0.8,      262,   33.2,  226 , 0, 0, 0, 0, 0, 1, 7,11,16,41,16, 5, 0, 0, 0, 0
),nrow=25)


# graphit <- function(m,i_name="undefined",i_users=0,i_bs="undefined") {

#graphit(i_m, i_name="randread", i_bs="8K")
#graphit(i_m, i_name="write", i_bs="1K")
#graphit(i_m, i_name="write", i_bs="8K")
#graphit(i_m, i_name="write", i_bs="1K")
#graphit(i_m, i_name="write", i_users=1")
#graphit(i_m, i_name="randread", i_bs="8K")

