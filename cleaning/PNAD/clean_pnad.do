forvalues y = 2001(1)2015 {

local filepath "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/data/PNAD/dta files/pnad`y'pes.dta" // Replace with your file name and extension

// Check if the file exists
if (fileexists("`filepath'")) {
	use "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/data/PNAD/dta files/pnad`y'pes.dta", clear

*************************************Rename variables
ren v0101 year 

*Basic demographs
ren v0301 order
ren v0302 sex
ren v3033 birthyr
ren v0401 relation_hh
ren v0402 relation_family
ren v0403 family_num
ren v0404 race



**Education
ren v0602 is_school


**Work
ren v9001 employ
ren v9906 main_occ
ren v9907 main_industry
ren v9029 employee_nonagri //Excluding agricultral activity
ren v9032 main_sector
ren v9532def main_monthly_inc
ren v9058 main_hrs // Hours per week
ren v9611 main_years
ren v9892 age_work

**Unemployment
ren v9067 employed_1year
ren v9971 prev_occ
ren v9972 prev_industry
ren v9077 prev_employee
ren v9078 prev_sector
ren v9106 employed_ever
ren v1091 yrs_ago_lastjob
ren v1092 months_ago_lastjob
ren v9910 prev_occ_last
ren v9911 prev_industry_last
ren v9112 prev_employee_last
ren v9115 look_job1
ren v9116 look_job2
ren v9117 look_job3


**************************Labels

label variable birthyr "birth year"
label variable relation_hh "status of ind in the household"
label variable relation_family "status of ind in the family"
label variable family_num "Family number"
label variable race "Race"
label variable is_school "Is attending school?"
label variable employ "is currently employed?"
label variable main_occ "Main occupation"
label variable main_industry "Main industry"
label variable employee_nonagri "Is employee/self employed etc in nonagriculture?"
label variable main_sector "Private or public sector?"
label variable main_monthly_inc "Monthly income of main job (in 2012 dollars)"
label variable main_years "Number of years in main job"
label variable age_work "Age at which start work"
label variable prev_occ "Previous occupation"
label variable prev_industry "Previous industry"
label variable prev_employee "Is employee/self employed at previous job"
label variable prev_sector "Private or public sector at previous job?"
label variable employed_1year "Is employed within the last year?"
label variable employed_ever "If unemployed within the last year, is employed before?"
label variable yrs_ago_lastjob "How many years ago was last job if employed ever"
label variable months_ago_lastjob "How many (years and) months ago was last job if employed ever"
label variable prev_occ_last "Last occ if ever employed"
label variable prev_industry_last "Last industry if ever employed"
label variable prev_employee_last "Was employee/self employed etc?"
label variable look_job1 "Did look for job wthin the last week (sep 21-27)?"
label variable look_job2 "Did look for job wthin the aug 29 - sep 20?"
label variable look_job3 "Did look for job jul 30 - aug 28?"
label variable main_hrs "Hours per week in main occupation"

drop v*

* Labeling values

label define employlbl 1 "yes" 3 "no"
label values employ employlbl
label values employed_1year employlbl
label define employed_everlbl 2 "yes" 4 "no"
label values employed_ever employed_everlbl
label define sexlbl 2 "male" 4 "female"
label values sex sexlbl
label define relation 1 "reference person" 2"spouse" 3 "son/daughter" 4 "another relative" 5 "not related" 6"pensioner" 7 "domestic employee" 8 "relative of the domestic employee"
label values relation_hh relation 
label values relation_family relation
*label define married_stt_lbl 1 "married" 3 "divorced/separated" 5"divorced" 7"widower" 0 "single"
*label values marital_stt married_stt_lbl

gen prev_occ2 = prev_occ
replace prev_occ2 = prev_occ_last if missing(prev_occ) 
label variable prev_occ2 "Most recent occupation if not employed in the reference week"

gen prev_industry2 = prev_industry
replace prev_industry2 = prev_industry_last if missing(prev_industry)
label variable prev_industry2 "Most recent industry if not employed in the reference week"


*************************Occupations
tempfile pnad
save `pnad', replace

use "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/age_discrimination/output/data/PNAD/occ_trans.dta", clear

ren occ_code main_occ
ren occ_name main_occ_name
merge 1:m main_occ using`pnad'
drop if _merge == 1
drop _merge

save "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/age_discrimination/output/data/PNAD/cleaned/cleaned_`y'.dta", replace

  
} 
else {
    display "File does not exist"
}

}
