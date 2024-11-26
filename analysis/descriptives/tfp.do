***Extract TFP growth#$*****
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"
import excel "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/macro/China/CIP_4.0_(2023)_4.xlsx", sheet("TFP(LP)") clear

ren A CIP_code
ren B SectorAcronym

local y = 1987
foreach var of varlist C-AG{
	ren `var' tfp_growth`y'
	local y = `y' + 1
}

drop tfp_growth1987
drop if _n < 3
drop if missing(CIP_code)
destring CIP_code, replace force
tempfile tfp
save `tfp', replace

*preserve
import excel "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/sector_match_key.xlsx", sheet("Sheet1") firstrow clear
keep CIPCode SectorAcronym UHSSector H
ren H industry
ren CIPCode CIP_code
drop if missing(CIP_code)

merge m:1 CIP_code using `tfp' 
drop _merge

* Convert the string global to a numeric local
local start_year_num = real("$start_year")

* Check if the numeric value is greater than 15
if `start_year_num' > 15 {
    * If true, create a local macro with "1986"
    local full_start_yr "19$start_year"
} 
else {
    * Otherwise, handle cases where the condition is not met (optional)
    local full_start_yr "20$start_year"
}

local temp = 1 
foreach var of varlist tfp_growth`full_start_yr' - tfp_growth20$end_year{
	local temp `temp' * (`var' + 1)
}
gen tfp_g_`full_start_yr'_20$end_year = (`temp')^.1 - 1

*Merge with VA data to weigh
merge m:1 CIP_code using output/data/va
drop va1987

forvalues y = 1988/2017{
	bysort industry: egen sum_va`y' = sum(va`y')
	gen weight`y' = va`y'/sum_va`y'
}

local varlist 
	forval year = `full_start_yr'(1)20$end_year {
		local varlist `varlist' weight`year'
	}
	egen mean_weight = rowmean(`varlist')
	label variable mean_weight "Average value added weight of CIP in UHS industry"
gen weighted_tfp_g_`full_start_yr'_20$end_year = mean_weight*tfp_g_`full_start_yr'_20$end_year
label variable weighted_tfp_g_`full_start_yr'_20$end_year "Average TFP growth weighted by VA `full_start_yr - 20$end_year'"
forvalues y = 1988/2017{
	gen temp_weighted_tfp_g`y' =  weight`y' * tfp_growth`y'
	bysort industry: egen weighted_tfp_g`y' = mean(temp_weighted_tfp_g`y')
	label variable weighted_tfp_g`y' "TFP growth of industry in year `y' weighted by VA of sub-industries"
}
drop temp* sum*

save output/data/tfp_growth_detail.dta, replace

keep weighted* UHSSector industry
duplicates drop industry, force 
reshape long weighted_tfp_g, i(industry) j(year)
save output/data/tfp_growth.dta, replace


/*
preserve
duplicates drop industry, force
summarize weighted_tfp_g_`full_start_yr'_20$end_year, detail
local median_weighted_tfp_g = r(p50)
local p75_weighted_tfp_g = r(p75)
*/
/*
forvalues y = 1988/2017{
	summarize weighted_tfp_g`y', d
	local p75_weighted_tfp_g`y' = r(p75)
}

restore

/*
gen tfp_median_dummy = (weighted_tfp_g_`full_start_yr'_20$end_year > `median_weighted_tfp_g')
gen tfp_p75_dummy = (weighted_tfp_g_`full_start_yr'_20$end_year > `p75_weighted_tfp_g')
*/

/*
forvalues y = 1988/2017{
	gen tfp_p75_yr_dummy`y' = (weighted_tfp_g`y' > `p75_weighted_tfp_g`y'')
}

*/

drop temp* sum*

*Reshape data to long for easier use
reshape long tfp_growth tfp_p75_yr_dummy va weight weighted_tfp_g, i(CIP_code industry) j(year)
drop _merge CIP_code SectorAcronym
duplicates drop industry year, force

*save output/data/tfp_growth_$start_year$end_year, replace
save output/data/tfp_growth_year, replace


/*
import excel "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/sector_match_key.xlsx", sheet("02-09") firstrow clear
keep CIPCode SectorAcronym UHSSector H
ren H industry_unified
ren CIPCode CIP_code
drop if missing(CIP_code)

merge 1:1 CIP_code using `tfp' 
drop _merge

*Reshape data to long for easier use
reshape long tfp_growth, i(CIP_code) j(year)


* Rename the resulting variable to a more descriptive name
rename tfp_growth_mean tfp_growth_5yr_avg
save output/data/tfp_growth_0209, replace
