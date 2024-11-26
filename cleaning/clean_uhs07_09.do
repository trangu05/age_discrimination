*********Cleaning UHS data 2006-2009*******
*******************************************************************************
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"

local years 07 08 09 
foreach y of local years {

    use "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/UHS/raw_data/86-09/02-09/20`y'p.dta", clear

    *Choose variables that we need*
    keep year prov a2 a6 a7 a8 a13 a14 a10 a151 a12
	ren a2 rel
	ren a6 gender
	ren a7 birthdate
	ren a8 edu
	ren a13 industry
	ren a14 occ
	ren a10 yearstart
	ren a151 salary
	ren a12 employ
	
	label variable rel "relationship to respondent"
	label variable gender "gender"
	label variable birthdate "Birth year and month"
	label variable edu "edu fine category"
	label variable industry "industry"
	label variable occ "occupation"
	label variable yearstart "year starting work"
	label variable salary "salary"
	label variable employ "Employment status"
	
	label define edulbl 1 "no schooling" 2 "literacy class" 3 "primary" 4 "middle" ///
	5 "high school" 6 "secondary specialized school" 7 "junior college" 8 "undergraduate" /// 
	9 "postgraduate"
	label values edu edulbl
	
	gen edu_broad = 0 if 0 < edu < 3 
	replace edu_broad = 1 if edu == 3
	replace edu_broad = 2 if edu == 4
	replace edu_broad = 3 if edu == 5 | edu ==6
	replace edu_broad = 4 if edu > 6
	
	label define edulbl2 0 "no schooling" 1 "primary" 2  "middle" 3 "high school" 4 "college+"
	label values edu_broad edulbl2
	
	label define occlbl 0 "not applicable" 1 "government" 2 "technical workers" 3 "clerical and admin personnel" 4 "commercial workers" 5 "service workers" 6 "agricultural personnel" 7 "production, transportation workers" 8 "other"
	label values occ occlbl 
	
	label define industrylbl 1 "agriculture, forestry, animal husbandry, fishery" 2 "mining" 3 "manufacturing" 4 "production and supply of eletricity, gas and water" ///
	5 "construction" 6 "transportation, storage and postal services" 7 "information transmission, computer services and software" 8 "wholesale and retail trade" 9 "accommodation and catering" ///
	10 "finance" 11 "real estate" 12 "leasing and business services" 13 "scientific research and technical services, geological exploration" 14 "water conservancy, environment and public facilities management" ///
	15 "residential services and other services" 16 "education" 17 "health, social security and social welfare" 18 "culture, sports and entertainment" 19 "public admin and social organization" 20 "international organization"
	label values industry industrylbl 
	
	*Drop invalid obs
	drop if gender == 0
	gen male = 1 if gender == 1 
	replace male = 0 if gender == 2 
	
	*Adjust salary to baseline 2015 CNY
	preserve 
	use "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/cpi_china.dta", clear
	local cpi = cpi20`y'
	restore
	gen salary_adj = salary*100/`cpi' //adjusted salary by CPI
	
	*Generate age
	gen birthyr_str = string(birthdate)
	gen birthyr = substr(birthyr_str, 1, 4)
	drop birthyr_str
	destring birthyr, force replace
	gen age = year - birthyr
	
	replace yearstart = year - yearstart

    save "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/clean_fh`y'.dta", replace


}
