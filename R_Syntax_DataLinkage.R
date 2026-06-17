###############################################################################
# Created by: Ali Mirzazadeh
# For questions or assistance: ali.mirzazadeh@ucsf.edu
###############################################################################

#############################
### Deterministic linkage ###
#############################

# Dataset A: Patient Registry
patient_registry <- data.frame(
  Name = c("John Smith", "Mary Johnson", "Robert Brown"),
  MRN = c(847291, 562834, 913675),
  DOB = c("1/15/80", "5/22/75", "11/8/90")
)

# Dataset B: Death Records
death_records <- data.frame(
  ID = c(562834, 847291, 913675),
  Date_of_Death = c("8/15/24", "3/10/25", "12/1/24")
)

# Deterministic linkage using MRN / ID
merged_data <- merge(
  patient_registry,
  death_records,
  by.x = "MRN",
  by.y = "ID",
  all = TRUE
)

# View merged dataset
print(merged_data)

############################
###### Fuzzy matching ######
############################

# Install packages if needed
# install.packages("fuzzyjoin")
# install.packages("dplyr")

library(fuzzyjoin)
library(dplyr)

# Dataset A: Patient Registry
patient_registry <- data.frame(
  Name = c("John Smith", "Mary Johnson", "Robert Brown"),
  DOB = c("1980-01-15", "1975-05-22", "1990-11-08"),
  stringsAsFactors = FALSE
)

# Dataset B: Death Records
death_records <- data.frame(
  Full_Name = c("Jon Smith", "Mary Jonson", "Robert Brown"),
  Date_of_Death = c("2025-03-10", "2024-08-15", "2024-12-01"),
  stringsAsFactors = FALSE
)

# Fuzzy match on name using string distance
# max_dist controls how different the names can be and still match
matches <- stringdist_left_join(
  patient_registry,
  death_records,
  by = c("Name" = "Full_Name"),
  method = "jw",      # Jaro-Winkler similarity
  max_dist = 0.15,    # smaller = stricter matching
  distance_col = "distance"
)
print(matches)

# Keep only matched records and make a similarity score
matches2 <- matches %>%
  filter(!is.na(Full_Name)) %>%
  mutate(similarity = 1 - distance) %>%
  select(Name, DOB, Full_Name, Date_of_Death, similarity)

print(matches2)


#############################
### Probabilistic linkage ###
#############################

library(stringdist)
library(dplyr)

# Dataset A: Patient Registry
patient_registry <- data.frame(
  Name = c("John Smith", "Mary Johnson", "Robert Brown"),
  DOB  = as.Date(c("1980-01-15", "1975-05-22", "1990-11-08")),
  stringsAsFactors = FALSE
)

# Dataset B: Death Records
death_records <- data.frame(
  Full_Name = c("Jon Smith", "Mary Jonson", "Robert Brown"),
  DOB  = as.Date(c("1980-01-15", "1975-06-10", "1990-11-08")),  # Mary is within 30 days
  Date_of_Death = as.Date(c("2025-03-10", "2024-08-15", "2024-12-01")),
  stringsAsFactors = FALSE
)

# Create all possible pairs
pairs <- merge(patient_registry, death_records, by = NULL)

# Name similarity (Jaro-Winkler)
pairs$name_similarity <- 1 - stringdist(
  pairs$Name,
  pairs$Full_Name,
  method = "jw"
)

# DOB difference in days
pairs$dob_diff_days <- abs(as.numeric(pairs$DOB.x - pairs$DOB.y))

# DOB similarity: exact match = 1, within 30 days = 0.9, otherwise = 0
pairs$dob_similarity <- ifelse(
  pairs$dob_diff_days == 0, 1,
  ifelse(pairs$dob_diff_days <= 30, 0.9, 0))

# Combined probabilistic score
pairs$prob_score <- 0.7 * pairs$name_similarity + 0.3 * pairs$dob_similarity
print(pairs)

# Keep likely matches
matches <- pairs %>%
  filter(prob_score >= 0.90) %>%
  select(Name, DOB.x, Full_Name, DOB.y, Date_of_Death,
         name_similarity, dob_similarity, prob_score)

print(matches)


##############################
### Fellegi-Sunter linkage ###
##############################

# The RecordLinkage package implements the Fellegi-Sunter
# probabilistic record linkage framework.
library(RecordLinkage)
library(dplyr)

# Dataset A: Patient Registry
#--------------------------------------------------
patient_registry <- data.frame(
  id1 = 1:3,
  Name = c("John Smith", "Mary Johnson", "Robert Brown"),
  DOB  = as.Date(c("1980-01-15", "1975-05-22", "1990-11-08")),
  stringsAsFactors = FALSE
)

# Dataset B: Death Records
#--------------------------------------------------
death_records <- data.frame(
  id2 = 1:3,
  Full_Name = c("Jon Smith", "Mary Jonson", "Robert Brown"),
  DOB  = as.Date(c("1980-01-15", "1975-06-10", "1990-11-08")),
  Date_of_Death = as.Date(c("2025-03-10", "2024-08-15", "2024-12-01")),
  stringsAsFactors = FALSE
)

# Prepare comparison datasets
#--------------------------------------------------
# Compare the same field names in both files.
# Keep the original death_records for the final output.
patient_compare <- patient_registry[, c("Name", "DOB")]
death_compare <- death_records[, c("Full_Name", "DOB")]
names(death_compare)[1] <- "Name"

# Compare records
#--------------------------------------------------
# Name is compared using approximate string matching.
# DOB is compared as an exact field.
rpairs <- compare.linkage(
  patient_compare,
  death_compare,
  strcmp = 1,
  strcmpfun = jarowinkler
)

# Estimate Fellegi-Sunter weights
# Calculates weights for Record Linkage based on an EM algorithm.
#--------------------------------------------------
rpairs <- emWeights(rpairs)

# Classify candidate pairs
#--------------------------------------------------
# Choose a threshold
thr = 0

# Match: Weight >= thr
# Possible Match: thr - 1 <= Weight < thr
# Non-Match: Weight < thr - 1
rpairs <- emClassify(
  rpairs,
  threshold.upper = thr,
  threshold.lower = thr-1
)

# Extract matched pairs
#--------------------------------------------------
pairs_df <- getPairs(rpairs, single.rows = TRUE)

# Add classification based on the Fellegi-Sunter weight
pairs_df <- pairs_df %>%
  mutate(
    match_status = case_when(
      Weight >= thr ~ "Match",
      Weight >= (thr - 1) & Weight < thr ~ "Possible Match",
      TRUE ~ "Non-Match"
    )
  )

# View results
pairs_df %>%
  select(id1,Name.1,DOB.1, id2,Name.2,DOB.2, Weight, match_status)


# Keep only the matched pairs
matched_pairs <- pairs_df %>%
  filter(match_status == "Match" | match_status == "Possible Match")

# Create final linked dataset
#--------------------------------------------------
final_linked_data <- matched_pairs %>%
  select(id1, id2, Weight,match_status) %>%
  left_join(patient_registry, by = "id1") %>%
  left_join(death_records, by = "id2", suffix = c("_x", "_y")) %>%
  select(
    Name,
    DOB_x,
    Full_Name,
    DOB_y,
    Date_of_Death,
    Weight,
    match_status
  ) %>%
  arrange(desc(Weight))

# View the final matched resutls 
print(final_linked_data)
