*********TFP Growth by Industry of the US*************


cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/"
import excel "data/macro/US/major-industry-total-factor-productivity-klems.xlsx", sheet("Annual") cellrange(A3:AO7293) firstrow clear

*Rename variables 
local y = 1987

foreach var of varlist F-AO{
	ren `var' tfp`y'
	local y = `y'+1
}

destring tfp*, force replace

*Only keep growth rates and TFP

keep if Measure == "Total factor productivity"
keep if Units == "% Change from previous year"

*******************Remove the sectors that are too general

* Identify 2-digit codes that have corresponding 3-digit codes
gen two_digit = substr(NAICS, 1, 2)
gen three_digit = substr(NAICS, 1, 3)

* Find 2-digit codes with corresponding 3-digit codes
bysort two_digit (three_digit): gen drop_two_digit = three_digit[_N] != two_digit[_N]

* Drop the 2-digit codes if there are corresponding 3-digit codes
drop if drop_two_digit == 1 & length(NAICS) == 2

*Drop Manufacturing which has other more detailed coded values
drop if NAICS == "MN" | NAICS == "DM" | NAICS == "ND"

*keep only relevant variables
keep NAICS Industry tfp*

ren NAICS naics
ren Industry industry

drop tfp1987 // no obs
*generate tfp_dummy for each year

forvalues y = 1988/2022{
	sum tfp`y', d
	gen tfp_p75_year_dummy`y' = tfp`y' >= `r(p75)'	
}



*Reshape from wide to long
reshape long tfp tfp_p75_year_dummy, i(naics) j(year)

label variable tfp "TFP growth"

save age_discrimination/output/data/US/us_tfp_growth.dta, replace

