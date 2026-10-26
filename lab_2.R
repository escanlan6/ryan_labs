# Q1 Pareto distribution: inverse transform, density comparison, and moment comparison

# Pareto inverse CDF for U ~ Uniform(0,1): X = beta / (1 - U)^(1/alpha)
rpareto <- function(n, alpha, beta = 1) {
  u <- runif(n)
  beta / (1 - u)^(1 / alpha)
}

# Pareto density and analytic moments

dpareto <- function(x, alpha, beta = 1) {
  ifelse(x >= beta, alpha * beta^alpha / x^(alpha + 1), 0)
}

pareto_mean <- function(alpha, beta = 1) {
  if (alpha <= 1) {
    Inf
  } else {
    alpha * beta / (alpha - 1)
  }
}

pareto_var <- function(alpha, beta = 1) {
  if (alpha <= 2) {
    Inf
  } else {
    alpha * beta^2 / (((alpha - 1)^2) * (alpha - 2))
  }
}

# Pick parameter values with finite mean and variance for the moment check
params <- expand.grid(alpha = c(2, 3, 5), beta = c(1, 2))

sim_df <- do.call(rbind, lapply(seq_len(nrow(params)), function(i) {
  alpha <- params$alpha[i]
  beta <- params$beta[i]
  x <- rpareto(100000, alpha = alpha, beta = beta)

  data.frame(
    alpha = alpha,
    beta = beta,
    sample_mean = mean(x),
    sample_var = var(x),
    analytic_mean = pareto_mean(alpha, beta),
    analytic_var = pareto_var(alpha, beta)
  )
}))

print(sim_df)

# Density comparison: empirical kernel densities versus analytic Pareto density
library(ggplot2)

density_df <- do.call(rbind, lapply(seq_len(nrow(params)), function(i) {
  alpha <- params$alpha[i]
  beta <- params$beta[i]
  x <- rpareto(100000, alpha = alpha, beta = beta)

  dens <- density(x, from = beta, n = 512)
  dens_df <- data.frame(
    alpha = alpha,
    beta = beta,
    x = dens$x,
    empirical = dens$y
  )
  dens_df$analytic <- dpareto(dens_df$x, alpha = alpha, beta = beta)
  dens_df
}))

density_df$label <- with(density_df, sprintf("alpha = %s, beta = %s", alpha, beta))

ggplot(density_df, aes(x = x)) +
  geom_line(aes(y = empirical, colour = "Empirical"), linewidth = 1) +
  geom_line(aes(y = analytic, colour = "Analytic"), linewidth = 1, linetype = "dashed") +
  facet_wrap(~ label, scales = "free_y") +
  labs(
    x = "x",
    y = "Density",
    colour = "Density",
    title = "Empirical vs analytic Pareto density"
  ) +
  theme_minimal()

# Optional: view moments in a summary table without using an external package
print(sim_df[, c("alpha", "beta", "sample_mean", "analytic_mean", "sample_var", "analytic_var")])
