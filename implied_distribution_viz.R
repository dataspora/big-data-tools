## a script visualize binomial distributions
## see code at bottom for running

## some tests of the binomial dist
ix <- 426
cx <- 8

iy <- 475
cy <- 12

## plot theta from 0.00 to 0.10
th <- seq(0,0.1,0.001)

## alternative
th <- seq(0.05,0.06,0.001)
plot(th,dbeta(th,cx,ix-cx),type='l')
points(th,dbeta(th,cy,iy-cy),type='l',col='red')

## the beta pdf and cdf functions
pdfx <- function(th) { dbeta(th,cx,ix-cx) }
pdfy <- function(th) { dbeta(th,cy,iy-cy) }
cdfx <- function(th) { pbeta(th,cx,ix-cx) }
cdfy <- function(th) { pbeta(th,cy,iy-cy) }

## now test them
th <- seq(0,0.10,0.001)
plot(th,cdfx(th),type='l')
points(th,cdfy(th),type='l',col='red')

## define their joint product as a function
jointxy <- function(th) { betax(th) * betay(th) }

## ratio
x <- function(th) { dbeta(th,cx,ix-cx) }
y <- function(th) { dbeta(th,cy,iy-cy) }

xory <- function(th) { pmax(x(th),y(th)) }
xy <- function(th) { pmin(x(th),y(th)) }

## confidence for that the larger is larger
## beta functions defined on the [0,1] interval
conf <- function(ix,cx,iy,cy) {

  x <- function(th) { dbeta(th,cx,ix-cx) }
  y <- function(th) { dbeta(th,cy,iy-cy) }
  ## traces the minimum at each point
  ## in the interval, representing the intersection
  xy <- function(th) { pmin(x(th),y(th)) }
  isect <- integrate(xy,0,1)
  p <- 1 - isect$value
  return(p)
} 

plot.conf <- function(ix,cx,iy,cy) {
  ## give an informative prior of a beta(1,20) distribution
  ## this also alleviates no data issue
  cp <- 1  ## 
  ip <- 20 ## 

  ## beta dist parameters, update the prior
  bx1 <- cp+cx
  bx2 <- ip+ix-cx
  by1 <- cp+cy
  by2 <- ip+iy-cy
    
  x <- function(th) { dbeta(th,bx1,bx2) }
  y <- function(th) { dbeta(th,by1,by2) }

  ## par(mfrow(2,1))
  colx <- '#00006688'  ## RGB values w/ alpha transparency
  coly <- '#88000088'
  colxy <-'#7F434A'

  upper <- 0.95 # upper quantile to capture
  hi <- max(qbeta(upper,bx1,bx2),qbeta(upper,by1,by2))
  th <- seq(0,hi,length.out=500)
  yhi <- max(x(th),y(th))

  plot(c(0,hi),c(0,yhi),type='n',
       xlab='CTR implicit spread',
       ylab='likelihood')

  ## add shading
  polygon(c(0,th,hi),c(0,x(th),0),col=colx,lty=0)
  ## points(th,y(th),type='l',col='880000')
  polygon(c(0,th,hi),c(0,y(th),0),col=coly,lty=0)
  ## traces the minimum at each point
  ## in the interval, representing the intersection
  xy <- function(th) { pmin(x(th),y(th)) }
  ## plot(th,xy(th))
  isect <- integrate(xy,0,1)
  p <- 1-isect$value

  xctr <- format(100*cx/ix,digits=2,nsmall=2)
  yctr <- format(100*cy/iy,digits=2,nsmall=2)
  pstr <- round(100*p)

  lstr <- c(paste(xctr,'% ctr (',cx,' out of ',ix,')',sep=''),
            paste(yctr,'% ctr (',cy,' out of ',iy,')',sep=''),
            paste(pstr,'% confidence of difference'))
  legend("topleft", lstr, pch=15, col=c(colx,coly,colxy),
         cex=0.5,
         inset = .02,
         box.lwd = 0)
  return(p)
}

## plot a series of these graphs

outfile <- 'implied_distribution_viz.pdf'
pdf(outfile,version = "1.1",paper="letter")
par(mfrow=c(2,2))
plot.conf(3282,36,2642,26)
plot.conf(426,8,475,12)
plot.conf(739,8,709,5)
plot.conf(162,7,739,18)
plot.conf(78,8,56,4)
plot.conf(2152,15,1238,4)
plot.conf(394,7,51,0)
plot.conf(54,1,117,0)
dev.off()

