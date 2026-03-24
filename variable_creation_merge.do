/*===========================================================================
  variable_creation_merge.do
  
  Creates the following four variables:
    1. BUScheck       – total noncorporate business equity (household level,
                        by y1), all active and non-active businesses combined
    2. BUScheckPT     – same, restricted to sole proprietorships /
                        partnerships (LFO codes 1 and 11)
    3. BUScheckOC     – same, restricted to other corporations (LFO code 4)
    4. scf_fa_forbes_equity_non_corp – DFA-concept noncorporate equity,
                        augmented with Forbes 400 wealth for the top 0.1 pct

  Sources
  -------
  BUScheck / BUScheckPT / BUScheckOC
    Drawn directly from 1_dataset.do (one year-block per SCF wave,
    1989–2022).  Only the raw SCF data loads and the variable-generation
    steps are retained; all wage-regression and labour-adjustment code
    that is not required for these three variables has been omitted.

  scf_fa_forbes_equity_non_corp
    Drawn from scf_fa_recon.do.  Only the noncorporate-equity
    reconciliation chain (net-worth and cost-basis approach) plus the
    Forbes augmentation loop are kept.  All other asset/liability
    categories are dropped.

  Data inputs (same paths as the originals; adjust as needed)
  -----------------------------------------------------------
  SCF raw implicates : $source/p[yy]i6.dta
  SCF summary files  : $source/rscfp[year].dta
  FA data            : $main/dfa_public_code/dfa_raw/fa_data.csv
  Forbes file        : $main/dfa_public_code/dfa_raw/
                         forbes_89_22_consistent_forDFA_public.xlsx
  Inflation          : $main/data/Inflation.xlsx
  Payout annuities   : $main/dfa_public_code/dfa_raw/payout_annuities.dta
  DFA DB public      : $main/dfa_public_code/dfa_raw/DFA_DB_public.dta
===========================================================================*/

clear
clear matrix
clear mata
set more off
set maxvar 10000

/*---------------------------------------------------------------------------
  SECTION A: BUScheck, BUScheckPT, BUScheckOC
  One block per SCF wave (1989, 1992, 1995, 1998, 2001, 2004, 2007,
  2010, 2013, 2016, 2019, 2022).

  The three variables are sums across all five implicates for a given
  primary sampling unit (y1):
    BUScheck    – total positive net equity across all business types
    BUScheckPT  – sole proprietorships and partnerships (x3X19 == 1 or 11)
    BUScheckOC  – other corporations (x3X19 == 4)

  "farmbus" is a standard SCF summary variable already present in the
  public summary files (rscfpXXXX.dta).
---------------------------------------------------------------------------*/

global source "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
global main   "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee"
global out    "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"


/* ----------------------------- 1989 ------------------------------------ */
foreach num1 of numlist 89(1)89 {

use "$source/p`num1'i6", clear
rename X* x*
rename Y1 x1
merge 1:1 x1 using "$source/rscfp19`num1'.dta", nogen
rename x1 y1
rename xx1 yy1
gen year = 19`num1'

/*----  business type classification (first active business slot) ---- */
gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

/*----  BUScheck: total equity across all businesses  ---- */
egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

/*----  BUScheckPT: sole proprietorships / partnerships (codes 1, 11) ---- */
egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

/*----  BUScheckOC: other corporations (code 4) ---- */
egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck89
save `buscheck89', replace
}


/* ----------------------------- 1992 ------------------------------------ */
foreach num1 of numlist 92(1)92 {

use "$source/p`num1'i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "$source/rscfp19`num1'.dta", nogen
gen year = 19`num1'

gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck92
save `buscheck92', replace
}


/* ----------------------------- 1995 ------------------------------------ */
foreach num1 of numlist 95(1)95 {

use "$source/p`num1'i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "$source/rscfp19`num1'.dta", nogen
gen year = 19`num1'

gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck95
save `buscheck95', replace
}


/* ----------------------------- 1998 ------------------------------------ */
foreach num1 of numlist 98(1)98 {

use "$source/p`num1'i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "$source/rscfp19`num1'.dta", nogen
gen year = 19`num1'

gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck98
save `buscheck98', replace
}


/* ----------------------------- 2001 ------------------------------------ */
use "$source/p01i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "$source/rscfp2001.dta", nogen
gen year = 2001

gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2001
save `buscheck2001', replace


/* ----------------------------- 2004 ------------------------------------ */
use "$source/p04i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "$source/rscfp2004.dta", nogen
ren _all, lower
gen year = 2004

gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2004
save `buscheck2004', replace


/* ----------------------------- 2007 ------------------------------------ */
use "$source/p07i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "$source/rscfp2007.dta", nogen
ren _all, lower
gen year = 2007

gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2007
save `buscheck2007', replace


/* ----------------------------- 2010 ------------------------------------ */
use "$source/p10i6", clear
rename X* x*
rename Y1 y1
merge 1:1 y1 using "$source/rscfp2010.dta", nogen
ren _all, lower
gen year = 2010

gen PP1 = 0
replace PP1 = 1 if inlist(x3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(x3119, 3, 4, 6, 40) | x3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(x3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(x3219, 3, 4, 6, 40) | x3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(x3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(x3319, 3, 4, 6, 40) | x3319 == -7

egen BUScheck = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
    + (x3335>0)*x3335 + farmbus ///
    + (x3408>0)*x3408 + (x3412>0)*x3412 + (x3416>0)*x3416 ///
    + (x3420>0)*x3420 + (x3424>0)*x3424 + (x3428>0)*x3428), by(y1)

egen BUScheckPT = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==1) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==1) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==1) ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==11) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==11) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==11) ///
    + (x3335>0)*x3335*(x3119==1)  + (x3335>0)*x3335*(x3119==11) ///
    + farmbus*(x3119==1) + farmbus*(x3119==11) ///
    + (x3408>0)*x3408 + (x3412>0)*x3412), by(y1)

egen BUScheckOC = sum(0 ///
    + ((x3129>0)*x3129 + (x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
    + ((x3229>0)*x3229 + (x3224>0)*x3224 - (x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
    + ((x3329>0)*x3329 + (x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
    + (x3335>0)*x3335*(x3119==4) + farmbus*(x3119==4) ///
    + (x3420>0)*x3420), by(y1)

keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2010
save `buscheck2010', replace


/* ----------------------------- 2013 ------------------------------------ */
use "$source/p13i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "$source/rscfp2013.dta", nogen
rename y1 Y1
gen year = 2013

gen PP1 = 0
replace PP1 = 1 if inlist(X3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(X3119, 3, 4, 6, 40) | X3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(X3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(X3219, 3, 4, 6, 40) | X3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(X3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(X3319, 3, 4, 6, 40) | X3319 == -7

/* Note: 2013+ uses upper-case X variables in the implicate file */
egen BUScheck = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326) ///
    + (X3335>0)*X3335 + farmbus ///
    + (X3408>0)*X3408 + (X3412>0)*X3412 + (X3416>0)*X3416 ///
    + (X3420>0)*X3420 + (X3424>0)*X3424 + (X3428>0)*X3428), by(Y1)

egen BUScheckPT = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326)*(X3319==1) ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326)*(X3319==11) ///
    + (X3335>0)*X3335*(X3119==1)  + (X3335>0)*X3335*(X3119==11) ///
    + farmbus*(X3119==1) + farmbus*(X3119==11) ///
    + (X3408>0)*X3408 + (X3412>0)*X3412), by(Y1)

egen BUScheckOC = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326)*(X3319==4) ///
    + (X3335>0)*X3335*(X3119==4) + farmbus*(X3119==4) ///
    + (X3420>0)*X3420), by(Y1)

rename Y1 y1
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2013
save `buscheck2013', replace


/* ----------------------------- 2016 ------------------------------------ */
use "$source/p16i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "$source/rscfp2016.dta", nogen
rename y1 Y1
gen year = 2016

gen PP1 = 0
replace PP1 = 1 if inlist(X3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(X3119, 3, 4, 6, 40) | X3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(X3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(X3219, 3, 4, 6, 40) | X3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(X3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(X3319, 3, 4, 6, 40) | X3319 == -7

egen BUScheck = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326) ///
    + (X3335>0)*X3335 + farmbus ///
    + (X3408>0)*X3408 + (X3412>0)*X3412 + (X3416>0)*X3416 ///
    + (X3420>0)*X3420 + (X3424>0)*X3424 + (X3428>0)*X3428), by(Y1)

egen BUScheckPT = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326)*(X3319==1) ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326)*(X3319==11) ///
    + (X3335>0)*X3335*(X3119==1)  + (X3335>0)*X3335*(X3119==11) ///
    + farmbus*(X3119==1) + farmbus*(X3119==11) ///
    + (X3408>0)*X3408 + (X3412>0)*X3412), by(Y1)

egen BUScheckOC = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
    + ((X3329>0)*X3329 + (X3324>0)*X3324 - (X3327==5)*(X3326>0)*X3326)*(X3319==4) ///
    + (X3335>0)*X3335*(X3119==4) + farmbus*(X3119==4) ///
    + (X3420>0)*X3420), by(Y1)

rename Y1 y1
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2016
save `buscheck2016', replace


/* ----------------------------- 2019 ------------------------------------ */
use "$source/p19i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "$source/rscfp2019.dta", nogen
rename y1 Y1
gen year = 2019

gen PP1 = 0
replace PP1 = 1 if inlist(X3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(X3119, 3, 4, 6, 40) | X3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(X3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(X3219, 3, 4, 6, 40) | X3219 == -7

gen PP3 = 0
replace PP3 = 1 if inlist(X3319, 1, 2, 11, 12)
replace PP3 = 2 if inlist(X3319, 3, 4, 6, 40) | X3319 == -7

/* 2019: business slot 3 (x3329 etc.) was dropped; X3335 is the catch-all
   "other" slot; nonactive slots x3415/x3419/x3427/x3451 used.         */
egen BUScheck = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226) ///
    + (X3335>0)*X3335 + farmbus ///
    + (X3408>0)*X3408 + (X3412>0)*X3412 + (X3416>0)*X3416 ///
    + (X3420>0)*X3420 + (X3428>0)*X3428), by(Y1)

egen BUScheckPT = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==1) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==11) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
    + (X3335>0)*X3335*(X3119==1) + (X3335>0)*X3335*(X3119==11) ///
    + farmbus*(X3119==1) + farmbus*(X3119==11) ///
    + (X3408>0)*X3408 + (X3412>0)*X3412), by(Y1)

egen BUScheckOC = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
    + (X3335>0)*X3335*(X3119==4) + farmbus*(X3119==4) ///
    + (X3420>0)*X3420), by(Y1)

rename Y1 y1
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2019
save `buscheck2019', replace


/* ----------------------------- 2022 ------------------------------------ */
/* 2022: only two active business slots (1 and 2); new nonactive slot X3451/
   X3454; X3120/X3122/X7144 used for an additional deduction.           */
use "$source/p22i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "$source/rscfp2022.dta", nogen
rename (y1 yy1) (Y1 YY1)
gen year = 2022

gen PP1 = 0
replace PP1 = 1 if inlist(X3119, 1, 2, 11, 12)
replace PP1 = 2 if inlist(X3119, 3, 4, 6, 40) | X3119 == -7

gen PP2 = 0
replace PP2 = 1 if inlist(X3219, 1, 2, 11, 12)
replace PP2 = 2 if inlist(X3219, 3, 4, 6, 40) | X3219 == -7

foreach var of varlist X* {
    replace `var' = round(`var') if `var' != 0 & `var' != 1
}

/* BUScheck_guar in 2022 applies an additional deduction for sub-S equity
   transferred to stock; replicate for BUScheck too                        */
egen BUScheck = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 ///
       - (X3120==1)*(X3122==5)*(X7144==1)*X3121) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226) ///
    + (X3335>0)*X3335 + farmbus ///
    + (X3408>0)*X3408 + (X3412>0)*X3412 + (X3416>0)*X3416 ///
    + (X3420>0)*X3420 + (X3452>0)*X3452 + (X3428>0)*X3428), by(Y1)

egen BUScheckPT = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 ///
       - (X3120==1)*(X3122==5)*(X7144==1)*X3121)*(X3119==1) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==1) ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 ///
       - (X3120==1)*(X3122==5)*(X7144==1)*X3121)*(X3119==11) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==11) ///
    + (X3335>0)*X3335*(X3119==1) + (X3335>0)*X3335*(X3119==11) ///
    + farmbus*(X3119==1) + farmbus*(X3119==11) ///
    + (X3408>0)*X3408 + (X3412>0)*X3412 + (X3452>0)*X3452), by(Y1)

egen BUScheckOC = sum(0 ///
    + ((X3129>0)*X3129 + (X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 ///
       - (X3120==1)*(X3122==5)*(X7144==1)*X3121)*(X3119==4) ///
    + ((X3229>0)*X3229 + (X3224>0)*X3224 - (X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
    + (X3335>0)*X3335*(X3119==4) + farmbus*(X3119==4) ///
    + (X3420>0)*X3420), by(Y1)

rename (Y1 YY1) (y1 yy1)
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

tempfile buscheck2022
save `buscheck2022', replace


/*---------------------------------------------------------------------------
  Append all years into one BUScheck dataset
---------------------------------------------------------------------------*/
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
  
  Reproduces only the noncorporate equity chain from scf_fa_recon.do:
    1. Load SCF (all years) + FA data
    2. Compute scf_fa_equity_non_corp via the net-worth + cost-basis blend
    3. For each year: compute the portfolio share of equity_non_corp in
       the top 0.1%, apply it to Forbes 400 NW, produce
       scf_fa_forbes_equity_non_corp = scf_fa_equity_non_corp for SCF
       households and forbes_equity_non_corp for Forbes households
===========================================================================*/

/*---------------------------------------------------------------------------
  B.1  Load FA data (used for fa_non_corp_eq and corp_for_ratio)
---------------------------------------------------------------------------*/
import delimited "$main/dfa_public_code/dfa_raw/fa_data.csv", clear

preserve
import excel "$main/data/Inflation.xlsx", first sheet("clean") clear
ren _all, lower
drop jul
tempfile cpi
save `cpi'
restore

merge 1:1 year using `cpi', nogen keep(3)

ds year perm_ratio cars_payable homes_payable corp_for_ratio index, not
local varlist `r(varlist)'
foreach var of local varlist {
    replace `var' = `var' * index
}
drop index

tempfile fadata
save `fadata', replace


/*---------------------------------------------------------------------------
  B.2  Load and stack SCF raw data (all waves)
---------------------------------------------------------------------------*/
foreach y in 19 22 {
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
    if (_rc == 0) rename (Y1 YY1) (y1 yy1)
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
merge m:1 age using "$main/dfa_public_code/dfa_raw/payout_annuities.dta", nogen keep(match)
ren (single married) (fa_single fa_married)
ren scf_married married
merge 1:1 y1 year using "$main/dfa_public_code/dfa_raw/DFA_DB_public.dta", nogen keep(match)


/*---------------------------------------------------------------------------
  B.3  Noncorporate equity: net-worth approach
  equity_non_corp_nw = nnresre + rentals + bus - sc_corp_value - vacant_land
  (sc_corp_value removes S-corp / C-corp businesses already captured in
   corporate equity)
---------------------------------------------------------------------------*/

/* ---- rental properties (needed for equity_non_corp_nw) ---- */
gen rental_properties1 = 0
gen rental_properties2 = 0
gen rental_properties3 = 0
gen rental_properties_more = 0

if year <= 1992 {
    replace rental_properties1 = x1706*(x1705/10000) if inlist(x1703,12,14,21,22,40,41,42,43,44,49,50,52,999)
    replace rental_properties1 = 0 if x1729 != 1
    replace rental_properties2 = x1806*(x1805/10000) if inlist(x1803,12,14,21,22,40,41,42,43,44,49,50,52,999)
    replace rental_properties2 = 0 if x1829 != 1
    replace rental_properties3 = x1906*(x1905/10000) if inlist(x1903,12,14,21,22,40,41,42,43,44,49,50,52,999)
    replace rental_properties3 = 0 if x1929 != 1
    replace rental_properties_more = max(0, x2002) if x2009 == 1
}
if year > 1992 & year <= 2007 {
    replace rental_properties1 = x1706*(x1705/10000) if inlist(x1703,12,21,40,41,42,49,50,999,-7)
    replace rental_properties1 = 0 if x1729 != 1
    replace rental_properties2 = x1806*(x1805/10000) if inlist(x1803,12,21,40,41,42,49,50,999,-7)
    replace rental_properties2 = 0 if x1829 != 1
    replace rental_properties3 = x1906*(x1905/10000) if inlist(x1903,12,21,40,41,42,49,50,999,-7)
    replace rental_properties3 = 0 if x1929 != 1
    replace rental_properties_more = max(0, x2002) if x2009 == 1
}
if year >= 2010 {
    replace rental_properties1 = x1706*(x1705/10000) if inlist(x1703,12,21,40,42,49,50,999,-7)
    replace rental_properties1 = 0 if x1729 != 1
    replace rental_properties2 = x1806*(x1805/10000) if inlist(x1803,12,21,40,42,49,50,999,-7)
    replace rental_properties2 = 0 if x1829 != 1
    replace rental_properties_more = max(0, x2002) if x2009 == 1
}
gen rentals = rental_properties1 + rental_properties2 + rental_properties3 + rental_properties_more

/* ---- vacant land ---- */
gen vacant_land = 0
replace vacant_land = x1706*(x1705/10000) if x1703 == 11
replace vacant_land = vacant_land + x1806*(x1805/10000) if x1803 == 11
replace vacant_land = vacant_land + x1906*(x1905/10000) if x1903 == 11

/* ---- corporate-form business values (S-corps & C-corps active) ---- */
gen sc_corp_value = 0
gen sc_corp_equity = 0
gen sc_corp_stocks = 0

if year < 2010 {
    replace sc_corp_value = max(0,x3129) if x3119 == 3 | x3119 == 4
    replace sc_corp_value = sc_corp_value + max(0, x3229) if x3219 == 3 | x3219 == 4
    replace sc_corp_value = sc_corp_value + max(0, x3329) if x3319 == 3 | x3319 == 4
    replace sc_corp_value = sc_corp_value + max(0, x3416) + max(0, x3420)
    replace sc_corp_stocks = x4022 if inlist(x4020,73,74)
    replace sc_corp_stocks = sc_corp_stocks + x4026 if inlist(x4024,73,74)
    replace sc_corp_stocks = sc_corp_stocks + x4030 if inlist(x4028,73,74)
    replace sc_corp_equity = sc_corp_stocks + sc_corp_value
    replace sc_corp_equity = 0 if sc_corp_equity < 0
}
if year >= 2010 {
    replace sc_corp_value = max(0,x3129) if x3119 == 3 | x3119 == 4
    replace sc_corp_value = sc_corp_value + max(0, x3229) if x3219 == 3 | x3219 == 4
    replace sc_corp_value = sc_corp_value + max(0, x3416) + max(0, x3420)
    replace sc_corp_stocks = x4022 if inlist(x4020,73,74)
    replace sc_corp_stocks = sc_corp_stocks + x4026 if inlist(x4024,73,74)
    replace sc_corp_stocks = sc_corp_stocks + x4030 if inlist(x4028,73,74)
    replace sc_corp_equity = sc_corp_stocks + sc_corp_value
    replace sc_corp_equity = 0 if sc_corp_equity < 0
}

/* ---- noncorporate equity: net-worth measure ---- */
gen equity_non_corp_nw = nnresre + rentals + bus - sc_corp_value - vacant_land


/*---------------------------------------------------------------------------
  B.4  Noncorporate equity: cost-basis approach
---------------------------------------------------------------------------*/
/* Active business cost basis */
gen active_bus_cb1 = 0
gen active_bus_cb2 = 0
gen active_bus_cb3 = 0
gen active_bus_cb4 = 0

if year < 2010 {
    replace active_bus_cb1 = max(0,x3130) if x3119 != 3 | x3119 != 4
    replace active_bus_cb2 = max(0,x3230) if x3219 != 3 | x3219 != 4
    replace active_bus_cb3 = max(0,x3330) if x3319 != 3 | x3319 != 4
    replace active_bus_cb4 = max(0,x3336)
}
if year >= 2010 {
    replace active_bus_cb1 = max(0,x3130) if x3119 != 3 | x3119 != 4
    replace active_bus_cb2 = max(0,x3230) if x3219 != 3 | x3219 != 4
    replace active_bus_cb3 = 0
    replace active_bus_cb4 = max(0,x3336)
}

/* S-corp / active-corporate cost basis (needed to net out) */
gen active_bus_cb1_sc = 0
gen active_bus_cb2_sc = 0
gen active_bus_cb3_sc = 0
gen active_bus_cb4_sc = 0
if year < 2010 {
    replace active_bus_cb1_sc = max(0,x3130) if x3119 == 3 | x3119 == 4
    replace active_bus_cb2_sc = max(0,x3230) if x3219 == 3 | x3219 == 4
    replace active_bus_cb3_sc = max(0,x3330) if x3319 == 3 | x3319 == 4
    replace active_bus_cb4_sc = max(0,x3336)
}
if year >= 2010 {
    replace active_bus_cb1_sc = max(0,x3130) if x3119 == 3 | x3119 == 4
    replace active_bus_cb2_sc = max(0,x3230) if x3219 == 3 | x3219 == 4
    replace active_bus_cb3_sc = 0
    replace active_bus_cb4_sc = max(0,x3336)
}
gen nonactive_bus_sc = max(0,x3417) + max(0,x3421)
gen sc_corp_cb = active_bus_cb1_sc + active_bus_cb2_sc + active_bus_cb3_sc ///
               + active_bus_cb4_sc + nonactive_bus_sc

/* Non-active business cost basis */
gen nonactive_bus_cb1 = 0
gen nonactive_bus_cb2 = 0
gen nonactive_bus_cb3 = 0
gen nonactive_bus_cb4 = 0
if year < 2010 {
    replace nonactive_bus_cb1 = max(0,x3409)
    replace nonactive_bus_cb2 = max(0,x3413)
    replace nonactive_bus_cb3 = max(0,x3425)
    replace nonactive_bus_cb4 = max(0,x3429)
}
if year >= 2010 {
    replace nonactive_bus_cb1 = max(0,x3409)
    replace nonactive_bus_cb2 = max(0,x3413)
    replace nonactive_bus_cb3 = max(0,x3453)
    replace nonactive_bus_cb4 = max(0,x3429)
}
gen bus_cb = active_bus_cb1 + active_bus_cb2 + active_bus_cb3 + active_bus_cb4 ///
           + nonactive_bus_cb1 + nonactive_bus_cb2 + nonactive_bus_cb3 + nonactive_bus_cb4

/* Rental property cost basis */
gen rental_properties_cb1 = 0
gen rental_properties_cb2 = 0
gen rental_properties_cb3 = 0
gen rental_properties_cb4 = 0

if year < 2010 {
    replace rental_properties_cb1 = x1709*(x1705/10000) if inlist(x1703,12,21,40,41,42,49,50,999,-7)
    replace rental_properties_cb1 = 0 if x1729 != 1
    replace rental_properties_cb2 = x1809*(x1805/10000) if inlist(x1803,12,21,40,41,42,49,50,999,-7)
    replace rental_properties_cb2 = 0 if x1829 != 1
    replace rental_properties_cb3 = x1909*(x1905/10000) if inlist(x1903,12,21,40,41,42,49,50,999,-7)
    replace rental_properties_cb3 = 0 if x1929 != 1
    replace rental_properties_cb4 = max(0, x2002) if x2009 == 1
}
if year >= 2010 & year < 2019 {
    replace rental_properties_cb1 = x1709*(x1705/10000) if inlist(x1703,12,21,40,41,42,49,50,999,-7)
    replace rental_properties_cb1 = 0 if x1729 != 1
    replace rental_properties_cb2 = x1809*(x1805/10000) if inlist(x1803,12,21,40,41,42,49,50,999,-7)
    replace rental_properties_cb2 = 0 if x1829 != 1
    replace rental_properties_cb4 = max(0, x2002) if x2009 == 1
}
if year >= 2019 {
    replace rental_properties_cb1 = x1709*(x1705/10000) if inlist(x1703,12,21,40,42,49,50,999,-7)
    replace rental_properties_cb1 = 0 if x1729 != 1
    replace rental_properties_cb2 = x1809*(x1805/10000) if inlist(x1803,12,21,40,42,49,50,999,-7)
    replace rental_properties_cb2 = 0 if x1829 != 1
    replace rental_properties_cb4 = max(0, x2002) if x2009 == 1
}
gen rentals_cb = rental_properties_cb1 + rental_properties_cb2 ///
              + rental_properties_cb3 + rental_properties_cb4

/* Non-residential real estate cost basis */
gen nnresre_cb1 = 0
gen nnresre_cb2 = 0
gen nnresre_cb3 = 0
if year < 1995 {
    replace nnresre_cb1 = max(0,x1709)*(x1705/10000) if inlist(x1703,1,2,3,4,5,6,7,10,11,13,15,24,45,46,47,48,51,53,-7)
    replace nnresre_cb2 = max(0,x1809)*(x1805/10000) if inlist(x1803,1,2,3,4,5,6,7,10,11,13,15,24,45,46,47,48,51,53,-7)
    replace nnresre_cb3 = max(0,x1909)*(x1905/10000) if inlist(x1903,1,2,3,4,5,6,7,10,11,13,15,24,45,46,47,48,51,53,-7)
}
if year == 1995 {
    replace nnresre_cb1 = max(0,x1709)*(x1705/10000) if inlist(x1703,1,2,3,4,5,6,7,10,11,12,15,45,46,47,51,53,-7)
    replace nnresre_cb2 = max(0,x1809)*(x1805/10000) if inlist(x1803,1,2,3,4,5,6,7,10,11,12,15,45,46,47,51,53,-7)
    replace nnresre_cb3 = max(0,x1909)*(x1905/10000) if inlist(x1903,1,2,3,4,5,6,7,10,11,12,15,45,46,47,51,53,-7)
}
if year == 1998 {
    replace nnresre_cb1 = max(0,x1709)*(x1705/10000) if inlist(x1703,1,2,3,4,5,6,7,10,11,12,15,45,47,51,53,-7)
    replace nnresre_cb2 = max(0,x1809)*(x1805/10000) if inlist(x1803,1,2,3,4,5,6,7,10,11,12,15,45,47,51,53,-7)
    replace nnresre_cb3 = max(0,x1909)*(x1905/10000) if inlist(x1903,1,2,3,4,5,6,7,10,11,12,15,45,47,51,53,-7)
}
if year > 1998 & year <= 2010 {
    replace nnresre_cb1 = max(0,x1709)*(x1705/10000) if inlist(x1703,1,2,3,4,5,6,7,10,11,12,45,47,51,53,-7)
    replace nnresre_cb2 = max(0,x1809)*(x1805/10000) if inlist(x1803,1,2,3,4,5,6,7,10,11,12,45,47,51,53,-7)
    replace nnresre_cb3 = max(0,x1909)*(x1905/10000) if inlist(x1903,1,2,3,4,5,6,7,10,11,12,45,47,51,53,-7)
}
if year >= 2010 {
    replace nnresre_cb1 = max(0,x1709)*(x1705/10000) if inlist(x1703,1,2,3,4,5,6,7,10,11,13,15,24,45,46,47,48,51,53,-7)
    replace nnresre_cb2 = max(0,x1809)*(x1805/10000) if inlist(x1803,1,2,3,4,5,6,7,10,11,13,15,24,45,46,47,48,51,53,-7)
}
gen nnresre_cb = nnresre_cb1 + nnresre_cb2 + nnresre_cb3

gen equity_non_corp_cb = bus_cb + rentals_cb + nnresre_cb

/* ---- DFA blend: 50% net-worth, 50% cost-basis ---- */
gen scf_fa_equity_non_corp = .5*equity_non_corp_nw + .5*equity_non_corp_cb

/* ---- Business oresre debt deduction ---- */
gen business_oresre1 = 0
gen business_oresre_debt1 = 0
gen business_oresre2 = 0
gen business_oresre_debt2 = 0
gen business_oresre3 = 0
gen business_oresre_debt3 = 0
gen business_oresre_more = 0
gen business_oresre_debt_more = 0

if year <= 1992 {
    replace business_oresre1 = x1706*(x1705/10000) if inlist(x1703,12,14,21,22,40,41,42,43,44,49,50,52,999)
    replace business_oresre1 = 0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
    replace business_oresre_debt1 = x1715
    replace business_oresre_debt1 = 0 if business_oresre1 == 0
    replace business_oresre2 = x1806*(x1805/10000) if inlist(x1803,12,14,21,22,40,41,42,43,44,49,50,52,999)
    replace business_oresre1 = 0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
    replace business_oresre_debt2 = x1815
    replace business_oresre_debt2 = 0 if business_oresre2 == 0
    replace business_oresre3 = x1906*(x1905/10000) if inlist(x1903,12,14,21,22,40,41,42,43,44,49,50,52,999)
    replace business_oresre1 = 0 if (x1904==1 | x1904==5 | (x1904==2 & x1929~=1))
    replace business_oresre_debt3 = x1915
    replace business_oresre_debt3 = 0 if business_oresre3 == 0
    replace business_oresre_more = max(0, x2002) if x2009 == 1
    replace business_oresre_debt_more = x2006
    replace business_oresre_debt_more = 0 if business_oresre_more == 0
}
if year >= 1995 & year <= 2007 {
    replace business_oresre1 = x1706*(x1705/10000) if inlist(x1703,12,21,40,41,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
    replace business_oresre_debt1 = x1715
    replace business_oresre_debt1 = 0 if business_oresre1 == 0
    replace business_oresre2 = x1806*(x1805/10000) if inlist(x1803,12,21,40,41,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
    replace business_oresre_debt2 = x1815
    replace business_oresre_debt2 = 0 if business_oresre2 == 0
    replace business_oresre3 = x1906*(x1905/10000) if inlist(x1903,12,21,40,41,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1904==1 | x1904==5 | (x1904==2 & x1929~=1))
    replace business_oresre_debt3 = x1915
    replace business_oresre_debt3 = 0 if business_oresre3 == 0
    replace business_oresre_more = max(0, x2002) if x2009 == 1
    replace business_oresre_debt_more = x2006
    replace business_oresre_debt_more = 0 if business_oresre_more == 0
}
if year >= 2010 & year < 2019 {
    replace business_oresre1 = x1706*(x1705/10000) if inlist(x1703,12,21,40,41,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
    replace business_oresre_debt1 = x1715
    replace business_oresre_debt1 = 0 if business_oresre1 == 0
    replace business_oresre2 = x1806*(x1805/10000) if inlist(x1803,12,21,40,41,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
    replace business_oresre_debt2 = x1815
    replace business_oresre_debt2 = 0 if business_oresre2 == 0
    replace business_oresre3 = x1906*(x1905/10000) if inlist(x1903,12,21,40,41,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1904==1 | x1904==5 | (x1904==2 & x1929~=1))
    replace business_oresre_debt3 = x1915
    replace business_oresre_debt3 = 0 if business_oresre3 == 0
    replace business_oresre_more = max(0, x2002) if x2009 == 1
    replace business_oresre_debt_more = x2006
    replace business_oresre_debt_more = 0 if business_oresre_more == 0
}
if year >= 2019 {
    replace business_oresre1 = x1706*(x1705/10000) if inlist(x1703,12,21,22,40,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1704==1 | x1704==5 | (x1704==2 & x1729~=1))
    replace business_oresre_debt1 = x1715
    replace business_oresre_debt1 = 0 if business_oresre1 == 0
    replace business_oresre2 = x1806*(x1805/10000) if inlist(x1803,12,21,22,40,42,49,50,999,-7)
    replace business_oresre1 = 0 if (x1804==1 | x1804==5 | (x1804==2 & x1829~=1))
    replace business_oresre_debt2 = x1815
    replace business_oresre_debt2 = 0 if business_oresre2 == 0
    replace business_oresre_more = max(0, x2002) if x2009 == 1
    replace business_oresre_debt_more = x2006
    replace business_oresre_debt_more = 0 if business_oresre_more == 0
}
gen bus_oresre_debt = business_oresre_debt1 + business_oresre_debt2 ///
                    + business_oresre_debt3 + business_oresre_debt_more

/* ---- Final adjustment: deduct business oresre debt from noncorp equity ---- */
replace scf_fa_equity_non_corp = scf_fa_equity_non_corp - bus_oresre_debt

tempfile scftemp
save `scftemp', replace


/*---------------------------------------------------------------------------
  B.5  Year-by-year loop: compute portfolio share of noncorp equity in
       top 0.1%, apply to Forbes, create scf_fa_forbes_equity_non_corp
---------------------------------------------------------------------------*/
forval year = 1989(3)2022 {
use `scftemp' if year == `year', clear
tempfile scf`year'
save `scf`year'', replace

/* ---- Weighted noncorp equity totals (needed for proportional scaling) ---- */
gen scf_fa_equity_non_corp_wgted = scf_fa_equity_non_corp * wgt
egen scf_fa_equity_non_corp_tot = sum(scf_fa_equity_non_corp_wgted), by(year)

/* ---- Allocate FA noncorp equity to households proportionally ---- */
gen equity_non_corp = fa_non_corp_eq * scf_fa_equity_non_corp_wgted / scf_fa_equity_non_corp_tot

/* ---- Reconstruct net worth (approximation; only noncorp equity needed) ---- */
gen recon_nw = networth

/* ---- Find top-0.1-pct portfolio share of noncorp equity ---- */
/* equity_non_corpshare = (FA-scaled noncorp equity of top 0.1%) /
   (total FA-scaled assets_recon of top 0.1%).  We approximate assets_recon
   with total FA equity_non_corp here since we only need the one component. */
_pctile recon_nw [aw=wgt], p(99.9)
tabstat equity_non_corp [aw=wgt] ///
    if recon_nw >= `r(r1)' & missing(recon_nw)==0, stats(sum) save
tabstatmat top01_enc
tabstat equity_non_corp [aw=wgt] if missing(recon_nw)==0, stats(sum) save
tabstatmat enc_total
mat equity_non_corpshare = top01_enc[1,1] / enc_total[1,1]

/* ---- Read Forbes data for this year ---- */
forvalues i = 1(1)5 {
    import excel using "$main/dfa_public_code/dfa_raw/forbes_89_22_consistent_forDFA_public.xlsx", ///
        sheet(Forbes`year') clear
    drop E
    gen forbes_rank = _n
    ren C forbes_nw
    ren D forbes_age
    replace forbes_age = 65 if missing(forbes_age)
    keep forbes_*
    gen year = `year'

    preserve
    import excel "$main/data/Inflation.xlsx", first sheet("clean") clear
    ren _all, lower
    drop jul
    tempfile cpi
    save `cpi'
    restore
    merge m:1 year using `cpi', nogen keep(3)

    replace forbes_nw = forbes_nw * 1000000 * index

    /* ---- Apply portfolio share to get Forbes noncorp equity ---- */
    gen forbes_equity_non_corp = equity_non_corpshare[1,1] * forbes_nw

    gen imp = `i'
    tempfile forbes`year'`i'
    save `forbes`year'`i'', replace
    clear
}

use `forbes`year'1', clear
forvalues i = 2(1)5 {
    append using `forbes`year'`i''
}
tempfile forbes`year'
save `forbes`year'', replace

/* ---- Merge SCF and Forbes ---- */
use `scf`year'', clear
gen imp = mod(y1,10)
append using `forbes`year''

gen double weight = wgt
replace weight = 1/5 if missing(wgt)
gen wgt_nwgac = weight

/* ---- Create scf_fa_forbes_equity_non_corp ---- */
clonevar scf_fa_forbes_equity_non_corp = scf_fa_equity_non_corp
replace  scf_fa_forbes_equity_non_corp = forbes_equity_non_corp if missing(forbes_equity_non_corp)==0

keep year y1 yy1 wgt wgt_nwgac scf_fa_equity_non_corp scf_fa_forbes_equity_non_corp

tempfile noncorpeq`year'
save `noncorpeq`year'', replace
}


/*---------------------------------------------------------------------------
  B.6  Append all years for scf_fa_forbes_equity_non_corp
---------------------------------------------------------------------------*/
use `noncorpeq1989', clear
forvalues year = 1992(3)2022 {
    append using `noncorpeq`year''
}
order year y1 yy1

tempfile noncorpeq_all
save `noncorpeq_all', replace


/*===========================================================================
  SECTION C: Combine all four variables into one dataset
  
  The three BUScheck variables are household-level (collapsed by y1);
  scf_fa_forbes_equity_non_corp is implicate-level.  We merge on (year, y1).
===========================================================================*/
use `noncorpeq_all', clear
merge m:1 year y1 using `buschecks_all', nogen

order year y1 yy1 wgt wgt_nwgac BUScheck BUScheckPT BUScheckOC ///
      scf_fa_equity_non_corp scf_fa_forbes_equity_non_corp

label var BUScheck      "Total noncorp business equity (sum across all LFO types, by y1)"
label var BUScheckPT    "Noncorp business equity: sole props & partnerships (LFO 1/11)"
label var BUScheckOC    "Noncorp business equity: other corporations (LFO 4)"
label var scf_fa_equity_non_corp       "DFA noncorp equity (50% NW + 50% cost basis)"
label var scf_fa_forbes_equity_non_corp "DFA noncorp equity augmented with Forbes 400"

save "$out/variable_creation_merge.dta", replace
