#General MCE function
mc_summary <- function(values, confidence = 0.95) {
  n <- length(values)
  estimate <- mean(values)
  standard_error <- sd(values) / sqrt(n)
  
  # z value for chosen confidence level
  z <- qnorm(1 - (1 - confidence) / 2)
  
  list(
    estimate = estimate,
    SE = standard_error,
    CI_lower = estimate - z * standard_error,
    CI_upper = estimate + z * standard_error
  )
}

make_results <- function(methods, summaries, vrfs) {
  data.frame(
    method = methods,
    estimate = sapply(summaries, function(x) x$estimate),
    SE = sapply(summaries, function(x) x$SE),
    CI_lower = sapply(summaries, function(x) x$CI_lower),
    CI_upper = sapply(summaries, function(x) x$CI_upper),
    VRF = vrfs,
    row.names = NULL
  )
}

#Q1 Antithetic Variates
#I1 = E[U^2] = integral from 0 to 1 of u^2 du

# Goal: Compute mu = E[Y]. We simulate iid Y1, Y2, ..., Yn; mu_hat = (1/n) sum Y_i. SE of mu_hat = sd(Y) / sqrt(n)
# True I1 = integral from 0 to 1 of u^2 du = u^3 / 3 {from 0 to 1} = 1/3
# MC I_hat = (1/n) sum U_i^2
# True Var[Y] = E[Y^2] - (E[Y])^2 = Var[U^2] = E[U^4] - (E[U^2])^2
# E[U^4] = integral from 0 to 1 of u^4 du = u^5 / 5 {from 0 to 1} = 1/5
# Var[U^2] = 1/5 - (1/3)^2 = 4/45
# True SD = sqrt(4/45 * N)
# H_i = (U_i^2 + (1 - U_i)^2) / 2 = u_i^2 - u_i + 1/2

set.seed(4101)
N1 <- 10000
true_I1 <- 1/3

# Q1(a): Crude MC method
U_crude_q1 <- runif(N1)
Y_crude_q1 <- U_crude_q1^2
crude_q1 <- mc_summary(Y_crude_q1)
print(crude_q1)

#Q1(b): Antithetic method
U_pairs_q1 <- runif(N1 / 2)
H_q1 <- (U_pairs_q1^2 + (1 - U_pairs_q1)^2) / 2
antithetic_q1 <- mc_summary(H_q1)
print(antithetic_q1)

VRF_av_q1 <- (crude_q1$SE^2) / (antithetic_q1$SE^2)
print(VRF_av_q1)


#Q2 Control Variates
#I2 = E[S_T], S_T is stock price at future time T under Black-Scholes model.
# S_T = S_0 * exp((r - 0.5 * sigma^2) * T + sigma * sqrt(T) * Z), Z ~ N(0,1)
# S_0 = 100, r = 0.03, sigma = 0.2, T = 0.5
# S_T = 100 * exp(0.005 + 0.2 * sqrt(0.5) * Z), Z ~ N(0,1)

set.seed(4102)
N2 <- 10000
S_0 <- 100
r <- 0.03
sigma <- 0.2
T <- 0.5

Z_q2 <- rnorm(N2)
S_T_q2 <- S_0 * exp((r - sigma^2 / 2) * T + sigma * sqrt(T) * Z_q2)

#Q2(a): Crude MCE of I2
crude_q2 <- mc_summary(S_T_q2)
print(crude_q2)

#Q2(b): Control variates method

# Imagine estimating E[Y], while a correlated RV X whose V = E[x] is known
# Y_CV = Y - b * (X - V)
# Let X = Z ~ N(0,1), E[X] = E[Z] = 0, Var[X]= Var[Z] = 1
# E[Y_CV] = E[Y] - b * (E[X] - V) = E[Y] - b * E[X]
# S_T_CV = S_T - b * Z, I2_CV = E[S_T_CV] = mean_S_T - b * mean_Z

# b_* = Cov[Y, X] / Var[X], X = Z, Y = S_T
# b_* = Cov[S_T, Z] / Var[Z] = Cov[S_T, Z] = E[S_T * Z]

# Let a = sigma * sqrt(T), E[e^(a * Z)] = e^(a^2 / 2), E[Z * e^(a * Z)] = a * e^(a^2 / 2)
# E[S_T] = S_0 * e^((r - sigma^2 / 2) * T) * E[e^(a * Z)] = S_0 * e^(r * T)
# Cov(S_T, Z)  = S_0 * e^((r - sigma^2 / 2) * T) * E[Z * e^(a * Z)] = sigma * sqrt(T) * S_0 * e^(r * T)

# True b_* = sigma * sqrt(T) * S_0 * e^(r * T) = 0.2 * sqrt(0.5) * 100 * e^(0.03 * 0.5)
# True I2 = S_0 * e^(r * T) = 100 * e^(0.03 * 0.5)

True_I2 = S_0 * exp(r * T)
b_opt_q2 = sigma * sqrt(T) * S_0 * exp(r * T)
control_q2 <- mc_summary(S_T_q2 - b_opt_q2 * Z_q2)
print(control_q2)

VRF_cv_q2 <- (crude_q2$SE^2) / (control_q2$SE^2)
print(VRF_cv_q2)


#Q3 Variance Reduction Methods
# I3 = integral from 0 to 1 of e^u du
# True I3 = integral from 0 to 1 of e^u du = e^1 - e^0 = e - 1

set.seed(4103)
true_I3 <- exp(1) - 1

#Q3(a)[i]: Crude MCE of I3
N3 <- 10000
U_crude_q3 <- runif(N3)
Y_crude_q3 <- exp(U_crude_q3)
crude_q3 <- mc_summary(Y_crude_q3)
print(crude_q3)

#Q3(a)[ii]: Antithetic method
U_pairs_q3 <- runif(N3 / 2)
H_q3 <- (exp(U_pairs_q3) + exp(1 - U_pairs_q3)) / 2
antithetic_q3 <- mc_summary(H_q3)
print(antithetic_q3)

#Q3(a)[iii]: Control variates method
# X = U, V = E[U] = 0.5, Y_i_CV = e^U_i - b * (U_i - 0.5)
# True b_* = Cov[e^U, U] / Var[U], Var[U] = 1/12
# E[e^U * U] = integral from 0 to 1 of u * e^u du = (u - 1) * e^u {from 0 to 1} = (0) - (-1) = 1
# Cov[e^U, U] = E[e^U * U] - E[e^U] * E[U] = 1 - (e - 1) * 0.5 = (3 - e) / 2
# True b_* = Cov[e^U, U] / Var[U] = ((3 - e) / 2) / (1/12) = 6 * (3 - e)
# I3_CV = 1 / N * sum (e^U_i - b_hat * (U_i - 0.5))

U_bar_q3 <- mean(U_crude_q3)
Y_bar_q3 <- mean(Y_crude_q3)
b_hat_q3 <- sum((U_crude_q3 - U_bar_q3) * (Y_crude_q3 - Y_bar_q3)) / sum((U_crude_q3 - U_bar_q3)^2)
control_q3 <- mc_summary(Y_crude_q3 - b_hat_q3 * (U_crude_q3 - 0.5))
print(control_q3)

#Q3(b): Estimated VRFs
VRF_av_q3 <- (crude_q3$SE^2) / (antithetic_q3$SE^2)
VRF_cv_q3 <- (crude_q3$SE^2) / (control_q3$SE^2)
print(VRF_av_q3)
print(VRF_cv_q3)
