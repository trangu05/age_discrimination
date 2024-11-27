*********Cleaning UHS data 2000*******
*******************************************************************************
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china"

local years 86 87

foreach y of local years {

    use "data/UHS/raw_data/86-09/86-01/86-01 data/fh`y'.dta", clear

	gen salary = x10*12
	gen yearstart = year-x9
	
    *Choose variables that we need*
    keep year code prov salary yearstart x2-x8
	ren x2 rel
	ren x3 gender
	ren x4 age
	ren x5 edu
	ren x6 industry
	ren x7 employ
	ren x8 occ
	
	label variable rel "relationship to respondent"
	label variable gender "gender"
	label variable age "age"
	label variable edu "edu years"
	label variable industry "industry"
	label variable employ "employment status"
	label variable occ "occupation"
	label variable yearstart "year starting work"
	label variable salary "salary"
	
		label define industrylbl1 1 "agriculture, forestry, animal husbandry, fishery" 2 "mining" 3 "production and supply of electricity, coal, natural gas and water supply" 4 "manufacturing" ///
	5 "geological survey, water management" 6 "construction" 7 "transportation, storage and postal services" 8 "commerce, trade, food and supply" 9 "accommodation and housing" ///
	10 "health, sports, social welfare" 11 "education, culture, arts, radio, film, tv" 12 "scientific research and technical services" 13 "finance and insurance" 14 "gov agencies, party and social organizations" ///
	15 "other"

	label values industry industrylbl1
	
	label define edulbl 1 "college" 2 "secondary edu" 3 "High school" 4 "middle school" 5 "primary school" 6"other"
	label values edu edulbl
	
    save "age_discrimination/output/data/clean_fh`y'.dta", replace
}
