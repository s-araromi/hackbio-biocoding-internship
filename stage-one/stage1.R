### QUESTION 1: DNA to Protein Translation

# DNA codon table (DNA -> amino acid)
codon_table <- c(
  "TTT" = "F", "TTC" = "F", "TTA" = "L", "TTG" = "L",
  "TCT" = "S", "TCC" = "S", "TCA" = "S", "TCG" = "S",
  "TAT" = "Y", "TAC" = "Y", "TAA" = "*", "TAG" = "*",
  "TGT" = "C", "TGC" = "C", "TGA" = "*", "TGG" = "W",
  "CTT" = "L", "CTC" = "L", "CTA" = "L", "CTG" = "L",
  "CCT" = "P", "CCC" = "P", "CCA" = "P", "CCG" = "P",
  "CAT" = "H", "CAC" = "H", "CAA" = "Q", "CAG" = "Q",
  "CGT" = "R", "CGC" = "R", "CGA" = "R", "CGG" = "R",
  "ATT" = "I", "ATC" = "I", "ATA" = "I", "ATG" = "M",
  "ACT" = "T", "ACC" = "T", "ACA" = "T", "ACG" = "T",
  "AAT" = "N", "AAC" = "N", "AAA" = "K", "AAG" = "K",
  "AGT" = "S", "AGC" = "S", "AGA" = "R", "AGG" = "R",
  "GTT" = "V", "GTC" = "V", "GTA" = "V", "GTG" = "V",
  "GCT" = "A", "GCC" = "A", "GCA" = "A", "GCG" = "A",
  "GAT" = "D", "GAC" = "D", "GAA" = "E", "GAG" = "E",
  "GGT" = "G", "GGC" = "G", "GGA" = "G", "GGG" = "G"
)

dna_to_protein <- function(dna) {
  dna <- toupper(dna)
  protein <- ""
  for (i in seq(1, nchar(dna) - 2, by = 3)) {
    codon <- substr(dna, i, i + 2)
    aa <- ifelse(codon %in% names(codon_table), codon_table[codon], "-")
    if (aa == "*") break
    protein <- paste0(protein, aa)
  }
  return(protein)
}

# Example usage:
dna_seq <- "ATGGCCATTGTAATGGGCCGCTGAAAGGGTGCCCGATAG"
cat("Protein sequence:", dna_to_protein(dna_seq), "\n")

### QUESTION 2: Logistic Growth Curve Simulation
simulate_growth <- function(N0 = 1e3, K = 1e9, total_time = 48, 
                           lag_duration, exp_duration) {
  times <- 0:total_time
  population <- numeric(length(times))
  
  # Calculate growth rate based on exponential phase duration
  r <- log(K/N0) / exp_duration
  
  for (i in seq_along(times)) {
    t <- times[i]
    if (t < lag_duration) {
      population[i] <- N0  # Lag phase
    } else {
      adjusted_t <- t - lag_duration
      population[i] <- K / (1 + (K - N0)/N0 * exp(-r * adjusted_t))
    }
  }
  data.frame(time = times, population = population)
}

# Example usage:
set.seed(123)
lag <- sample(2:10, 1)     # Random lag (2-10 hrs)
exp_dur <- sample(10:20, 1) # Random exponential phase (10-20 hrs)
growth_curve <- simulate_growth(lag_duration = lag, exp_duration = exp_dur)
head(growth_curve)

## Generate 100 Growth Curves
set.seed(123)
growth_curves <- lapply(1:100, function(i) {
  lag <- sample(2:10, 1)
  exp_dur <- sample(10:20, 1)
  df <- simulate_growth(lag_duration = lag, exp_duration = exp_dur)
  df$curve_id <- i
  df$lag <- lag
  df$exp_dur <- exp_dur
  df
}) |> dplyr::bind_rows()

# View structure:
str(growth_curves)


### QUESTION 3: Time to 80% Carrying Capacity
time_to_80 <- function(growth_df, K = 1e9) {
  threshold <- 0.8 * K
  times <- growth_df$time
  pop <- growth_df$population
  idx <- which(pop >= threshold)[1]
  ifelse(is.na(idx), NA, times[idx])
}

# Example usage:
time_to_80(growth_curve, K = 1e9)

### QUESTION 4: Hamming Distance
hamming_distance <- function(str1, str2) {
  chars1 <- strsplit(str1, "")[[1]]
  chars2 <- strsplit(str2, "")[[1]]
  max_len <- max(length(chars1), length(chars2))
  length(chars1) <- max_len  # Pad with NA
  length(chars2) <- max_len
  chars1[is.na(chars1)] <- " "
  chars2[is.na(chars2)] <- " "
  sum(chars1 != chars2)
}

# Example usage:
slack <- "Sulaimon Araromi"
twitter <- "@SulaimonAraromi"
cat("Hamming distance:", hamming_distance(slack, twitter), "\n")
