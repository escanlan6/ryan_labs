# Q1
# inverse distribution function calculation (Let alpha = a, beta = b)
# f(x) = a * b^a / x^(a + 1), x >= b > 0

# integrate f(x) from b to x 
# # take a * b^a outside the integral
# # integrate 1/x^(a + 1) -> x^(-a - 1) -> x^(-a) / -a
# # a * b^a * (x^(-a) / -a = - b^a * x^(-a) = - (b / x)^a
# # apply limits: - (b / x)^a + (b / b)^a = 1 - (b / x)^a

# set 1 - (b / x)^a = u, solve for x
# # (b / x)^a = 1 - u
# # b / x = (1 - u)^(1/a)
# # x = b / (1 - u)^(1/a)

# Pareto inverse CDF for U ~ Uniform(0,1): X = b / (1 - U)^(1/a)
inverse_pareto <- function(u, alpha, beta) {
  return(beta / (1 - u)^(1/alpha))
}

density_pareto <- function(x, beta, alpha) {
  ifelse(x < beta, 0, alpha * beta^alpha / x^(alpha + 1))
}

alpha <- c(2,3,5,3)
beta <- c(1,1,1,3)
n <- 10000
set.seed(2025)
par(mfrow = c(2,2))
pareto_mean <- numeric(length(alpha))
# Theoretical mean calculation
# E[x] = integral {from b to inf} x * f(x) = integral x * ((a * b^a) / (x^(a + 1)))
# = (a * b^a) / (x^a) = a * b^a * integral 1 / x^a 
# = x^-a = x^(-a + 1) / (-a + 1) = x^(1 - a) / (1 - a) = (a * b^a) / ((1 - a) * x^(a - 1))
# apply limits: (a * b^a) / ((1 - a) * x^(a - 1)) {from b to inf}
# = 0 {x -> inf} - (a * b^a) / ((1 - a) * b^(a - 1))
# = (a * b^a) / ((a - 1) * b^(a - 1)) = (a * b) / (a - 1)

# Theoretical mean = (a * b) / (a - 1)
theoretical_mean <- function(alpha, beta) {
  return((alpha * beta) / (alpha - 1))
}
pareto_var <- numeric(length(alpha))
# Theoretical variance calculation
# Var[x] = E[x^2] - (E[x])^2 = integral {from b to inf} x^2 * f(x) - (E[x])^2

# E[x^2] = integral {from b to inf} x^2 * f(x) = x^2 * ((a * b^a) / (x^(a + 1)))
# # = (a * b^a) integral x / x^a = x^(-a + 1) = (x^(-a + 2)) / (-a + 2)
# # = (a * b^a) / (2 - a)(x^(a - 2))
# # apply limits = - a / (2 - a) * b^a / b^(a - 2) = a / ((a - 2) * b^-2) = (a * b^2) / (a - 2)

# (E[x])^2 = ((a * b) / (a - 1))^2

# (a * b^2) / (a - 2) - ((a * b) / (a - 1))^2
# a * b^2 (1 / (a - 2) - a / (a - 1)^2)
# a * b^2 ((a - 1)^2 - a * (a - 2)) / ((a - 2) * (a - 1)^2)
# # = a^2 - 2a + 1 - a^2 + 2a = 1
# a *b^2 / ((a - 2) * (a - 1)^2) 

# Theoretical variance = (a * b^2) / ((a - 1)^2 * (a - 2))
theoretical_var <- function(alpha, beta) {
  return((alpha * beta^2) / ((alpha - 1)^2 * (alpha - 2)))
}
u = runif(n)
for (i in seq_along(alpha)) {
  pareto_sample <- inverse_pareto(u, alpha[i], beta[i])
  pareto_mean[i] <- mean(pareto_sample)
  pareto_var[i] <- var(pareto_sample)

  hist(
  pareto_sample,
  breaks = 50,
  probability = TRUE,
  main = paste("Pareto Sample: α =", alpha[i], ", β =", beta[i]),
  col = "lightblue",
  border = "white",
  xlim = c(beta[i], max(pareto_sample))
)
x_grid <- seq(beta[i], max(pareto_sample), length.out = 100)
lines(x_grid, density_pareto(x_grid, beta[i], alpha[i]), col = "red", lwd = 2)
}
moment_results <- data.frame(
  alpha = alpha,
  beta = beta,
  sample_mean = pareto_mean,
  theoretical_mean = theoretical_mean(alpha, beta),
  sample_var = pareto_var,
  theoretical_var = theoretical_var(alpha, beta)
)

print(moment_results)

#Q2 - ARM
# f(x) = (x^2 / 2) * e^-x, x >= 0
# g(x) = lambda * e^(-lambda * x), x >= 0
# m(x) = f(x) / g(x) = (x^2 / 2 * lambda) * e^(-x * (1 - lambda))

# maximise m -> differentiate m with respect to x and set to 0
# # product rule: (uv)' = u'v + uv'
# # u = (x^2 / 2 * lambda), v = e^(-x * (1 - lambda))
# # u' = x / lambda, v' = - (1 - lambda) * e^(-x * (1 - lambda))
# # m'(x) factorised = ((x * e^(-x * (1 - lambda))) /  lambda) * 1 - (x * (1 - lambda) / 2)
# # set m'(x) = 0, solve for x
# # ((x * e^(-x * (1 - lambda))) /  lambda) can't be 0, so 1 - (x * (1 - lambda) / 2) = 0
# # x = 2 / (1 - lambda)

# sub it back into m(x): (1 / 2 * lambda) * (2 / (1 - lambda))^2 * e^((-2 / (1 - lambda)) * (1 - lambda)))
# simplify: (2 * e^-2) / (lambda * (1 - lambda)^2)
# minimise c: same as maximising inverse = lambda * (1 - lambda)^2
# differentiate with respect to lambda and set to 0
# lambda * (1 - lambda)^2 = lambda^3 - 2lambda^2 + lambda
# differentiate: 3lambda^2 - 4lambda + 1 = 0
# factorise: (lambda - 1)(3lambda - 1) = 0
# lambda = 1, 1/3. 1 is not in (0,1), so lambda = 1/3

# calculate optimal c: (2 * e^-2) / (1/3 * (1 - 1/3)^2) = 2 * e^-2 / (1/3 * 4/9) = 2 * e^-2 / (4/27) = 27 * e^-2 / 2
set.seed(2025)
arm <- function(N) {
  lambda <- 1/3
  c <- 27 * exp(-2) / 2
  fx <- function(x) {
    return((x^2 / 2) * exp(-x))
  }
  gx <- function(x, lambda) {
    return(lambda * exp(-lambda * x))
  }
  observed <- numeric(N)
  accepted <- 0
  while (accepted < N) {
    y <- rexp(1, rate = lambda)
    u <- runif(1)
    if (u <= fx(y) / (c * gx(y, lambda))) {
      accepted <- accepted + 1
      observed[accepted] <- y
    }
  }
  return(observed)
}

sample_sizes <- c(100, 1000, 10000, 50000)
for (i in seq_along(sample_sizes)) {
  arm_sample <- arm(sample_sizes[i])

  hist(
    arm_sample,
    breaks = 50,
    probability = TRUE,
    main = paste("ARM Sample: N =", sample_sizes[i]),
    xlab = "x",
    xlim = c(0, max(arm_sample)),
    col = "lightblue",
    border = "white",

  )
 curve(
    (x^2 / 2) * exp(-x),
    from = 0,
    to = max(arm_sample),
    add = TRUE,
    col = "red",
    lwd = 2
  )
}

#Q3 - KS-test
#X ~ Exp(2)
# F2(x) = 1 - e^(-2 * x), x >= 0
    set.seed(2025)
    N <- 200
    rate <- 2
    alpha <- 0.05

    exp_sample <- rexp(
      N,
      rate = rate
    )

    empirical_cdf <- ecdf(
      exp_sample
    )
      

    plot(
      empirical_cdf,
      verticals = TRUE,
      do.points = FALSE,
      main = "Empirical and theoretical CDF",
      xlab = "x",
      ylab = "F(x)",
      xlim = c(
        0,
        max(exp_sample)
      ),
      col = "blue",
      lwd = 2
    )

x_grid <- seq(
  0,max(exp_sample),
  length.out = 1000
)

lines(
  x_grid,
  pexp(
    x_grid, rate = rate),
  col = "red",
  lwd = 2
)

ordered_sample <- sort(exp_sample)

theoretical_cdf <- pexp(
  ordered_sample,
  rate = rate
)

D_plus <- max((1:N)/N - theoretical_cdf)
D_minus <- max(theoretical_cdf - (0:(N-1))/N)
D_N <- max(D_plus, D_minus)

manual_results <- data.frame(
  D_plus = D_plus,
  D_minus = D_minus, 
  D_N = D_N
)
print(manual_results)

ks_result <- ks.test(
  exp_sample,
  "pexp",
  rate = rate,
  exact = FALSE
)

if (ks_result$p.value < alpha) {
  print(
    "Reject H0 at the 5% significance level."
  )
} else {
  print(
    "Do not reject H0 at the 5% significance level."
  )
}

M <- 1000
rejected <- numeric(M)
set.seed(2025)
for (m in 1:M) {
  gen_sample <- rexp(N, rate = rate)
  gen_result <- ks.test(gen_sample, "pexp", rate = rate, exact = FALSE)
  if (gen_result$p.value < alpha) {
    rejected[m] <- 1
  }
}

number_rejected <- sum(rejected)
rejection_proportion <- mean(rejected)
rejection_percentage <- 100 * rejection_proportion

simulation_results <- data.frame(
  number_of_simulations = M,
  sample_size = N,
  number_rejected = number_rejected,
  rejection_proportion = rejection_proportion,
  rejection_percentage = rejection_percentage 
)
print(simulation_results)

expected_rejections <- alpha * M
expected_rejections
