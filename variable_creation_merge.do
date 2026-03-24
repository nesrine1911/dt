/*===========================================================================
  variable_creation_merge.do

  Creates a single clean dataset with only the four target variables:
    - BUScheck
    - BUScheckPT
    - BUScheckOC
    - scf_fa_forbes_equity_non_corp

  SECTION A  BUScheck / BUScheckPT / BUScheckOC
  ---------------------------------------------
  Drawn directly from 1_dataset.do, one block per SCF wave (1989-2022).
  For each year only the minimum required steps are kept:
    1. Load SCF implicate file and merge with summary file (farmbus comes
       from the summary file and is needed in the BUScheck formulas)
    2. Round x/X variables exactly as in the original
    3. Create BUScheck, BUScheckPT, BUScheckOC with the original exact code
  Everything else in 1_dataset.do (wage dummies, regressions, labour merge,
  profits, keep/save) is omitted because it is not used in these three vars.

  SECTION B  scf_fa_forbes_equity_non_corp
  ----------------------------------------
  Run scf_fa_recon.do verbatim via do, then pull only that variable from
  its output file.

  SECTION C  Merge and save
  -------------------------
  Merge the two outputs on (year, y1) and keep the four target variables.

  *** ADJUST PATHS BELOW before running ***
===========================================================================*/

local in   "C:\Users\nhadjara\Dropbox\Equity&WealthIneq\data\scf"
local adj  "C:\Users\nhadjara\Dropbox\Equity&WealthIneq\Maitreyee"

global source "`in'"
global main   "`adj'"

clear
clear matrix
clear mata
set more off
set maxvar 10000


/*===========================================================================
  SECTION A: BUScheck, BUScheckPT, BUScheckOC
===========================================================================*/

**********************************
************** 1989 **************
**********************************

foreach num of numlist 89(1)89 {

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 x1
merge 1:1 x1 using "`in'/rscfp19`num'.dta", nogen
rename x1 y1
rename xx1 yy1
gen year=19`num'

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
	  + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
                   +(x3335>0)*x3335*(x3119==1) +(x3335>0)*x3335*(x3119==11) +  farmbus*(x3119==1)+  farmbus*(x3119==11)+ ///
                    (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck89
save `buscheck89', replace
}


**********************************
************** 1992 **************
**********************************

foreach num of numlist 92(1)92 {

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "`in'/rscfp19`num'.dta", nogen
gen year=19`num'

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
	  + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
                   +(x3335>0)*x3335*(x3119==1) +(x3335>0)*x3335*(x3119==11) +  farmbus*(x3119==1)+  farmbus*(x3119==11)+ ///
                    (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck92
save `buscheck92', replace
}


**********************************
************** 1995 **************
**********************************

foreach num of numlist 95(1)95 {

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "`in'/rscfp19`num'.dta", nogen
gen year=19`num'

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
	  + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
                   +(x3335>0)*x3335*(x3119==1) +(x3335>0)*x3335*(x3119==11) +  farmbus*(x3119==1)+  farmbus*(x3119==11)+ ///
                    (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck95
save `buscheck95', replace
}


**********************************
************** 1998 **************
**********************************

foreach num of numlist 98(1)98 {

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "`in'/rscfp19`num'.dta", nogen
gen year=19`num'

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
	  + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
                   +(x3335>0)*x3335*(x3119==1) +(x3335>0)*x3335*(x3119==11) +  farmbus*(x3119==1)+  farmbus*(x3119==11)+ ///
                    (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck98
save `buscheck98', replace
}


**********************************
************** 2001 **************
**********************************

foreach num of numlist 2001(1)2001 {

use "`in'/p01i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "`in'/rscfp2001.dta", nogen
gen year=2001

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
	  + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
                   +(x3335>0)*x3335*(x3119==1) +(x3335>0)*x3335*(x3119==11) +  farmbus*(x3119==1)+  farmbus*(x3119==11)+ ///
                    (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2001
save `buscheck2001', replace
}


**********************************
************** 2004 **************
**********************************

foreach num of numlist 2004(1)2004 {

use "`in'/p04i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "`in'/rscfp2004.dta", nogen
gen year=2004

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
	  + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
                   +(x3335>0)*x3335*(x3119==1) +(x3335>0)*x3335*(x3119==11) +  farmbus*(x3119==1)+  farmbus*(x3119==11)+ ///
                    (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2004
save `buscheck2004', replace
}


**********************************
************** 2007 **************
**********************************

foreach num of numlist 2007(1)2007 {

use "`in'/p07i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "`in'/rscfp2007.dta", nogen
gen year=2007

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
	  + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
                   +(x3335>0)*x3335*(x3119==1) +(x3335>0)*x3335*(x3119==11) +  farmbus*(x3119==1)+  farmbus*(x3119==11)+ ///
                    (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2007
save `buscheck2007', replace
}


**********************************
************** 2010 **************
**********************************

* Note: from 2010 onward the implicate file already uses uppercase variable
* names (no rename X*->x* needed); only 2 active business slots (X3119,
* X3219); new non-active slot X3452 added; BUScheckSP renamed BUScheckactSP

foreach num of numlist 10(1)10 {

use "`in'/p10i6", clear
merge 1:1 Y1 using "`in'/rscfp20`num'.dta", nogen
rename Y1 y1
rename YY1 yy1
gen year=20`num'

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
                    +(X3335>0)*X3335*(X3119==1) +(X3335>0)*X3335*(X3119==11) +  farmbus*(X3119==1)+  farmbus*(X3119==11)+ ///
                    (X3408>0)*X3408 + (X3412>0)*X3412 +(X3452>0)*X3452), by(y1)

egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2010
save `buscheck2010', replace
}


**********************************
************** 2013 **************
**********************************

foreach num of numlist 13(1)13 {

use "`in'/p13i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "`in'/rscfp2013.dta", nogen
rename (y1 yy1) (Y1 YY1)
gen year=20`num'

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(Y1)

egen BUScheckPT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
                    +(X3335>0)*X3335*(X3119==1) +(X3335>0)*X3335*(X3119==11) +  farmbus*(X3119==1)+  farmbus*(X3119==11)+ ///
                    (X3408>0)*X3408 + (X3412>0)*X3412 +(X3452>0)*X3452), by(Y1)

egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(Y1)

rename Y1 y1
rename YY1 yy1
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2013
save `buscheck2013', replace
}


**********************************
************** 2016 **************
**********************************

foreach num of numlist 16(1)16 {

use "`in'/p16i6", clear
merge 1:1 Y1 using "`in'/rscfp2016.dta", nogen
rename Y1 y1
rename YY1 yy1
gen year=20`num'

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(y1)

egen BUScheckPT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
                    +(X3335>0)*X3335*(X3119==1) +(X3335>0)*X3335*(X3119==11) +  farmbus*(X3119==1)+  farmbus*(X3119==11)+ ///
                    (X3408>0)*X3408 + (X3412>0)*X3412 +(X3452>0)*X3452), by(y1)

egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2016
save `buscheck2016', replace
}


**********************************
************** 2019 **************
**********************************

foreach num of numlist 19(1)19 {

use "`in'/p19i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "`in'/rscfp20`num'.dta", nogen
rename (y1 yy1) (Y1 YY1)
gen year=20`num'

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(Y1)

egen BUScheckPT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
                    +(X3335>0)*X3335*(X3119==1) +(X3335>0)*X3335*(X3119==11) +  farmbus*(X3119==1)+  farmbus*(X3119==11)+ ///
                    (X3408>0)*X3408 + (X3412>0)*X3412 +(X3452>0)*X3452), by(Y1)

egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(Y1)

rename Y1 y1
rename YY1 yy1
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2019
save `buscheck2019', replace
}


**********************************
************** 2022 **************
**********************************

foreach num of numlist 22(1)22 {

use "`in'/p22i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "`in'/rscfp20`num'.dta", nogen
rename (y1 yy1) (Y1 YY1)
gen year=20`num'

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(Y1)

egen BUScheckPT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
                    +(X3335>0)*X3335*(X3119==1) +(X3335>0)*X3335*(X3119==11) +  farmbus*(X3119==1)+  farmbus*(X3119==11)+ ///
                    (X3408>0)*X3408 + (X3412>0)*X3412 +(X3452>0)*X3452), by(Y1)

egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(Y1)

rename Y1 y1
rename YY1 yy1
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC
tempfile buscheck2022
save `buscheck2022', replace
}


* Append all years
use `buscheck89', clear
foreach yr in 92 95 98 {
    append using `buscheck`yr''
}
foreach yr in 2001 2004 2007 2010 2013 2016 2019 2022 {
    append using `buscheck`yr''
}
order year y1 yy1

tempfile buschecks_all
save `buschecks_all', replace


/*===========================================================================
  SECTION B: scf_fa_forbes_equity_non_corp
  The code below is taken verbatim from scf_fa_recon.do and pared down to
  only the steps needed to produce scf_fa_forbes_equity_non_corp:
    - Full FA + SCF data load and reconciliation (all asset categories are
      needed because recon_nw drives the Forbes portfolio shares)
    - Forbes data read and equity_non_corp allocation
    - Append Forbes to SCF, create scf_fa_forbes_equity_non_corp
  All tabstat matrix outputs, demographic tables, and every other
  scf_fa_forbes_xxx variable are dropped.
===========================================================================*/

import delimited "$main\dfa_public_code\dfa_raw\fa_data.csv", clear

*** start here for code to convert to constant
preserve

import excel "C:\Users\nhadjara\Dropbox\Equity&WealthIneq\Maitreyee\data\Inflation.xlsx", first sheet("clean") clear
ren _all, lower
drop jul

tempfile cpi
save `cpi'
restore

merge 1:1 year using `cpi', nogen keep (3)

ds year perm_ratio cars_payable homes_payable corp_for_ratio index, not
local varlist `r(varlist)'

foreach var of local varlist {
    replace `var' = `var' * index
}

drop index
** end here 

tempfile fadata
save `fadata', replace 

foreach y in 19 22{
    use "$source/p`y'i6.dta", clear
    tempfile scf`y'r
    ren *, lower
    save `scf`y'r', replace
    use "$source/rscfp20`y'.dta", clear
    merge 1:1 y1 using `scf`y'r', gen(merge`y')
    gen year = 20`y'
    drop j*
    cumul networth [aw=wgt], gen(ranknw) 
    tempfile scf`y'
    save `scf`y'', replace
}

foreach y in 01 04 07 10 13 16 {
    use "$source/p`y'i6.dta", clear
    tempfile scf`y'r
    ren *, lower
    save `scf`y'r', replace
    use "$source/rscfp20`y'.dta", clear
	capture confirm variable Y1 YY1
	if (_rc == 0) {
    rename (Y1 YY1) (y1 yy1)
		}
    merge 1:1 y1 using `scf`y'r', gen(merge`y')
    gen year = 20`y'
	ren _all, lower
    drop j*
    cumul networth [aw=wgt], gen(ranknw) 
    tempfile scf`y'
    save `scf`y'', replace
}
foreach y in 95 98 {
    use "$source/p`y'i6.dta", clear
    tempfile scf`y'r
    ren *, lower
    save `scf`y'r', replace
    use "$source/rscfp19`y'.dta", clear
    merge 1:1 y1 using `scf`y'r', gen(merge`y')
    gen year = 19`y'
    drop j*
    cumul networth [aw=wgt], gen(ranknw) 
    tempfile scf`y'
    save `scf`y'', replace
}
foreach y in 92 {
    use "$source/p`y'i6.dta", clear
    tempfile scf`y'r
    ren *, lower
    save `scf`y'r', replace
    use "$source/rscfp19`y'.dta", clear
    merge 1:1 y1 using `scf`y'r', gen(merge`y')
    gen year = 19`y'
    drop j*
    cumul networth [aw=wgt], gen(ranknw) 
    tempfile scf`y'
    save `scf`y'', replace
}
foreach y in 89 {
    use "$source/p`y'i6.dta", clear
    tempfile scf`y'r
    ren *, lower
    drop if xx1 >= 4001
    save `scf`y'r', replace
    use "$source/rscfp19`y'.dta", clear
    rename (x1 xx1) (y1 yy1)
    merge 1:1 y1 using `scf`y'r', gen(merge`y')
    gen year = 19`y'
    drop j*
    cumul networth [aw=wgt], gen(ranknw) 
    tempfile scf`y'
    save `scf`y'', replace
}
** Append all SCF years to create one dataset
use `scf22', clear
qui append using `scf19'
qui append using `scf16'
qui append using `scf13'
qui append using `scf10'
qui append using `scf07'
qui append using `scf04'
qui append using `scf01'
qui append using `scf98'
append using `scf95', force
append using `scf92', force
append using `scf89', force

merge m:1 year using `fadata', nogen
ren married scf_married
merge m:1 age using "$main\dfa_public_code\dfa_raw\payout_annuities.dta", nogen keep(match)

ren (single married) (fa_single fa_married)
ren scf_married married

merge 1:1 y1 year using "$main\dfa_public_code\dfa_raw\DFA_DB_public.dta", nogen keep(match)

*************************** RECONCILE FA AND SCF *******************************


**************************** RECONCILE REAL ESTATE *****************************


if year<=1992{
gen rental_properties1=0
replace rental_properties1=x1706*(x1705/10000) if inlist(x1703, 12, 14, 21, 22, 40, 41, 42, 43, 44, 49, 50, 52, 999) 
replace rental_properties1=0 if x1729!=1
gen rental_properties2=0
replace rental_properties2=x1806*(x1805/10000) if inlist(x1803, 12, 14, 21, 22, 40, 41, 42, 43, 44, 49, 50, 52, 999) 
replace rental_properties2=0 if x1829!=1
gen rental_properties3=0
replace rental_properties3=x1906*(x1905/10000) if inlist(x1903, 12, 14, 21, 22, 40, 41, 42, 43, 44, 49, 50, 52, 999) 
replace rental_properties3=0 if x1929!=1
gen rental_properties_more=0
replace rental_properties_more=max(0, x2002) if x2009==1
}


if year>1992 & year<=2007{
gen rental_properties1=0
replace rental_properties1=x1706*(x1705/10000) if inlist(x1703, 12, 21, 40, 41, 42, 49, 50, 999, -7) 
replace rental_properties1=0 if x1729!=1
gen rental_properties2=0
replace rental_properties2=x1806*(x1805/10000) if inlist(x1803, 12, 21, 40, 41, 42, 49, 50, 999, -7) 
replace rental_properties2=0 if x1829!=1
gen rental_properties3=0
replace rental_properties3=x1906*(x1905/10000) if inlist(x1903, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace rental_properties3=0 if x1929!=1
gen rental_properties_more=0
replace rental_properties_more=max(0, x2002) if x2009==1 
}
if year>=2010 {
gen rental_properties1=0
replace rental_properties1=x1706*(x1705/10000) if inlist(x1703, 12, 21, 40, 42, 49, 50, 999, -7)
replace rental_properties1=0 if x1729!=1
gen rental_properties2=0
replace rental_properties2=x1806*(x1805/10000) if inlist(x1803, 12, 21, 40, 42, 49, 50, 999, -7)
replace rental_properties2=0 if x1829!=1
gen rental_properties3=0
gen rental_properties_more=0
replace rental_properties_more=max(0, x2002) if x2009==1 
}

gen rentals=0
replace rentals=rental_properties1 + rental_properties2 + rental_properties3 + rental_properties_more

gen oresre_norent=0
replace oresre_norent=oresre-rentals

gen vacant_land=0
replace vacant_land=x1706*(x1705/10000) if x1703==11
replace vacant_land=vacant_land + x1806*(x1805/10000) if x1803==11
replace vacant_land=vacant_land + x1906*(x1905/10000) if x1903==11

gen scf_fa_real_estate=0
replace scf_fa_real_estate=houses+oresre_norent
replace scf_fa_real_estate=houses+oresre_norent+vacant_land
replace scf_fa_real_estate=0 if scf_fa_real_estate==0

************************* RECONCILE CONSUMER DURABLES **************************


if year < 2019{
gen scf_fa_consumer_durables=0
replace scf_fa_consumer_durables=vehic
replace scf_fa_consumer_durables=scf_fa_consumer_durables+x4022 if x4020<=25 | x4020==75 | x4020==76
replace scf_fa_consumer_durables=scf_fa_consumer_durables+x4026 if x4024<=25 | x4024==75 | x4024==76
replace scf_fa_consumer_durables=scf_fa_consumer_durables+x4030 if x4028<=25 | x4028==75 | x4028==76
}

**For 2019 SCF public data code 75 is combined with code 76
if year>=2019{
gen scf_fa_consumer_durables=0
replace scf_fa_consumer_durables=vehic
replace scf_fa_consumer_durables=scf_fa_consumer_durables+x4022 if x4020<=25 | x4020==76 
replace scf_fa_consumer_durables=scf_fa_consumer_durables+x4026 if x4024<=25 | x4024==76 
replace scf_fa_consumer_durables=scf_fa_consumer_durables+x4030 if x4028<=25 | x4028==76
}


gen scf_fa_vehicles=vehic
gen scf_fa_other_durables=scf_fa_consumer_durables-scf_fa_vehicles

************************** RECONCILE FOREIGN DEPOSITS **************************

gen cpi=1901/2115 if year==1989
gen scf_fa_foreign_dep=0
replace scf_fa_foreign_dep = fin*0.06 if x7647==1 & year>1989
summarize scf_fa_foreign_dep [aw=wgt] if year==1992
di r(sum)
gen for_dep92=r(sum)
egen wgt89=total(wgt) if year==1989
gen for_dep89=(for_dep92*cpi)/wgt89 if year==1989
replace scf_fa_foreign_dep=for_dep89 if year==1989


*********************** RECONCILE CHECK DEPOSITS / CURRENCY ********************

gen cash = ((x4020==63)*x4022) + ((x4024==63)*x4026) + ((x4028==63)*x4030) 

replace prepaid=0 if prepaid==.
gen checkable = checking+prepaid+cash 
gen scf_fa_check_fgn_dep_curr = checking+prepaid+cash+scf_fa_foreign_dep 

************************** RECONCILE TIME / SAV DEPOSITS ***********************

gen iradebtsec=0
*all debtsec
replace iradebtsec = iradebtsec + irakh if inlist(year,1989,1992,1995,1998,2001) & inlist(x3631,3)
** In public SCF data, code 9 is combined with code 2; code 9 is not included in internal DFA code
replace iradebtsec = iradebtsec + (x6551+x6552+x6553+x6554) if inlist(year,2004,2007,2010,2013,2016,2019) & x6555==2
replace iradebtsec = iradebtsec + (x6559+x6560+x6561+x6562) if inlist(year,2004,2007,2010,2013,2016,2019) & x6563==2
replace iradebtsec = iradebtsec + (x6567+x6568+x6569+x6570) if inlist(year,2004,2007,2010,2013,2016,2019) & x6571==2
*part debtsec
replace iradebtsec = iradebtsec + .5*irakh if inlist(year,1989,1992,1995,1998,2001) & inlist(x3631,5,6)
replace iradebtsec = iradebtsec + .33*irakh if inlist(year,1989,1992,1995,1998,2001) & inlist(x3631,4)
replace iradebtsec = iradebtsec + (1-(x6556/10000))*(x6551+x6552+x6553+x6554) if inlist(year,2004,2007,2010,2013,2016,2019) & x6555==3
replace iradebtsec = iradebtsec + (1-(x6564/10000))*(x6559+x6560+x6561+x6562) if inlist(year,2004,2007,2010,2013,2016,2019) & x6563==3
replace iradebtsec = iradebtsec + (1-(x6572/10000))*(x6567+x6568+x6569+x6570) if inlist(year,2004,2007,2010,2013,2016,2019) & x6571==3

gen irainterest = 0
replace irainterest = irainterest + irakh if inlist(year,1989,1992,1995,1998,2001) & inlist(x3631,1)
replace irainterest = irainterest + .33*irakh if inlist(year,1989,1992,1995,1998,2001) & inlist(x3631,4)

//split trusts into underlying asset components
g trustsdebtsec=0
*component codes vary by year '89-'98, '01, '04-'07, '10+
*all debtsec
replace trustsdebtsec = trustsdebtsec + trusts if inlist(year,1989,1992,1995) & inlist(x3947,2)
replace trustsdebtsec = trustsdebtsec + trusts if inlist(year,1998,2001) & x6826==2
*Beginning in 2007, code 9 (Guaranteed Income Contract) is combined with code 2; code 9 is not included in internal DFA code
replace trustsdebtsec = trustsdebtsec + trusts if year>2001 & inlist(x6591,2)
*part debtsec
replace trustsdebtsec = trustsdebtsec + .5*trusts if inlist(year,1989,1992,1995) & inlist(x3947,5,6)
replace trustsdebtsec = trustsdebtsec + .33*trusts if inlist(year,1989,1992,1995) & inlist(x3947,4,-7)
replace trustsdebtsec = trustsdebtsec + .5*trusts if inlist(year,1998,2001) & inlist(x6841,5,6)
replace trustsdebtsec = trustsdebtsec + .33*trusts if inlist(year,1998,2001) & inlist(x6841,4,-7)
*code 30 (Mutual Fund) introduced in 2010
replace trustsdebtsec = trustsdebtsec + (1-(x6592/10000))*trusts if year>2001 & inlist(x6591,3,30)


gen scf_fa_time_dep = saving+cds+mmda  
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2022
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2019
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2016
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2013
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2010
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2007
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2004
replace scf_fa_time_dep = saving+cds+mmda+(0.10*iradebtsec)+(0.25*trustsdebtsec) if year==2001
replace scf_fa_time_dep = saving+cds+mmda+irainterest+(0.25*trustsdebtsec) if year>=1989 & year<2001


******************** RECONCILE MONEY MARKET MUTUAL FUND SHARES *****************

gen scf_fa_mmmf_shares = mmmf
replace scf_fa_mmmf_shares = mmmf + 0.35*iradebtsec + 0.10*trustsdebtsec if year==2022
replace scf_fa_mmmf_shares = mmmf + 0.35*iradebtsec + 0.10*trustsdebtsec if year==2019
replace scf_fa_mmmf_shares = mmmf + 0.35*iradebtsec + 0.10*trustsdebtsec if year==2016
replace scf_fa_mmmf_shares = mmmf + 0.40*iradebtsec + 0.10*trustsdebtsec if year==2013
replace scf_fa_mmmf_shares = mmmf + 0.40*iradebtsec + 0.10*trustsdebtsec if year==2010
replace scf_fa_mmmf_shares = mmmf + 0.40*iradebtsec + 0.10*trustsdebtsec if year==2007
replace scf_fa_mmmf_shares = mmmf + 0.50*iradebtsec + 0.10*trustsdebtsec if year==2004
replace scf_fa_mmmf_shares = mmmf + 0.50*(iradebtsec) + 0.10*trustsdebtsec if year==2001
replace scf_fa_mmmf_shares = mmmf + 0.50*(iradebtsec) + 0.10*trustsdebtsec if year==1998
replace scf_fa_mmmf_shares = mmmf + 0.50*(iradebtsec) + 0.10*trustsdebtsec if year==1995
replace scf_fa_mmmf_shares = mmmf + 0.50*(iradebtsec) + 0.10*trustsdebtsec if year==1992
replace scf_fa_mmmf_shares = mmmf + 0.50*(iradebtsec) + 0.10*trustsdebtsec if year==1989



**************************** RECONCILE DEBT SECURITIES *************************


gen scf_fa_treas_sec = govtbnd + savbnd

gen scf_fa_agency_gse_sec = mortbnd

gen scf_fa_muni_sec = notxbnd


/// 8. DEBT SECURITIES
/*---------------
Remainder of irasebtsec and trustdebtsec goes to bonds.
---------------*/

gen scf_fa_debtsec = bond + savbnd + iradebtsec + trustsdebtsec
gen scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(iradebtsec + trustsdebtsec)
gen scf_fa_corp_for_bnds = obnd + corp_for_ratio*(iradebtsec + trustsdebtsec)

replace scf_fa_debtsec = bond + savbnd + 0.55*iradebtsec + 0.65*trustsdebtsec if year==2022
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.55*iradebtsec + 0.65*trustsdebtsec) if year==2022
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.55*iradebtsec + 0.65*trustsdebtsec) if year==2022

replace scf_fa_debtsec = bond + savbnd + 0.55*iradebtsec + 0.65*trustsdebtsec if year==2019
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.55*iradebtsec + 0.65*trustsdebtsec) if year==2019
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.55*iradebtsec + 0.65*trustsdebtsec) if year==2019

replace scf_fa_debtsec = bond + savbnd + 0.55*iradebtsec + 0.65*trustsdebtsec if year==2016
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.55*iradebtsec + 0.65*trustsdebtsec) if year==2016
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.55*iradebtsec + 0.65*trustsdebtsec) if year==2016

replace scf_fa_debtsec = bond + savbnd + 0.50*iradebtsec + 0.65*trustsdebtsec if year==2013
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.50*iradebtsec + 0.65*trustsdebtsec) if year==2013
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.50*iradebtsec + 0.65*trustsdebtsec) if year==2013

replace scf_fa_debtsec = bond + savbnd + 0.50*iradebtsec + 0.65*trustsdebtsec if year==2010
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.50*iradebtsec + 0.65*trustsdebtsec) if year==2010
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.50*iradebtsec + 0.65*trustsdebtsec) if year==2010


replace scf_fa_debtsec = bond + savbnd + 0.50*iradebtsec + 0.65*trustsdebtsec if year==2007
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.50*iradebtsec + 0.65*trustsdebtsec) if year==2007
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.50*iradebtsec + 0.65*trustsdebtsec) if year==2007

replace scf_fa_debtsec = bond + savbnd + 0.40*iradebtsec + 0.65*trustsdebtsec if year==2004
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==2004
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==2004

replace scf_fa_debtsec = bond + savbnd + 0.40*(iradebtsec-irainterest) + 0.65*trustsdebtsec if year==2001
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==2001
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==2001

replace scf_fa_debtsec = bond + savbnd + 0.40*(iradebtsec-irainterest) + 0.65*trustsdebtsec if year==1998
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1998
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1998


replace scf_fa_debtsec = bond + savbnd + 0.40*(iradebtsec-irainterest) + 0.65*trustsdebtsec if year==1995
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1995
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1995

replace scf_fa_debtsec = bond + savbnd + 0.40*(iradebtsec-irainterest) + 0.65*trustsdebtsec if year==1992
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1992
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1992

replace scf_fa_debtsec = bond + savbnd + 0.40*(iradebtsec-irainterest) + 0.65*trustsdebtsec if year==1989
replace scf_fa_gov_muni_bnds = scf_fa_treas_sec + scf_fa_agency_gse_sec + scf_fa_muni_sec + (1-corp_for_ratio)*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1989
replace scf_fa_corp_for_bnds = obnd + corp_for_ratio*(0.40*iradebtsec + 0.65*trustsdebtsec) if year==1989


//preliminary analysis indicates that hedge funds hold approximately 30% equities and 70% fixed income.
*1.	.3*omutf stays with mutual funds (REITS)
*2.	.7*omutf = hedge funds
*3.	.7*hedgefunds = hedge_fund_fixed_income (move from MF to bonds) = 0.49*omutf
*4.	.3*hedgefunds goes back into mutual funds


gen hedge_fixed_income = .49*(omutf) 
gen hedge_gov_muni = .75*hedge_fixed_income 
gen hedge_corp_foreign = hedge_fixed_income - hedge_gov_muni
replace scf_fa_debtsec = scf_fa_debtsec + hedge_fixed_income
replace scf_fa_gov_muni_bnds = scf_fa_gov_muni_bnds + hedge_gov_muni
replace scf_fa_corp_for_bnds = scf_fa_corp_for_bnds + hedge_corp_foreign


**************************** RECONCILE OTHER LOANS AND ADVANCSES / MORTGAGES *************************

*mortgages & other loans owed after 2010
egen mort_owed1_1316 = rowmax(x1306 x1310) if (x1304>=1 & x1304<=2) & year>2010
replace mort_owed1_1316 = 0 if missing(mort_owed1_1316)==1
egen mort_owed2_1316 = rowmax(x1325 x1329) if (x1323>=1 & x1323<=2) & year>2010
replace mort_owed2_1316 = 0 if missing(mort_owed2_1316)==1

egen othln_owed1_1316 = rowmax(x1306 x1310) if (x1304==3) & year>2010
replace othln_owed1_1316 = 0 if missing(othln_owed1_1316)==1
egen othln_owed2_1316 = rowmax(x1325 x1329) if (x1323==3) & year>2010
replace othln_owed2_1316 = 0 if missing(othln_owed2_1316)==1

gen scf_fa_mort_owed_1316 =  mort_owed1_1316+mort_owed2_1316+x1339
gen scf_fa_othln_owed_1316 = othln_owed1_1316+othln_owed2_1316+call

*mortgages & other loans owed for 2010
egen mort_owed1_10 = rowmax(x1405 x1409) if (x1404>=1 & x1404<=2) & year==2010
replace mort_owed1_10 = 0 if missing(mort_owed1_10)==1
egen mort_owed2_10 = rowmax(x1505 x1509) if (x1504>=1 & x1504<=2) & year==2010
replace mort_owed2_10 = 0 if missing(mort_owed2_10)==1
gen scf_fa_mort_owed_10 =  mort_owed1_10+mort_owed2_10+x1619

egen othln_owed1_10 = rowmax(x1405 x1409) if (x1404==3) & year==2010
replace othln_owed1_10 = 0 if missing(othln_owed1_10)==1
egen othln_owed2_10 = rowmax(x1505 x1509) if (x1504==3) & year==2010
replace othln_owed2_10 = 0 if missing(othln_owed2_10)==1

gen scf_fa_othln_owed10 = othln_owed1_10+othln_owed2_10+call


*mortgages & other loans owed before 2010
egen mort_owed1_8907 = rowmax(x1405 x1409) if (x1404>=1 & x1404<=2) & year<2010
replace mort_owed1_8907 = 0 if missing(mort_owed1_8907)==1
egen mort_owed2_8907 = rowmax(x1505 x1509) if (x1504>=1 & x1504<=2) & year<2010
replace mort_owed2_8907 = 0 if missing(mort_owed2_8907)==1
egen mort_owed3_8907 = rowmax(x1605 x1609) if (x1604>=1 & x1604<=2) & year<2010
replace mort_owed3_8907= 0 if missing(mort_owed3_8907)==1

egen othln_owed1_8907 = rowmax(x1405 x1409) if (x1404==3) & year<2010
replace othln_owed1_8907 = 0 if missing(othln_owed1_8907)==1
egen othln_owed2_8907 = rowmax(x1505 x1509) if (x1504==3) & year<2010
replace othln_owed2_8907 = 0 if missing(othln_owed2_8907)==1
egen othln_owed3_8907 = rowmax(x1605 x1609) if (x1604==3) & year<2010
replace othln_owed3_8907= 0 if missing(othln_owed3_8907)==1

gen scf_fa_mort_owed_8907 = mort_owed1_8907+mort_owed2_8907+mort_owed3_8907+x1619
gen scf_fa_othln_owed8907 = othln_owed1_8907+othln_owed2_8907+othln_owed3_8907+call

gen scf_fa_mort_owed = .
replace scf_fa_mort_owed = scf_fa_mort_owed_1316 if year>2010
replace scf_fa_mort_owed = scf_fa_mort_owed_10 if year==2010
replace scf_fa_mort_owed = scf_fa_mort_owed_8907 if year<2010

gen scf_fa_othln_owed = .
replace scf_fa_othln_owed = scf_fa_othln_owed_1316 if year>2010
replace scf_fa_othln_owed = scf_fa_othln_owed10 if year==2010
replace scf_fa_othln_owed = scf_fa_othln_owed8907 if year<2010


************************** RECONCILE CORPORATE EQUITIES ************************
*For x3732, codes 3, and 7 are combined with code 2 in the public dataset; all three codes are in internal DFA code beginning in 2010.
gen nontradsaveq=0
replace nontradsaveq=x3730*(x3732==2)*((x7074==1)+ (x7075*(x7074==3 | x7074==30)/10000)) ///
                   + x3736*(x3738==2)*((x7077==1)+ (x7078*(x7077==3 | x7077==30)/10000)) ///
		   + x3742*(x3744==2)*((x7080==1)+ (x7081*(x7080==3 | x7080==30)/10000)) ///
		   + x3748*(x3750==2)*((x7083==1)+ (x7084*(x7083==3 | x7083==30)/10000)) ///
		   + x3754*(x3756==2)*((x7086==1)+ (x7087*(x7086==3 | x7083==30)/10000)) ///
		   + x3760*(x3762==2)*((x7089==1)+ (x7090*(x7089==3 | x7089==30)/10000)) if year>=2010
*In 2007, the public dataset combines codes 2 and 3 for x3732; both codes are included in internal DFA code.
replace nontradsaveq=x3730*(x3732==2 | x3732==7)*((x7074==1)+ (x7075*(x7074==3 | x7074==30)/10000)) ///
                   + x3736*(x3738==2 | x3738==7)*((x7077==1)+ (x7078*(x7077==3 | x7077==30)/10000)) ///
		   + x3742*(x3744==2 | x3744==7)*((x7080==1)+ (x7081*(x7080==3 | x7080==30)/10000)) ///
		   + x3748*(x3750==2 | x3750==7)*((x7083==1)+ (x7084*(x7083==3 | x7083==30)/10000)) ///
		   + x3754*(x3756==2 | x3756==7)*((x7086==1)+ (x7087*(x7086==3 | x7083==30)/10000)) ///
		   + x3760*(x3762==2 | x3762==7)*((x7089==1)+ (x7090*(x7089==3 | x7089==30)/10000)) if year>=2007

gen scf_fa_corp_equity = stocks + irakh - iradebtsec + trusts - trustsdebtsec + nontradsaveq
replace scf_fa_time_dep = scf_fa_time_dep - nontradsaveq

**************************************************** RECONCILE MUTUAL FUND SHARES ************************

gen scf_fa_mut_fund_shares = nmmf - hedge_fixed_income

**************************** RECONCILE LIFE INSURANCE **************************

forvalues y=1989(3)2022{
summarize x4006[aw=wgt] if year==`y'
di r(sum)
local total_perm`y'=r(sum)
}

gen total_perm=.
forvalues y=1989(3)2022{
replace total_perm=`total_perm`y'' if year==`y'
}

forvalues y=1989(3)2022{
summarize x4003[aw=wgt] if year==`y'
di r(sum)
local total_term`y'=r(sum)
}

gen total_term=.
forvalues y=1989(3)2022{
replace total_term=`total_term`y'' if year==`y'
}

gen fa_life_reserv_gen=ga_reserves
gen fa_life_reserv_sep=fa_life_ins_perm_sep_reserves

gen fa_life_reserv_perm = perm_ratio*fa_life_reserv_gen+fa_life_reserv_sep
gen fa_life_reserv_term = (1-perm_ratio)*fa_life_reserv_gen

gen scf_fa_life_ins_perm = x4006*fa_life_reserv_perm/total_perm
gen scf_fa_life_ins_term = x4003*fa_life_reserv_term/total_term

gen scf_fa_life_ins = scf_fa_life_ins_term + scf_fa_life_ins_perm 



************************* RECONCILE PENSION ENTITLEMENTS ***********************


gen scf_fa_dc_assets = thrift + futpen + currpen

gen scf_fa_db_assets = currec_pv_dbamt_hhtot + future_pv_dbamt_hhtot  + curjob_pv_dbamt_r + curjob_pv_dbamt_sp

gen fa_annuit_factor_r=0
replace fa_annuit_factor_r = x6577 + x6580*fa_married if married==1 & year>2001
replace fa_annuit_factor_r = x6577 + x6580*fa_single if married==2 & year>2001
replace fa_annuit_factor_r = x6820 + x6817*fa_married if married==1 & year <=2001 & year>1995
replace fa_annuit_factor_r = x6820 + x6817*fa_married if married==2 & year <=2001 & year>1995
replace fa_annuit_factor_r = x3939*fa_married if married==1 & year <=1995  
replace fa_annuit_factor_r = x3939*fa_married if married==2 & year <=1995 

gen fa_annuit_factor_sp=0
replace fa_annuit_factor_sp = x6577 + x6580*fa_married if married==1 & x104>0 & year>2001
replace fa_annuit_factor_sp = x6577 + x6580*fa_single if married==2 & x104>0&year>2001
replace fa_annuit_factor_sp = x6820 + x6817*fa_married if married==1 & x104>0 & year <=2001 & year>1995
replace fa_annuit_factor_sp = x6820 + x6817*fa_married if married==2 & x104>0 & year <=2001 & year>1995
replace fa_annuit_factor_sp = x3939*fa_married if married==1 & x104>0 & year <=1995  
replace fa_annuit_factor_sp = x3939*fa_married if married==2 & x104>0 & year <=1995 


forvalues y=1989(3)2022{
summarize fa_annuit_factor_r[aw=wgt] if year==`y'
di r(sum)
local total_fa_annuit_r`y'=r(sum)
}

gen total_annuit_r=0
forvalues y=1989(3)2022{
replace total_annuit_r=`total_fa_annuit_r`y'' if year==`y'
}

forvalues y=1989(3)2022{
summarize fa_annuit_factor_sp[aw=wgt] if year==`y'
di r(sum)
local total_fa_annuit_sp`y'=r(sum)
}

gen total_annuit_sp=0
forvalues y=1989(3)2022{
replace total_annuit_sp=`total_fa_annuit_sp`y'' if year==`y'
}

gen scf_fa_annuit = 0
replace scf_fa_annuit = fa_ind_annuity_reserves*((fa_annuit_factor_r+fa_annuit_factor_sp)/(total_annuit_r+total_annuit_sp))

preserve 
collapse (sum) scf_fa_annuit [pw=wgt], by(year)
list
restore



************************* RECONCILE NONCORPORATE EQUITY ************************

gen sc_corp_equity=0
gen sc_corp_value=0
gen sc_corp_stocks=0

if year<2010{
replace sc_corp_value= max(0,x3129) if x3119==3 | x3119==4 
replace sc_corp_value=sc_corp_value + max(0, x3229) if x3219==3 | x3219==4 
replace sc_corp_value=sc_corp_value + max(0, x3329) if x3319==3 | x3319==4 
replace sc_corp_value=sc_corp_value + max(0, x3416) + max(0,x3420)
** Beginning in 1998, the public SCF combines code 78 with code 74; code 78 is not in internal DFA code
replace sc_corp_stocks=x4022 if x4020==73 | x4020==74 
replace sc_corp_stocks=sc_corp_stocks + x4026 if x4024==73 | x4024==74 
replace sc_corp_stocks=sc_corp_stocks + x4030 if x4028==73 | x4028==74

replace sc_corp_equity=sc_corp_stocks + sc_corp_value
replace sc_corp_equity=0 if sc_corp_equity<0
}
**Beginning in 2019, the public SCF combines code 6 with code 4; code 6 is not in internal DFA code	
if year>=2010{
replace sc_corp_value= max(0,x3129) if x3119==3 | x3119==4 
replace sc_corp_value=sc_corp_value + max(0, x3229) if x3219==3 | x3219==4 
replace sc_corp_value=sc_corp_value + max(0, x3416) + max(0,x3420)

** Beginning in 1998, the public SCF combines code 78 with code 74; code 78 is not in internal DFA code

replace sc_corp_stocks=x4022 if x4020==73 | x4020==74 
replace sc_corp_stocks=sc_corp_stocks + x4026 if x4024==73 | x4024==74 
replace sc_corp_stocks=sc_corp_stocks + x4030 if x4028==73 | x4028==74

replace sc_corp_equity=sc_corp_stocks + sc_corp_value
replace sc_corp_equity=0 if sc_corp_equity<0

}

*subtract off sc_corp_value bc sc_corp_stocks not in bus
gen equity_non_corp_nw=nnresre+rentals+bus-sc_corp_value - vacant_land


// Cost basis 
gen active_bus_cb1=0
gen active_bus_cb2=0
gen active_bus_cb3=0
gen active_bus_cb4=0

if year<2010{
replace active_bus_cb1=max(0,x3130) if x3119!=3 | x3119!=4
replace active_bus_cb2=max(0,x3230) if x3219!=3 | x3219!=4
replace active_bus_cb3=max(0,x3330) if x3319!=3 | x3319!=4
replace active_bus_cb4=max(0,x3336)
}
**Beginning in 2019, the public SCF combines code 6 with code 4; code 6 is not in internal DFA code
if year>=2010{
replace active_bus_cb1=max(0,x3130) if x3119!=3 | x3119!=4
replace active_bus_cb2=max(0,x3230) if x3219!=3 | x3219!=4
replace active_bus_cb3=0
replace active_bus_cb4=max(0,x3336)
}

// sc_corp cost basis
gen active_bus_cb1_sc=0
gen active_bus_cb2_sc=0
gen active_bus_cb3_sc=0
gen active_bus_cb4_sc=0

if year<2010{
replace active_bus_cb1_sc=max(0,x3130) if (x3119==3 | x3119==4)
replace active_bus_cb2_sc=max(0,x3230) if (x3219==3 | x3219==4)
replace active_bus_cb3_sc=max(0,x3330) if (x3319==3 | x3319==4)
replace active_bus_cb4_sc=max(0,x3336)
}

**Beginning in 2019, the public SCF combines code 6 with code 4; code 6 is not in internal DFA code
if year>=2010{
replace active_bus_cb1_sc=max(0,x3130) if (x3119==3 | x3119==4)
replace active_bus_cb2_sc=max(0,x3230) if (x3219==3 | x3219==4)
replace active_bus_cb3_sc=0
replace active_bus_cb4_sc=max(0,x3336)
}

gen nonactive_bus_sc=0
replace nonactive_bus_sc=max(0,x3417) + max(0,x3421)

gen sc_corp_cb=active_bus_cb1_sc + active_bus_cb2_sc + active_bus_cb3_sc + active_bus_cb4_sc + nonactive_bus_sc 

// nonactive cost basis (all others)
gen nonactive_bus_cb1=0
gen nonactive_bus_cb2=0
gen nonactive_bus_cb3=0
gen nonactive_bus_cb4=0

if year<2010{
replace nonactive_bus_cb1=max(0,x3409)
replace nonactive_bus_cb2=max(0,x3413)
replace nonactive_bus_cb3=max(0,x3425)
replace nonactive_bus_cb4=max(0,x3429)
}

if year>=2010{
replace nonactive_bus_cb1=max(0,x3409)
replace nonactive_bus_cb2=max(0,x3413)
replace nonactive_bus_cb3=max(0,x3453)
replace nonactive_bus_cb4=max(0,x3429)
}

gen bus_cb=active_bus_cb1 + active_bus_cb2 + active_bus_cb3 + active_bus_cb4 + nonactive_bus_cb1 + nonactive_bus_cb2 + nonactive_bus_cb3 + nonactive_bus_cb4

gen rental_properties_cb1=0
gen rental_properties_cb2=0
gen rental_properties_cb3=0
gen rental_properties_cb4=0
** In public SCF, codes 13, 14, and 22 are combined with code 12; code 13 is not n internal DFA code
**Code 25 is combined with code 21; code 25 is not included in internal DFA code
**Codes 43 and 44 are combined with code 42; all are in internal DFA code
**Code 52 is combined with code -7, -7 is not in internal DFA code
**rentals using purchase price
if year<2010{
replace rental_properties_cb1=x1709*(x1705/10000) if inlist(x1703, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace rental_properties_cb1=0 if x1729!=1
replace rental_properties_cb2=x1809*(x1805/10000) if inlist(x1803, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace rental_properties_cb2=0 if x1829!=1
replace rental_properties_cb3=x1909*(x1905/10000) if inlist(x1903, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace rental_properties_cb3=0 if x1929!=1
replace rental_properties_cb4=max(0, x2002) if x2009==1 
}
**Codes 13, 14, and 22 are combined with code 12; code 13 is not in internal DFA code
**Code 24 is combined with code 50; 24 not in internal DFA code
**Code 25 is combined with code 21; 25 not in internal DFA code
**Codes 43 and 44 are combined with code 42; all are in internal DFA code
**Code 52 is combined with code -7; -7 not in internal DFA code
if year>=2010 & year<2019{
replace rental_properties_cb1=x1709*(x1705/10000) if inlist(x1703, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace rental_properties_cb1=0 if x1729!=1
replace rental_properties_cb2=x1809*(x1805/10000) if inlist(x1803, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace rental_properties_cb2=0 if x1829!=1
replace rental_properties_cb4=max(0, x2002) if x2009==1 
}

**Codes 13, 14, and 22 are combined with code 12; 13 is not in internal DFA code
**Code 25 is combined with code 21; 25 is not in internal DDFA code
**Code 24 is combined with code 50; 24 is not in internal DFA code
**Codes 41, 43, and 44 are combined with code 42; all are in internal DFA code
**Code 52 is combined with code -7; -7 is not in internal DFA code
if year>=2019{
replace rental_properties_cb1=x1709*(x1705/10000) if inlist(x1703, 12, 21, 40, 42, 49, 50, 999, -7)
replace rental_properties_cb1=0 if x1729!=1
replace rental_properties_cb2=x1809*(x1805/10000) if inlist(x1803, 12, 21, 40, 42, 49, 50, 999, -7)
replace rental_properties_cb2=0 if x1829!=1
replace rental_properties_cb4=max(0, x2002) if x2009==1 
}

gen nnresre_cb1=0
gen nnresre_cb2=0
gen nnresre_cb3=0
if year<1995{
replace nnresre_cb1= max(0,x1709)*(x1705/10000) if inlist(x1703, 1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 15, 24, 45, 46, 47, 48, 51, 53, -7)
replace nnresre_cb2= max(0,x1809)*(x1805/10000) if inlist(x1803, 1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 15, 24, 45, 46, 47, 48, 51, 53, -7)
replace nnresre_cb3= max(0,x1909)*(x1905/10000) if inlist(x1903, 1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 15, 24, 45, 46, 47, 48, 51, 53, -7)
}
** Codes 13, 14, and 22 are combined with code 12; only 13 is in internal DFA code
**Code 48 is combined with code 47; both are in internal DFA code
**Code 52 is combined with code -7; 52 is not in internal DFA code
if year==1995{
replace nnresre_cb1= max(0,x1709)*(x1705/10000) if inlist(x1703, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 15, 45, 46, 47, 51, 53, -7)
replace nnresre_cb2= max(0,x1809)*(x1805/10000) if inlist(x1803, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 15, 45, 46, 47, 51, 53, -7)
replace nnresre_cb3= max(0,x1909)*(x1905/10000) if inlist(x1903, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 15, 45, 46, 47, 51, 53, -7)
}
** Codes 13, 14, and 22 are combined with code 12; only 13 is in internal DFA code
**Codes 48 are combined with code 47; both are in internal DFA code
**Code 46 is combined with code 45; both are in internal DFA code
**Code 52 is combined with code -7; 52 is not in internal DFA code
if year==1998{
replace nnresre_cb1= max(0,x1709)*(x1705/10000) if inlist(x1703, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 15, 45, 47, 51, 53, -7)
replace nnresre_cb2= max(0,x1809)*(x1805/10000) if inlist(x1803, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 15, 45, 47, 51, 53, -7)
replace nnresre_cb3= max(0,x1909)*(x1905/10000) if inlist(x1903, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 15, 45, 47, 51, 53, -7)
}

if year>1998 & year<=2010{
replace nnresre_cb1= max(0,x1709)*(x1705/10000) if inlist(x1703, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 45, 47, 51, 53, -7)
replace nnresre_cb2= max(0,x1809)*(x1805/10000) if inlist(x1803, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 45, 47, 51, 53, -7)
replace nnresre_cb3= max(0,x1909)*(x1905/10000) if inlist(x1903, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 45, 47, 51, 53, -7)
}
** Codes 13, 14, and 22 are combined with code 12; only 13 is in internal DFA code
**Codes 48 and 15 are combined with code 47
**Code 46 is combined with code 45
**Code 52 is combined with code -7; 52 is not in internal DFA code
if year>=2010{
replace nnresre_cb1= max(0,x1709)*(x1705/10000) if inlist(x1703, 1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 15, 24, 45, 46, 47, 48, 51, 53, -7)
replace nnresre_cb2= max(0,x1809)*(x1805/10000) if inlist(x1803, 1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 15, 24, 45, 46, 47, 48, 51, 53, -7)
}
gen rentals_cb = rental_properties_cb1 + rental_properties_cb2 + rental_properties_cb3 + rental_properties_cb4 

gen nnresre_cb = nnresre_cb1 + nnresre_cb2 + nnresre_cb3

gen equity_non_corp_cb = bus_cb + rentals_cb + nnresre_cb

* DFA concept for noncorporate equity is an average of net worth and cost basis
gen scf_fa_equity_non_corp = .5*equity_non_corp_nw + .5*equity_non_corp_cb
replace scf_fa_corp_equity = scf_fa_corp_equity + .5*sc_corp_equity + .5*sc_corp_cb

************************* MORTGAGE DEBT ***********************
*solve for component of oresre ((and resdbt) by business or jointly owned and rented
if year<=1992{
g business_oresre1=0
g business_oresre_debt1=0
replace business_oresre1=x1706*(x1705/10000) if inlist(x1703, 12, 14, 21, 22, 40, 41, 42, 43, 44, 49, 50, 52, 999)
replace business_oresre1=0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
replace business_oresre_debt1=x1715
replace business_oresre_debt1=0 if business_oresre1==0
g business_oresre2=0
g business_oresre_debt2=0
replace business_oresre2=x1806*(x1805/10000) if inlist(x1803, 12, 14, 21, 22, 40, 41, 42, 43, 44, 49, 50, 52, 999)
replace business_oresre1=0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
replace business_oresre_debt2=x1815
replace business_oresre_debt2=0 if business_oresre2==0
g business_oresre3=0
g business_oresre_debt3=0
replace business_oresre3=x1906*(x1905/10000) if inlist(x1903, 12, 14, 21, 22, 40, 41, 42, 43, 44, 49, 50, 52, 999)
replace business_oresre1=0 if (x1904==1 | x1904==5 | (x1904==2 & x1929~=1))
replace business_oresre_debt3=x1915
replace business_oresre_debt3=0 if business_oresre3==0
g business_oresre_more=0
g business_oresre_debt_more=0
replace business_oresre_more=max(0, x2002) if x2009==1 
replace business_oresre_debt_more=x2006
replace business_oresre_debt_more=0 if business_oresre_more==0
}

**Codes 13, 14, 22, and 24 are combined w code 12; codes 13 and 24 not in internal DFA code in 1995
**Codes 13, 14, and 22 are combined with code 12; code 13 not in internal DFA code from 1998-2007
**Code 24 is combined with code 50 from 1995-2007
**Code 25 is combined with code 21; code 25 not in internal DFA code
**Codes 43 and 44 are combined with code 42
**Code 52 is combined with code -7; -7 not in internal DFA code
if year>=1995 & year<=2007 {
g business_oresre1=0
g business_oresre_debt1=0
replace business_oresre1=x1706*(x1705/10000) if inlist(x1703, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
replace business_oresre_debt1=x1715
replace business_oresre_debt1=0 if business_oresre1==0
g business_oresre2=0
g business_oresre_debt2=0
replace business_oresre2=x1806*(x1805/10000) if inlist(x1803, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
replace business_oresre_debt2=x1815
replace business_oresre_debt2=0 if business_oresre2==0
g business_oresre3=0
g business_oresre_debt3=0
replace business_oresre3=x1906*(x1905/10000) if inlist(x1903, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1904==1 | x1904==5 | (x1904==2 & x1929~=1))
replace business_oresre_debt3=x1915
replace business_oresre_debt3=0 if business_oresre3==0
g business_oresre_more=0
g business_oresre_debt_more=0
replace business_oresre_more=max(0, x2002) if x2009==1 
replace business_oresre_debt_more=x2006
replace business_oresre_debt_more=0 if business_oresre_more==0
}

**Codes 13, 14, and 22 are combined with code 12; code 13 not in internal DFA code
**Code 24 is combined with code 50 
**Code 25 is combined with code 21; 25 not in internal DFA code
**Codes 43 and 44 are combined with code 42
**Code 52 is combined with code -7; -7 not in internal DFA code
if year>=2010 & year<2019{
g business_oresre1=0
g business_oresre_debt1=0
replace business_oresre1=x1706*(x1705/10000) if inlist(x1703, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
replace business_oresre_debt1=x1715
replace business_oresre_debt1=0 if business_oresre1==0
g business_oresre2=0
g business_oresre_debt2=0
replace business_oresre2=x1806*(x1805/10000) if inlist(x1803, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
replace business_oresre_debt2=x1815
replace business_oresre_debt2=0 if business_oresre2==0
g business_oresre3=0
g business_oresre_debt3=0
replace business_oresre3=x1906*(x1905/10000) if inlist(x1903, 12, 21, 40, 41, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1904==1 | x1904==5 | (x1904==2 & x1929~=1))
replace business_oresre_debt3=x1915
replace business_oresre_debt3=0 if business_oresre3==0
g business_oresre_more=0
g business_oresre_debt_more=0
replace business_oresre_more=max(0, x2002) if x2009==1 
replace business_oresre_debt_more=x2006
replace business_oresre_debt_more=0 if business_oresre_more==0
}
**Codes 13, 14, and 22 are combined with code 12; 13 not in internal DFA code
**Code 24 is combined with code 50; 24 not in internal DFA code
*Codes 41, 43, and 44 are combined with code 42
*Code 52 is combined with code -7; -7 not in internal DFA code
if year>=2019{
g business_oresre1=0
g business_oresre_debt1=0
replace business_oresre1=x1706*(x1705/10000) if inlist(x1703, 12, 21, 22, 40, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
replace business_oresre_debt1=x1715
replace business_oresre_debt1=0 if business_oresre1==0
g business_oresre2=0
g business_oresre_debt2=0
replace business_oresre2=x1806*(x1805/10000) if inlist(x1803, 12, 21, 22, 40, 42, 49, 50, 999, -7)
replace business_oresre1=0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
replace business_oresre_debt2=x1815
replace business_oresre_debt2=0 if business_oresre2==0
g business_oresre3=0
g business_oresre_debt3=0
g business_oresre_more=0
g business_oresre_debt_more=0
replace business_oresre_more=max(0, x2002) if x2009==1 
replace business_oresre_debt_more=x2006
replace business_oresre_debt_more=0 if business_oresre_more==0
}
g bus_oresre=business_oresre1 + business_oresre2 + business_oresre3 + business_oresre_more
g bus_oresre_debt=business_oresre_debt1 + business_oresre_debt2 + business_oresre_debt3 + business_oresre_debt_more

gen scf_fa_mort_debt = resdbt - bus_oresre_debt + mrthel

* remove bus_oresre_debt from noncorp equity
replace scf_fa_equity_non_corp = scf_fa_equity_non_corp-bus_oresre_debt

/*CONSUMER CREDIT*/

**Income deciles are created using SCF perecentiles (found in SCF bulletin https://www.federalreserve.gov/econres/files/bulletin.macro.txt)

gen incdec=.
replace incdec=1 if incpctlecat==1
replace incdec=2 if incpctlecat==2
replace incdec=3 if incpctlecat==3
replace incdec=4 if incpctlecat==4
replace incdec=5 if incpctlecat==5
replace incdec=6 if incpctlecat==6
replace incdec=7 if incpctlecat==7
replace incdec=8 if incpctlecat==8
replace incdec=9 if incpctlecat==9
replace incdec=10 if incpctlecat>9

*the FA concept for credit cards is total charges, including convenience charges, whereas the SCF concept is revolving balances
*we scale revovling balances up to total differentially by income deciles
gen ccbalmult=.
replace ccbalmult = ccbal * 1.265823 if incdec==1
replace ccbalmult = ccbal * 1.257862 if incdec==2
replace ccbalmult = ccbal * 1.30719 if incdec==3
replace ccbalmult = ccbal * 1.342282 if incdec==4
replace ccbalmult = ccbal * 1.369863 if incdec==5
replace ccbalmult = ccbal * 1.398601 if incdec==6
replace ccbalmult = ccbal * 1.428571 if incdec==7
replace ccbalmult = ccbal * 1.459854 if incdec==8
replace ccbalmult = ccbal * 1.550388 if incdec==9
replace ccbalmult = ccbal * 1.724138 if incdec==10
**Beginning in 2004, code 29 is combined with code 11 in the public data
gen inst_type=. if x1103==5 |x1114==5 | x1125==5
replace inst_type=1 if x9087<=13 | x9088<=13 | x9089<=13 
replace inst_type=2 if x9087>=14 | x9088>=14 | x9089>=14
gen inst_type_oth=. 
replace inst_type_oth=1 if x9107<=13 | x9108<=13 | x9109<=13 | x9110<=13 | x9111<=13 | x9112<=13
replace inst_type_oth=2 if x9107>=14 | x9108>=14 | x9109>=14 | x9110>=14 | x9111>=14 | x9112>=14

replace oth_inst = 0 if oth_inst==.

* Following OTHLOC Bulletin definition from SCF Macro
gen othloc_dep_inst = x1108*(x1103!=1 & x9087<=13)+x1119*(x1114!=1 & x9088<=13)+x1130*(x1125!=1 & x9089<=13)+max(0,x1136)*(x1108*(x1103!=1 & x9087<=13)+x1119*(x1114!=1 & x9088<=13)+x1130*(x1125!=1 & x9089<=13))/(x1108+x1119+x1130)
replace othloc_dep_inst = 0 if (x1108+x1119+x1130)<=0

*This captures case when (X1108+X1119+X1130)<=0
gen othloc_non_dep_inst = othloc-othloc_dep_inst

* Following INSTALL Bulletin definition from SCF Macro, excluding Codebook variables captured in EDN_INST and VEH_INST

gen oth_inst_dep_inst = x1044*(x1046<=13)+x1215*(x1217<=13)

if nnresre==0 & oresre<=0 & year<1998{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(x2710==78 & x9107<=13) + x2740*(x2727==78 & x9108<=13)+ x2823*(x2810==78 & x9109<=13) + x2840*(x2827==78 & x9110<=13) + x2923*(x2910==78 & x9111<=13) + x2940*(x2927==78 & x9112<=13)
}

**Codes 74, 75, 76, 78, and 79 are combined with code 7
if nnresre==0 & oresre<=0 & year>=1998{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(x2710==7 & x9107<=13) + x2740*(x2727==7 & x9108<=13)+ x2823*(x2810==7 & x9109<=13) + x2840*(x2827==7 & x9110<=13) + x2923*(x2910==7 & x9111<=13) + x2940*(x2927==7 & x9112<=13)
}

**Code 67 combined with code -7; -7 not in internal DFA code
if oresre<=0 & year==1989{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(x2710==-7 & x9107<=13) + x2740*(x2727==-7 & x9108<=13)+ x2823*(x2810==-7 & x9109<=13) + x2840*(x2827==-7 & x9110<=13) + x2923*(x2910==-7 & x9111<=13) + x2940*(x2927==-7 & x9112<=13)
}
**
if oresre<=0 & year>1989 & year<1998{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(x2710==67 & x9107<=13) + x2740*(x2727==67 & x9108<=13)+ x2823*(x2710==67 & x9109<=13) + x2840*(x2727==67 & x9110<=13) + x2923*(x2710==67 & x9111<=13) + x2940*(x2727==67 & x9112<=13)
}

if oresre<=0 & year>=1998{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(x2710==1 & x9107<=13) + x2740*(x2727==1 & x9108<=13)+ x2823*(x2710==1 & x9109<=13) + x2840*(x2727==1 & x9110<=13) + x2923*(x2710==1 & x9111<=13) + x2940*(x2727==1 & x9112<=13)
}

* Excludes codes 67 (cottage, vacation property, mobile home, etc.), 78 (investment real estate), and 83 (education/school) 
if year==1989{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(!inlist(x2710,-7,78,83) ///
& x9107<=13) + x2740*(!inlist(x2727,-7,78,83) & x9108<=13)+ x2823*(!inlist(x2810,-7,78,83) & x9109<=13) ///
+ x2840*(!inlist(x2827,-7,78,83) & x9110<=13) + x2923*(!inlist(x2910,-7,78,83) & x9111<=13) ///
+ x2940*(!inlist(x2927,-7,78,83) & x9112<=13)
}

if year >1989 & year<1998{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(!inlist(x2710,67,78,83) ///
& x9107<=13) + x2740*(!inlist(x2727,67,78,83) & x9108<=13)+ x2823*(!inlist(x2810,67,78,83) & x9109<=13) ///
+ x2840*(!inlist(x2827,67,78,83) & x9110<=13) + x2923*(!inlist(x2910,67,78,83) & x9111<=13) ///
+ x2940*(!inlist(x2727,67,78,83) & x9112<=13)
}


if year>=1998{
replace oth_inst_dep_inst = oth_inst_dep_inst + x2723*(!inlist(x2710,1,7,9) ///
& x9107<=13) + x2740*(!inlist(x2727,1,7,9) & x9108<=13)+ x2823*(!inlist(x2810,1,7,9) & x9109<=13) ///
+ x2840*(!inlist(x2827,1,7,9) & x9110<=13) + x2923*(!inlist(x2910,1,7,9) & x9111<=13) ///
+ x2940*(!inlist(x2927,1,7,9) & x9112<=13)
}
*This captures X1219
gen oth_inst_non_dep_inst = oth_inst - oth_inst_dep_inst

gen scf_fa_consumer_credit = ccbalmult + othloc_non_dep_inst + edn_inst + oth_inst_non_dep_inst + veh_inst
gen scf_fa_edninst = edn_inst 


/*DEPOSITORY INST LOANS*/

gen scf_fa_dep_inst_loans = othloc_dep_inst + oth_inst_dep_inst 


/*OTHER LOANS AND ADVANCES*/
forvalues y=1989(3)2022{
summarize x4010[aw=wgt] if year==`y'
di r(sum)
local total_policy_loans`y'=r(sum)
}

gen total_policy_loans=.
forvalues y=1989(3)2022{
replace total_policy_loans=`total_policy_loans`y'' if year==`y'
}

forvalues y=1989(3)2022{
summarize x3932[aw=wgt] if year==`y'
di r(sum)
local total_margin_accts`y'=r(sum)
}

gen total_margin_accts=.
forvalues y=1989(3)2022{
replace total_margin_accts=`total_margin_accts`y'' if year==`y'
}

gen scf_fa_policy_loans = fa_policy_loans*x4010/total_policy_loans
gen scf_fa_margin_accts = fa_margin_accts_bd*x3932/total_margin_accts

forvalues y=1989(3)2022{
summarize nh_mort[aw=wgt] if year==`y'
di r(sum)
local total_nh_mort`y'=r(sum)
}

gen total_nh_mort=.
forvalues y=1989(3)2022{
replace total_nh_mort=`total_nh_mort`y'' if year==`y'
}

gen scf_fa_govt_loans = nh_mort*fa_fed_loans/total_nh_mort

gen scf_fa_oth_loans = scf_fa_policy_loans + scf_fa_margin_accts + scf_fa_govt_loans

/*MISC ASSETS*/
gen other_health_ins_scale=.
replace other_health_ins_scale=0.038634 if incdec==1
replace other_health_ins_scale=0.031785 if incdec==2
replace other_health_ins_scale=0.05524 if incdec==3
replace other_health_ins_scale=0.081037 if incdec==4
replace other_health_ins_scale=0.099169 if incdec==5
replace other_health_ins_scale=0.108794 if incdec==6
replace other_health_ins_scale=0.125345 if incdec==7
replace other_health_ins_scale=0.142911 if incdec==8
replace other_health_ins_scale=0.148345 if incdec==9
replace other_health_ins_scale=0.16874 if incdec==10

forvalues y=1989(3)2022{
summarize other_health_ins_scale [aw=wgt] if year==`y'
di r(sum)
local total_other_hi_scale`y'=r(sum)
}

gen total_other_hi_scale=.
forvalues y=1989(3)2022{
replace total_other_hi_scale=`total_other_hi_scale`y'' if year==`y'
}

gen num_has_health_ins = 0
* Number of individuals in household (including NPEU) minus one for each type of person in household without health insurance
if year<=2007 {
gen num_has_health_ins_gov =x101*(x6301==1)-(x6308==1)-(x6309==1)-(x6310==1)-(x6311==1)-(x6312==1)-(x6313==1)-(x6314==8|x6314==10|x6314==11)
replace num_has_health_ins_gov = 0 if num_has_health_ins_gov<=0
gen num_has_health_ins_priv =(x101 - num_has_health_ins_gov)*(x6315==1)-(x6330==1)-(x6331==1)-(x6332==1)-(x6333==1)-(x6334==1)-(x6335==1)-(x6336==8|x6336==10|x6336==11)
replace num_has_health_ins_priv = 0 if num_has_health_ins_priv<=0
replace num_has_health_ins = num_has_health_ins_gov + num_has_health_ins_priv
}
replace num_has_health_ins = x101*(x6341==1)-(x6358==1)-(x6359==1)-(x6360==1)-(x6361==1)-(x6362==1)-(x6363==1|x6363==8|x6363==10|x6363==11) if year>=2010
replace num_has_health_ins = 0 if num_has_health_ins <=0 & year>=2010

gen has_milit_retiree_health = 0
gen has_postal_retiree_health = 0

* Armed services retirees are eligible for retiree healthcare at 65
replace has_milit_retiree_health = (x5906==1)*(x14>=65) + (x6106==1)*(x19>=65) if year>=2001

* Postal workers can retire at 56 and receive healthcare immediately
replace has_postal_retiree_health = (x7402==6370)*(x14>=56) + (x7412==6370)*(x19>=56) if year>=2004

forvalues y=1989(3)2022{
summarize houses[aw=wgt] if year==`y'
di r(sum)
local total_houses`y'=r(sum)
summarize oresre [aw=wgt] if year==`y'
di r(sum)
local total_oresre`y'=r(sum)

}

gen total_houses=.
gen total_oresre=.
forvalues y=1989(3)2022{
replace total_houses=`total_houses`y'' if year==`y'
replace total_oresre=`total_oresre`y'' if year==`y'
}

forvalues y=1989(3)2022{
summarize vehic[aw=wgt] if year==`y'
di r(sum)
local total_vehic`y'=r(sum)
}


gen total_vehic=.

forvalues y=1989(3)2022{
replace total_vehic=`total_vehic`y'' if year==`y'
}


forvalues y=1989(3)2022{
summarize num_has_health_ins[aw=wgt] if year==`y'
di r(sum)
local total_num_has_health_ins`y'=r(sum)
}

gen total_num_has_health_ins=.
forvalues y=1989(3)2022{
replace total_num_has_health_ins=`total_num_has_health_ins`y'' if year==`y'
}

forvalues y=1989(3)2022{
summarize has_milit_retiree_health[aw=wgt] if year==`y'
di r(sum)
local total_has_mil_ret_health`y'=r(sum)
}

gen total_has_milit_retiree_health=.
forvalues y=1989(3)2022{
replace total_has_milit_retiree_health=`total_has_mil_ret_health`y'' if year==`y'
}

forvalues y=1989(3)2022{
summarize has_postal_retiree_health[aw=wgt] if year==`y'
di r(sum)
local total_has_post_ret_health`y'=r(sum)
}

gen total_has_postal_retiree_health=.
forvalues y=1989(3)2022{
replace total_has_postal_retiree_health=`total_has_post_ret_health`y'' if year==`y'
}

forvalues y=1989(3)2022{
summarize x4005[aw=wgt] if year==`y'
di r(sum)
local total_perm_fv`y'=r(sum)
}

gen total_perm_fv=.
forvalues y=1989(3)2022{
replace total_perm_fv=`total_perm_fv`y'' if year==`y'
}

gen fa_pc_houses = homes_payable*fa_pc_receivables
gen fa_pc_vehic = cars_payable*fa_pc_receivables
gen scf_fa_pc_houses = (houses+oresre)*fa_pc_houses/(total_houses+total_oresre)
gen scf_fa_pc_vehic = vehic*fa_pc_vehic/total_vehic
gen scf_fa_pc_receivables = scf_fa_pc_houses + scf_fa_pc_vehic

gen fa_health_ins_reserves = fa_health_gen + fa_health_sep
gen scf_fa_health_ins_reserves = num_has_health_ins*fa_health_ins_reserves/total_num_has_health_ins

gen scf_fa_milit_retiree_health=0
replace scf_fa_milit_retiree_health = has_milit_retiree_health*fa_milit_retiree_health/total_has_milit_retiree_health if year >=2001 & total_has_milit_retiree_health !=0

gen scf_fa_postal_retiree_health=0
replace scf_fa_postal_retiree_health = has_postal_retiree_health*fa_postal_retiree_health/total_has_postal_retiree_health if year>2004 & total_has_postal_retiree_health !=0
gen scf_fa_gov_retiree_health = scf_fa_milit_retiree_health + scf_fa_postal_retiree_health

gen fa_life_div = fa_life_div_gen + fa_life_div_sep
gen scf_fa_life_ins_div = x4006*fa_life_div/total_perm

gen fa_life_claims_term = fa_life_claims*(1-perm_ratio)
gen fa_life_claims_perm = fa_life_claims*perm_ratio
gen scf_fa_life_ins_term_claim = x4003*fa_life_claims_term/total_term
gen scf_fa_life_ins_perm_claim = x4005*fa_life_claims_perm/total_perm_fv
gen scf_fa_life_ins_claims = scf_fa_life_ins_term_claim + scf_fa_life_ins_perm_claim

gen scf_oth_health_ins_reserves=other_health_ins_scale*ah_reserves/total_other_hi_scale

gen scf_fa_misc_assets = scf_fa_pc_receivables + scf_oth_health_ins_reserves + scf_fa_life_ins_div + scf_fa_life_ins_claims + scf_fa_gov_retiree_health


/*DEFERRED AND UNPAID LIFE INSURANCE*/

gen fa_life_unpaid_term = fa_life_unpaid*(1-perm_ratio)
gen fa_life_unpaid_perm = fa_life_unpaid*perm_ratio
gen scf_fa_life_ins_term_unpaid = x4003*fa_life_unpaid_term/total_term
gen scf_fa_life_ins_perm_unpaid = x4006*fa_life_unpaid_perm/total_perm

gen scf_fa_life_ins_unpaid = scf_fa_life_ins_term_unpaid + scf_fa_life_ins_perm_unpaid

replace racecl4 = 1 if x6809 == 1 & x6810 == 5 & year==2010
replace racecl4 = 2 if x6809 == 2 & x6810 == 5 & year==2010
replace racecl4 = 3 if x6809 == 3 & x6810 == 5 & year==2010
replace racecl4 = 4 if inrange(x6809, 4, 7) & year==2010 | x6810 == 1 & year==2010

tempfile scftemp
save `scftemp' , replace    


/*-----------------------------------------------------------
Start setting up to add Forbes. 
-----------------------------------------------------------*/

forval year = 1989(3)2022 {
use `scftemp' if year == `year', clear

tempfile scf`year'
save `scf`year'', replace                                

/*-----------------------------------------------------------
// A. Find asset portfolio of top 0.1 in SCF data to apply to Forbes
-----------------------------------------------------------*/

/*ADDITIONAL AGGREGATES BASED ON FA BALANCE SHEET*/
gen scf_fa_dc_assets_wgted = scf_fa_dc_assets*wgt

egen scf_fa_dc_assets_tot=sum(scf_fa_dc_assets_wgted), by(year)

gen scf_fa_pension_tot = (fa_dc_aggregate*scf_fa_dc_assets_wgted/scf_fa_dc_assets_tot) /// 
                       + (scf_fa_db_assets + annuities)*wgt + scf_fa_annuit*wgt
					   
qui g long scf_fa_pension = scf_fa_pension_tot/wgt

gen scf_fa_corpeq_mut = scf_fa_corp_equity + scf_fa_mut_fund_shares 
gen scf_fa_nonfin = scf_fa_real_estate + scf_fa_consumer_durables
gen scf_fa_loans_assets = scf_fa_mort_owed + scf_fa_othln_owed
replace scf_fa_life_ins = 0 if scf_fa_life_ins < 0

gen scf_fa_fin = scf_fa_debtsec + scf_fa_loans_assets + scf_fa_check_fgn_dep_curr ///
               + scf_fa_time_dep + scf_fa_mmmf_shares + scf_fa_corpeq_mut + scf_fa_pension ///
               + scf_fa_equity_non_corp + scf_fa_life_ins + scf_fa_misc_assets

gen scf_fa_assets = scf_fa_nonfin + scf_fa_fin

gen scf_fa_loans_liab = scf_fa_mort_debt + scf_fa_dep_inst_loans + scf_fa_consumer_credit + scf_fa_oth_loans
gen scf_fa_liab = scf_fa_loans_liab + scf_fa_life_ins_unpaid
gen scf_fa_nw = scf_fa_assets - scf_fa_liab


/*SCALE TO FA VALUES*/
foreach x in scf_fa_real_estate scf_fa_consumer_durables scf_fa_check_fgn_dep_curr scf_fa_time_dep ///
             scf_fa_mmmf_shares scf_fa_gov_muni_bnds scf_fa_corp_for_bnds scf_fa_othln_owed ///
	     scf_fa_mort_owed scf_fa_corpeq_mut scf_fa_pension scf_fa_equity_non_corp ///
	     scf_fa_misc_assets scf_fa_mort_debt scf_fa_consumer_credit scf_fa_oth_loans ///
	     scf_fa_life_ins_unpaid scf_fa_life_ins scf_fa_dep_inst_loans scf_fa_edninst {
	gen `x'_wgted=`x'*wgt
}

egen scf_fa_real_estate_tot=sum(scf_fa_real_estate_wgted), by(year)
egen scf_fa_consumer_durables_tot=sum(scf_fa_consumer_durables_wgted), by(year)
egen scf_fa_check_fgn_dep_curr_tot=sum(scf_fa_check_fgn_dep_curr_wgted), by(year)
egen scf_fa_time_dep_tot=sum(scf_fa_time_dep_wgted), by(year)
egen scf_fa_mmmf_shares_tot=sum(scf_fa_mmmf_shares_wgted), by(year)
egen scf_fa_gov_muni_bnds_tot=sum(scf_fa_gov_muni_bnds_wgted), by(year)
egen scf_fa_corp_for_bnds_tot=sum(scf_fa_corp_for_bnds_wgted), by(year)
egen scf_fa_othln_owed_tot=sum(scf_fa_othln_owed_wgted), by(year)
egen scf_fa_mort_owed_tot=sum(scf_fa_mort_owed_wgted), by(year)
egen scf_fa_corpeq_mut_tot=sum(scf_fa_corpeq_mut_wgted), by(year)

egen scf_fa_equity_non_corp_tot=sum(scf_fa_equity_non_corp_wgted), by(year)
egen scf_fa_misc_assets_tot=sum(scf_fa_misc_assets_wgted), by(year)
egen scf_fa_mort_debt_tot=sum(scf_fa_mort_debt_wgted), by(year)
egen scf_fa_consumer_credit_tot=sum(scf_fa_consumer_credit_wgted), by(year)
egen scf_fa_edninst_tot=sum(scf_fa_edninst_wgted), by(year)
egen scf_fa_oth_loans_tot=sum(scf_fa_oth_loans_wgted), by(year)
egen scf_fa_life_ins_unpaid_tot=sum(scf_fa_life_ins_unpaid_wgted), by(year)
egen scf_fa_life_ins_tot=sum(scf_fa_life_ins_wgted), by(year)
egen scf_fa_dep_inst_loans_tot=sum(scf_fa_dep_inst_loans_wgted), by(year)


gen scf_fa_wgted = scf_fa_real_estate_wgted + scf_fa_consumer_durables_wgted + ///
                 scf_fa_check_fgn_dep_curr_wgted + scf_fa_time_dep_wgted + scf_fa_mmmf_shares_wgted + ///
		 scf_fa_gov_muni_bnds_wgted + scf_fa_corp_for_bnds_wgted + scf_fa_othln_owed_wgted + ///
		 scf_fa_mort_owed_wgted + scf_fa_corpeq_mut_wgted + scf_fa_equity_non_corp_wgted + ///
		 scf_fa_misc_assets_wgted + scf_fa_life_ins_wgted	 

// nonfin and components
gen real_estate = fa_real_estate*scf_fa_real_estate_wgted/scf_fa_real_estate_tot 
gen consumer_durables = fa_con_durables*scf_fa_consumer_durables_wgted/scf_fa_consumer_durables_tot
gen nonfinasset = fa_real_estate*scf_fa_real_estate_wgted/scf_fa_real_estate_tot + ///
                   fa_con_durables*scf_fa_consumer_durables_wgted/scf_fa_consumer_durables_tot

// fin and components
gen debtsec = (fa_us_gov_muni*scf_fa_gov_muni_bnds_wgted/scf_fa_gov_muni_bnds_tot + ///
                    fa_corp_for_bonds*scf_fa_corp_for_bnds_wgted/scf_fa_corp_for_bnds_tot)
gen gov_muni_bnds = fa_us_gov_muni*scf_fa_gov_muni_bnds_wgted/scf_fa_gov_muni_bnds_tot 
gen corp_for_bnds = fa_corp_for_bonds*scf_fa_corp_for_bnds_wgted/scf_fa_corp_for_bnds_tot

gen loans_assets = (fa_morts_owed*scf_fa_mort_owed_wgted/scf_fa_mort_owed_tot + ///
                         fa_oth_loans*scf_fa_othln_owed_wgted/scf_fa_othln_owed_tot)
gen mort_owed = fa_morts_owed*scf_fa_mort_owed_wgted/scf_fa_mort_owed_tot 
gen othln_owed = fa_oth_loans*scf_fa_othln_owed_wgted/scf_fa_othln_owed_tot
			 
gen liqfin =  (fa_check_curr*scf_fa_check_fgn_dep_curr_wgted/scf_fa_check_fgn_dep_curr_tot + ///
		     fa_time_dep*scf_fa_time_dep_wgted/scf_fa_time_dep_tot + ///
		     fa_mmfs*scf_fa_mmmf_shares_wgted/scf_fa_mmmf_shares_tot)
gen check_fgn_dep_curr = fa_check_curr*scf_fa_check_fgn_dep_curr_wgted/scf_fa_check_fgn_dep_curr_tot if scf_fa_check_fgn_dep_curr_tot!=0
gen time_dep =  fa_time_dep*scf_fa_time_dep_wgted/scf_fa_time_dep_tot if scf_fa_time_dep_tot!=0
gen mmmf_shares = fa_mmfs*scf_fa_mmmf_shares_wgted/scf_fa_mmmf_shares_tot if scf_fa_mmmf_shares_tot!=0

gen corpeq_mut =  (fa_corp_equ_mfs*scf_fa_corpeq_mut_wgted/scf_fa_corpeq_mut_tot )
gen pension =	 scf_fa_pension_tot 

gen long dc_assets = fa_dc_aggregate*scf_fa_dc_assets_wgted/scf_fa_dc_assets_tot
g long dbassets = (scf_fa_db_assets + annuities)*wgt 
replace annuit = scf_fa_annuit*wgt


gen equity_non_corp =  (fa_non_corp_eq*scf_fa_equity_non_corp_wgted/scf_fa_equity_non_corp_tot )

gen misc_assets = fa_misc_assets*scf_fa_misc_assets_wgted/scf_fa_misc_assets_tot

gen life_ins = scf_fa_life_ins*wgt

gen finasset = check_fgn_dep_curr + time_dep + mmmf_shares + gov_muni_bnds + corp_for_bnds ///
              + othln_owed + mort_owed + corpeq_mut + pension + equity_non_corp + misc_assets + life_ins

gen assets_recon = nonfinasset + finasset

// Liab
gen loans_liab = fa_morts*scf_fa_mort_debt_wgted/scf_fa_mort_debt_tot + ///
                       fa_dep_loans*scf_fa_dep_inst_loans_wgted/scf_fa_dep_inst_loans_tot + ///
		       fa_cons_cred*scf_fa_consumer_credit_wgted/scf_fa_consumer_credit_tot + ///
		       fa_oth_loans_adv*scf_fa_oth_loans_wgted/scf_fa_oth_loans_tot

gen mort_liab = fa_morts*scf_fa_mort_debt_wgted/scf_fa_mort_debt_tot
gen depln_liab = fa_dep_loans*scf_fa_dep_inst_loans_wgted/scf_fa_dep_inst_loans_tot 
gen concr_liab = fa_cons_cred*scf_fa_consumer_credit_wgted/scf_fa_consumer_credit_tot 
gen edninst_liab = fa_cons_cred*scf_fa_edninst_wgted/scf_fa_consumer_credit_tot 
gen oth_liab = fa_oth_loans_adv*scf_fa_oth_loans_wgted/scf_fa_oth_loans_tot
gen lins_liab = fa_unpaid_life_ins*scf_fa_life_ins_unpaid_wgted/scf_fa_life_ins_unpaid_tot	
     		     
gen liab_recon = loans_liab + fa_unpaid_life_ins*scf_fa_life_ins_unpaid_wgted/scf_fa_life_ins_unpaid_tot
gen recon_nw = (assets_recon - liab_recon)/wgt
gen recon_nw_wgt = (assets_recon - liab_recon)

// Find portfolio share of top 0.1 pct.
_pctile recon_nw [aw=wgt], p(99.9)
tabstat recon_nw_wgt assets_recon liab_recon real_estate consumer_durables check_fgn_dep_curr ///
        time_dep mmmf_shares gov_muni_bnds corp_for_bnds mort_owed othln_owed corpeq_mut ///
        pension dc_assets dbassets annuit equity_non_corp misc_assets life_ins ///
	mort_liab depln_liab concr_liab oth_liab lins_liab ///
	if recon_nw>=`r(r1)' & missing(recon_nw)==0, stats(sum) save
mat top01 = r(StatTotal)

// Share of assets in each asset type
mat shares = .
local i = 4 
foreach v in real_estate consumer_durables check_fgn_dep_curr ///
        time_dep mmmf_shares gov_muni_bnds corp_for_bnds mort_owed othln_owed corpeq_mut ///
        pension dc_assets dbassets annuit equity_non_corp misc_assets life_ins ///
	 {
  mat shares = shares , top01[1,`i'] / top01[1,2] 
  mat `v'share = top01[1,`i'] / top01[1,2]
  local i = `i' + 1
}
mat shares = shares[1,2...]

// Share of liab in each type of liab
mat lshares = .
local i = 21
foreach v in mort_liab depln_liab concr_liab oth_liab lins_liab {
   mat lshares = lshares , top01[1,`i'] / top01[1,3] 
   mat `v'share = top01[1,`i'] / top01[1,3]
   local i = `i' + 1
}
mat lshares = lshares[1,2...]

// assets-to-NW ratio of top 0.1
local assets_to_nw = top01[1,2]/top01[1,1]

// cap factor from top 0.1 of SCF
_pctile recon_nw [aw=wgt], p(99.9)
gen top01= (recon_nw>=(r(r1)))
gen ratio = income/recon_nw
tabstat ratio [aw=wgt], by(top01) stats(median) save
mat top = r(Stat1) \ r(Stat2)
mat top01ratio = top[2,1]
local cap = top01ratio[1,1]

/*-----------------------------------------------------------
// B. Read in Forbes data
-----------------------------------------------------------*/

forvalues i = 1(1)5 {
  import excel using "$main\dfa_public_code\dfa_raw\forbes_89_22_consistent_forDFA_public.xlsx", sheet(Forbes`year') clear
  drop E 
  gen forbes_rank = _n
  ren C forbes_nw
  ren D forbes_age
  replace forbes_age = 65 if missing(forbes_age)==1
  
  keep forbes_*
  gen year=`year'

  ** start here to convert to current
  preserve 
  
  import excel "$main\data\Inflation.xlsx", first sheet("clean") clear
  ren _all, lower
  drop jul

  tempfile cpi
  save `cpi'
  restore

  merge m:1 year using `cpi', nogen keep (3)

  ** end here 
  
  gen imp = `i'
  
  // Wealth
  replace forbes_nw = forbes_nw * 1000000 * index 

  // Parse out NW into portfolio components -- only equity_non_corp needed for output,
  // but all components are generated so the Forbes rows merge cleanly into SCF
  mat li shares
  foreach v in real_estate consumer_durables check_fgn_dep_curr time_dep mmmf_shares ///
               gov_muni_bnds corp_for_bnds mort_owed othln_owed ///
               corpeq_mut equity_non_corp misc_assets pension dc_assets dbassets annuit life_ins {  
    gen forbes_`v' = `v'share[1,1]*forbes_nw*`assets_to_nw'  
    }
  foreach v in mort_liab depln_liab concr_liab oth_liab lins_liab {
    gen forbes_`v' = `v'share[1,1]*forbes_nw*(1-`assets_to_nw')
    }

  gen forbes_income = `cap'*forbes_nw

  tempfile forbes`year'`i'
  save `forbes`year'`i'', replace

  clear
}

// Make 5-implicate Forbes
use `forbes`year'1', clear
append using `forbes`year'2'
append using `forbes`year'3'
append using `forbes`year'4'
append using `forbes`year'5'

tempfile forbes`year'
save `forbes`year'', replace

/*-----------------------------------------------------------
// C. Append Forbes to SCF and create scf_fa_forbes_equity_non_corp
-----------------------------------------------------------*/

use `scf`year'', clear 

gen is_scf = 1
gen imp = mod(y1,10)

append using `forbes`year''

* Use SCF NW for SCF families, Forbes wealth for Forbes families
gen double wealth = networth
replace wealth = forbes_nw if missing(networth)==1

* Use SCF weight for SCF fam, 1/5 for Forbes families
gen double weight = wgt
replace weight = 1/5 if missing(wgt)==1

gen wgt_nwgac = weight

// Create scf_fa_forbes_equity_non_corp
clonevar scf_fa_forbes_equity_non_corp = scf_fa_equity_non_corp
replace  scf_fa_forbes_equity_non_corp = forbes_equity_non_corp if missing(forbes_equity_non_corp)==0

* Keep only SCF households -- Forbes rows appended above are not in
* buschecks_all and would make the merge key non-unique
keep if is_scf == 1

keep year y1 yy1 wgt wgt_nwgac scf_fa_equity_non_corp scf_fa_forbes_equity_non_corp

tempfile noncorpeq`year'
save `noncorpeq`year'', replace

}

// Append all years
use `noncorpeq1989', clear
forvalues year = 1992(3)2022 {
    append using `noncorpeq`year''
}

tempfile noncorpeq_all
save `noncorpeq_all', replace


/*===========================================================================
  SECTION C: Merge and keep only the four target variables
===========================================================================*/

use `buschecks_all', clear
sort year y1 yy1

merge 1:1 year y1 yy1 using `noncorpeq_all', ///
    keepusing(scf_fa_forbes_equity_non_corp) keep(1 3) nogen

* Households not matched (dropped by DFA DB merge in Section B) get 0
replace scf_fa_forbes_equity_non_corp = 0 if missing(scf_fa_forbes_equity_non_corp)

order year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC scf_fa_forbes_equity_non_corp

save "`adj'\data\target_variables.dta", replace
