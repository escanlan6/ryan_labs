#Q1 Cauchy Distribution
#Q1(a) Compute the inverse distribution function

# Cauchy distribution (pdf): f(x) = 1 / (pi * (1 + x^2))
# pdf to cdf: integrate f(x) from -inf to x
# 1 / pi * integral 1 / (1 + t^2) dt = 1 / pi * arctan(t) {from -inf to x}
# = 1 / pi * (arctan(x) - arctan(-inf)) = 1 / pi * (arctan(x) + pi/2) = 1/2 + arctan(x)/pi
# CDF: F(x) = 1/2 + arctan(x)/pi

# set cdf = u, solve for x
# u = 1/2 + arctan(x)/pi => u - 1/2 = arctan(x)/pi = pi * (u - 1/2) = arctan(x)
# x = tan(pi * (u - 1/2))

inverse_cauchy <- function(u) {
  return(tan(pi * (u - 1/2)))
}

#Q1(b) Generate Cauchy randon numbers and show CLT doesn't hold (the mean and variance are undefined)
sample_size <- 500
replications <- c(10, 100, 1000, 10000)
par(mfrow = c(2, 2))
set.seed(2025)
for (i in seq_along(replications)) {
  M <- replications[i]
  samples <- matrix(runif(M * sample_size), nrow = M, ncol = sample_size)
  cauchy_samples <- inverse_cauchy(samples)

  sample_means <- rowMeans(cauchy_samples)
  empirical_density <- density(sample_means, from = -10, to = 10, n = 1000)

  fitted_mean <- mean(sample_means)
  fitted_sd <- sd(sample_means)
  fitted_normal <- dnorm(empirical_density$x, mean = fitted_mean, sd = fitted_sd)

  plot(
    empirical_density$x,
    empirical_density$y,
    type = "l",
    lwd = 2,
    col = "blue",
    xlim = c(-10, 10),
    ylim = c(0, max(empirical_density$y, fitted_normal)),
    main = paste("Replications =", M),
    xlab = "Sample mean",
    ylab = "Density"
  )

  lines(empirical_density$x, fitted_normal, col = "red", lwd = 2, lty = 2)
}


#Q2 Monte Carlo Method
# General Monte Carlo function
MonteCarlo <- function(samples, A, confidence = 0.95) {
  # Sample size
  n <- length(samples)
  
  # Apply A(x) to the simulated observations
  Y <- A(samples)
  
  # Monte Carlo estimate
  # mu_hat = (1/n) sum A(X_i)
  estimate <- mean(Y)
  
  # Estimated standard deviation of A(X)
  sd_est <- sd(Y)
  
  # Standard error
  standard_error <- sd_est / sqrt(n)
  
  # z value for chosen confidence level
  alpha <- 1 - confidence
  z <- qnorm(1 - alpha / 2)
  
  # Practical confidence interval for the true expectation
  CI_lower <- estimate - z * standard_error
  CI_upper <- estimate + z * standard_error
  
  return(
    c(
      estimate = estimate,
      sd = sd_est,
      SE = standard_error,
      CI_lower = CI_lower,
      CI_upper = CI_upper
    )
  )
}

#Q2(a): Interpret integral I1
# I1 = integral from 0 to inf of x * e^-x dx
# Density of exponential distribution: f(x) = lambda * exp(-lambda * x) for x >= 0
# Y ~ Exp(lambda)
# E[G[Y]] = integral from 0 to inf of G(x) * f(x) = G(x) * lambda * exp(-lambda * x)
# To have I1 = E[G[Y]], we need G(x) * lambda * exp(-lambda * x) = x * exp(-x)
# Set lambda = 1, then G(x) = x, so I1 = E[Y] where Y ~ Exp(1)
A1 <- function(x) {
  return(x)
}

#Q2(b): Give an asymptotic 95% confidence interval for the MC estimate
set.seed(2025)
n <- 10000
x <- rexp(n, rate = 1)
result_I1 <- MonteCarlo(x, A1, confidence = 0.95)
print(result_I1)

# Theoretical values: mu = 1, sigma = 1
mu1 <- 1
sigma1 <- 1

# Theoretical 95% interval for the Monte Carlo estimator:
# mu +/- 1.96 sigma / sqrt(n)

z <- qnorm(0.975)
theoretical_lower <- mu1 - z * sigma1 / sqrt(n)
theoretical_upper <- mu1 + z * sigma1 / sqrt(n)
c(
  theoretical_lower = theoretical_lower,
  theoretical_upper = theoretical_upper
)

par(mfrow = c(2,2))
set.seed(2025)
sample_sizes <- seq(1000, 100000, by = 1000)

# Storage
Q2_results <- matrix(NA, nrow = length(sample_sizes), ncol = 5)

colnames(Q2_results) <- c(
  "estimate",
  "sd",
  "SE",
  "CI_lower",
  "CI_upper"
)

#Q2(c): Repeat Monte Carlo experiment
for (i in seq_along(sample_sizes)) {
  n <- sample_sizes[i]
  # Generate sample
  X <- rexp(n, rate = 1)
  # Calculate estimate and confidence interval
  Q2_results[i, ] <- MonteCarlo(X, A1, 0.95)
}

# Plot 1: Monte Carlo estimate versus sample size
plot(
  sample_sizes,
  Q2_results[, "estimate"],
  type = "l",
  col = "blue",
  lwd = 2,
  xlab = "Sample size",
  ylab = "Monte Carlo estimate",
  main = "Monte Carlo Estimate of I1"
)

abline(h = mu1, col = "red", lwd = 2, lty = 2)

# Plot 2: Estimated SD versus theoretical SD
plot(
  sample_sizes,
  Q2_results[, "sd"],
  type = "l",
  col = "blue",
  lwd = 2,
  xlab = "Sample size",
  ylab = "Estimated standard deviation",
  main = "Estimated SD"
)

abline(h = sigma1, col = "red", lwd = 2, lty = 2)

# Plot 3: Practical confidence interval
plot(
  sample_sizes,
  Q2_results[, "CI_upper"],
  type = "l",
  col = "blue",
  lwd = 2,
  ylim = range(
    Q2_results[, "CI_lower"],
    Q2_results[, "CI_upper"]
  ),
  xlab = "Sample size",
  ylab = "95% confidence interval",
  main = "95% Confidence Interval for I1"
)

lines(sample_sizes, Q2_results[, "CI_lower"], col = "blue", lwd = 2)

abline(h = mu1, col = "red", lwd = 2, lty = 2)

#Q2(d): Repeat the entire Monte Carlo experiment many times.
# For a 95% CI, approximately 95% of intervals should
# contain the true value mu = 1.
set.seed(2025)
trials <- 1000
sample_size <- 1000
contains_true_value <- logical(trials)

for (j in 1:trials) {
  X <- rexp(sample_size, rate = 1) 
  result <- MonteCarlo(X, A1, confidence = 0.95)
  contains_true_value[j] <- result["CI_lower"] <= mu1 && mu1 <= result["CI_upper"]
}

coverage_probability <- mean(contains_true_value)
print(coverage_probability)
coverage_percentage <- 100 * coverage_probability

print(paste("Empirical coverage =", round(coverage_percentage, 2), "%"))
# We expect approximately 95%.


#Q3
#I2 = integral from 1 to 8 ((x^7 -3x^2) * (e^(4-sqrt(x))) * sin^2(x)) / (x-1/2)
# Since the integral has finite limits, the simplest choice is to use a uniform distribution on [1, 8]
# The pdf of a uniform random variable on [a, b] is 1 / (b - a)
# For I2, the pdf (f_X(x)) is 1 / (8 - 1) = 1 / 7 for x in [1, 8]
# Let f(x) = ((x^7 -3x^2) * (e^(4-sqrt(x))) * sin^2(x)) / (x-1/2)
# Since pdf is 1 / 7, A(x) = 7 * f(x)

f <- function(x) {
  return(((x^7 - 3 * x^2) * (exp(4 - sqrt(x))) * sin(x)^2) / (x - 1/2))
}

A2 <- function(x) {
  return(7 * f(x))
}

#Q3(a): MCE of I2
set.seed(2025)
n <- 10000
# Generate Uniform(1,8) observations
X <- runif(n, min = 1, max = 8)
# Monte Carlo estimate
result_I2 <- MonteCarlo(X, A2, confidence = 0.95)
print(result_I2)

#Q3(b): Give an asymptotic 95% confidence interval for the MC estimate
# Theoretical value of the integral
mu2 <- integrate(f, lower = 1, upper = 8)$value
print(mu2)

# Theoretical variance and 95% CI
# Var[A(X)] = E[A(X)^2] - (E[A(X)])^2
# E[A(X)^2] = integral from 1 to 8 of A(x)^2 * f_X(x) dx

EA2 <- integrate(function(x) A2(x)^2 * (1/7), lower = 1, upper = 8)$value

Var_A2 <- EA2 - mu2^2
sigma2 <- sqrt(Var_A2)

print(
c(
    true_integral = mu2,
    theoretical_sd = sigma2
  )
)

# Theoretical 95% interval for estimator
theoretical_Q3_CI <- c(
  mu2 - z * sigma2 / sqrt(n),
  mu2 + z * sigma2 / sqrt(n)
)
print(theoretical_Q3_CI)

#Q3(c): Repeat for different sample sizes and plot the results
par(mfrow = c(2,2))
set.seed(2025)
sample_sizes <- seq(1000, 100000, by = 1000)

# Storage
Q3_results <- matrix(NA, nrow = length(sample_sizes), ncol = 5)

colnames(Q3_results) <- c(
  "estimate",
  "sd",
  "SE",
  "CI_lower",
  "CI_upper"
)

# Repeat Monte Carlo experiment
for (i in seq_along(sample_sizes)) {
  n <- sample_sizes[i]
  # Generate sample
  X <- runif(n, min = 1, max = 8)
  # Calculate estimate and confidence interval
  Q3_results[i, ] <- MonteCarlo(X, A2, 0.95)
}

# Plot 1: Monte Carlo estimate versus sample size
plot(
  sample_sizes,
  Q3_results[, "estimate"],
  type = "l",
  col = "blue",
  lwd = 2,
  xlab = "Sample size",
  ylab = "Monte Carlo estimate",
  main = "Monte Carlo Estimate of I2"
)

abline(h = mu2, col = "red", lwd = 2, lty = 2)

# Plot 2: Estimated SD versus theoretical SD
plot(
  sample_sizes,
  Q3_results[, "sd"],
  type = "l",
  col = "blue",
  lwd = 2,
  xlab = "Sample size",
  ylab = "Estimated standard deviation",
  main = "Estimated SD"
)

abline(h = sigma2, col = "red", lwd = 2, lty = 2)

# Plot 3: Practical confidence interval
plot(
  sample_sizes,
  Q3_results[, "CI_upper"],
  type = "l",
  col = "blue",
  lwd = 2,
  ylim = range(
    Q3_results[, "CI_lower"],
    Q3_results[, "CI_upper"]
  ),
  xlab = "Sample size",
  ylab = "95% confidence interval",
  main = "95% Confidence Interval for I2"
)

lines(sample_sizes, Q3_results[, "CI_lower"], col = "blue", lwd = 2)

abline(h = mu2, col = "red", lwd = 2, lty = 2)