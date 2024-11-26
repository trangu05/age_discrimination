cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"

use "output/data/total_0209.dta" , clear

* Step 1: Create a unified labeling system
label define industry_unified 1 "Agriculture, Forestry, Animal Husbandry, Fishery" ///
                             2 "Mining" ///
                             3 "Manufacturing" ///
                             4 "Production and Supply of Electricity, Gas and Water" ///
                             5 "Construction" ///
                             6 "Transportation, Storage and Postal Services" ///
                             7 "Wholesale and Retail Trade" ///
                             8 "Finance and Insurance" ///
                             9 "Real Estate" ///3
                             10 "Scientific Research and Technical Services" ///
                             11 "Education" ///
                             12 "Health, Social Security and Social Welfare" ///
                             13 "Public Administration and Social Organization" ///
                             14 "Other"

* Step 2: Create a new variable to map old labels to unified labels
gen industry_unified = .

* For data with industrylbl1 (2002-2003)
replace industry_unified = 1 if inrange(industry, 1, 1) & year < 2004
replace industry_unified = 2 if inrange(industry, 2, 2)& year < 2004
replace industry_unified = 3 if inrange(industry, 3, 3)& year < 2004
replace industry_unified = 4 if inrange(industry, 4, 4)& year < 2004
replace industry_unified = 5 if inrange(industry, 5, 5)& year < 2004
replace industry_unified = 6 if inrange(industry, 7, 7)& year < 2004
replace industry_unified = 7 if inrange(industry, 8, 8)& year < 2004
replace industry_unified = 8 if inrange(industry, 9, 9)& year < 2004
replace industry_unified = 9 if inrange(industry, 10, 10) & year < 2004
replace industry_unified = 10 if inrange(industry, 14, 14)& year < 2004
replace industry_unified = 11 if inrange(industry, 13, 13)& year < 2004
replace industry_unified = 12 if inrange(industry, 12, 12)& year < 2004
replace industry_unified = 13 if inrange(industry, 15, 15)& year < 2004
replace industry_unified = 14 if inrange(industry, 6, 6) | inrange(industry, 11, 11) | inrange(industry, 16, 16)& year < 2004 

* For data with industrylbl2 (2004 onwards)
replace industry_unified = 1 if inrange(industry, 1, 1) & year >= 2004
replace industry_unified = 2 if inrange(industry, 2, 2) & year >= 2004
replace industry_unified = 3 if inrange(industry, 3, 3) & year >= 2004
replace industry_unified = 4 if inrange(industry, 4, 4) & year >= 2004
replace industry_unified = 5 if inrange(industry, 5, 5) & year >= 2004
replace industry_unified = 6 if inrange(industry, 6, 6) | inrange(industry, 7, 7) & year >= 2004
replace industry_unified = 7 if inrange(industry, 8, 8) | inrange(industry, 9, 9) & year >= 2004
replace industry_unified = 8 if inrange(industry, 10, 10) & year >= 2004
replace industry_unified = 9 if inrange(industry, 11, 11) & year >= 2004
replace industry_unified = 10 if inrange(industry, 13, 13) & year >= 2004
replace industry_unified = 11 if inrange(industry, 16, 16) & year >= 2004
replace industry_unified = 12 if inrange(industry, 17, 17) & year >= 2004
replace industry_unified = 13 if inrange(industry, 19, 19) & year >= 2004
replace industry_unified = 14 if inrange(industry, 12, 12) | inrange(industry, 14, 14) | inrange(industry, 15, 15) | inrange(industry, 18, 18) | inrange(industry, 20, 20) & year >= 2004

label values industry_unified industry_unified


*Merge with tfp data
merge m:1 year industry_unified using "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/tfp_growth_0209.dta"
keep if _merge == 3

gen age_sq = age^2
gen tfp_growth_sq = age_sq * tfp_growth
gen tfp_growth_age = age * tfp_growth

drop if age < 18 | age > 60
drop if industry == 0 //invalid industry code
gen edu_broad2 = edu_broad
replace edu_broad2 = 1 if edu_broad == 0 |edu_broad == 1
gen lnsalary = log(salary_adj)
*Drop outliers
sort year
by year: egen p2_5 = pctile(lnsalary), p(2.5)
by year: egen p97_5 = pctile(lnsalary), p(97.5)
gen outlier = (lnsalary <= p2_5 | lnsalary >= p97_5)
drop if outlier == 1 
keep if male == 1
reg lnsalary  age tfp_growth age_sq tfp_growth_age  i.edu_broad2 i.year i.prov if male == 1, vce(robust)

reg lnsalary  age tfp_growth age_sq tfp_growth_age tfp_growth_sq i.edu_broad2 i.year i.prov if male == 1, vce(robust)

gen occ2 = 0
replace occ2 = 1 if occ == 1 | occ == 7 | occ == 3


reg lnsalary c.age##i.occ2 c.age_sq##occ2 c.tfp_growth c.age_sq c.tfp_growth_age i.edu_broad2 i.year i.prov if male == 1 


regress lnsalary c.age##i.occ2 c.age_sq##occ2 c.tfp_growth c.age_sq c.tfp_growth_age c.tfp_growth_sq i.edu_broad2 i.year i.prov if male == 1, vce(robust)

* Generate the age group variable
recode age (16/24=1) (25/34=2) (35/44=3) (45/54=4) (55/max=5), gen(age_group)


****************GRAPH SALARY BY AGE FOR EACH YEAR
forvalues p = 25(25)75{
	by year: egen tfp_`p' = pctile(tfp_growth), p(`p')
}

gen quantile_tfp = 1 if tfp_growth < tfp_25 
replace quantile_tfp = 2 if tfp_growth >= tfp_25 & tfp_growth <= tfp_50
replace quantile_tfp = 3 if tfp_growth >= tfp_50 & tfp_growth <= tfp_75
replace quantile_tfp = 4 if tfp_growth > tfp_75


gen median_tfp_dummy = 1 if tfp_growth > tfp_50
replace median_tfp_dummy = 0 if tfp_growth <= tfp_50

gen p75_tfp_dummy = 1 if tfp_growth > tfp_75
replace p75_tfp_dummy = 0 if tfp_growth <= tfp_75


*****GRAPH BY AGE

bysort age year quantile_tfp: egen mean_salary_age_quantile = mean(lnsalary)
bysort age year median_tfp_dummy: egen mean_salary_age_median = mean(lnsalary)
bysort age year p75_tfp_dummy: egen mean_salary_age_p75 = mean(lnsalary)

* Plot all lines
twoway (line mean_salary_age_quantile age if year == 2004 & quantile_tfp == 1, lcolor(blue)) || (line mean_salary_age_quantile age if year == 2004 & quantile_tfp == 2, lcolor(red)) || (line mean_salary_age_quantile age if year == 2004 & quantile_tfp == 3, lcolor(yellow)) || ///
(line mean_salary_age_quantile age if year == 2004 & quantile_tfp == 4 , lcolor(green))

twoway (line mean_salary_age_quantile age if year == 2005 & quantile_tfp == 1, lcolor(blue)) || (line mean_salary_age_quantile age if year == 2005 & quantile_tfp == 2, lcolor(red)) || (line mean_salary_age_quantile age if year == 2005 & quantile_tfp == 3, lcolor(yellow)) || ///
(line mean_salary_age_quantile age if year == 2005 & quantile_tfp == 4 , lcolor(green))



forvalues y = 2002(1)2009 {
twoway (line mean_salary_age_median age if year == `y' & median_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_median age if year == `y' & median_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median"))
 graph export output/figures/UHS/mean_salary_age_median_unified`y'.png, replace
}


forvalues y = 2002(1)2009 {
twoway (line mean_salary_age_p75 age if year == `y' & p75_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_p75 age if year == `y' & p75_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p25"))
 graph export output/figures/UHS/mean_salary_age_p75_unified`y'.png, replace
}

*****GRAPH BY AGE GROUP
bysort age_group year quantile_tfp: egen mean_salary_age_quantile_group = mean(lnsalary)
bysort age_group year median_tfp_dummy: egen mean_salary_age_median_group = mean(lnsalary)
bysort age_group year p75_tfp_dummy: egen mean_salary_age_p75_group = mean(lnsalary)


forvalues y = 2002(1)2009 {
twoway (line mean_salary_age_quantile_group age_group if year == `y' & quantile_tfp == 1, lcolor(blue)) || (line mean_salary_age_quantile_group age_group if year == `y' & quantile_tfp == 2, lcolor(red)) || (line mean_salary_age_quantile_group age_group if year == `y' & quantile_tfp == 3, lcolor(yellow)) || ///
(line mean_salary_age_quantile_group age_group if year == `y'& quantile_tfp == 4 , lcolor(green)) , legend(label(1 "Quartile 1") label(2 "Quartile 2") label (3 "Quartile 3" ) label (4 "Quartile 4"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
graph export output/figures/UHS/mean_salary_age_quartile_group_unified`y'.png, replace
}

forvalues y = 2002(1)2009 {
twoway (line mean_salary_age_median_group age_group if year == `y' & median_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_median_group age_group if year == `y' & median_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
 graph export output/figures/UHS/mean_salary_age_median_group_unified`y'.png, replace
}


forvalues y = 2002(1)2009 {
twoway (line mean_salary_age_p75_group age_group if year == `y' & p75_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_p75_group age_group if year == `y' & p75_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p25"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
 graph export output/figures/UHS/mean_salary_age_p75_group_unified`y'.png, replace
}

****************BY EDUCATION
gen college = 1 if edu_broad2 == 4
replace college = 0 if edu_broad2 != 4

*bysort college age_group year quantile_tfp: egen mean_salary_age_quantile_group_college = mean(lnsalary)
bysort college age_group year median_tfp_dummy: egen mean_salary_age_median_group_col= mean(lnsalary)
bysort college age_group year p75_tfp_dummy: egen mean_salary_age_p75_group_col = mean(lnsalary)


forvalues y = 2002(1)2009 {
twoway (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 1 & college == 1, lcolor(blue)) ///
       (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 0 & college == 1, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///
       xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") ///
       title("College Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age Group") ///
       name(college_graph, replace)

twoway (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 1 & college == 0, lcolor(blue)) ///
       (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 0 & college == 0, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///
       xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") ///
       title("Non-College Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age Group") ///
       name(non_college_graph, replace)

graph combine college_graph non_college_graph, ///
    title("Mean Salary by Age Group, TFP Median, and College Attendance") ///
    colfirst
graph export output/figures/UHS/mean_salary_age_median_group_edu`y'.png, replace
}


forvalues y = 2002(1)2009 {
twoway (line mean_salary_age_p75_group age_group if year == `y' & p75_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_p75_group age_group if year == `y' & p75_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p25"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
 graph export output/figures/UHS/mean_salary_age_p75_group`y'.png, replace
}
*/
*********************** AVERAGE TFP GROWTH. BY AGE 

bysort industry: egen mean_tfp_growth_0409 = mean(tfp_growth)
forvalues p = 25(25)75{
 egen tfp_`p'_0409 = pctile(mean_tfp_growth_0409), p(`p')
}
gen quantile_tfp_0409 = 1 if mean_tfp_growth_0409< tfp_25_0409 
replace quantile_tfp_0409 = 2 if mean_tfp_growth_0409>= tfp_25_0409 & mean_tfp_growth_0409 <= tfp_50_0409
replace quantile_tfp_0409 = 3 if mean_tfp_growth_0409>= tfp_50 & mean_tfp_growth_0409 <= tfp_75_0409
replace quantile_tfp_0409 = 4 if mean_tfp_growth_0409 > tfp_75_0409


gen median_tfp_0409_dummy = 1 if  mean_tfp_growth_0409> tfp_50_0409
replace median_tfp_0409_dummy = 0 if  mean_tfp_growth_0409 <=tfp_50_0409

gen p75_tfp_0409_dummy = 1 if  mean_tfp_growth_0409 > tfp_75_0409
replace p75_tfp_0409_dummy = 0 if  mean_tfp_growth_0409 <= tfp_75_0409

bysort quantile_tfp_0409 age: egen mean_salary_age_quantile_0409 = mean(lnsalary)
bysort median_tfp_0409_dummy age: egen mean_salary_age_median_0409 = mean(lnsalary)
bysort p75_tfp_0409_dummy age: egen mean_salary_age_p75_0409 = mean(lnsalary)

twoway (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 1, lcolor(blue)) || (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 2, lcolor(red)) || (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 3, lcolor(yellow)) || (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 4, lcolor(green)), xscale(range(30 60)) xlabel(20(10)60) legend(label(1 "Quartile 1") label(2 "Quartile 2") label (3 "Quartile 3" ) label (4 "Quartile 4")) 
graph export output/figures/UHS/mean_salary_age_quantile_0409.png, replace

preserve
duplicates drop age median_tfp_0409_dummy , force
twoway (line mean_salary_age_median_0409 age if median_tfp_0409_dummy == 1, lcolor(blue)) || (line mean_salary_age_median_0409 age if median_tfp_0409_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median"))  
graph export output/figures/UHS/mean_salary_age_median_0409.png, replace
restore
twoway (line mean_salary_age_p75_0409 age if p75_tfp_0409_dummy == 1, lcolor(blue)) || (line mean_salary_age_p75_0409 age if p75_tfp_0409_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p75"))  
graph export output/figures/UHS/mean_salary_age_p75_0409.png, replace

*********************** AVERAGE TFP GROWTH BY AGE GROUP

bysort quantile_tfp_0409 age_group: egen mean_salary_age_quantile_grp0409 = mean(lnsalary)
bysort median_tfp_0409_dummy age_group: egen mean_salary_age_median_grp0409 = mean(lnsalary)
bysort p75_tfp_0409_dummy age_group: egen mean_salary_age_p75_grp0409 = mean(lnsalary)
twoway (line mean_salary_age_quantile_grp0409 age_group if quantile_tfp_0409 == 1, lcolor(blue)) || (line mean_salary_age_quantile_grp0409 age_group if quantile_tfp_0409 == 2, lcolor(red)) || (line mean_salary_age_quantile_grp0409 age_group if quantile_tfp_0409 == 3, lcolor(yellow)) || (line mean_salary_age_quantile_grp0409 age_group if quantile_tfp_0409 == 4, lcolor(green)),  legend(label(1 "Quartile 1") label(2 "Quartile 2") label (3 "Quartile 3" ) label (4 "Quartile 4")) ///
xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")

preserve
duplicates drop age_group median_tfp_0409_dummy, force
twoway (line  mean_salary_age_median_grp0409 age_group if median_tfp_0409_dummy== 1, lcolor(blue)) || (line  mean_salary_age_median_grp0409 age_group if median_tfp_0409_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median")) ///
xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") 
restore
graph export output/figures/UHS/mean_salary_age_median_0409.png, replace

twoway (line mean_salary_age_p75_grp0409 age_group if p75_tfp_0409_dummy== 1, lcolor(blue)) || (line mean_salary_age_p75_grp0409 age_group if p75_tfp_0409_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p75")) ///
xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") 
graph export output/figures/UHS/mean_salary_age_p75_0409.png, replace





