% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/robust_treatment.R
\name{robust_treatment}
\alias{robust_treatment}
\title{Plot a sequence of average treatment effects with increasing posterior certainty}
\usage{
robust_treatment(object, newX, n.steps = 5)
}
\arguments{
\item{object}{ace object}

\item{newX}{(optional) The covariate matrix for the treatment effect predictions. If omitted, uses training samples.}

\item{n.steps}{(default: 10) The number of steps to be evaluated. The steps are equally spaced from 0\% (1 observation) to 100\% (full dataset).}
}
\value{
A matrix with the index for each discarding point along the x-axis.
}
\description{
{The method plots a sequence of average treatment effects by sequentially discarding points with the largest treatment uncertainty.
The shape of the curve indicates the robustness of the average treatment effect with respect to the treatment balance in the covariate space.
A substantial change of the treatment effect over the levels of removal is a good indicator for limited support but the reverse need not be true.

Note that the average treatment effect on the treated/untreated (ATT and ATU) is only supported for training set evaluation (if \code{newX} missing).
}
}
\examples{
library(ace)
## Example with binary treatment similar to Hill (2011)'s

set.seed(1231)
n <- 300

# generate treatment
Z <- rbinom(n, 1, 0.3)

# generate confounder and exogenous variable
X <- matrix(NaN, n, 1)
X[Z==1, ] <- rnorm(sum(Z), mean = 30,sd = 10)
X[Z==0, ] <- rnorm(n - sum(Z), mean = 20, sd = 10)
E <- runif(n) # exogenous variable
X <- data.frame(X, E)

# sort Confounder for visualizations
sort.idx <- sort(X[, 1], index.return = TRUE)$ix

# define and draw the reponse function
y_truefun <- function(x, z) {
    mat <- matrix(NaN, length(z), 1)
    mat[z==0, 1] <- matrix(72 + 3 * (x[z == 0,1] > 0) * sqrt(abs(x[z == 0, 1])), sum(z == 0), 1)
    mat[z==1, 1] <- matrix(90 + exp(0.06 * x[z == 1, 2]), sum(z == 1), 1)
    c(mat)}
y0_true <- y_truefun(X, rep(0, n))
y1_true <- y_truefun(X, rep(1, n))
Y0 <- rnorm(n, mean = y0_true, sd = 1)
Y1 <- rnorm(n, mean = y1_true, sd = 1)
Y <- Y0 * (1 - Z) + Y1 * Z

# run model
my.ace <- ace.train(Y, X, Z,
                    kernel = "SE", optimizer = "Nadam",
                    learning_rate = 0.005, maxiter = 1000)

# plot treatment curve
plot_ace(my.ace, 1, marginal = TRUE)

# Check for robustness of ATE:
idx = robust_treatment(my.ace, n.steps=5)

# Let's see which points were discarded (X[, 1] is the sole confounder here):
plot(X[, 1], idx[, 4], xlab="Retained Observations Flag", ylab="Confounder")
# When comparing to the treatment plot above, we keep the
# observations for which we have local overlap.


}
