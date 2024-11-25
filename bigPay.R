library(jsonlite)
library(httr)
library(tidyverse)


bigPay_api <- "https://bigpayme.com/api/ratesByCountry/?currency=MYR&secret=e0b9ce5414484611e81aa563b0e0b107ebb1a7e8"

# Define tier dictionaries
tier1 <- list("CNY" = "China", "SGD" = "Singapore","AUD" = "Australia")
tier2 <- list("INR" = "India", "GBP" = "England", "THB" = "Thailand", "EUR" = "Europe")
tier3 <- list("IDR" = "Indonesia", "PHP" = "Philipines", "BDT" = "Bangladesh", "VND" = "Vietnam", "NPR" = "Nepal")

# Fetch data from BigPay API
bigPay_data <- GET(bigPay_api) %>%
  content(as = "text", encoding='UTF-8') %>%
  fromJSON(simplifyVector = TRUE)

timestamp <- bigPay_data$timestamp
bigPay_rateDict <- bigPay_data$rates$rates


# Write header to CSV
write.table(data.frame(paste0("Timestamp: ",timestamp)), file = "bigpay.csv", row.names = FALSE, col.names = FALSE)
write.table(data.frame(paste0("Big Pay Rates as of ", as.character(Sys.time()))), file = "bigpay.csv", append = TRUE, col.names = FALSE, row.names = FALSE)
write.table(data.frame(""), file = "bigpay.csv", append = TRUE, col.names = FALSE, row.names = FALSE, sep = ",")
write.table(data.frame("Country", "Currency", "Amount", "Counter Rate", "Service Charge (RM)", "Receivable Amount", "Tier"), file = "bigpay.csv", append = TRUE, col.names = FALSE, row.names = FALSE, sep = ",")

# Write data to CSV
write_to_csv <- function(country, currency, amount, rate, fee, receivable_amount, tier) {
  con <- file("bigpay.csv", "a")
  write.table(data.frame(country, currency, amount, rate, fee, receivable_amount, tier), file=con, append = TRUE, col.names = FALSE, row.names = FALSE, sep = ",")
  close(con)
}

# Loop over tiers
for (i in 1:3) {
  if (i == 1) {
    transfer_amount_my <- 5000
    currency_tier <- tier1} 
  else if (i == 2) {
    transfer_amount_my <- 10000
    currency_tier <- tier2} 
  else {
    transfer_amount_my <- 5000
    currency_tier <- tier3}
  
  cat('\n\n\n')
  cat(paste0("Tier", i, "\n\n"))
  
  #loop over currency in  each tier
  for (tier in names(currency_tier)) {
    cat('start scraping...',tier)
    cat ('\n')
    
    bigPay_rateDict <- bigPay_data$rates$rates[[tier]]
    country <- currency_tier[[tier]]
    currency <- tier
    rate <- bigPay_rateDict$rate
    fee <- bigPay_rateDict$fee
    destination_amount <- round((transfer_amount_my - fee) * rate,2)
    
    
    # Write to CSV
    write_to_csv(country, currency, transfer_amount_my, rate, fee, destination_amount, i)
  }
  # Sys.sleep(60)
}

cat("========== End of Script ==========\n")
