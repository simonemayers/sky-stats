# Load necessary libraries
library(data.table)
library(dplyr)
library(lubridate)
library(tidyr)
library(GGally)
library(ggplot2)
library(scales)


# The Data Quality Report
# Load dataset
data <- fread("flight_delays.csv")

# Check for NA values and empty strings
sum(is.na(data$ScheduledDepartureHour))  # Count NA values
sum(data$ScheduledDepartureHour == "", na.rm = TRUE)  # Count empty strings

# Replace empty strings with a default value "00:00"
data$ScheduledDepartureHour[data$ScheduledDepartureHour == ""] <- "00:00"
data$ActualDepartureHour[data$ActualDepartureHour == ""] <- "00:00"
data$ScheduledArrivalHour[data$ScheduledArrivalHour == ""] <- "00:00"
data$ActualArrivalHour[data$ActualArrivalHour == ""] <- "00:00"

# Replace any rows that fail to parse with NA
data$ScheduledDepartureHour[is.na(hm(data$ScheduledDepartureHour))] <- NA

# Convert the time columns to Period format using hm()
data$ScheduledDepartureHour <- hm(data$ScheduledDepartureHour)
data$ActualDepartureHour <- hm(data$ActualDepartureHour)
data$ScheduledArrivalHour <- hm(data$ScheduledArrivalHour)
data$ActualArrivalHour <- hm(data$ActualArrivalHour)

# Inspect the structure after conversion
str(data)



## Continuous Features
summary(data[, .(DelayMinutes, Distance)])
continuousFeatureNames <- c("DelayMinutes", "Distance")

continuousFeatureCounts <- sapply(data[, ..continuousFeatureNames], function(x) sum(!is.na(x)))
continuousFeatureMissingPercents <- sapply(data[, ..continuousFeatureNames], function(x) mean(is.na(x)) * 100)
continuousFeatureCardinalities <- sapply(data[, ..continuousFeatureNames], function(x) length(unique(x)))
continuousFeatureMinimums <- sapply(data[, ..continuousFeatureNames], function(x) min(x, na.rm=TRUE))
continuousFeature1stQuartiles <- sapply(data[, ..continuousFeatureNames], function(x) quantile(x, 0.25, na.rm=TRUE))
continuousFeatureMeans <- sapply(data[, ..continuousFeatureNames], function(x) mean(x, na.rm=TRUE))
continuousFeatureMedians <- sapply(data[, ..continuousFeatureNames], function(x) median(x, na.rm=TRUE))
continuousFeature3rdQuartiles <- sapply(data[, ..continuousFeatureNames], function(x) quantile(x, 0.75, na.rm=TRUE))
continuousFeatureMaximums <- sapply(data[, ..continuousFeatureNames], function(x) max(x, na.rm=TRUE))
continuousFeatureStDevs <- sapply(data[, ..continuousFeatureNames], function(x) sd(x, na.rm=TRUE))


Create Continuous Feature Data Quality Table:
continuousFeatureQualityReportTable <- data.frame(
  Feature=continuousFeatureNames,
  Count=continuousFeatureCounts,
  "Missing %"=continuousFeatureMissingPercents,
  Cardinality=continuousFeatureCardinalities,
  Minimum=continuousFeatureMinimums,
  "First Quartile"=continuousFeature1stQuartiles,
  Mean=continuousFeatureMeans,
  Median=continuousFeatureMedians,
  "Third Quartile"=continuousFeature3rdQuartiles,
  Maximum=continuousFeatureMaximums,
  StDev=continuousFeatureStDevs
)

print(continuousFeatureQualityReportTable)




## Categorical Features
categoricalFeatureNames <- c("Airline", "FlightNumber", "Origin", "Destination", "DelayReason", "Cancelled",
                             "Diverted", "AircraftType", "TailNumber", "ScheduledDepartureDate",
                             "ScheduledDepartureHour","ActualDepartureDate", "ActualDepartureHour", "ScheduledArrivalDate",
                             "ScheduledArrivalHour", "ActualArrivalDate", "ActualArrivalHour")

# Calculate feature counts, missing percentages, and cardinalities for categorical features
categoricalFeatureCounts <- sapply(data[, ..categoricalFeatureNames], function(x) sum(!is.na(x)))
categoricalFeatureMissingPercents <- sapply(data[, ..categoricalFeatureNames], function(x) mean(is.na(x)) * 100)
categoricalFeatureCardinalities <- sapply(data[, ..categoricalFeatureNames], function(x) length(unique(x)))

# Calculate mode, mode frequency, and mode percentage for categorical features
categoricalFeatureModes <- sapply(data[, ..categoricalFeatureNames], function(x) names(sort(-table(x)))[1])
categoricalFeatureModeFrequencies <- sapply(data[, ..categoricalFeatureNames], function(x) max(table(x)))
categoricalFeatureModePercents <- sapply(data[, ..categoricalFeatureNames], function(x) max(table(x))/length(x)*100)


#Create Categorical Feature Data Quality Table:
categoricalFeatureQualityReportTable <- data.frame(
  Feature=categoricalFeatureNames,
  Count=categoricalFeatureCounts,
  "Missing %"=categoricalFeatureMissingPercents,
  Cardinality=categoricalFeatureCardinalities,
  Mode=categoricalFeatureModes,
  "Mode Frequency"=categoricalFeatureModeFrequencies,
  "Mode %"=categoricalFeatureModePercents
)

print(categoricalFeatureQualityReportTable)



# Histograms of Continuous Features
# Create histograms for DelayMinutes and Distance
ggplot(data, aes(x = DelayMinutes)) +
  geom_histogram(binwidth = 2, fill = "purple", color = "black") +
  labs(title = "Distribution of Delay Minutes", x = "Delay Minutes", y = "Frequency")

ggplot(data, aes(x = Distance)) +
  geom_histogram(binwidth = 150, fill = "cyan", color = "black") +
  labs(title = "Distribution of Distance", x = "Flight Distance (Miles)", y = "Frequency")



# Identification of Data Quality Issues

#Consider the missing values, irregular cardinality problems, and outliers. Summarize the **data quality issues** using a three-column table. The first column is the feature name, the second column is the associated data quality issue, and the third column describes potential handling strategies.


# Data Quality Summary for all features

data_quality_issues <- data.frame(
  Feature = c(
    "ScheduledDeparture", "ActualDeparture", "ScheduledArrival", "ActualArrival", 
    "DelayMinutes", "Distance", "Airline", "FlightNumber", "Origin", 
    "Destination", "DelayReason", "Cancelled", "Diverted", "AircraftType", "TailNumber"
  ),
  DataQualityIssue = c(
    "Missing values, Inconsistent time format", 
    "Missing values, Inconsistent time format", 
    "Missing values, Inconsistent time format", 
    "Missing values, Inconsistent time format", 
    "Outliers (negative values), Missing values", 
    "None", 
    "Irregular cardinality (too few airlines)", 
    "No significant issues", 
    "No significant issues", 
    "No significant issues", 
    "Missing values", 
    "No significant issues", 
    "No significant issues", 
    "No significant issues", 
    "No significant issues"
  ),
  HandlingStrategy = c(
    "Convert to proper datetime format, Impute missing values with median or mode", 
    "Convert to proper datetime format, Impute missing values with median or mode", 
    "Convert to proper datetime format, Impute missing values with median or mode", 
    "Convert to proper datetime format, Impute missing values with median or mode", 
    "Remove or adjust negative values, Impute missing values with median", 
    "No action required", 
    "Check for any additional airlines, Ensure all valid airlines are included", 
    "No action required", 
    "No action required", 
    "No action required", 
    "Impute missing values with the most frequent delay reason (mode)", 
    "No action required", 
    "No action required", 
    "No action required", 
    "No action required"
  )
)

# Print the summary table
print(data_quality_issues)



# Scatterplot Matrix
# Scatterplot matrix for continuous features
ggpairs(data, columns = c("DelayMinutes", "Distance"),
        title = "Scatterplot Matrix of Continuous Features")




# Visualizing Pairs of Categorical Features
# Use multiple **barplot visualizations**.
# Bar plot for Airline vs DelayReason
ggplot(data, aes(x = Airline, fill = DelayReason)) +
  geom_bar(position = "dodge") +
  labs(title = "Airline vs Delay Reason", x = "Airline", y = "Count") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))





data_melted <- data %>%
  pivot_longer(cols = c(Cancelled, Diverted), names_to = "FlightStatus", values_to = "Status")

# Plot the data with the new structure
ggplot(data_melted, aes(x = FlightStatus, fill = as.factor(Status))) +
  geom_bar(position = "dodge") +
  labs(title = "Comparison of Cancelled vs Diverted Flights", 
       x = "Flight Status", 
       y = "Count", 
       fill = "Status (True/False)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# Bar plot for Cancelled vs Origin
ggplot(data, aes(x = Origin, fill = as.factor(Cancelled))) +
  geom_bar(position = "dodge") +
  labs(title = "Cancelled Flights by Origin Airport", 
       x = "Origin Airport", 
       y = "Number of Flights", 
       fill = "Cancelled") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability


# Side-by-side bar plot with a log scale
ggplot(data, aes(x = Airline, fill = as.factor(Cancelled))) +
  geom_bar(position = position_dodge(width = 0.8), width = 0.6) +
  labs(title = "Cancelled Flights by Airline (Log Scale)", 
       x = "Airline", 
       y = "Number of Flights (Log Scale)", 
       fill = "Cancelled") +
  scale_y_log10() +  # Apply log scale to the y-axis
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability




# Visualizing Relationship Between a Catergorical and Continuous Feature
#For a subset of the categorical and continuous features, perform **stacked barplot visualizations**. Comment on what you observed.
# Create bins for DelayMinutes
data$DelayCategory <- cut(data$DelayMinutes, 
                          breaks = c(-Inf, 0, 30, 60, Inf), 
                          labels = c("No Delay", "Short Delay", "Moderate Delay", "Long Delay"))
# Stacked bar plot for Airline vs DelayCategory
ggplot(data, aes(x = Airline, fill = DelayCategory)) +
  geom_bar(position = "stack") +
  labs(title = "Delay Category Distribution by Airline", 
       x = "Airline", 
       y = "Number of Flights", 
       fill = "Delay Category") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability



# Stacked bar plot for Airline vs Cancelled
ggplot(data, aes(x = Airline, fill = as.factor(Cancelled))) +
  geom_bar(position = "stack") +
  labs(title = "Cancelled Flights by Airline", 
       x = "Airline", 
       y = "Number of Flights", 
       fill = "Cancelled") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability



# Stacked bar plot for Origin vs Cancelled
ggplot(data, aes(x = Origin, fill = as.factor(Cancelled))) +
  geom_bar(position = "stack") +
  labs(title = "Cancelled Flights by Origin Airport", 
       x = "Origin Airport", 
       y = "Number of Flights", 
       fill = "Cancelled") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability



# Boxplot Visualizations
ggplot(data, aes(x = Airline, y = DelayMinutes)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Delay Minutes by Airline", 
       x = "Airline", 
       y = "Delay Minutes") +
  ylim(0, 30) +  # Adjust the y-axis to zoom in on shorter delays
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability


# Filter out entries with missing delay reasons
filtered_data <- data %>% filter(DelayReason != "")

# Boxplot for DelayMinutes by DelayReason
ggplot(filtered_data, aes(x = DelayReason, y = DelayMinutes)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Delay Minutes by Delay Reason", 
       x = "Delay Reason", 
       y = "Delay Minutes") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability


# Stacked bar plot for Cancelled vs Origin Airport
ggplot(data, aes(x = Origin, fill = as.factor(Cancelled))) +
  geom_bar(position = "stack") +
  labs(title = "Cancelled Flights by Origin Airport", 
       x = "Origin Airport", 
       y = "Number of Flights", 
       fill = "Cancelled") +

  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability


# Covariance Matrix
# Select only the continuous features
continuous_features <- data %>% select(DelayMinutes, Distance)

# Compute the covariance matrix
cov_matrix <- cov(continuous_features, use = "complete.obs")

# Print the covariance matrix
print(cov_matrix)

# Correlation Matrix
# Compute the correlation matrix for the continuous features
cor_matrix <- cor(continuous_features, use = "complete.obs")

# Print the correlation matrix
print(cor_matrix)


# Binning
# Create equal-width bins for DelayMinutes (for example, 4 bins)
delay_bins_equal_width <- cut(data$DelayMinutes, breaks = 4, labels = c("Very Short Delay", "Short Delay", "Moderate Delay", "Long Delay"))

# Display the binned values for DelayMinutes
print("Equal-Width Binned DelayMinutes:")
head(delay_bins_equal_width)


# Create equal-frequency bins for Distance (for example, 4 bins)
distance_bins_equal_frequency <- ntile(data$Distance, 4)  # Using ntile() for equal frequency binning

# Convert the numeric bin numbers into labels
distance_bins_equal_frequency <- factor(distance_bins_equal_frequency, labels = c("Short Distance", "Medium Distance", "Long Distance", "Very Long Distance"))

# Display the binned values for Distance
print("Equal-Frequency Binned Distance:")
head(distance_bins_equal_frequency)



# Undersampling
# Check for imbalance in Cancelled
table(data$Cancelled)

# Check for imbalance in Diverted
table(data$Diverted)

# Step 1: Check the frequency of each AircraftType
aircraftnumber_counts <- table(data$AircraftType)
print(aircraftnumber_counts)

# Step 2: Find the minimum number of instances (for undersampling)
min_count <- min(aircraftnumber_counts)
print(min_count)

# Step 3: Apply undersampling to each TailNumber
set.seed(123)  # For reproducibility
undersampled_data <- data %>%
  group_by(AircraftType) %>%
  sample_n(min_count, replace = FALSE) %>%
  ungroup()

# Step 4: Check the distribution after undersampling
table(undersampled_data$AircraftType)





# Oversampling
# Check for imbalance in DelayReason
table(data$DelayReason)
# Check for imbalance in AircraftType
table(data$AircraftType)
# Check for imbalance in Scheduled Departure Date
table(data$ScheduledDepartureDate)
