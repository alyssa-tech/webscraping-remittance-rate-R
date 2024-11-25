library(httr)
library(jsonlite)
library(tidyverse)

# Define tier dictionaries
tier1 <- list("KRW-KR" = "Korea",
              "CNY-CN" = "China",
              "HKD-HK" = "Hong Kong",
              "SGD-SG" = "Singapore",
              "AUD-AU" = "Australia",
              "NZD-NZ" = "New Zealand")

tier2 <- list("INR-IN" = "India",
              "JPY-JP" = "Japan",
              "USD-US" = "America",
              "GBP-GB" = "England",
              "THB-TH" = "Thailand",
              "EUR-DE" = "Europe")

tier3 <- list("IDR-ID" = "Indonesia",
              "PHP-PH" = "Philipines",
              "BDT-BD" = "Bangladesh",
              "VND-VN" = "Vietnam",
              "PKR-PK" = "Pakistan",
              "NPR-NP" = "Nepal")

sunway_api <- "https://sunwaymoney.com/information/getRate/"

# Open CSV file for writing
con <- file("Sunway Money.csv", "w")

# Write header
write.table(data.frame(paste0("Sunway Money Rates as of ", as.character(Sys.time()))), file = con, row.names = FALSE, col.names = FALSE,sep = ',')
write.table(data.frame(""), file = con, append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(data.frame(""), file = con, append = TRUE, row.names = FALSE, col.names = FALSE)
write.table(data.frame("Country", "Currency", "Amount", "Counter Rate", "Service Charge (RM)", "Receivable Amount", "Tier"), file = con, row.names = FALSE,col.names = FALSE,sep = ',')

# Close CSV file
close(con)

for (j in 1:3) {
  
  if (j == 1) {
    transfer_amount_my <- 5000
    currency_tier <- tier1
  } else if (j == 2) {
    transfer_amount_my <- 10000
    currency_tier <- tier2
  } else {
    transfer_amount_my <- 5000
    currency_tier <- tier3
  }
  
  cat('\n\n\n')
  cat(paste0("Tier", i, "\n\n"))
  #loop over currency in  each tier
  for (tier in names(currency_tier)) {
    url <- paste0(sunway_api, tier)
    headers <- c(
      Accept = "*/*",
      `Accept-Language` = "en-US,en;q=0.9",
      Connection = "keep-alive",
      Cookie = "_gac_UA-112005561-2=1.1709880082.CjwKCAiA6KWvBhAREiwAFPZM7rmud8f2F9vBzy3LgFX6mPHp3n5cZpr6gTNijCnXJYX5wiGRmxZcdxoCY_oQAvD_BwE; _gcl_aw=GCL.1709880082.CjwKCAiA6KWvBhAREiwAFPZM7rmud8f2F9vBzy3LgFX6mPHp3n5cZpr6gTNijCnXJYX5wiGRmxZcdxoCY_oQAvD_BwE; _gcl_au=1.1.1203821574.1709880082; _fbp=fb.1.1709880081820.45955372; _gid=GA1.2.791087410.1710143670; _ga_D1W1DQRJBP=GS1.1.1710147093.2.1.1710147398.55.0.0; _ga=GA1.1.989809730.1709880082; _ga_4YBC36Y7ZQ=GS1.1.1710147077.3.1.1710147472.60.0.0",
      `Sec-Fetch-Dest` = "empty",
      `Sec-Fetch-Mode` = "cors",
      `Sec-Fetch-Site` = "same-origin",
      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
      `X-Requested-With` = "XMLHttpRequest",
      `^sec-ch-ua` = "^Chromium^;v=^122^, ^Not",
      `sec-ch-ua-mobile` = "?0",
      `^sec-ch-ua-platform` = "^Windows^^^"
    )
    
    # Fetch data from Instarem API
    r <- GET(url, add_headers(.headers=headers))
    data <- content(r, "parsed")
    cat('start scraping...',tier)
    cat ('\n')
    
    # Get rate
    country <- currency_tier[[tier]]
    destination_currency <- tier
    currency<-gsub("-.*", "", destination_currency)
    sunway_rate <- as.numeric(data$myrRate)
    
    
    # Define function to get fee
    get_fee <- function() {
      if (destination_currency == 'JPY-JP') {
        if (transfer_amount_my > 30000) {
          fee <- 1
        } else {
          fee <- 8
        }
      } else if (destination_currency == "THB-TH") {
        if (transfer_amount_my > 5000) {
          fee <- 1
        } else {
          fee <- 8
        }
      } else {
        fee <- 8
      }
      return(fee)
    }
    
    # Calculate total amount
    total_amount <- (transfer_amount_my - get_fee()) * sunway_rate
    destination_amount <- sprintf("%.2f", total_amount)
    item = c(country, currency, transfer_amount_my, sunway_rate, get_fee(), destination_amount, j)
    
    
    col <- file("Sunway Money.csv", "a")
    
    # Append to CSV file
    write.table(data.frame(country, currency, transfer_amount_my, sunway_rate, get_fee(), destination_amount, j), file = col, append = TRUE,  row.names = FALSE, col.names = FALSE, sep = ',')
    
    close(col)
    }
  # Sys.sleep(60)
}

cat("========== End of Script ==========\n")
