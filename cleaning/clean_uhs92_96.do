*********Cleaning UHS data 1988-1991*******
*******************************************************************************
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/"

local years 92 93 94 95 96
foreach y of local years {

    use "data/UHS/raw_data/86-09/86-01/86-01 data/fh`y'.dta", clear

    *Choose variables that we need*
    keep year code prov x4-x8 x10 x11 x13
	ren x4 rel
	ren x5 gender
	ren x6 age
	ren x7 edu
	ren x8 industry
	ren x10 occ
	ren x11 yearstart
	ren x13 salary
	
	label variable rel "relationship to respondent"
	label variable gender "gender"
	label variable age "age"
	label variable edu "edu years"
	label variable industry "industry"
	label variable occ "occupation"
	label variable yearstart "year starting work"
	label variable salary "salary"

	label define industrylbl 1 "Agriculture, Forestry, Animal Husbandry, Fishery" ///
                             2 "Manufacturing" ///
                             3 "Geological Prospecting and Surveying" ///
                             4 "Construction" ///
                             5 "Transportation, Storage and Postal Service" ///
                             6 "Commerce, Public Food services, material supply and storage" ///
                             7 "Real estate" ///
                             8 "Health, Social Security and Social Welfare" ///
                             9 "Educaitonn, Culture, Arts and Radio and TV" ///
                             10 "Scientific Research and Technical Services" ///
                             11 "Finance and Insurance" ///
                             12 "Public Administration and Social Organization" ///
                             13 "Other" ///
                          
	label values industry industrylbl
	
	label define edulbl 1 "university" 2 "college/associate degree" 3 "upper secondary" 4 "lower secondary" ///
	5 "primary edu" 6 "literate" 7 "illiterate"
	label values edu edulbl
	
	gen male = (gender == 1)
	gen edu_broad = 0 if edu == 6 | edu == 7
	replace edu_broad = 1 if edu == 5
	replace edu_broad = 2 if edu == 4
	replace edu_broad = 3 if edu == 3
	replace edu_broad = 4 if edu >= 2
	
	label define edulbl2 0 "no schooling" 1 "primary" 2  "middle" 3 "high school" 4 "college+"
	label values edu_broad edulbl2
	
    save "age_discrimination/output/data/clean_fh`y'.dta", replace
}
