#' @title Identify Misclassified Sites in a Random Forest Model  
#' @description This function uses a trained random forest model to make predictions 
#' on a set of site attributes and compares the predictions with the actual site 
#' categories to identify misclassified sites.  
#' 
#' @param RFoptimized A trained random forest model object.  
#' @param sitedata A tibble containing the site attributes used for predictions. 
#' Must include the column `site_category_fact` (the actual category for each site) 
#' and `site_no` (a unique identifier for each site).  
#' 
#' @returns A data frame containing the site number, actual category, predicted 
#' category, and a logical column `Misclassified` indicating whether each site 
#' was misclassified (`TRUE`) or not (`FALSE`).  
#' 
#' @examples 
#' # Assuming `RFoptimized` is a trained random forest model and `p5_site_attr` 
#' # is a data frame with site attributes:
#' misclassified <- find_misclassifiedRF(RFoptimized, p5_site_attr)
#' print(misclassified)

misclassified_randomforest <- function(RFoptimized, sitedata) {

  # Make predictions on the test set
  predictions <- predict(RFoptimized, sitedata)
  
  # predict(p5_rf_model_optimized, a)
  
  # Get the actual values from the test set
  actual_values <- sitedata$site_category_fact
  
  # Create a data frame to compare predictions and actual values
  comparison_df <- data.frame(
    site = sitedata$site_no,
    Actual = actual_values,
    Predicted = predictions
  )
  
  # Identify misclassified sites
  comparison_df$Misclassified <- comparison_df$Actual != comparison_df$Predicted
  
  # Display the misclassified sites
  misclassified_sites <- comparison_df[comparison_df$Misclassified, ]
  
  # Print the misclassified sites
  return(misclassified_sites)
}
