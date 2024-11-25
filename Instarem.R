library(httr)
library(jsonlite)
library(tidyverse)

# Define tier dictionaries
tier1 <- list("KRW" = "Korea",
              "CNY" = "China",
              "HKD" = "Hong Kong",
              "SGD" = "Singapore",
              "AUD" = "Australia",
              "USD" = "New Zealand")

tier2 <- list("INR" = "India",
              "USD" = "Japan",
              "USD" = "America",
              "GBP" = "England",
              "THB" = "Thailand",
              "EUR" = "Europe")

tier3 <- list("IDR" = "Indonesia",
              "PHP" = "Philipines",
              "BDT" = "Bangladesh",
              "VND" = "Vietnam",
              "PKR" = "Pakistan",
              "NPR" = "Nepal")

url <- "https://www.instarem.com/api/v1/public/transaction/computed-value"

# Open CSV file for writing
con <- file("Instarem.csv", "w")

# Write header
write.table(data.frame(paste0("Instarem Rates as of ", as.character(Sys.time()))), file = con, row.names = FALSE, col.names = FALSE,sep = ',')
write.table(data.frame(""), file = con, append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(data.frame(""), file = con, append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(data.frame("Country", "Currency", "Amount", "Counter Rate", "Service Charge (RM)", "Receivable Amount", "Tier"), file = con, row.names = FALSE,col.names = FALSE,sep = ',')

# Close CSV file
close(con)

# Iterate over tiers
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
    
    query_params <- list(
    source_currency = "MYR",
    destination_currency = tier,
    instarem_bank_account_id = "26",
    source_amount = transfer_amount_my,
    country_code = "MY"
    )
  
    headers <- c(
    "authority" = "www.instarem.com",
    "accept" = "*/*",
    "accept-language" = "en-US,en;q=0.9",
    "referer" = "https://www.instarem.com/en-my/",
    "^sec-ch-ua" = "^Chromium^;v=^122^, ^Not",
    "sec-ch-ua-mobile" = "?0",
    "^sec-ch-ua-platform" = "^Windows^^^",
    "sec-fetch-dest" = "empty",
    "sec-fetch-mode" = "cors",
    "sec-fetch-site" = "same-origin",
    "user-agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "x-requested-with" = "XMLHttpRequest"
    )
    
    # Fetch data from Instarem API
    r <- GET(url, query = query_params, add_headers(.headers=headers))
    data <- content(r, "parsed")
    cat('start scraping...',tier)
    cat ('\n')
    
    country <- currency_tier[[tier]]
    destination_currency <- tier
    gross_source_amount <- data$data$gross_source_amount
    instarem_fx_rate <- data$data$instarem_fx_rate
    regular_transaction_fee_amount <- data$data$regular_transaction_fee_amount
    
    destination_amount <- round((gross_source_amount- regular_transaction_fee_amount)*instarem_fx_rate,2)
    
    col <- file("Instarem.csv", "a")
    # Append to CSV file
    write.table(data.frame(country, destination_currency, gross_source_amount, instarem_fx_rate, regular_transaction_fee_amount, destination_amount, i), file = col, append = TRUE, row.names = FALSE, col.names = FALSE, sep = ',')
    close(col)  
  }
  
  # Sys.sleep(60)
}

cat("========== End of Script ==========\n")
