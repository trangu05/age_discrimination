cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"

use "output/data/total.dta" , clear

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

* For data with industrylbl1 (1997-2003)
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

save output/data/total_industry_unified.dta, replace
