cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"
import excel "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/macro/China/CIP_4.0_(2023)_4.xlsx", sheet("Nominal VA") cellrange(A3:AG41) firstrow clear
ren CIPcode CIP_code
ren Industry SectorAcronym
local y = 1987
foreach var of varlist C-AG{
	ren `var' va`y'
	local y = `y' + 1
}
destring CIP_code, replace force
drop if missing(CIP_code)
save output/data/va, replace

