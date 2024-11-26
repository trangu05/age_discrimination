cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"

use "output/data/total_0409.dta" , clear

*Merge with tfp data
merge m:1 year industry using "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/tfp_growth_0409.dta"
keep if _merge == 3

gen age_sq = age^2
gen tfp_growth_sq = age_sq * tfp_growth
gen tfp_growth_age = age * tfp_growth
gen tfp_growth_1999_2009_age = age * tfp_g_1999_2009
gen tfp_growth_1999_2009_sq = age_sq * tfp_g_1999_2009


drop if age < 18 | age > 60
drop if industry == 0 //invalid industry code
gen edu_broad2 = edu_broad
replace edu_broad2 = 1 if edu_broad == 0 |edu_broad == 1
gen lnsalary = log(salary_adj)
gen occ2 = 0
replace occ2 = 1 if occ == 1 
* Generate the age group variable
recode age (18/24=1) (25/34=2) (35/44=3) (45/54=4) (55/max=5), gen(age_group)
recode age (18/24=1) (25/29=2) (30/34=3) (35/39=4) (40/44=5) (45/49 = 6) (50/54 = 7) (54/max = 8), gen(age_group2)



*Drop outliers
sort year
by year: egen p2_5 = pctile(lnsalary), p(2.5)
by year: egen p97_5 = pctile(lnsalary), p(97.5)
gen outlier = (lnsalary <= p2_5 | lnsalary >= p97_5)
drop if outlier == 1 
keep if male == 1

gen college = 1 if edu_broad2 == 4
replace college = 0 if edu_broad2 != 4
gen occ3 = (occ == 2)
*Drop industries that prioritize tenure
drop if industry == 19 | industry == 16 



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

bysort occ2 age_group year median_tfp_dummy: egen mean_salary_age_median_group_occ= mean(salary_adj)
bysort occ2 age_group year p75_tfp_dummy: egen mean_salary_age_p75_group_occ = mean(salary_adj)
bysort occ2 age year median_tfp_dummy: egen mean_salary_age_median_occ = mean(salary_adj)
bysort occ2 age_group2 year median_tfp_dummy: egen mean_salary_age_median_occ_grp2 = mean(salary_adj)
preserve
*drop if industry == 19 | industry == 16
bysort occ2 age_group2 median_tfp_dummy: egen mean_salary_age_med_occ_grp2_a = mean(salary_adj)

twoway (line   mean_salary_age_med_occ_grp2_a age_group2 if median_tfp_dummy == 1 & occ2 == 1, lcolor(blue)) ///
       (line   mean_salary_age_med_occ_grp2_a age_group2  if median_tfp_dummy == 0 & occ2 == 1, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///   
       title("occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age") ///
       name(occ2_agegrp2_graph, replace)

twoway (line  mean_salary_age_med_occ_grp2_a age_group2 if  median_tfp_dummy == 1 & occ2 == 0, lcolor(blue)) ///
       (line  mean_salary_age_med_occ_grp2_a age_group2 if  median_tfp_dummy == 0 & occ2 == 0, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///
       title("Non-occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age") ///
       name(non_occ2_agegrp2_graph, replace)


graph combine occ2_agegrp2_graph non_occ2_agegrp2_graph, ///
    title("Mean Salary by Age Group, TFP Median, and occ2 Attendance") ///
    colfirst
restore
forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median_group_occ age_group if year == `y' & median_tfp_dummy == 1 & occ2 == 1, lcolor(blue)) ///
       (line mean_salary_age_median_group_occ age_group if year == `y' & median_tfp_dummy == 0 & occ2 == 1, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///
       xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") ///
       title("occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age Group") ///
       name(occ2_graph, replace)

twoway (line mean_salary_age_median_group_occ age_group if year == `y' & median_tfp_dummy == 1 & occ2 == 0, lcolor(blue)) ///
       (line mean_salary_age_median_group_occ age_group if year == `y' & median_tfp_dummy == 0 & occ2 == 0, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///
       xlabel(1 "18-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") ///
       title("Non-occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age Group") ///
       name(non_occ2_graph, replace)

graph combine occ2_graph non_occ2_graph, ///
    title("Mean Salary by Age Group, TFP Median, and occ2 Attendance") ///
    colfirst
graph export output/figures/UHS/mean_salary_age_median_group_occ`y'.png, replace
}


forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median_occ age if year == `y' & median_tfp_dummy == 1 & occ2 == 1, lcolor(blue)) ///
       (line mean_salary_age_median_occ age if year == `y' & median_tfp_dummy == 0 & occ2 == 1, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///   
       title("occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age") ///
       name(occ2_age_graph, replace)

twoway (line mean_salary_age_median_occ age if year == `y' & median_tfp_dummy == 1 & occ2 == 0, lcolor(blue)) ///
       (line mean_salary_age_median_occ age if year == `y' & median_tfp_dummy == 0 & occ2 == 0, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///
       title("Non-occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age") ///
       name(non_occ2_age_graph, replace)

graph combine occ2_age_graph non_occ2_age_graph, ///
    title("Mean Salary by Age Group, TFP Median, and occ2 Attendance") ///
    colfirst
graph export output/figures/UHS/mean_salary_age_median_occ`y'.png, replace
}

forvalues y = 2004(1)2009 {
twoway (line  mean_salary_age_median_occ_grp2 age_group2 if year == `y' & median_tfp_dummy == 1 & occ2 == 1, lcolor(blue)) ///
       (line  mean_salary_age_median_occ_grp2 age_group2 if year == `y' & median_tfp_dummy == 0 & occ2 == 1, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///   
       title("occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age") ///
       name(occ2_agegrp2_graph, replace)

twoway (line  mean_salary_age_median_occ_grp2 age_group2 if year == `y' & median_tfp_dummy == 1 & occ2 == 0, lcolor(blue)) ///
       (line  mean_salary_age_median_occ_grp2 age_group2 if year == `y' & median_tfp_dummy == 0 & occ2 == 0, lcolor(red)), ///
       legend(order(1 "Greater than median" 2 "Lower than median")) ///
       title("Non-occ2 Group") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age") ///
       name(non_occ2_agegrp2_graph, replace)

graph combine occ2_agegrp2_graph non_occ2_agegrp2_graph, ///
    title("Mean Salary by Age Group, TFP Median, and occ2 Attendance") ///
    colfirst
graph export output/figures/UHS/mean_salary_age_median_group2_occ`y'.png, replace
}


graph export output/figures/UHS/mean_salary_age_median_group2_occ`y'.png, replace



*****Regressions

reg lnsalary i.prov i.year c.age##i.occ2 c.age_sq##occ2 c.tfp_g_1999_2009##i.occ2##c.age  c.tfp_g_1999_2009##i.occ2##c.age_sq, vce(robust)

reg lnsalary i.prov i.year c.age##i.occ3 c.age_sq##occ3 c.tfp_g_1999_2009##i.occ3##c.age  c.tfp_g_1999_2009##i.occ3##c.age_sq, vce(robust)

reg lnsalary i.prov i.year c.age##i.occ2 c.age_sq##occ2 i.tfp_median_dummy##i.occ2##c.age  i.tfp_median_dummy##i.occ2##c.age_sq, vce(robust)

reg lnsalary i.prov i.year c.age##i.college c.age_sq##college c.tfp_g_1999_2009##i.college##c.age  c.tfp_g_1999_2009##i.college##c.age_sq, vce(robust)

reg lnsalary  age tfp_growth age_sq tfp_growth_1999_2009_age tfp_growth_1999_2009_sq i.college i.year i.prov if male == 1, vce(robust)
