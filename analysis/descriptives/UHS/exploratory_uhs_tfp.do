cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"

use "output/data/total_0409.dta" , clear

*Merge with tfp data
merge m:1 year industry using "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/tfp_growth_0409.dta"
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
replace occ2 = 1 if occ == 1 

gen college = 1 if edu_broad2 == 4
replace college = 0 if edu_broad2 != 4
reg lnsalary c.age##i.occ2 c.age_sq##occ2 c.tfp_growth c.age_sq c.tfp_growth_age i.edu_broad2 i.year i.prov if male == 1 

regress lnsalary c.age##i.occ2 c.age_sq##occ2 c.tfp_growth c.age_sq c.tfp_growth_age c.tfp_growth_sq i.edu_broad2 i.year i.prov, vce(robust)
reg lnsalary i.prov i.year c.age##i.occ2 c.age_sq##occ2 c.tfp_growth##i.occ2##c.age  c.tfp_growth##i.occ2##c.age_sq, vce(robust)
reg lnsalary i.prov i.year c.age##i.college c.age_sq##i.college c.tfp_growth##i.college##c.age  c.tfp_growth##i.college##c.age_sq, vce(robust)

* Generate the age group variable
recode age (18/24=1) (25/34=2) (35/44=3) (45/54=4) (55/max=5), gen(age_group)
recode age (18/24=1) (25/29=2) (30/34=3) (35/39=4) (40/44=5) (45/49 = 6) (50/54 = 7) (54/max = 8), gen(age_group2)

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



forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median age if year == `y' & median_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_median age if year == `y' & median_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p25"))
 graph export output/figures/UHS/mean_salary_age_median`y'.png, replace
}


forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_p75 age if year == `y' & p75_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_p75 age if year == `y' & p75_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p25"))
 graph export output/figures/UHS/mean_salary_age_p75`y'.png, replace
}

*****GRAPH BY AGE GROUP
bysort age_group year quantile_tfp: egen mean_salary_age_quantile_group = mean(lnsalary)
bysort age_group year median_tfp_dummy: egen mean_salary_age_median_group = mean(lnsalary)
bysort age_group year p75_tfp_dummy: egen mean_salary_age_p75_group = mean(lnsalary)
bysort age_group2 year median_tfp_dummy: egen mean_salary_age_median_group2 = mean(lnsalary)

forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_quantile_group age_group if year == `y' & quantile_tfp == 1, lcolor(blue)) || (line mean_salary_age_quantile_group age_group if year == `y' & quantile_tfp == 2, lcolor(red)) || (line mean_salary_age_quantile_group age_group if year == `y' & quantile_tfp == 3, lcolor(yellow)) || ///
(line mean_salary_age_quantile_group age_group if year == `y'& quantile_tfp == 4 , lcolor(green)) , legend(label(1 "Quartile 1") label(2 "Quartile 2") label (3 "Quartile 3" ) label (4 "Quartile 4"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
graph export output/figures/UHS/mean_salary_age_quartile_group`y'.png, replace
}

forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median_group age_group if year == `y' & median_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_median_group age_group if year == `y' & median_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
 graph export output/figures/UHS/mean_salary_age_median_group`y'.png, replace
}

forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median_group2 age_group2 if year == `y' & median_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_median_group2 age_group2 if year == `y' & median_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median"))  xlabel(1 "18-24" 2 "25-29" 3 "30-34" 4 "35-39" 5 "40-44" 6"45-49" 7 "50-54" 8 "54+")
 graph export output/figures/UHS/mean_salary_age_median_group2`y'.png, replace
}
forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median_group age_group if year == `y' & median_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_median_group age_group if year == `y' & median_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
 graph export output/figures/UHS/mean_salary_age_median_group`y'.png, replace
}

forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_p75_group age_group if year == `y' & p75_tfp_dummy == 1, lcolor(blue)) || (line mean_salary_age_p75_group age_group if year == `y' & p75_tfp_dummy == 0, lcolor(red)), legend(label(1 "Greater than p75") label(2 "Lower than p25"))  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+")
 graph export output/figures/UHS/mean_salary_age_p75_group`y'.png, replace
}
*/
****************BY EDUCATION


*bysort college age_group year quantile_tfp: egen mean_salary_age_quantile_group_college = mean(lnsalary)
bysort college age_group year median_tfp_dummy: egen mean_salary_age_median_group_col= mean(lnsalary)
bysort college age_group year p75_tfp_dummy: egen mean_salary_age_p75_group_col = mean(lnsalary)


forvalues y = 2004(1)2009 {
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


forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 1 & college == 1, lcolor(blue)) ///
       (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 1 & college == 0, lcolor(red)), ///
       legend(order(1 "College" 2 "Non college")) ///
       xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") ///
       title("Greater than median") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age Group") ///
       name(greater_median_graph, replace)

twoway (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 0 & college == 1, lcolor(blue)) ///
       (line mean_salary_age_median_group_col age_group if year == `y' & median_tfp_dummy == 0 & college == 0, lcolor(red)), ///
       legend(order(1 "College" 2 "Non college")) ///
       xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") ///
       title("Lower than median") ///
       ytitle("Mean Adjusted Salary") ///
       xtitle("Age Group") ///
       name(lower_median_graph, replace)

graph combine greater_median_graph lower_median_graph, ///
    title("Mean Salary by Age Group, TFP Median, and College Attendance") ///
    colfirst
graph export output/figures/UHS/mean_salary_age_median_group_edu2`y'.png, replace
}

forvalues y = 2004(1)2009 {
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
bysort year  median_tfp_0409_dummy age: egen mean_salary_age_median_0409_yr = mean(lnsalary)


twoway (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 1, lcolor(blue)) || (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 2, lcolor(red)) || (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 3, lcolor(yellow)) || (line mean_salary_age_quantile_0409 age if quantile_tfp_0409 == 4, lcolor(green)), xscale(range(30 60)) xlabel(20(10)60) legend(label(1 "Quartile 1") label(2 "Quartile 2") label (3 "Quartile 3" ) label (4 "Quartile 4")) 
graph export output/figures/UHS/mean_salary_age_quantile_0409.png, replace


forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_median_0409_yr age if year == `y' & median_tfp_0409_dummy == 1, lcolor(blue)) || (line mean_salary_age_median_0409_yr age if year == `y' & median_tfp_0409_dummy == 0, lcolor(red)), legend(label(1 "Greater than median") label(2 "Lower than median")) 
 graph export output/figures/UHS/mean_salary_age_median_0409`y'.png, replace
}

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


******** Single out one industry
bysort year industry age_group occ2: egen mean_salary_age_group_ind = mean(lnsalary)

forvalues y = 2004(1)2009 {
twoway (line mean_salary_age_group_ind age_group if year == `y' & industry == 19 & occ2 == 1, lcolor(blue)) || (line mean_salary_age_group_ind age_group if year == `y' & industry == 19 & occ2 ==0, lcolor(red)),  xlabel(1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55+") 
 graph export output/figures/UHS/mean_salary_age_19_occ2`y'.png, replace
}


*****BY OCCUPATION

