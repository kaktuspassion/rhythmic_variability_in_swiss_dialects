
# Assignment 1. Rhythmic Variability in Swiss German Dialects
# Computational Processing of Speech Rhythm, University of Zurich
# 27 Nov. 2023
# Haonan Chen, 22-738-512, Olat:haonch
# Rong Li, 22-738-009, Olat:ronli
# Yating Pan, 22-733-380, Olat:yating

install.packages("dlookr")
install.packages("cowplot")
install.packages("modelr")
install.packages("modelr")
install.packages("caret")
install.packages("MASS")
install.packages("ggord")
install.packages("rstatix")

rm(list = ls())

# Libraries
library(dplyr) # for data wrangling (standardization)
library(ggplot2) # for data visualization
library(dlookr) # a lot of EDA functions
library(cowplot) # for grid plotting
library(modelr) # to add residuals of lm

library(caret)   # pre-processing
library(MASS)    # LDA, evaluation matrix 
library(ggord)   # LDA biplot
library(rstatix) # for Box's M statistic
library(BSDA) # for z test

## 1. Loading data 
data <- read.csv("duration.csv", sep = "\t")
summary(data)
describe(data)

# correlation check for specific variables
data %>%
  select(deltaCLn_tier1, varcoC_tier1, nPVI_C_tier1, deltaVLn_tier1, varcoV_tier1, nPVI_V_tier1, percentV_tier1) %>%
  correlate() %>%
  plot()

# correlation between features chosen: nPVI_C, varcoV
features <- c('nPVI_C_tier1', 'varcoV_tier1')
cor(data[, features])
# 0.06, nearly zero correlation, independent analysis reasonable 


## 2. Data preprocessing 
# 2.1 data splitting 
set.seed(24)
# creating the partition
dialect_counts <- table(data$dialect)
print(dialect_counts)
# we use the "dialect" variable to indicate that we want a balanced partition depending on that label
index <- createDataPartition(data$dialect, p = 0.8, list = FALSE)
# p = 0.8 indicates that we want the ratio train:test to be 80:20
train <- data[index, ]
test <- data[-index, ]
nrow(test) / nrow(data) # should be close to 0.2

# 2.2 standardization 
# note: parameters estimated on train data, applied to both train and test data 
# estimating parameters for standardization
preproc.params <- train %>% preProcess(method = c("center", "scale"))
# Standardizing
train <- preproc.params %>% predict(train)
test <- preproc.params %>% predict(test) # using the same parameters


## 3. EDA
# 3.1 outlier detection
# typical data
plot1 <- ggplot(data = train, mapping = aes(x = nPVI_C_tier1)) + 
  geom_histogram(binwidth = 0.1)
plot2 <- ggplot(data = train, mapping = aes(x = varcoV_tier1)) + 
  geom_histogram(binwidth = 0.1)
plot_grid(plot1, plot2, nrow = 1, ncol = 2)

# detecting outliers 
ggplot(data = train, mapping = aes(x = nPVI_C_tier1)) + 
  geom_histogram(binwidth = 0.05) +
  coord_cartesian(ylim = c(0, 40))
ggplot(data = train, mapping = aes(x = varcoV_tier1)) + 
  geom_histogram(binwidth = 0.05) +
  coord_cartesian(ylim = c(0, 40))

# managing outliers 
# save the unusual values for nPVI_C_tier1 in a different dataset
unusual1 <- train %>%
  filter(nPVI_C_tier1 > 3.7) %>% select(file, gender, dialect, nPVI_C_tier1, varcoV_tier1) %>% arrange(nPVI_C_tier1)
unusual1
# save the unusual values for varcV_tier1 in a different dataset
unusual2 <- train %>%
  filter(varcoV_tier1 > 4.0) %>% select(file, gender, dialect, nPVI_C_tier1, varcoV_tier1) %>% arrange(varcoV_tier1)
unusual2
# update the data by setting outliers into NA values 
# train <- train %>%
#   mutate(nPVI_C_tier1 = ifelse(nPVI_C_tier1 > 3.7, NA, nPVI_C_tier1),
#          varcoV_tier1 = ifelse(varcoV_tier1 > 4.0, NA, varcoV_tier1))
train <- train %>%
  filter(!(nPVI_C_tier1 > 3.7),
         !(varcoV_tier1 > 4.0))

# 3.2 variable normalization
# normality diagnosis plot for 2 features 
plot_normality(train, nPVI_C_tier1)
plot_normality(train, varcoV_tier1)
# evaluate normality using Shapiro-Wilk test on original data
shapiro.test(train$nPVI_C_tier1)
shapiro.test(train$varcoV_tier1)

# # choose quantile transformation 
# train2 <- train %>%
#   mutate(qq_nPVI_C_tier1 = qnorm(ppoints(nPVI_C_tier1)), 
#          qq_varcoV_tier1 = qnorm(ppoints(varcoV_tier1)))
# # evaluate normality using Shapiro-Wilk test on transformed data
# shapiro.test(train2$qq_nPVI_C_tier1)
# shapiro.test(train2$qq_varcoV_tier1)

# 3.3 relations between a continuous variable and categorical variable


## 4. LDA
# 4.1 LDA training and visualization 
# create feature and response variables for the training set and the testing set
to_exclude <- c("file", "speaker", "gender", "dialect", "sentence_number") # non-feature columns
# Create feature and response variables for the training set and the testing set
train.set <- train[, !colnames(train) %in% to_exclude]
train.response <- train$dialect
test.set <- test[, !colnames(test) %in% to_exclude]
test.response <- test$dialect

# Create a new data frame with only the selected features
train.subset_features <- train.set[, features]
test.subset_features <- test.set[, features]

# training of the model on the training data
lda.model <- lda(train.subset_features, grouping = train.response)
# str(lda.model)

# training predictions
train.pred <- predict(lda.model, train.subset_features) # transformed data in train.lda$x

# Visualizations:
# scatter plot
# Create a data frame to use with ggplot2
plot.data <- data.frame(train.pred$x, "dialect" = train.response)
plot.data
# sccaterplot
ggplot(data = plot.data, mapping = aes(x = LD1, y = LD2, color = dialect)) +
  geom_point(alpha = .4)
# scatterplot with ellipses
plot <- ggord(lda.model, grp_in = train.response, arrow = NULL, txt = NULL) + 
ggsave("scatterplot_with_ellipses.png", plot, width = 8, height = 6, units = "in")

# 4.2 LDA testing and visualization 
test.pred <- predict(lda.model, test.subset_features)
train.pred <- predict(lda.model, train.subset_features)
test.acc <- length(which(test.pred$class == test.response)) / length(test.response)
train.acc <- length(which(train.pred$class == train.response)) / length(train.response)
print(paste("Training accuracy =", train.acc))
print(paste("Testing accuracy =", test.acc))

# Visualizing test results
# we select only the first two dimensions
plot.data <- data.frame(
  test.pred$x[, 1:2], 
  "predicted" = test.pred$class,
  "true" = test.response
)
ggplot(
  data = plot.data,
  mapping = aes(x = LD1, y = LD2, color = true, shape = predicted)
) +
  geom_point(alpha = 0.8)

## 5. Model Evaluation Results
# 5.1 confusion matrix
test.response <- factor(test.response, levels = levels(test.pred$class))
confusionMatrix(data = test.pred$class, reference = test.response)

# 5.2 accuracy and comparison with NIR 
print(paste("Training accuracy =", train.acc))
print(paste("Testing accuracy =", test.acc))
# "Training accuracy = 0.416347731000547"
# "Testing accuracy = 0.430601092896175"
# NIR = 0.4175 

# 5.3 class specific statistics (precision, recall, F1 score, etc.)
# Precision, Recall, and F1 Score Calculation for Class "ba"
precision_ba <- 0.2
recall_ba <- 0.005263
f1_score_ba <- 2 * (precision_ba * recall_ba) / (precision_ba + recall_ba)

# Precision, Recall, and F1 Score Calculation for Class "be"
precision_be <- 0.40491
recall_be <- 0.19242
f1_score_be <- 2 * (precision_be * recall_be) / (precision_be + recall_be)

# Precision, Recall, and F1 Score Calculation for Class "zh"
precision_zh <- 0.4378
recall_zh <- 0.856
f1_score_zh <- 2 * (precision_zh * recall_zh) / (precision_zh + recall_zh)

# Print F1 Scores
cat("F1 Score (ba):", f1_score_ba, "\n")
cat("F1 Score (be):", f1_score_be, "\n")
cat("F1 Score (zh):", f1_score_zh, "\n")

