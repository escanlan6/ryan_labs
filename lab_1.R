
#Q1
A <- matrix(c(3,5,0,2), nrow=2, ncol=2)
B <- matrix(c(1,4,4,7), nrow=2, ncol=2)

#(a) A+B
A + B

#(b) A-B
A - B

#(c) AB (matrix multiplication)
A %*% B

#(d) A(B^-1)
A %*% solve(B)

#(e) A/B  # MATLAB-style right division: A * inv(B)
A %*% solve(B)

#(f) A\B  # MATLAB-style left division: inv(A) * B
solve(A) %*% B

#(g) A.*B  # element-wise multiplication
A * B

#(h) A./B  # element-wise division
A / B


#Q2
C <- matrix(c(1,2,1,4,4,6,3,13,3,8,4,15,7,3,5,15), nrow=4, ncol=4)

# Show rank of C using QR decomposition
qr(C)$rank

# Why is the rank of C not 4?
# Because C is singular: det(C) = 0 and the smallest singular value is ~0, so the columns are linearly dependent; specifically c2 + c3 = 7*c1, giving rank 3.

#Q3
D <- matrix(c(1,2,1,4,4,6,3,1,3,8,4,7,7,3,5,6), nrow=4, ncol=4)
d <- matrix(c(14,8,10,18), nrow=4, ncol=1)

# Solve the system Dx = d
solve(D, d)


#Q4
# Generate E: 4x4 matrix of uniform random numbers and compute trace and determinant
set.seed(6372)
E <- matrix(runif(16), nrow = 4, ncol = 4)
# Trace of E
sum(diag(E))
# Determinant of E
det(E)

# Verify eigenvalue relations: product(eigenvalues) == determinant, sum(eigenvalues) == trace
ev <- eigen(E)$values
prod_ev <- prod(ev)
sum_ev <- sum(ev)
detE <- det(E)
trE <- sum(diag(E))
# Compare (coerce determinant/trace to complex to match eigenvalue mode)
prod_equal <- all.equal(prod_ev, as.complex(detE))
sum_equal <- all.equal(sum_ev, as.complex(trE))

# Print results
ev
prod_ev
as.complex(detE)
prod_equal
sum_ev
as.complex(trE)
sum_equal


#Q5
# Generate vectors x, y, z
x <- seq(-6, 121, by = 1)
x
y <- seq(-6, 120, by = 2)
y
z <- 2^(1:7)
z


#Q6
# Create a 5x6 matrix F and assign values using for/if/else if/else
F <- matrix(0, nrow = 5, ncol = 6)
for(i in 1:nrow(F)){
  for(j in 1:ncol(F)){
    if(i == j){
      F[i,j] <- -8
    } else if(abs(i - j) == 1){
      F[i,j] <- 3
    } else {
      F[i,j] <- 0
    }
  }
}

# Show F
F


#Q7
# Plot sine and cosine using ggplot
x_sc <- seq(0, 2 * pi, length.out = 400)
df_sc <- data.frame(
  x = rep(x_sc, times = 2),
  value = c(sin(x_sc), cos(x_sc)),
  func = rep(c("sin", "cos"), each = length(x_sc))
)
library(ggplot2)
ggplot(df_sc, aes(x = x, y = value, color = func)) +
  geom_line() +
  labs(title = "Sine and Cosine", x = "x", y = "value")

#Q8
# Simulate tossing a biased coin with P(heads)=0.4 using Bernoulli trials
set.seed(7321)
p <- 0.4
N <- 1000
# simulate via uniform draws (Bernoulli): 1=heads, 0=tails
tosses <- as.numeric(runif(N) < p)
# sample mean
sample_mean <- mean(tosses)
# show results
sample_mean


#Q9
# Demonstrate the Law of Large Numbers with fair coin tosses (p = 0.5)
set.seed(8427)
N_lln <- 10000
# 1 = heads, 0 = tails
tosses_fair <- rbinom(N_lln, size = 1, prob = 0.5)
# cumulative sample mean
cummean <- cumsum(tosses_fair) / seq_len(N_lln)
# prepare data frame for plotting
df_lln <- data.frame(trial = seq_len(N_lln), cummean = cummean)
# plot showing convergence toward 0.5
library(ggplot2)
ggplot(df_lln, aes(x = trial, y = cummean)) +
  geom_line() +
  geom_hline(yintercept = 0.5, linetype = "dashed") +
  labs(title = "Law of Large Numbers: cumulative mean of fair coin tosses",
       x = "Trial",
       y = "Cumulative mean")


#Q10
# Generate a Binomial(50, 0.2) random variable using uniform draws
set.seed(2917)
n_bin <- 50
p_bin <- 0.2
# one Binomial draw as sum of Bernoulli trials via uniforms
X_bin <- sum(runif(n_bin) < p_bin)
X_bin


#Q11
# Simulate a discrete random variable X with P(X=1)=0.35, P(X=2)=0.15, P(X=3)=0.4, P(X=4)=0.1 using a uniform draw
set.seed(4891)
u <- runif(1)
if (u < 0.35) {
  X <- 1
} else if (u < 0.35 + 0.15) {
  X <- 2
} else if (u < 0.35 + 0.15 + 0.4) {
  X <- 3
} else {
  X <- 4
}
# show simulated value
X


#Q12
# Simulate an Exponential(1) random variable using inverse transform of a uniform(0,1)
set.seed(7391)
U_exp <- runif(1)
X_exp <- -log(U_exp)
# show simulated exponential draw
X_exp


#Q13
# Generate 5000 pairs of independent standard Normal(0,1) variables via Box-Muller using uniforms and plot histograms
set.seed(5460)
n_pairs <- 5000
u1 <- runif(n_pairs)
u2 <- runif(n_pairs)
z1 <- sqrt(-2 * log(u1)) * cos(2 * pi * u2)
z2 <- sqrt(-2 * log(u1)) * sin(2 * pi * u2)
# combined data frame for plotting
library(ggplot2)
df_norm <- data.frame(value = c(z1, z2), var = rep(c("Z1", "Z2"), each = n_pairs))
# plot separate histograms for Z1 and Z2
ggplot(df_norm, aes(x = value)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "black") +
  facet_wrap(~var, ncol = 1) +
  labs(title = "Histograms of Z1 and Z2 from Box–Muller", x = "Value", y = "Count")
