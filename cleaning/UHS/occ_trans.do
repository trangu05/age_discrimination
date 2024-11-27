import excel "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/PNAD/occ_code_translated.xlsx", sheet("Sheet1") clear

gen occ_code = real(regexs(1)) if regexm(A,"([0-9]+)")
gen occ_name = ustrregexra(A, "[0-9]", "")
drop if missing(occ_code)

drop A

save "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/age_discrimination/output/data/PNAD/occ_trans.dta", replace
