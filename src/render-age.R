library(stringr)

# render_age <- function(age){
#   age_number <- floor(age)
#   if (age>=2) {
#     return(str_c(age_number, " years"))
#   } else if(age>=1) {
#     months_number <- round(12*(age-1), digits = 0)
#     if (months_number==1){
#       return(str_c("1 year, ", months_number, " month"))
#     } else if(months_number>1){
#       return(str_c("1 year, ", months_number, " months"))
#     } else {
#       return(str_c("1 year"))
#     }
#   } else {
#     months_number <- round(12*(age), digits = 0)
#     if(months_number>1){
#       return(str_c(months_number, " months"))
#     } else if(months_number==1){
#       return(str_c("1 month"))
#     } else {
#       return("less than 30 days")
#     }
#   }
# }

render_age <- function(age){
  age_number <- floor(age)
  months_number <- round(12*(age-age_number), digits = 0)
                           
  age_string <- case_when(
    age_number >= 2 ~ str_c(age_number, " years"),
    (age_number==1) & (months_number>1) ~ str_c("1 year, ", months_number, " months"),
    (age_number==1) & (months_number==1) ~ str_c("1 year, ", months_number, " month"),
    (age_number==1) & (months_number==0) ~ str_c("1 year"),
    (age_number==0) & (months_number>1) ~ str_c(months_number, " months"),
    (age_number==0) & (months_number==1) ~ str_c(months_number, " month"),
    (age_number==0) & (months_number==0) ~ str_c("less than 30 days")
  )
  return(age_string)
} 
