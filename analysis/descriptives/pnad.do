*Append data for the years we need
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"


use output/data/PNAD/appended.dta, clear
replace birthyr = . if birthyr < 1000
gen age = year - birthyr 
sort year
drop if age < 16 | age > 65
keep if main_hrs >= 35 // keep full time workers
gen hrly_wage = main_monthly_inc / (main_hrs *4)
preserve

*Get hourly wage
collapse (p10) p10_wage= hrly_wage (p90) p90_wage= hrly_wage, by(year)

* Compute the log (90/10) earnings ratio
gen log_90_10 = log(p90_wage/p10_wage)

tempfile collapsed_data
save `collapsed_data', replace
restore

merge m:1 year using `collapsed_data'

twoway (line log_90_10 year), ///
    title("Log (90/10) Earnings Ratio Over Time") ///
    xlabel (2000 (2) 2015) ///
    ytitle("Log (90/10) Earnings Ratio") ///
    xtitle("Year")
	
	
** Graph cross-sectional lifetime earnings:
gen exp = age - age_work
binscatter hrly_wage age 
binscatter hrly_wage exp 

* Graph for each year

binscatter hrly_wage age if year > 2007, by (year) linetype(connect)
binscatter hrly_wage exp if year > 2007, by (year) linetype(connect)
graph export output/figures/PNAD/hrly_wage_age.jpg, replace


binscatter hrly_wage age if year > 2007, by (year)
binscatter hrly_wage exp if year > 2007, by (year)
* Graph by occupation
