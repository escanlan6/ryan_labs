#Q1
A = matrix(c(3,5,0,2), nrow=2)
B = matrix(c(1,4,4,7), nrow=2)

#a
A + B
#b
A - B
#c
A %*% B
#d
A %*% solve(B)
#e
A %*% solve(B)
#f
solve(A, B)
#g
A * B
#h
A / B

#Q2
A = matrix(c(1,2,1,4,4,6,3,13,3,8,4,15,7,3,5,15), nrow=4)
qr(A)$rank

#Q3
A = matrix(c(1,2,1,2,4,6,3,1,3,8,4,7,7,3,5,6), nrow=4)
a = matrix(c(14,8,10,18), nrow=4)
solve(A, a)

#Q4
set.seed(6354)
A = matrix(runif(16), nrow=4)
sum(diag(A))
det(A)
ev = eigen(A)$values

#Q5
x = seq(-6, 121, by=1)
y = seq(-6, 120, by=2)
z = 2^(seq(1, 7, by=1))

#Q6
A = matrix(0, nrow=5, ncol=6)
for (row in 1:nrow(A)) {
  for (col in 1:ncol(A)) {
    if (row - col == 0) {
      A[row,col] = -8
    }
    else if (abs(row - col) == 1) {
      A[row,col] = 3
    }
  }
}

#Q7
x = seq(0,6,0.01)
y1 = sin(x)
y2 = cos(x)
df <- data.frame(x,y1,y2)

install.packages("ggplot2")
library(ggplot2)
require(ggplot2)
ggplot(df, aes(x=x)) +                    
  geom_line(aes(y=y1), colour="blue") +  
  geom_line(aes(y=y2), colour="orange", linetype="dashed")+
  annotate("text", x = 5, y = 0.9, label = "sin(x)", colour = "blue")+
  annotate("text", x = 5, y = 0.7, label = "cos(x)", colour = "red")

#Q8
x<-runif(1000)
y<-(x<=0.4)*1
mean(y)

#Q9
x <-rbinom(1000,1,0.5)
mean(x)

#Q10
x<-runif(50)
y<-(x<=0.2)*1
mean(y)

#Q11
x<-runif(1)
if(x<=0.35){
  y<-1
}else if(x>0.35 & x<=0.5){
  y<-2
}else if(x>0.5 & x<=0.9){
  y<-3
}else{
  y<-4
}

#Q12
x<-runif(1)
y = -log(1-x)

#Q13
U<-matrix(runif(10000,0,1),nrow=2)
dataset<-matrix(0, nrow = 2, ncol = 5000)
dataset[1,]<-sqrt(-2*log(U[1,]))*cos(2*pi*U[2,])
dataset[2,]<-sqrt(-2*log(U[1,]))*sin(2*pi*U[2,])
hist(dataset[1,])
var(dataset[1,])
hist(dataset[2,])
var(dataset[2,])