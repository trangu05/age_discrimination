*Append data for the years we need
clear
cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"
local years 04 05 06 07 08 09 10 11 12


// Initialize a counter
local i = 1

// Loop through the years
foreach year of local years {
    // For the first year, use "use" instead of "append"
    if `i' == 1 {
        use "output/data/clean_fh`year'", clear
    }
    else {
        append using "output/data/clean_fh`year'"
    }
    local ++i
}

save output/data/total_$start_year$end_year.dta, replace

/*
*Append 2002 and 2003
local years 02 03
// Initialize a counter
local i = 1

// Loop through the years
foreach year of local years {
    // For the first year, use "use" instead of "append"
 
        append using "output/data/clean_fh`year'"
    local ++i
}

save output/data/total_02$end_year.dta, replace
*/
