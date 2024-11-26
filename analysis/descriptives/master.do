*************** AGE DISCRIMINATION MASTERFILE***********************************

cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"
global start_year "04"
global end_year = "12"
* Convert the string global to a numeric local
local start_year_num = real("$start_year")

* Check if the numeric value is greater than 15
if `start_year_num' > 15 {
    * If true, create a local macro with "1986"
    global full_start_yr "19$start_year"
} 
else {
    * Otherwise, handle cases where the condition is not met (optional)
    global full_start_yr "20$start_year"
}
 
*Append datasets
do "code/analysis/descriptives/append.do"

*Extract VA by industry
do "code/analysis/descriptives/va.do"

*Extract TFP growth
do "code/analysis/descriptives/tfp.do"

***************Exploratory
*Salary by industry, age and occupation 
do "code/analysis/descriptives/binscatter_occ.do" 
*do "code/analysis/descriptives/binscatter_occ_year.do" 

