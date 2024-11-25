library(httr)
library(jsonlite)

# Define Variables
wise_api <- "https://wise.com/gateway/v3/comparisons?"
sourceCurrency <- "MYR"

# Define tier dictionaries
tier1 <- list(
  "KRW" = "Korea",
  "CNY" = "China",
  "HKD" = "Hong Kong",
  "SGD" = "Singapore",
  "AUD" = "Australia",
  "NZD" = "New Zealand"
)

tier2 <- list(
  "INR" = "India",
  "JPY" = "Japan",
  "USD" = "America",
  "GBP" = "England",
  "THB" = "Thailand",
  "EUR" = "Europe"
)

tier3 <- list(
  "IDR" = "Indonesia",
  "PHP" = "Philipines",
  "BDT" = "Bangladesh",
  "VND" = "Vietnam",
  "PKR" = "Pakistan",
  "NPR" = "Nepal"
)

# Open CSV file for writing
con <- file("Wise.csv", "w")

# Write header
write.table(data.frame(paste0("Wise Rates as of ", as.character(Sys.time()))), file = con, row.names = FALSE, col.names = FALSE)
write.table(data.frame(""), file = con, append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(data.frame(""), file = con, append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(data.frame("Country", "Currency", "Amount", "Counter Rate", "Service Charge (RM)", "Receivable Amount", "Tier"), file = con, append = TRUE, row.names = FALSE, col.names = FALSE, sep = ',')

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
    targetCurrency <- tier
    url <- paste0(wise_api, "sourceCurrency=", sourceCurrency, "&targetCurrency=", targetCurrency, "&sendAmount=", transfer_amount_my)
    
    #cat(paste0("\tRequesting: ", url, "\n"))
    cat('start scraping...',tier)
    cat ('\n')
    
    # Fetch data from Wise API
    wise_api_call <- GET(url)
    page <- content(wise_api_call, as = "parsed")
    list_of_providers <- page$providers
    
    for (provider in list_of_providers) {
      if (provider$alias == "wise") {
        wise_rates <- provider$quotes[[1]]
        rate <- wise_rates$rate
        fee <- wise_rates$fee
        receivedAmount <- wise_rates$receivedAmount
        
        # Append to CSV file
        con <- file("Wise.csv", "a")
        write.table(data.frame(country = currency_tier[tier], 
                             targetCurrency, 
                             transfer_amount_my, 
                             rate, 
                             fee, 
                             receivedAmount, 
                             i), 
                  file = con, 
                  row.names = FALSE, 
                  col.names = FALSE, 
                  append = TRUE, sep = ',')
        close(con)
      }
    }
  }
}

cat("========== End of Script ==========\n")



