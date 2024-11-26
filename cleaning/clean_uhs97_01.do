*********Cleaning UHS data 2000*******
*******************************************************************************
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china"

local years 97 98 99 00 01 

foreach y of local years {

    use "data/UHS/raw_data/86-09/86-01/86-01 data/fh`y'.dta", clear

    *Choose variables that we need*
    keep year code prov x4-x11 x14
    ren x4 rel
    ren x5 gender
    ren x6 age
    ren x7 edu
    ren x8 industry
    ren x9 employ
    ren x10 occ
    ren x11 yearstart
    ren x14 salary
	

	label variable rel "relationship to respondent"
	label variable gender "gender"
	label variable age "age"
	label variable edu "edu"
	label variable industry "industry"
	label variable employ "employment status"
	label variable occ "occupation"
	label variable yearstart "year starting work"
	label variable salary "salary"
	
	label define edulbl 1 "college+" 2 "junior college" 3 "senior high school" 4 "technical secondary school" 5 "middle" 6 "primary" 7 "other"
	label values edu edulbl
	gen edu_broad = 0 if edu == 7
	replace edu_broad = 1 if edu == 6
	replace edu_broad = 2 if edu == 5 | edu == 4
	replace edu_broad = 3 if edu == 3 
	replace edu_broad = 4 if edu == 2 | edu_broad == 1
		
	label define edulbl2 0 "no schooling" 1 "primary" 2  "middle" 3 "high school" 4 "college+"
	label values edu_broad edulbl2
	
label define industrylbl 1 "agriculture, forestry, animal husbandry, fishery" 2 "mining" 3 "manufacturing" 4 "production and supply of eletricity, gas and water" ///
	5 "construction" 6 "geological survey, water management" 7 "transportation, storage and postal services" 8 "wholesale and retail trade, hospitality industry" 9 "finance, insurance" ///
	10 "real estate" 11 "social services" 12 "health, sports, social welfare" 13 "education, culture, arts, radio, film, tv" 14 "scientific research and technical services" ///
	15 "gov agencies, party and oscial organizations" 16 "other"
	label values industry industyrlbl 
	
    save "age_discrimination/output/data/clean_fh`y'.dta", replace
}
