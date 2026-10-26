#Q1 (a,c)
set.seed(1065)
N <- c(10, 100, 1000, 10000)
unif_mean <- numeric(length(N))
unif_var <- numeric(length(N))
par(mfrow = c(2,2))
for (i in seq_along(N)) {
  unif_sample <- runif(N[i], min=0, max=1)
  unif_mean[i] <- mean(unif_sample)
  unif_var[i] <- var(unif_sample)

  bins <- min(N[i], 50)
  unif_breaks <- seq(0, 1, length.out = bins)

  hist(
    unif_sample,
    breaks = unif_breaks,
    probability = TRUE,
    main = paste("Uniform Sample: N =", N[i]),
    col = "lightblue",
    border = "white",

  )
  x_unif <- seq(0, 1, length.out = 100)
  lines(x_unif, dunif(x_unif), col = "red", lwd = 2)
}
unif_results <- data.frame(N, unif_mean, unif_var)
print(unif_results)

#Q1 (b,c)
normal_mean <- numeric(length(N))
normal_var <- numeric(length(N))
par(mfrow = c(2,2))
for (i in seq_along(N)) {
  normal_sample <- rnorm(N[i], mean=0, sd=1)
  normal_mean[i] <- mean(normal_sample)
  normal_var[i] <- var(normal_sample)

  hist(
    normal_sample,
    breaks = min(N[i], 50),
    probability = TRUE,
    main = paste("Normal Sample: N =", N[i]),
    xlab = "x",
    xlim = c(-4, 4),
    col = "lightblue",
    border = "white",

  )
  x_normal <- seq(-4, 4, length.out = 100)
  lines(x_normal, dnorm(x_normal), col = "red", lwd = 2)
}
normal_results <- data.frame(N, normal_mean, normal_var)
print(normal_results)


#Q2
LCG = function(N, a, c, m, x0){
  x = numeric(N+1)
  x[1] = x0
  for(i in 1:N){
    x[i+1] = (a * x[i] + c) %% m
  }
  u = x/m
  return(u[-1])
}

par(mfrow=c(1,1))
rv = LCG(10000, 1+4*5673869, 1, 2^32, 1)
mean(rv)
dens = density(rv)
plot(dens$x, dens$y, type='l')
hist(rv, breaks=15, prob=TRUE)
lines(dens$x, dens$y, col='red', lwd=2)

#Q3
ChiTest = function(N, sample, alpha) {
  bins = seq(0, 1, 1/N)
  observed = hist(sample, breaks=bins, plot=FALSE)$counts
  expected = rep(length(sample)/N, N)
  T = sum((observed - expected)^2 / expected)
  deg_freedom = N - 1
  critical_value = qchisq(alpha, df=deg_freedom)
  p_value = 1 - pchisq(T, df=deg_freedom)
  if (T>critical_value) {
    decision = "Reject H0"
  } else {
    decision = "Do not reject H0"
  }
  return(list(
    decision = decision,
    test_statistic = T,
    p_value = p_value
  ))
}

ChiTest(15, rv, 0.95)

n_samples <- 2000
sample_size <- 500
n_bins <- 10
confidence_level <- 0.95
a <- 1+4*5673869
c <- 1
m <- 2^32
x0 <- 12345

lcg_sequence <- LCG(n_samples * sample_size, a, c, m, x0)
lcg_samples <- matrix(
  lcg_sequence, 
  nrow = n_samples, 
  ncol = sample_size, 
  byrow = TRUE
)

test_decisions <- character(n_samples)
test_statistics <- numeric(n_samples)

for (i in 1:n_samples) {
  test_result <- ChiTest(
    n_bins, 
    lcg_samples[i, ], 
    confidence_level
  )
  test_decisions[i] <- test_result$decision
  test_statistics[i] <- test_result$test_statistic
}

n_rejected <- sum(test_decisions == "Reject H0")
percentage_rejected <- (n_rejected / n_samples) * 100

rep_summary <- data.frame(
  n_samples = n_samples,
  sample_size = sample_size,
  n_bins = n_bins,
  confidence_level = confidence_level,
  n_rejected = n_rejected,
  percentage_rejected = percentage_rejected
)

print("Repeated chi-squared test results")
print(rep_summary)
print("At 95% confidence level, approximately 5% rejections expected")
