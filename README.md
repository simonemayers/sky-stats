# Airline Flight Data Analysis - README

This project provides a comprehensive data quality and exploratory data analysis (EDA) report on airline flight data. The analysis focuses on understanding patterns, identifying data quality issues, and uncovering insights regarding flight delays, cancellations, aircraft types, and more.

## Project Structure

The project is organized as follows:

1. **Data Loading and Preparation**
   - The dataset `flight_delays.csv` is loaded and cleaned.
   - Missing values and empty strings are identified and replaced as needed.
   - Time columns are parsed and converted into proper datetime formats for further analysis.

2. **Continuous Feature Analysis**
   - Aggregates (e.g., counts, missing percentages, cardinalities, statistical measures) are calculated for continuous features such as `DelayMinutes` and `Distance`.
   - A data quality table summarizes these characteristics.

3. **Categorical Feature Analysis**
   - Aggregates (e.g., mode, frequency, cardinalities) are calculated for categorical features, including `Airline`, `FlightNumber`, `Origin`, and `DelayReason`.
   - A summary table presents quality issues and handling strategies for each feature.

4. **Data Visualizations**
   - Histograms, bar plots, and boxplots are used to visualize distributions and relationships among features.
   - Scatterplot matrices and covariance matrices reveal relationships within continuous features, while bar plots compare categorical features such as `Cancelled` by `Airline` and `DelayReason`.

5. **Data Quality Reporting**
   - Issues such as missing values, irregular cardinalities, and outliers are documented in a summary table.
   - Handling strategies are provided for each identified data quality issue.

6. **Normalization and Binning**
   - Continuous features `DelayMinutes` and `Distance` are normalized for consistency.
   - Binning (equal-width and equal-frequency) is applied to selected continuous features to enable categorical analysis.

7. **Sampling Techniques**
   - **Undersampling**: Balances classes in the `TailNumber` feature to prevent bias from over-represented planes.
   - **Oversampling**: Assessed but found unnecessary for most features, ensuring balanced representation without artificially increasing minority classes.

8. **Summary**
   - A final executive summary synthesizes key findings, highlighting insights into delays, cancellations, feature distributions, and data quality considerations.

## Usage Instructions

To execute this analysis:
1. Install necessary R packages:
   ```r
   install.packages("data.table")
   install.packages("dplyr")
   install.packages("ggplot2")
   install.packages("lubridate")
   install.packages("GGally")
   ```
2. Load the dataset `flight_delays.csv` in the root directory.
3. Run the provided R script in RStudio or an R environment that supports RMarkdown to view visualizations and data quality reports.

## Visualizations

- **Histograms** for continuous features, showing the distribution of `DelayMinutes` and `Distance`.
- **Bar Plots** for categorical comparisons, such as `Cancelled` flights by `Airline`.
- **Box Plots** for delay distributions by delay reason and airline.
- **Scatterplot Matrices** and **Covariance/Correlation Matrices** for examining feature relationships.

## Findings and Recommendations

1. **Short Delays** are most common across all airlines, with a few extreme outliers.
2. **Balanced Cancellations** across airlines indicate that these may stem from industry-wide factors.
3. **TailNumber Imbalance** required undersampling to avoid over-representing certain planes.

## Summary Report

The report highlights:
- Data quality issues (e.g., missing values, format inconsistencies).
- Relationships among features, especially regarding delays.
- The need for additional data quality checks and normalization to improve analysis accuracy.

## License

This project is licensed under the MIT License. See `LICENSE` for details.


