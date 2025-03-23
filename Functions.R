extract_state <- function(text) {
  # Vector of state names in lowercase and their corresponding two-letter abbreviations
  state_names <- c(
    "alabama" = "AL", "alaska" = "AK", "arizona" = "AZ", "arkansas" = "AR", "california" = "CA", 
    "colorado" = "CO", "connecticut" = "CT", "delaware" = "DE", "florida" = "FL", "georgia" = "GA",
    "hawaii" = "HI", "idaho" = "ID", "illinois" = "IL", "indiana" = "IN", "iowa" = "IA", 
    "kansas" = "KS", "kentucky" = "KY", "louisiana" = "LA", "maine" = "ME", "maryland" = "MD", 
    "massachusetts" = "MA", "michigan" = "MI", "minnesota" = "MN", "mississippi" = "MS", 
    "missouri" = "MO", "montana" = "MT", "nebraska" = "NE", "nevada" = "NV", "new hampshire" = "NH", 
    "new jersey" = "NJ", "new mexico" = "NM", "new york" = "NY", "north carolina" = "NC", 
    "north dakota" = "ND", "ohio" = "OH", "oklahoma" = "OK", "oregon" = "OR", "pennsylvania" = "PA", 
    "rhode island" = "RI", "south carolina" = "SC", "south dakota" = "SD", "tennessee" = "TN", 
    "texas" = "TX", "utah" = "UT", "vermont" = "VT", "virginia" = "VA", "washington" = "WA", 
    "west virginia" = "WV", "wisconsin" = "WI", "wyoming" = "WY"
  )
  
  state_codes <- c(
    ", al" = "AL", ", ak" = "AK", ", az" = "AZ", ", ar" = "AR", ", ca" = "CA", 
    ", co" = "CO", ", ct" = "CT", ", de" = "DE", ", fl" = "FL", ", ga" = "GA",
    ", hi" = "HI", ", id" = "ID", ", il" = "IL", ", in" = "IN", ", ia" = "IA", 
    ", ks" = "KS", ", ky" = "KY", ", la" = "LA", ", me" = "ME", ", md" = "MD", 
    ", ma" = "MA", ", mi" = "MI", ", mn" = "MN", ", ms" = "MS", ", mo" = "MO", 
    ", mt" = "MT", ", ne" = "NE", ", nv" = "NV", ", nh" = "NH", ", nj" = "NJ", 
    ", nm" = "NM", ", ny" = "NY", ", nc" = "NC", ", nd" = "ND", ", oh" = "OH", 
    ", ok" = "OK", ", or" = "OR", ", pa" = "PA", ", ri" = "RI", ", sc" = "SC", 
    ", sd" = "SD", ", tn" = "TN", ", tx" = "TX", ", ut" = "UT", ", vt" = "VT", 
    ", va" = "VA", ", wa" = "WA", ", wv" = "WV", ", wi" = "WI", ", wy" = "WY"
  )
  
  # Convert the input text to lowercase for case-insensitive matching
  text_lower <- tolower(text)
  
  # Check if any lowercase state name is present in the text
  for (state_name in names(state_names)) {
    if (grepl(state_name, text_lower)) {
      return(state_names[state_name])
    }
  }
  
  for (state_code in names(state_codes)) {
    if (grepl(state_code, text_lower)) {
      return(state_codes[state_code])
    }
  }
  
  # If no match is found
  return(NA)
}


