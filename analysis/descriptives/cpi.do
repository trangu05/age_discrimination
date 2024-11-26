*Extract China's CPI

import excel "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/macro/CPI.xls", sheet("Data") cellrange(A4:BP270) firstrow clear

local y = 1960
foreach var of varlist E-BP{
	ren `var' year`y'
	label variable year`y' "CPI (2010 = 100) year `y'"
	local y = `y' + 1 
	
}

drop year1960-year1985
keep if CountryName == "China"

forvalues y = 1986/2023{
	
	gen cpi`y' = year`y' * 100 / year2015
	label variable cpi`y' "CPI (2015 = 100) year`y' China"
}

keep cpi*

save "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination/output/data/cpi_china.dta", replace
