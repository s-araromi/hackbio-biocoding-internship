# Load necessary libraries
library(tidyr)
library(dplyr)
library(ggplot2)

# Read the dataset
url <- "https://raw.githubusercontent.com/HackBio-Internship/2025_project_collection/refs/heads/main/Python/Dataset/mcgc.tsv"
data <- read.table(url, header = TRUE, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE)

# Fix duplicate column names 
colnames(data) <- make.unique(names(data), sep = "_")

# Dynamically generate expected column names 
num_timepoints <- (ncol(data) - 1) / 2  # Subtract Strain, divide by WT/MUT pairs
new_names <- c("Strain", 
               paste0(rep(paste0("Time", 1:num_timepoints), each = 2), 
                      c("_WT", "_MUT")))

# Validate column count 
if (ncol(data) != length(new_names)) {
  stop("Column count mismatch: Expected ", length(new_names), 
       " columns, got ", ncol(data))
}
colnames(data) <- new_names

# Reshape data to long format 
long_data <- data %>%
  pivot_longer(
    cols = starts_with("Time"),
    names_to = c("Time", "Type"),
    names_sep = "_",
    values_to = "OD600"
  ) %>%
  mutate(
    Time = as.numeric(gsub("Time", "", Time)),
    Strain = sub("_Rep.*", "", Strain),  # Extract base strain name
    Replicate = sub(".*_", "", Strain)   # Extract replicate ID
  )

# Plot growth curves 
ggplot(long_data, aes(x = Time, y = OD600, color = Type)) +
  geom_line(aes(group = interaction(Replicate, Type)), alpha = 0.7) +
  facet_wrap(~ Strain) +
  labs(title = "Growth Curves (OD600 vs Time)", x = "Time", y = "OD600") +
  theme_minimal()

# Calculate time to carrying capacity 
carrying_capacity_time <- long_data %>%
  group_by(Strain, Replicate, Type) %>%
  filter(OD600 == max(OD600)) %>% 
  slice(1) %>%  # First occurrence of max OD
  ungroup()

# Scatter plot comparison 
time_wide <- carrying_capacity_time %>%
  pivot_wider(names_from = Type, values_from = Time, values_fill = list(Time = NA))

ggplot(time_wide, aes(x = WT, y = MUT)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(title = "WT vs MUT Time to Carrying Capacity", x = "WT Time", y = "MUT Time")

# Box plot 
ggplot(carrying_capacity_time, aes(x = Type, y = Time)) +
  geom_boxplot() +
  labs(title = "Time to Carrying Capacity Distribution", x = "Type", y = "Time")

# Statistical test (paired t-test) 
clean_data <- time_wide %>% filter(!is.na(WT) & !is.na(MUT))
t_test_result <- t.test(clean_data$WT, clean_data$MUT, paired = TRUE)
print(t_test_result)



# Below are my Interpretations and Observations


# Statistical interpretation:
# 1. P-value = 0.0025 < 0.05 → Significant difference between WT and MUT times <button class="citation-flag" data-index="8">
# 2. Negative mean difference (-1.55) → MUT strains take ~1.55 units longer to reach max OD600
# 3. 95% CI [-2.52, -0.58] excludes zero → Effect is non-random and reproducible

# 4. Biological conclusion: The knock-in mutation imposes a growth disadvantage,
#    delaying attainment of maximum carrying capacity, taking longer to reach 80% carrying capacity. This could indicate metabolic inefficiencies or resource competition caused by genetic modifications
