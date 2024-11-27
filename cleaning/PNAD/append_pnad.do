*Append data for the years we need
clear
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"


local files : dir "output/data/PNAD/cleaned" files "*.dta"
di `files'
    foreach file in `files' {
        append using output/data/PNAD/cleaned/`file'
    }

	
save output/data/PNAD/appended.dta, replace
