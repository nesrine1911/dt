/*===========================================================================
  validate_variables.do

  Purpose: verify that the four variables produced by variable_creation_merge.do
  are numerically identical to the originals produced by:
    - 1_dataset.do      --> BUScheck, BUScheckPT, BUScheckOC
                           (saved in coefdata_adjusted.dta)
    - scf_fa_recon.do   --> scf_fa_forbes_equity_non_corp
                           (saved in dfa_adjusted_constant.dta)

  For each variable the script:
    1. Loads both the original and the new version
    2. Merges them on the join key
    3. Computes the absolute difference at every observation
    4. Reports: number of mismatches, max absolute difference, and -- if any
       mismatches are found -- lists the offending rows

  A clean run prints "ALL CHECKS PASSED" at the end.
  Any discrepancy prints the offending rows and exits with an error so the
  failure is impossible to miss.

  *** ADJUST THE TWO PATH LOCALS BELOW BEFORE RUNNING ***
===========================================================================*/

local adj  "C:\Users\nhadjara\Dropbox\Equity&WealthIneq\Maitreyee"

* Output of variable_creation_merge.do
local new  "`adj'\data\target_variables.dta"

* Originals
local orig_bus    "`adj'\data\coefdata_adjusted.dta"
local orig_recon  "`adj'\data\dfa_adjusted_constant.dta"

clear
clear matrix
clear mata
set more off


/*---------------------------------------------------------------------------
  HELPER: generic comparison programme
  Usage:
    compare_var, new(`new') orig(`orig') key(`key') var(`var') [orig_var(`v')]

  Merges new on orig using `key', computes abs difference for `var',
  reports results and aborts if any mismatch is found.
---------------------------------------------------------------------------*/

program define compare_var
    syntax , new(string) orig(string) key(string) var(string) [orig_var(string)]

    * If the variable has a different name in the original, allow renaming
    if "`orig_var'" == "" local orig_var `var'

    di as text _newline(1) "============================================================"
    di as text "Checking: `var'"
    di as text "  new file : `new'"
    di as text "  orig file: `orig'"
    di as text "============================================================"

    * Load new file -- keep only key + variable
    use `key' `var' using "`new'", clear
    ren `var' new_`var'
    sort `key'
    tempfile tmp_new
    save `tmp_new', replace

    * Load original -- keep only key + variable (renamed if needed)
    use `key' `orig_var' using "`orig'", clear
    if "`orig_var'" != "`var'" ren `orig_var' `var'
    sort `key'
    tempfile tmp_orig
    save `tmp_orig', replace

    * Merge
    use `tmp_new', clear
    merge 1:1 `key' using `tmp_orig', keep(3) nogen

    * Compute difference
    gen double diff_`var' = abs(new_`var' - `var')

    qui count if missing(new_`var') != missing(`var')
    local n_missing_mismatch = r(N)

    qui count if diff_`var' > 1e-8 & !missing(diff_`var')
    local n_diff = r(N)

    qui sum diff_`var'
    local max_diff = r(max)

    di as text "  Missing-status mismatches : `n_missing_mismatch'"
    di as text "  Value mismatches (>1e-8)  : `n_diff'"
    di as text "  Max absolute difference   : `max_diff'"

    if `n_missing_mismatch' > 0 | `n_diff' > 0 {
        di as error "MISMATCH DETECTED for `var'!"
        di as error "First offending rows:"
        list `key' new_`var' `var' diff_`var' ///
            if (diff_`var' > 1e-8 & !missing(diff_`var')) | ///
               (missing(new_`var') != missing(`var')) ///
            in 1/20
        error 1
    }
    else {
        di as result "  OK: `var' is identical in both files."
    }
end


/*---------------------------------------------------------------------------
  CHECK 1: BUScheck
  Key: year + y1  (BUScheck is collapsed by y1 so one value per y1-year)
---------------------------------------------------------------------------*/

compare_var ,                      ///
    new("`new'")                   ///
    orig("`orig_bus'")             ///
    key("year y1")                 ///
    var("BUScheck")


/*---------------------------------------------------------------------------
  CHECK 2: BUScheckPT
---------------------------------------------------------------------------*/

compare_var ,                      ///
    new("`new'")                   ///
    orig("`orig_bus'")             ///
    key("year y1")                 ///
    var("BUScheckPT")


/*---------------------------------------------------------------------------
  CHECK 3: BUScheckOC
---------------------------------------------------------------------------*/

compare_var ,                      ///
    new("`new'")                   ///
    orig("`orig_bus'")             ///
    key("year y1")                 ///
    var("BUScheckOC")


/*---------------------------------------------------------------------------
  CHECK 4: scf_fa_forbes_equity_non_corp
  Key: year + y1  (implicate-level in recon output; merge on both)
---------------------------------------------------------------------------*/

compare_var ,                               ///
    new("`new'")                            ///
    orig("`orig_recon'")                    ///
    key("year y1")                          ///
    var("scf_fa_forbes_equity_non_corp")


/*---------------------------------------------------------------------------
  All checks passed
---------------------------------------------------------------------------*/

di as result _newline(2) "============================================================"
di as result "ALL CHECKS PASSED -- variable_creation_merge.do is exact."
di as result "============================================================"
