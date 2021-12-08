library(lubridate)
library(e1071)
library(psych)
library(ggplot2)
library(DescTools)
library(fitdistrplus)
library(logspline)
library(data.table)
library(Pareto)
library(EnvStats)
library(gofgamma)
library(readxl)
library(ks)
########################## All 24 CORE ##########################
it.24 <- read_excel("path to file", sheet = "All 24", 
                     col_types = c("skip", "skip", "skip", "skip", "skip", "numeric", "skip"))
it.24 <- as.numeric(it.24$Seconds)
it.24 <- na.omit(it.24)
it.24 <- as.numeric(it.24)

### SUMMARY STATISTICS
summary(it.24)
var(it.24)
sd(it.24)
cv <- sd(it.24) / mean(it.24)
cv
skewness(it.24)
describe(it.24)
table(range=cut(it.24, breaks = c(0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 9000, 
                                   10000, 20000, 30000, 40000, 50000, Inf), 
                labels = c("0-100", "100-200", "200-300", "300-400", "400-500", "500-600", "600-700", "700-800", "800-900", "900-1000", "1000-1500", 
                           "1500-2000", "2000-2500", "2500-3000", "3000-3500", "3500-4000", "4000-4500", "4500-5000", "5000-6000", "6000-7000", "7000-8000", "8000-9000", "9000-10000", 
                           "10000-20000", "20000-30000", "30000-40000", "40000-50000", "50000-")))

#### HISTOGRAM & BOXPLOT
act <- hist(it.24, breaks=500)
boxplot(it.24, horizontal = TRUE)


#### Trying Distributions
descdist(it.24, discrete = FALSE)
it.24_scaled <- (it.24 - min(it.24) + 0.001) / (max(it.24) - min(it.24) + 0.002)
fit.exp.24 <- fitdist(it.24_scaled, "exp")
plot(fit.exp.24)
fit.exp.24$aic

fit.beta.24 <- fitdist(it.24_scaled, "beta")
plot(fit.beta.24)
fit.beta.24$aic
fit.beta.24$estimate

fit.gamma.24 <- fitdist(it.24_scaled, "gamma")
plot(fit.gamma.24)
fit.gamma.24$aic
fit.gamma.24$estimate

fit.lnorm.24 <- fitdist(it.24_scaled, "lnorm")
plot(fit.lnorm.24)
fit.lnorm.24$aic
fit.lnorm.24$estimate

### Comparison of Goodness of Fit Tests
gofstat(list(fit.beta.24, fit.gamma.24, fit.lnorm.24), fitnames = c("Beta", "Gamma", "Log Normal"))
test.KS(it.24_scaled, boot = 500, alpha = 0.1)
test.AD(it.24_scaled, boot = 500, alpha = 0.1)



########################## All 28 CORE ##########################
it.28 <- read_excel("path to file", sheet = "All 28", 
                    col_types = c("skip", "skip", "skip", "skip", "skip", "numeric", "skip"))
it.28 <- as.numeric(it.28$Seconds)
it.28 <- na.omit(it.28)
it.28 <- as.numeric(it.28)

### SUMMARY STATISTICS
summary(it.28)
var(it.28)
sd(it.28)
cv <- sd(it.28) / mean(it.28)
cv
skewness(it.28)
describe(it.28)
table(range=cut(it.28, breaks = c(0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 9000, 
                                  10000, 20000, 30000, 40000, 50000, Inf), 
                labels = c("0-100", "100-200", "200-300", "300-400", "400-500", "500-600", "600-700", "700-800", "800-900", "900-1000", "1000-1500", 
                           "1500-2000", "2000-2500", "2500-3000", "3000-3500", "3500-4000", "4000-4500", "4500-5000", "5000-6000", "6000-7000", "7000-8000", "8000-9000", "9000-10000", 
                           "10000-20000", "20000-30000", "30000-40000", "40000-50000", "50000-")))

#### HISTOGRAM & BOXPLOT
act <- hist(it.28, breaks=500)
boxplot(it.28, horizontal = TRUE)

#### Trying Distributions
descdist(it.28, discrete = FALSE)
it.28_scaled <- (it.28 - min(it.28) + 0.001) / (max(it.28) - min(it.28) + 0.002)
fit.exp.28 <- fitdist(it.28_scaled, "exp")
plot(fit.exp.28)
fit.exp.28$aic

fit.beta.28 <- fitdist(it.28_scaled, "beta")
plot(fit.beta.28)
fit.beta.28$aic
fit.beta.28$estimate

fit.gamma.28 <- fitdist(it.28_scaled, "gamma")
plot(fit.gamma.28)
fit.gamma.28$aic
fit.gamma.28$estimate

fit.lnorm.28 <- fitdist(it.28_scaled, "lnorm")
plot(fit.lnorm.28)
fit.lnorm.28$aic
fit.lnorm.28$estimate

### Comparison of Goodness of Fit Tests
gofstat(list(fit.beta.28, fit.gamma.28, fit.lnorm.28), fitnames = c("Beta", "Gamma", "Log Normal"))
test.KS(it.28_scaled, boot = 500, alpha = 0.1)
test.AD(it.28_scaled, boot = 500, alpha = 0.1)



########################## All 40 CORE ##########################
it.40 <- read_excel("path to file", sheet = "All 40", 
                    col_types = c("skip", "skip", "skip", "skip", "skip", "numeric", "skip"))
it.40 <- as.numeric(it.40$Seconds)
it.40 <- na.omit(it.40)
it.40 <- as.numeric(it.40)

### SUMMARY STATISTICS
summary(it.40)
var(it.40)
sd(it.40)
cv <- sd(it.40) / mean(it.40)
cv
skewness(it.40)
describe(it.40)
table(range=cut(it.40, breaks = c(0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 9000, 
                                  10000, 20000, 30000, 40000, 50000, Inf), 
                labels = c("0-100", "100-200", "200-300", "300-400", "400-500", "500-600", "600-700", "700-800", "800-900", "900-1000", "1000-1500", 
                           "1500-2000", "2000-2500", "2500-3000", "3000-3500", "3500-4000", "4000-4500", "4500-5000", "5000-6000", "6000-7000", "7000-8000", "8000-9000", "9000-10000", 
                           "10000-20000", "20000-30000", "30000-40000", "40000-50000", "50000-")))

#### HISTOGRAM & BOXPLOT
act <- hist(it.40, breaks=500)
boxplot(it.40, horizontal = TRUE)

#### Trying Distributions
descdist(it.40, discrete = FALSE)
it.40_scaled <- (it.40 - min(it.40) + 0.001) / (max(it.40) - min(it.40) + 0.002)
fit.exp.40 <- fitdist(it.40_scaled, "exp")
plot(fit.exp.40)
fit.exp.40$aic

fit.beta.40 <- fitdist(it.40_scaled, "beta")
plot(fit.beta.40)
fit.beta.40$aic
fit.beta.40$estimate

fit.gamma.40 <- fitdist(it.40_scaled, "gamma")
plot(fit.gamma.40)
fit.gamma.40$aic
fit.gamma.40$estimate

fit.lnorm.40 <- fitdist(it.40_scaled, "lnorm")
plot(fit.lnorm.40)
fit.lnorm.40$aic
fit.lnorm.40$estimate

### Comparison of Goodness of Fit Tests
gofstat(list(fit.beta.40, fit.gamma.40, fit.lnorm.40), fitnames = c("Beta", "Gamma", "Log Normal"))
test.KS(it.40_scaled, boot = 500, alpha = 0.1)
test.AD(it.40_scaled, boot = 500, alpha = 0.1)



########################## All GPU ##########################
it.GPU <- read_excel("path to file", sheet = "All GPU", 
                    col_types = c("skip", "skip", "skip", "skip", "skip", "numeric", "skip"))
it.GPU <- as.numeric(it.GPU$Seconds)
it.GPU <- na.omit(it.GPU)
it.GPU <- as.numeric(it.GPU)

### SUMMARY STATISTICS
summary(it.GPU)
var(it.GPU)
sd(it.GPU)
cv <- sd(it.GPU) / mean(it.GPU)
cv
skewness(it.GPU)
describe(it.GPU)
table(range=cut(it.GPU, breaks = c(0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 9000, 
                                  10000, 20000, 30000, 40000, 50000, Inf), 
                labels = c("0-100", "100-200", "200-300", "300-400", "400-500", "500-600", "600-700", "700-800", "800-900", "900-1000", "1000-1500", 
                           "1500-2000", "2000-2500", "2500-3000", "3000-3500", "3500-4000", "4000-4500", "4500-5000", "5000-6000", "6000-7000", "7000-8000", "8000-9000", "9000-10000", 
                           "10000-20000", "20000-30000", "30000-40000", "40000-50000", "50000-")))

#### HISTOGRAM & BOXPLOT
act <- hist(it.GPU, breaks=500)
boxplot(it.GPU, horizontal = TRUE)

#### Trying Distributions
descdist(it.GPU, discrete = FALSE)
it.GPU_scaled <- (it.GPU - min(it.GPU) + 0.001) / (max(it.GPU) - min(it.GPU) + 0.002)
fit.exp.GPU <- fitdist(it.GPU_scaled, "exp")
plot(fit.exp.GPU)
fit.exp.GPU$aic

fit.beta.GPU <- fitdist(it.GPU_scaled, "beta")
plot(fit.beta.GPU)
fit.beta.GPU$aic
fit.beta.GPU$estimate

fit.gamma.GPU <- fitdist(it.GPU_scaled, "gamma")
plot(fit.gamma.GPU)
fit.gamma.GPU$aic
fit.gamma.GPU$estimate

fit.lnorm.GPU <- fitdist(it.GPU_scaled, "lnorm")
plot(fit.lnorm.GPU)
fit.lnorm.GPU$aic
fit.lnorm.GPU$estimate

### Comparison of Goodness of Fit Tests
gofstat(list(fit.beta.GPU, fit.gamma.GPU, fit.lnorm.GPU), fitnames = c("Beta", "Gamma", "Log Normal"))
gofstat(fit.beta.GPU, chisqbreaks)
test.KS(it.GPU_scaled, boot = 500, alpha = 0.1)
test.AD(it.GPU_scaled, boot = 500, alpha = 0.1)