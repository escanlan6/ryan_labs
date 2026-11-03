#Q1 Cauchy Distribution
# Cauchy distribution (pdf): f(x) = 1 / (pi * (1 + x^2))
# pdf to cdf: integrate f(x) from -inf to x
# 1 / pi * integral 1 / (1 + t^2) dt = 1 / pi * arctan(t) {from -inf to x}
# = 1 / pi * (arctan(x) - arctan(-inf)) = 1 / pi * (arctan(x) + pi/2) = 1/2 + arctan(x)/pi
# CDF: F(x) = 1/2 + arctan(x)/pi

# set cdf = u, solve for x
# u = 1/2 + arctan(x)/pi = u + 1/2 = arctan(x)/pi = pi * (u - 1/2) = arctan(x)
# x = tan(pi * (u - 1/2))

inverse_cauchy <- function(u) {
  return(tan(pi * (u - 1/2)))
}

sample_size <- 500
replications <- c(10, 100, 1000, 10000)
par(mfrow = c(2, 2))
set.seed(1065)
for (i in seq_along(replications)) {
  M <- replications[i]
  samples <- matrix(runif(M * sample_size), nrow = M, ncol = sample_size)
  cauchy_samples <- inverse_cauchy(samples)

  sample_means <- rowMeans(cauchy_samples)
  empirical_density <- density(sample_means, from = -10, to = 10, n = 1000)

  fitted_mean <- mean(sample_means)
  fitted_sd <- sd(sample_means)
  fitted_normal <- dnorm(
    empirical_density$x,
    mean = fitted_mean,
    sd = fitted_sd
  )
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

  lines(
    empirical_density$x,
    fitted_normal,
    col = "red",
    lwd = 2,
    lty = 2
  )
}

#Q2 Monte Carlo Method
#I1 = integral from 0 to inf of x * e^-x dx
