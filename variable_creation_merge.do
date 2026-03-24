/*===========================================================================
  variable_creation_merge.do

  Purpose: create a single clean table containing only the four variables
    of interest:
      - BUScheck
      - BUScheckPT
      - BUScheckOC
      - scf_fa_forbes_equity_non_corp

  Approach: run the two original do-files exactly as written (no changes
  to their code), then merge their outputs on (year, y1) and keep only
  the four target variables plus the identifiers year, y1, yy1, and wgt.

  Inputs (paths defined inside the original do-files):
    1_dataset.do     --> saves  $main\data\coefdata_adjusted.dta
    scf_fa_recon.do  --> saves  $main\data\dfa_adjusted_constant.dta

  Output:
    $main\data\target_variables.dta
      year  y1  yy1  wgt  BUScheck  BUScheckPT  BUScheckOC
      scf_fa_forbes_equity_non_corp
===========================================================================*/

clear
clear matrix
clear mata
set more off
set maxvar 10000

/* ---------- PART 1: run 1_dataset.do verbatim ----------------------------- */

do "1_dataset.do"

/* ---------- PART 2: run scf_fa_recon.do verbatim -------------------------- */

do "scf_fa_recon.do"

/* ---------- PART 3: merge the two outputs and keep only what we need ------- */

* Load the output from 1_dataset.do (contains BUScheck, BUScheckPT, BUScheckOC)
use "$main\data\coefdata_adjusted.dta", clear

* Keep only the identifiers and the three target BUScheck variables
keep year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC

* Sort for merge
sort year y1 yy1

* Merge with the output from scf_fa_recon.do (contains scf_fa_forbes_equity_non_corp)
* dfa_adjusted_constant has one row per household per implicate per year,
* identified by (year, y1).  Use m:1 since coefdata may have one row per
* implicate while scf_fa_recon collapses to one per household.
merge m:1 year y1 using "$main\data\dfa_adjusted_constant.dta", ///
    keepusing(scf_fa_forbes_equity_non_corp) keep(1 3) nogen

* Keep only the four target variables plus identifiers
order year y1 yy1 wgt BUScheck BUScheckPT BUScheckOC scf_fa_forbes_equity_non_corp

save "$main\data\target_variables.dta", replace
