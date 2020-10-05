# simple bootstrap sparse Matrices containing integer values.

edgeSamp = function(A,q, inflate = 1){
  # returns Atest, using epsilon computed with q.
  #  you can set inflate.  Should be either 1 or greater than 1. 
  #  epsilon is made to be defaultEpsilon * inflate. 
  n = nrow(A)
  epsilon = n^(-1) *(2 *log(2*q) + 10 *log(2 *log(n)))*inflate
  
  TT = as(A, "dgTMatrix")
  AtestX= rbinom(length(A@x), A@x, prob=epsilon)
  # el = cbind(, j= , x = )
  Atest = spMatrix(nrow(A), ncol(A), i= TT@i[AtestX>0]+1, j= TT@j[AtestX>0] +1, x= AtestX[AtestX>0])
  rm(TT)
  return(Atest)
}


bootStats = function(Atest, A, rowFactor, colFactor){
  q = ncol(rowFactor)
  n = nrow(A)
  dat  = matrix(NA, nrow = q, ncol = 3)
  for(j in 1:q){
    u = rowFactor[,j]/sqrt(nrow(rowFactor))
    v = colFactor[,j]/sqrt(nrow(colFactor))
    u2 = u^2; v2 = v^2
    epsilon = sum(Atest)/sum(A)
    sig = sqrt(epsilon*t(u2)%*%A%*%v2) %>% as.matrix
    dat[j,] = c(as.matrix(t(u)%*%Atest%*%v), sig, sqrt(max(u2)*max(v2))*log(n)/sig)
  }
  dat
}

edgeBoot = function(A, q){
  Atest = edgeSamp(A,q)
  Afit = A - Atest
  Afit@x = log(Afit@x+1)
  rs=rowSums(Afit)
  cs=colSums(Afit)
  Dr = Diagonal(nrow(Afit), 1/sqrt(rs + mean(rs)))
  Dc = Diagonal(ncol(Afit), 1/sqrt(cs + mean(cs)))
  L = Dr%*%A
  L = L%*%Dc
  s = svds(L, q)
  bootStats(Atest, A, s$u,s$v)
}
# plot(bootStats[,1]/bootStats[,2])


