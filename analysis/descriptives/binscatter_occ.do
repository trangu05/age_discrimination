cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"

use "output/data/total.dta" , clear

*Merge with tfp data
merge m:1 year industry using "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/tfp_growth.dta"
keep if _merge == 3
drop _merge

*Keep only the years we are interested in
local first_char = substr("$start_year", 1, 1)

* Check if the first character is "0"
if "`first_char'" == "0" {
    local startyr = 20$start_year
} 
else {
    local startyr = 19$start_year'
}

local endyr = 20$end_year
di `startyr'
keep if year >= `startyr' & year <= `endyr'


drop if age < 18 | age > 65
drop if industry == 0 //invalid industry code
gen edu_broad2 = edu_broad
replace edu_broad2 = 1 if edu_broad == 0 |edu_broad == 1
gen lnsalary = log(salary_adj)
gen occ3 = 0
replace occ3 = 1 if (occ == 2 & year > 2006 ) | (occ == 1 & year <= 2006)
* Generate the age group variable
recode age (18/24=1) (25/34=2) (35/44=3) (45/54=4) (55/max=5), gen(age_group)
egen age_bin = cut(age), at(0(2)65) icodes
egen age_bin2 = cut(age), at(18 25 30 40 65) label



*Drop outliers
sort year
by year: egen p2_5 = pctile(lnsalary), p(2.5)
by year: egen p97_5 = pctile(lnsalary), p(97.5)
gen outlier = (lnsalary <= p2_5 | lnsalary >= p97_5)
drop if outlier == 1 
keep if male == 1

gen college = 1 if edu_broad2 == 4
replace college = 0 if edu_broad2 != 4

*Generate TFP indicators

preserve
duplicates drop industry, force
summarize weighted_tfp_g_*_20$end_year, detail
local p75_weighted_tfp_g = r(p75)
restore
local full_start_yr $full_start_yr
gen tfp_p75_dummy = (weighted_tfp_g_`full_start_yr'_20$end_year > `p75_weighted_tfp_g')


preserve
duplicates drop year industry, force
egen p75_tfp_growth = pctile(weighted_tfp_g), by(year) p(75)
gen tfp_p75_yr_dummy = (weighted_tfp_g >= p75_tfp_growth)
keep year industry tfp_p75_yr_dummy
tempfile tfp_p75_yr_dummy
save `tfp_p75_yr_dummy', replace
restore

merge m:1 year industry using `tfp_p75_yr_dummy'

*Drop industries that prioritize tenure
drop if industry == 19 | industry == 16 



****************GRAPH SALARY BY AGE FOR EACH YEAR
/*
forvalues p = 25(25)75{
	by year: egen tfp_`p' = pctile(tfp_growth), p(`p')
}

gen quantile_tfp = 1 if tfp_growth < tfp_25 
replace quantile_tfp = 2 if tfp_growth >= tfp_25 & tfp_growth <= tfp_50
replace quantile_tfp = 3 if tfp_growth >= tfp_50 & tfp_growth <= tfp_75
replace quantile_tfp = 4 if tfp_growth > tfp_75

gen p75_tfp_dummy = 1 if tfp_growth > tfp_75
replace p75_tfp_dummy = 0 if tfp_growth <= tfp_75
*/




********************BINSCATTER PLOTS
* Create binned scatter plot for tfp_p75_dummy == 1 (fast-growing industries)
binscatter salary_adj age if tfp_p75_dummy == 1, by(occ3) linetype(connect) ///
     xline(40) name(fast_growing, replace) title("Fast Growing Industry")   legend(order(1 "Nontechnical" 2 "Technical"))
* Create binned scatter plot for tfp_p75_dummy == 0 (other industries)
binscatter salary_adj age if tfp_p75_dummy == 0, by(occ3) linetype(connect) ///
    name(other_industries, replace) title("Slow Growing Industry") legend(order(1 "Nontechnical" 2 "Technical"))
* Combine the saved plots into one graph
graph combine fast_growing other_industries, ///
    title("Salary Growth by Age and Industry") ///
    colfirst ycommon
graph export output/figures/UHS/binscatter_20_p75.png, replace
	
binscatter salary_adj age if tfp_p75_dummy == 1, by(occ3) linetype(connect)  ///
    nquantiles(10) name(fast_growing, replace)	title("Fast Growing Industry")   legend(order(1 "Nontechnical" 2 "Technical"))
binscatter salary_adj age if tfp_p75_dummy == 0, by(occ3) linetype(connect)  ///
     nquantiles(10) name(other_growing, replace) title("Slow Growing Industry")   legend(order(1 "Nontechnical" 2 "Technical")) 
graph combine fast_growing other_growing, ///
    title("Salary Growth by Age and Industry") ///
    colfirst ycommon
graph export output/figures/UHS/binscatter_10_p75.png, replace

binscatter salary_adj age if tfp_p75_dummy == 1, by(occ3) discrete rd (30 35)  ///
    name(fast_growing, replace)	 title("Fast Growing Industry")   legend(order(1 "Nontechnical" 2 "Technical"))
binscatter salary_adj age if tfp_p75_dummy == 0, by(occ3) discrete rd (30 35)  ///
   name(other_growing, replace) title("Slow Growing Industry") legend(order(1 "Nontechnical" 2 "Technical"))
 graph combine fast_growing other_growing, ///
    title("Salary Growth by Age and Industry") ///
    colfirst ycommon 
graph export output/figures/UHS/binscatter_rd_p75.png, replace

binscatter salary_adj age if tfp_p75_dummy == 1, discrete rd (30 45)  ///
    name(fast_growing, replace)	 title("Fast Growing Industry")   legend(order(1 "Nontechnical" 2 "Technical"))
binscatter salary_adj age if tfp_p75_dummy == 0, discrete rd (30 45)  ///
   name(other_growing, replace) title("Slow Growing Industry") legend(order(1 "Nontechnical" 2 "Technical"))
 graph combine fast_growing other_growing, ///
    title("Salary Growth by Age and Industry") ///
    colfirst ycommon 

		
binscatter salary_adj age if tfp_p75_dummy == 1, linetype(connect)  ///
    nquantiles(10) name(fast_growing, replace)	title("Fast Growing Industry")   legend(order(1 "Nontechnical" 2 "Technical"))
binscatter salary_adj age if tfp_p75_dummy == 0, linetype(connect)  ///
     nquantiles(10) name(other_growing, replace) title("Slow Growing Industry")   legend(order(1 "Nontechnical" 2 "Technical")) 
	 graph combine fast_growing other_growing, ///
    title("Salary Growth by Age and Industry") ///
    colfirst ycommon
	
	
binsreg salary_adj age if tfp_p75_dummy == 1, by(occ3) nbins(10)  name(fast_growing, replace) title("Fast Growing Industry") ///
     legend(order(2 "Nontechnical" 5 "Technical"))
binsreg salary_adj age if tfp_p75_dummy == 0, by(occ3) nbins(10) name(other_growing, replace) ///
    title("Slow Growing Industry") ///
    legend(order(2 "Nontechnical" 5 "Technical"))

// Combine graphs
graph combine fast_growing other_growing, ///
    title("Salary Growth by Age and Industry") ///
    colfirst ycommon

// Export graph
graph export output/figures/UHS/binscatter_cb_p75_v2.png, replace

/*
gen age_23to24=age>=23 & age<=24
gen age_25to26=age>=25 & age<=26
gen age_27to28=age>=27 & age<=28
gen age_29to30=age>=29 & age<=30
gen age_31to32=age>=31 & age<=32
gen age_33to34=age>=33 & age<=34
gen age_35to36=age>=35 & age<=36
gen age_37to38=age>=37 & age<=38
gen age_39to40=age>=39 & age<=40
gen age_41to42=age>=41 & age<=42
gen age_43to44=age>=43 & age<=44
gen age_45to46=age>=45 & age<=46
gen age_47to48=age>=47 & age<=48
gen age_49to50=age>=49 & age<=50

foreach var of varlist age_23to24- age_49to50  {
	gen tfp_occ_`var'= tfp_p75_dummy* occ3*`var'	
	gen occ_`var' = occ3 * `var'
	gen tfp_`var' = tfp_p75_dummy * `var'
}

local effects "tfp_occ_age_23to24 tfp_occ_age_25to26 tfp_occ_age_27to28 tfp_occ_age_29to30 tfp_occ_age_31to32 tfp_occ_age_33to34 tfp_occ_age_35to36 tfp_occ_age_37to38 tfp_occ_age_39to40 tfp_occ_age_41to42 tfp_occ_age_43to44 tfp_occ_age_45to46 tfp_occ_age_47to48 tfp_occ_age_49to50"

local effects1 "occ_age_23to24 occ_age_25to26 occ_age_27to28 occ_age_29to30 occ_age_31to32 occ_age_33to34 occ_age_35to36 occ_age_37to38 occ_age_39to40 occ_age_41to42 occ_age_43to44 occ_age_45to46 occ_age_47to48 occ_age_49to50"

local effects2 "tfp_age_23to24 tfp_age_25to26 tfp_age_27to28 tfp_age_29to30 tfp_age_31to32 tfp_age_33to34 tfp_age_35to36 tfp_age_37to38 tfp_age_39to40 tfp_age_41to42 tfp_age_43to44 tfp_age_45to46 tfp_age_47to48 tfp_age_49to50"

reg salary_adj i.prov i.year i.college age_23to24 - age_49to50 `effects' `effects1' `effects2', robust

reg lnsalary i.prov i.year i.age_group2##i.occ3  i.tfp_p75_dummy##i.occ3##i.age_group2 , vce(robust)
reg lnsalary i.prov i.year  i.tfp_p75_dummy##i.occ3##i.age_bin i.college , vce(robust)
reg salary_adj i.prov i.year i.tfp_p75_dummy##i.occ3##i.age_bin i.college , vce(robust)
reg lnsalary i.prov i.year i.age_bin##i.occ3 i.college, vce(robust)
reg salary_adj i.prov i.year c.age##i.tfp_p75_dummy##i.occ3 c.age_sq##i.tfp_p75_dummy##i.occ3 i.college , vce(robust)

reg salary_adj i.prov i.year  i.age_30_40 i.age_40_plus tfp_occ_age_30_40 tfp_occ_age_40_plus i.occ_age_30_40 occ_age_40_plus tfp_age_30_40 tfp_age_40_plus i.college, robust

reg salary_adj i.prov i.year i.age_bin2##tfp_p75_dummy i.college if occ3 == 1, robust
*/


gen reg1 = (age-30) * (age > 30)
gen reg2 = (age-40) * (age>40)
reg salary_adj age reg1 reg2 if occ3 == 0 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 if occ3 == 0 & tfp_p75_dummy == 1, robust
reg salary_adj age reg1 reg2  if occ3 == 1 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 if occ3 == 1 & tfp_p75_dummy == 1, robust



reg salary_adj age reg1 reg2 i.year i.prov i.college if occ3 == 0 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 i.year i.prov i.college if occ3 == 0 & tfp_p75_dummy == 1, robust
reg salary_adj age reg1 reg2 i.year i.prov i.college  if occ3 == 1 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2  i.year i.prov i.college if occ3 == 1 & tfp_p75_dummy == 1, robust


reg salary_adj age reg1 reg2  i.year i.college if occ3 == 0 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 i.year i.college if occ3 == 0 & tfp_p75_dummy == 1, robust
reg salary_adj age reg1 reg2 i.year i.college  if occ3 == 1 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 i.year i.college if occ3 == 1 & tfp_p75_dummy == 1, robust


reg salary_adj age reg1 reg2  i.prov i.college if occ3 == 0 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 i.prov i.college if occ3 == 0 & tfp_p75_dummy == 1, robust
reg salary_adj age reg1 reg2 i.prov i.college  if occ3 == 1 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 i.prov i.college if occ3 == 1 & tfp_p75_dummy == 1, robust

reg salary_adj c.age##c.age i.year i.prov i.college if occ3 == 0 & tfp_p75_dummy == 0, robust
reg salary_adj c.age##c.age i.year i.prov i.college  if occ3 == 0 & tfp_p75_dummy == 1, robust
reg salary_adj c.age##c.age i.year i.prov i.college   if occ3 == 1 & tfp_p75_dummy == 0, robust
reg salary_adj c.age##c.age i.year i.prov i.college  if occ3 == 1 & tfp_p75_dummy == 1, robust

twoway (kdensity age if tfp_p75_dummy == 0, lcolor(blue)) ///
       (kdensity age if tfp_p75_dummy == 1, lcolor(red)), by (year) ///
       title("Age Density by TFP Dummy") ///
       legend(label(1 "TFP = 0") label(2 "TFP = 1"))
	   
	   
twoway (kdensity age if tfp_p75_yr_dummy == 0, lcolor(blue)) ///
       (kdensity age if tfp_p75_yr_dummy == 1, lcolor(red)), by (year) ///
       title("Age Density by TFP Dummy") ///
       legend(label(1 "TFP = 0") label(2 "TFP = 1"))



/*
replace birthyr = year - age
gen cohort = floor((birthyr-1937)/5) + 1 // creates 5-year cohort groups starting from 1937
collapse (mean) salary_adj age reg1 reg2, by(cohort year occ3 tfp_p75_dummy)
reg salary_adj age reg1 reg2 i.cohort if occ3 == 0 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 i.cohort if occ3 == 0 & tfp_p75_dummy == 1, robust
reg salary_adj age reg1 reg2  i.cohort if occ3 == 1 & tfp_p75_dummy == 0, robust
reg salary_adj age reg1 reg2 i.cohort if occ3 == 1 & tfp_p75_dummy == 1, robust
*/

/*
gen reg3 = reg1*occ3*tfp_p75_dummy
gen reg4 = reg2*occ3*tfp_p75_dummy
gen reg5 = age*occ3*tfp_p75_dummy
gen reg6 = reg1*occ3
gen reg7 = reg2*occ3
gen reg8 = reg1*tfp_p75_dummy
gen reg9 = reg2*tfp_p75_dummy

reg salary_adj age reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9 i.college i.year i.prov , robust

/*	
*****Regressions

reg lnsalary i.prov i.year c.age##i.occ3  c.tfp_g_1999_2009##i.occ3##c.age , vce(robust)

reg lnsalary i.prov i.year i.age_group2##i.occ3  i.tfp_p75_dummy##i.occ3##i.age_group2 , vce(robust)

reg lnsalary i.prov i.year c.age##i.occ3 c.age_sq##occ3 c.tfp_g_1999_2009##i.occ3##c.age  c.tfp_g_1999_2009##i.occ3##c.age_sq, vce(robust)

reg lnsalary i.prov i.year c.age##i.occ3 c.age_sq##occ3 i.tfp_median_dummy##i.occ3##c.age  i.tfp_median_dummy##i.occ3##c.age_sq, vce(robust)

reg lnsalary i.prov i.year c.age##i.college c.age_sq##college c.tfp_g_1999_2009##i.college##c.age  c.tfp_g_1999_2009##i.college##c.age_sq, vce(robust)

reg lnsalary  age tfp_growth age_sq tfp_growth_1999_2009_age tfp_growth_1999_2009_sq i.college i.year i.prov if male == 1, vce(robust)

sort industry year
by industry year: gen first = _n == 1
by industry: gen lag_tfp_growth = tfp_growth[_n-1] if first == 1
by industry: replace lag_tfp_growth = lag_tfp_growth[_n-1] if missing(lag_tfp_growth)
regress lnsalary c.age##i.occ3  c.age_sq##occ3 c.lag_tfp_growth##i.occ3##c.age  c.lag_tfp_growth##i.occ3##c.age_sq i.prov i.year, vce(robust) 
