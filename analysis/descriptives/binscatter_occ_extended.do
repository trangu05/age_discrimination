******KEEP SAMPLE CONSISTENT*****


cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"

use "output/data/total_$start_year$end_year.dta" , clear

*Merge with tfp data
merge m:1 year industry using "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/tfp_growth_$start_year$end_year.dta"
keep if _merge == 3

drop if age < 18 | age > 65
drop if industry == 0 //invalid industry code
gen edu_broad2 = edu_broad
replace edu_broad2 = 1 if edu_broad == 0 |edu_broad == 1
gen lnsalary = log(salary_adj)
gen occ3 = 0
replace occ3 = 1 if occ == 2
* Generate the age group variable
recode age (18/24=1) (25/34=2) (35/44=3) (45/54=4) (55/max=5), gen(age_group)
recode age (18/24=1) (25/29=2) (30/34=3) (35/39=4) (40/44=5) (45/49 = 6) (50/54 = 7) (54/max = 8), gen(age_group2)

capture program drop generate_graph
program define generate_graph 
distinct prov
local num_prov = r(ndistinct)
*Drop outliers
sort year
by year: egen p2_5 = pctile(lnsalary), p(2.5)
by year: egen p97_5 = pctile(lnsalary), p(97.5)
gen outlier = (lnsalary <= p2_5 | lnsalary >= p97_5)
drop if outlier == 1 
keep if male == 1


gen tfp_p75_yr_dummy = .
levelsof year, local (year_unique)

foreach y of local year_unique{
preserve
keep if year == `y'
duplicates drop industry, force
sum tfp_growth, d
local p75 = r(p75)
restore

replace tfp_p75_yr_dummy = 1 if tfp_growth >= `p75' & year == `y'
replace  tfp_p75_yr_dummy = 0 if tfp_growth < `p75' & year == `y'
}




binscatter salary_adj age if tfp_p75_yr_dummy == 1, by(occ3) discrete rd (35 40)  ///
    name(fast_growing, replace)	 title("Top 25th pct Industry")   legend(order(1 "Nontechnical" 2 "Technical"))
binscatter salary_adj age if tfp_p75_yr_dummy == 0, by(occ3) discrete rd (35 40)  ///
   name(other_growing, replace) title("Other Industries") legend(order(1 "Nontechnical" 2 "Technical"))
 graph combine fast_growing other_growing, ///
    title("Salary Growth (men) by Age and Industry, `num_prov prov'") ///
    colfirst ycommon 
graph export output/figures/UHS/binscatter_rd_p75_year_`num_prov'prov_year_$start_year$end_year.png, replace


binscatter salary_adj age if tfp_p75_yr_dummy == 1, by(occ3) linetype(connect)  ///
    nquantiles(10) name(fast_growing, replace)	title("Top 25th pct Industry")   legend(order(1 "Nontechnical" 2 "Technical"))
binscatter salary_adj age if tfp_p75_yr_dummy == 0, by(occ3) linetype(connect)  ///
     nquantiles(10) name(other_growing, replace) title("Other Industries")   legend(order(1 "Nontechnical" 2 "Technical")) 
graph combine fast_growing other_growing, ///
    title("Salary Growth (men) by Age and Industry, `num_prov' provs") ///
    colfirst ycommon
graph export output/figures/UHS/binscatter_10_p75_year_`num_prov'prov_year_$start_year$end_year.png, replace

binsreg salary_adj age if tfp_p75_dummy == 1, by(occ3) ci(T) nbins(10) cb(T) name(fast_growing, replace) title("Top 25th pct Industry") ///
     legend(order(2 "Nontechnical" 5 "Technical"))
binsreg salary_adj age if tfp_p75_dummy == 0, by(occ3) ci(T) nbins(10) cb(T) name(other_growing, replace) ///
    title("Other Industries") ///
    legend(order(2 "Nontechnical" 5 "Technical"))

// Combine graphs
graph combine fast_growing other_growing, ///
    title("Salary Growth by Age and Industry, `num_prov provs'") ///
    colfirst ycommon

// Export graph
graph export output/figures/UHS/binscatter_cb_p75_`num_prov'prov_year_$start_year$end_year.png, replace

end

preserve
*Keep sample consistent throughout 2004-2012 by keeping only 3 provinces
keep if prov == 44 | prov == 51
generate_graph 

restore

drop if year == 2011
keep if prov == 21| prov == 44 | prov == 51
generate_graph 



