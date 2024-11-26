*********Cleaning UHS data 2000*******
*******************************************************************************

cd "C:\Users\nguye\OneDrive - Yale University\online job ads_china\data\UHS\raw_data\86-09\86-01\86-01 data"

use "fh00.dta", clear

*Choose variables that we need*

keep year code prov x3-x14
ren x3 memberno
ren x4 rel
ren x5 gender
ren x6 age
ren x7 edu
ren x8 industry
ren x9 employ
ren x10 occ
ren x11 yearstart
ren x12 totalinc
ren x13 earnings
ren x14 salary

save clean_fh00.dta, replace
