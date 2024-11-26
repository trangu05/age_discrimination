cd "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/age_discrimination"
 use "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/data/CPS/cps_00002.dta", clear
 
keep if month == 3

save ../data/CPS/cps_march.dta, replace
 
drop if age < 16 | age > 65
preserve
keep if ind1990 == 322 // Manufacturing, computer equipment

* Create a new empty string variable to hold the labels
gen str_occ_label = ""

* Loop over each unique value of occ1990
levelsof occ1990, local(occvals)

foreach val in `occvals' {
    * Get the label for each value and assign it to the new variable
    replace str_occ_label = "`: label (occ1990) `val''" if occ1990 == `val'
}

gen engineer = (strpos(str_occ_label, "engineer") > 0)
gen technician = (strpos(str_occ_label, "technician") > 0)
gen operator = (strpos(str_occ_label, "operator") > 0)

drop if incwage == 0 

local graphnames

forvalues y = 1990/2000 {
    binscatter incwage age if year == `y', by(engineer) linetype(connect) nquantiles(5) ///
        name(engineer_`y', replace)
    
    * Add the graph name to the macro
    local graphnames `graphnames' engineer_`y'
}
*Combine all the generated graphs using the stored names in the macro
graph combine `graphnames', ///
    title("Salary Growth by Age and Industry") ///
    colfirst ycommon
