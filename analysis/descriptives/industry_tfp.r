# set-up
library(readstata13)
library(dplyr)
library(R.matlab)
data_loc <- "/Users/sabrina_peng/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/firm survey/industry_98-13_v1.dta"

# read in firm level data and comparison tfp data
ind_df <- read.dta13(data_loc)
firm_panel <- ind_df %>% select(panelid, year, company_name, ind3, ind2, gyxsczxjxgd, tfplp, tfpop)
tfp0107 <- readMat("./other_data/log_tfp_data_0.mat")
tfp0107_df <- as.data.frame(tfp0107)
tfp0712 <- readMat("./other_data/log_tfp_data_1.mat")
tfp0712_df <- as.data.frame(tfp0712)

# compare the distribution
firm_0712 <- firm_panel %>% filter(year >= 2007 & year <=2012) %>% mutate(
    log_tfp_lp = log(tfplp), log_tfp_op = log(tfpop))
table(firm_0712$year)
hist(tfp0712_df$log.tfp.data)
summary(tfp0712_df$log.tfp.data)
summary(firm_0712$tfplp)
summary(firm_0712$tfpop)
