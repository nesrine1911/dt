* Part one: building the dataset from SCF raw data
clear
clear matrix
clear mata
set more off
set maxvar 10000

**********************************
************** 1989 **************
**********************************

foreach num1 of numlist 89(1)89 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output\kartashova_intermediate"

use "`in'/p`num1'i6", clear
rename X* x*
rename Y1 x1 
merge 1:1 x1 using "`in'/rscfp19`num1'.dta", nogen

rename x1 y1 
rename xx1 yy1
gen year=19`num1'


gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen type=0
replace type=1 if (x3119==1|x3119==11|x3119==12)
replace type=2 if (x3119==2)
replace type=3 if (x3119==3)
replace type=4 if (x3119==4|x3119==6)
replace type=5 if (x3119==-7|x3119==40)

table x4106 x3119 if x3104==1 [aw=wgt]

gen work_for="salary_wage" if x4125==1 | x4126==1
replace work_for="net_earnings" if x4127==1
replace work_for="other" if x4128==1
* Identify those workers that are not paid wages but own a business 
gen no_pay="yes" if x4112==-1 
replace no_pay="no" if no_pay!="yes"

* drop no_wage_dummy_1 no_wage_dummy_7 paid_wage_dummy_1 paid_wage_dummy_7

* Define value of business and look at those businesses with positive equity, where the respondent/spouse work - the _guar variable corresponds to the variable used in previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
         + (x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
	
	* The no_wage_dummy is created to identify individuals (and spouses, later) that are 
	** self-employed
	** actively manage their business 
	** earn income through one or more of the following -- net earnings (of the business) or a wage or salary that is not from the business
	
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'27==1 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12==-1  & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'28==1  & x3113==1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}

* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* SPOUSE

foreach num of numlist 7/7 {  

gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'27==1 & BUScheck_guar>0 
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12==-1 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'28==1  & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}

* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* The following identify respondents and spouses that are business owners that actively manage their business and do have a wage paying job at the business -- do not need to be imputed. 

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'27==1 & x4`num'12==0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'28==1 & x4`num'12==0 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'26==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'27==1 & x4`num'12==0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'28==1 & x4`num'12==0 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* drop hours_worked
foreach num of numlist 1/1 7/7 {

* We build hours worked manually based on how the responses 
gen hours_worked_`num'=x4`num'10
replace hours_worked_`num'=95 if x4`num'10==-2
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=x4`num'11 if x4`num'13==2 
* just keep the weeks worked
replace per`num'=x4`num'11/2 if x4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=x4`num'11/4 if x4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=x4`num'11/(4*3) if x4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if x4`num'13==6 
* annnual
replace per`num'=1 if x4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=x4`num'11 if x4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=x4`num'11*x4`num'10/8 if (x4`num'13==1 & x8021==1) 
replace per`num'=x4`num'11*x4`num'10/7 if (x4`num'13==1 & x8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
}

* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*x4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*x4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & paid_wage_dummy_`num'==1
count if x4`num'11==0 & paid_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if x4`num'06==1 & x4`num'12>0
gen paid_wage_`num'=per`num'*x4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*x4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & no_wage_dummy_`num'==1
count if x4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}
* Creating the necessary covariates for imputations 
generate ageR=x14
generate ageS=x19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(x8021==1)
generate genderdummy_S=(x103==1)

gen hsdummy_R=((x5902==1 & x5904==5)+(x5901>12 & x5904==5)) 
gen hsdummy_S=((x6102==1 & x6104==5)+(x6101>12 & x6104==5))

generate cdummy_R=(x5904==1)
generate cdummy_S=(x6104==1)

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_`num1'_new_regress", replace
}

foreach num of numlist 89/89 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_`num1'_new_regress"
gen implicat = mod(y1, 10)

* Run regression itself for a RESPONDENT
* As per Kartashova, the regressions are run separately for each imputation in the SCF 

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}

foreach num of numlist 89/89 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_`num'_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(y1, 10)
sort implicat

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}

foreach num2 of numlist 89/89 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_`num2'_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.

* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

sort y1 yy1
save "`in'/labour_regression_results`num1'", replace
}
}

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort y1 yy1
merge y1 yy1 using "`in'/labour_regression_results7" 

* Identify total wages paid for each type of business owned

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot

sort y1 yy1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 89(1)89 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 x1 
merge 1:1 x1 using "`in'/rscfp19`num'.dta", nogen

rename x1 y1 
rename xx1 yy1

sort y1 yy1

merge y1 yy1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

gen year=19`num'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen PP3=0 
replace PP3=1 if (x3319==1 | x3319==2 | x3319==11 | x3319==12)
replace PP3=2 if (x3319==3 | x3319==4 | x3319==6 | x3319==40 | x3319==-7)

gen PP2=0 
replace PP2=1 if (x3219==1 | x3219==2 | x3219==11 | x3219==12)
replace PP2=2 if (x3219==3 | x3219==4 | x3219==6 | x3219==40 | x3219==-7)

egen sumPP3PPwgt=sum((PP3==1)*wgt)
egen sumPP3SCwgt=sum((PP3==2)*wgt)
gen sumPP3wgt=sumPP3PPwgt+sumPP3SCwgt
gen PP3PPshare=sumPP3PPwgt/sumPP3wgt
gen PP3SCshare=sumPP3SCwgt/sumPP3wgt

egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)+(x3415==1)+(x3419==1)+(x3427==1)))
egen naPPwgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)))
egen naSCwgtsum=sum(wgt*((x3415==1)+(x3419==1)+(x3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+sumPP3wgt+nawgtsum)

gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt+sumPP3wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)3{
	egen sumPP`x'PTwgt = sum(((x3`x'19==1) + (x3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((x3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((x3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((x3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt + sumPP3PTwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt + sumPP3SPwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt + sumPP3Swgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt + sumPP3OCwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

gen SCorpratio = wgtdSshare/(wgtdOCshare + wgtdSshare)
gen OCorpratio = wgtdOCshare/(wgtdOCshare + wgtdSshare)

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==3) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==3) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==3) ///
                    +(x3335>0)*x3335*(x3119==3)+ farmbus*(x3119==3)+ ///
                    (x3416>0)*x3416), by(y1)
					
egen BUScheckSP=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==2) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==2) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==2) ///
                   +(x3335>0)*x3335*(x3119==2) + farmbus*(x3119==2)+ ///
                    (x3424>0)*x3424), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==-7) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==-7) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==-7) ///
                    +(x3335>0)*x3335*(x3119==-7) + farmbus*(x3119==-7)+ ///
                    (x3428>0)*x3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         x3132*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3337!=-1)*x3337+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)+ ///
	   (x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1)+(x3415==1)*x3418*(x3418!=-1)	   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSP= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)
	   
gen profitS= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OCratio + ///
	   (x3419==1)*x3422*(x3422!=-1) ///
	   
gen profitOT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OTratio + ///
	   (x3427==1)*x3430*(x3430!=-1)		   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)

gen profitSCAT= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*0.7+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)	 
	  	  
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSPAT= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)

gen profitSAT= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen profitOCAT= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OCratio*0.7 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OTratio*0.7 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*0.7*0.6+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7*0.6+ ///
         x3132*(x3119==3)*(x3128/10000)*(x3128>0)*0.8*(x3132!=-1)+ ///
	   x3232*(x3219==3)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
	   x3332*(x3319==3)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3415==1)*x3418*0.8*(x3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3407==1)*x3410*(x3410!=-1)*0.8+(x3411==1)*x3414*(x3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	    (x3423==1)*x3426*(x3426!=-1)*0.8

gen profitSATRE= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)*0.8+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)*0.8+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)*0.8+ ///
	   (x3415==1)*x3418*(x3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OCratio*0.7*0.6 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OTratio*0.7*0.6 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	
	rename (x*) (X*)
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X1930 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_stats_type.dta", replace
save "`out'/wealth_wip_stats_type.dta", replace

}

**********************************
************** 1992 **************
**********************************

foreach num1 of numlist 92(1)92 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p`num1'i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp19`num1'.dta", nogen 

gen year=19`num1'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen type=0
replace type=1 if (x3119==1|x3119==11|x3119==12)
replace type=2 if (x3119==2)
replace type=3 if (x3119==3)
replace type=4 if (x3119==4|x3119==6)
replace type=5 if (x3119==-7|x3119==40)

table x4106 x3119 if x3104==1 [aw=wgt]

gen no_pay="yes" if x4112==-1
replace no_pay="no" if no_pay!="yes"
 
table x4106 if x3104==1 [aw=wgt]
table x4706 if x3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
         + (x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0 
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=x4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=x4`num'11 if x4`num'13==2 
* just keep the weeks worked
replace per`num'=x4`num'11/2 if x4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=x4`num'11/4 if x4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=x4`num'11/(4*3) if x4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if x4`num'13==6 
* annnual
replace per`num'=1 if x4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=x4`num'11 if x4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=x4`num'11*x4`num'10/8 if (x4`num'13==1 & x8021==1) 
replace per`num'=x4`num'11*x4`num'10/7 if (x4`num'13==1 & x8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=x4`num'11/(4*2) if x4`num'13==12
* bimonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if x4`num'13==14
* by the piece, by the job
replace per`num'=x4`num'11*x4`num'10 if x4`num'13==18
* by hour 
}

* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*x4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*x4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & paid_wage_dummy_`num'==1
count if x4`num'11==0 & paid_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if x4`num'06==1 & x4`num'12>0
gen paid_wage_`num'=per`num'*x4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*x4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & no_wage_dummy_`num'==1
count if x4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}

generate ageR=x14
generate ageS=x19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(x8021==1)
generate genderdummy_S=(x103==1)

gen hsdummy_R=((x5902==1 & x5904==5)+(x5901>12 & x5904==5)) 
gen hsdummy_S=((x6102==1 & x6104==5)+(x6101>12 & x6104==5))

generate cdummy_R=(x5904==1)
generate cdummy_S=(x6104==1)

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_`num1'_new_regress", replace
}

foreach num of numlist 92/92 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_`num1'_new_regress"
gen implicat = mod(y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}

foreach num of numlist 92/92 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_`num'_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}

foreach num2 of numlist 92/92 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_`num2'_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.

* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort y1 yy1
save "`in'/labour_regression_results`num1'", replace
}
}

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort y1 yy1
merge y1 yy1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort y1 yy1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 92(1)92 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp19`num'.dta", nogen 

sort y1 yy1

merge y1 yy1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

gen year=19`num'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen PP3=0 
replace PP3=1 if (x3319==1 | x3319==2 | x3319==11 | x3319==12)
replace PP3=2 if (x3319==3 | x3319==4 | x3319==6 | x3319==40 | x3319==-7)

gen PP2=0 
replace PP2=1 if (x3219==1 | x3219==2 | x3219==11 | x3219==12)
replace PP2=2 if (x3219==3 | x3219==4 | x3219==6 | x3219==40 | x3219==-7)

egen sumPP3PPwgt=sum((PP3==1)*wgt)
egen sumPP3SCwgt=sum((PP3==2)*wgt)
gen sumPP3wgt=sumPP3PPwgt+sumPP3SCwgt
gen PP3PPshare=sumPP3PPwgt/sumPP3wgt
gen PP3SCshare=sumPP3SCwgt/sumPP3wgt

egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)+(x3415==1)+(x3419==1)+(x3427==1)))
egen naPPwgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)))
egen naSCwgtsum=sum(wgt*((x3415==1)+(x3419==1)+(x3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+sumPP3wgt+nawgtsum)

gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt+sumPP3wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)3{
	egen sumPP`x'PTwgt = sum(((x3`x'19==1) + (x3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((x3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((x3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((x3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt + sumPP3PTwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt + sumPP3SPwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt + sumPP3Swgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt + sumPP3OCwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

gen SCorpratio = wgtdSshare/(wgtdOCshare + wgtdSshare)
gen OCorpratio = wgtdOCshare/(wgtdOCshare + wgtdSshare)

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==3) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==3) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==3) ///
                    +(x3335>0)*x3335*(x3119==3)+ farmbus*(x3119==3)+ ///
                    (x3416>0)*x3416), by(y1)
					
egen BUScheckSP=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==2) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==2) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==2) ///
                   +(x3335>0)*x3335*(x3119==2) + farmbus*(x3119==2)+ ///
                    (x3424>0)*x3424), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==-7) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==-7) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==-7) ///
                    +(x3335>0)*x3335*(x3119==-7) + farmbus*(x3119==-7)+ ///
                    (x3428>0)*x3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         x3132*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3337!=-1)*x3337+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)+ ///
	   (x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1)+(x3415==1)*x3418*(x3418!=-1)	   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSP= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)
	   
gen profitS= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OCratio + ///
	   (x3419==1)*x3422*(x3422!=-1) ///
	   
gen profitOT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OTratio + ///
	   (x3427==1)*x3430*(x3430!=-1)		   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)

gen profitSCAT= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*0.7+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)	 
	  	  
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSPAT= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)

gen profitSAT= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen profitOCAT= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OCratio*0.7 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OTratio*0.7 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*0.7*0.6+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7*0.6+ ///
         x3132*(x3119==3)*(x3128/10000)*(x3128>0)*0.8*(x3132!=-1)+ ///
	   x3232*(x3219==3)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
	   x3332*(x3319==3)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3415==1)*x3418*0.8*(x3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3407==1)*x3410*(x3410!=-1)*0.8+(x3411==1)*x3414*(x3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	    (x3423==1)*x3426*(x3426!=-1)*0.8

gen profitSATRE= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)*0.8+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)*0.8+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)*0.8+ ///
	   (x3415==1)*x3418*(x3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OCratio*0.7*0.6 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OTratio*0.7*0.6 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	
	rename (x*) (X*)
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X1930 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}

**********************************
************** 1995 **************
**********************************

foreach num1 of numlist 95(1)95 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p`num1'i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp19`num1'.dta", nogen 

gen year=19`num1'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen type=0
replace type=1 if (x3119==1|x3119==11|x3119==12)
replace type=2 if (x3119==2)
replace type=3 if (x3119==3)
replace type=4 if (x3119==4|x3119==6)
replace type=5 if (x3119==-7|x3119==40)

table x4106 x3119 if x3104==1 [aw=wgt]

gen no_pay="yes" if x4112==-1
replace no_pay="no" if no_pay!="yes"
 
table x4106 if x3104==1 [aw=wgt]
table x4706 if x3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
         + (x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0 
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=x4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=x4`num'11 if x4`num'13==2 
* just keep the weeks worked
replace per`num'=x4`num'11/2 if x4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=x4`num'11/4 if x4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=x4`num'11/(4*3) if x4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if x4`num'13==6 
* annnual
replace per`num'=1 if x4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=x4`num'11 if x4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=x4`num'11*x4`num'10/8 if (x4`num'13==1 & x8021==1) 
replace per`num'=x4`num'11*x4`num'10/7 if (x4`num'13==1 & x8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=x4`num'11/(4*2) if x4`num'13==12
* bimonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if x4`num'13==14
* by the piece, by the job
replace per`num'=x4`num'11*x4`num'10 if x4`num'13==18
* by hour 
}

* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*x4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*x4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & paid_wage_dummy_`num'==1
count if x4`num'11==0 & paid_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if x4`num'06==1 & x4`num'12>0
gen paid_wage_`num'=per`num'*x4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*x4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & no_wage_dummy_`num'==1
count if x4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}

generate ageR=x14
generate ageS=x19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(x8021==1)
generate genderdummy_S=(x103==1)

gen hsdummy_R=((x5902==1 & x5904==5)+(x5901>12 & x5904==5)) 
gen hsdummy_S=((x6102==1 & x6104==5)+(x6101>12 & x6104==5))

generate cdummy_R=(x5904==1)
generate cdummy_S=(x6104==1)

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_`num1'_new_regress", replace
}

foreach num of numlist 95/95 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_`num1'_new_regress"
gen implicat = mod(y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}

foreach num of numlist 95/95 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_`num'_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}

foreach num2 of numlist 95/95 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_`num2'_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.

* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort y1 yy1
save "`in'/labour_regression_results`num1'", replace
}
}

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort y1 yy1
merge y1 yy1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot

sort y1 yy1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 95(1)95 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp19`num'.dta", nogen 

sort y1 yy1

merge y1 yy1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

gen year=19`num'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen PP3=0 
replace PP3=1 if (x3319==1 | x3319==2 | x3319==11 | x3319==12)
replace PP3=2 if (x3319==3 | x3319==4 | x3319==6 | x3319==40 | x3319==-7)

gen PP2=0 
replace PP2=1 if (x3219==1 | x3219==2 | x3219==11 | x3219==12)
replace PP2=2 if (x3219==3 | x3219==4 | x3219==6 | x3219==40 | x3219==-7)

egen sumPP3PPwgt=sum((PP3==1)*wgt)
egen sumPP3SCwgt=sum((PP3==2)*wgt)
gen sumPP3wgt=sumPP3PPwgt+sumPP3SCwgt
gen PP3PPshare=sumPP3PPwgt/sumPP3wgt
gen PP3SCshare=sumPP3SCwgt/sumPP3wgt

egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)+(x3415==1)+(x3419==1)+(x3427==1)))
egen naPPwgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)))
egen naSCwgtsum=sum(wgt*((x3415==1)+(x3419==1)+(x3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+sumPP3wgt+nawgtsum)

gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt+sumPP3wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)3{
	egen sumPP`x'PTwgt = sum(((x3`x'19==1) + (x3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((x3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((x3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((x3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt + sumPP3PTwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt + sumPP3SPwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt + sumPP3Swgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt + sumPP3OCwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

gen SCorpratio = wgtdSshare/(wgtdOCshare + wgtdSshare)
gen OCorpratio = wgtdOCshare/(wgtdOCshare + wgtdSshare)

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==3) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==3) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==3) ///
                    +(x3335>0)*x3335*(x3119==3)+ farmbus*(x3119==3)+ ///
                    (x3416>0)*x3416), by(y1)
					
egen BUScheckSP=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==2) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==2) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==2) ///
                   +(x3335>0)*x3335*(x3119==2) + farmbus*(x3119==2)+ ///
                    (x3424>0)*x3424), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==-7) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==-7) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==-7) ///
                    +(x3335>0)*x3335*(x3119==-7) + farmbus*(x3119==-7)+ ///
                    (x3428>0)*x3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         x3132*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3337!=-1)*x3337+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)+ ///
	   (x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1)+(x3415==1)*x3418*(x3418!=-1)	   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSP= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)
	   
gen profitS= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OCratio + ///
	   (x3419==1)*x3422*(x3422!=-1) ///
	   
gen profitOT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OTratio + ///
	   (x3427==1)*x3430*(x3430!=-1)		   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)

gen profitSCAT= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*0.7+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)	 
	  	  
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSPAT= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)

gen profitSAT= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen profitOCAT= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OCratio*0.7 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OTratio*0.7 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*0.7*0.6+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7*0.6+ ///
         x3132*(x3119==3)*(x3128/10000)*(x3128>0)*0.8*(x3132!=-1)+ ///
	   x3232*(x3219==3)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
	   x3332*(x3319==3)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3415==1)*x3418*0.8*(x3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3407==1)*x3410*(x3410!=-1)*0.8+(x3411==1)*x3414*(x3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	    (x3423==1)*x3426*(x3426!=-1)*0.8

gen profitSATRE= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)*0.8+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)*0.8+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)*0.8+ ///
	   (x3415==1)*x3418*(x3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OCratio*0.7*0.6 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OTratio*0.7*0.6 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	
	rename (x*) (X*)	
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X1930 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}

**********************************
************** 1998 **************
**********************************

foreach num1 of numlist 98(1)98 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p`num1'i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp19`num1'.dta", nogen 

gen year=19`num1'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen type=0
replace type=1 if (x3119==1|x3119==11|x3119==12)
replace type=2 if (x3119==2)
replace type=3 if (x3119==3)
replace type=4 if (x3119==4|x3119==6)
replace type=5 if (x3119==-7|x3119==40)

table x4106 x3119 if x3104==1 [aw=wgt]

gen no_pay="yes" if x4112==-1
replace no_pay="no" if no_pay!="yes"
 
table x4106 if x3104==1 [aw=wgt]
table x4706 if x3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
         + (x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0 
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=x4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=x4`num'11 if x4`num'13==2 
* just keep the weeks worked
replace per`num'=x4`num'11/2 if x4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=x4`num'11/4 if x4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=x4`num'11/(4*3) if x4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if x4`num'13==6 
* annnual
replace per`num'=1 if x4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=x4`num'11 if x4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=x4`num'11*x4`num'10/8 if (x4`num'13==1 & x8021==1) 
replace per`num'=x4`num'11*x4`num'10/7 if (x4`num'13==1 & x8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=x4`num'11/(4*2) if x4`num'13==12
* bimonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if x4`num'13==14
* by the piece, by the job
replace per`num'=x4`num'11*x4`num'10 if x4`num'13==18
* by hour 
}

* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*x4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*x4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & paid_wage_dummy_`num'==1
count if x4`num'11==0 & paid_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if x4`num'06==1 & x4`num'12>0
gen paid_wage_`num'=per`num'*x4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*x4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & no_wage_dummy_`num'==1
count if x4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}

generate ageR=x14
generate ageS=x19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(x8021==1)
generate genderdummy_S=(x103==1)

gen hsdummy_R=((x5902==1 & x5904==5)+(x5901>12 & x5904==5)) 
gen hsdummy_S=((x6102==1 & x6104==5)+(x6101>12 & x6104==5))

generate cdummy_R=(x5904==1)
generate cdummy_S=(x6104==1)

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_`num1'_new_regress", replace
}

foreach num of numlist 98/98 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_`num1'_new_regress"
gen implicat = mod(y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}

foreach num of numlist 98/98 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_`num'_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}

foreach num2 of numlist 98/98 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_`num2'_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.

* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort y1 yy1
save "`in'/labour_regression_results`num1'", replace
}
}

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort y1 yy1
merge y1 yy1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort y1 yy1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 98(1)98 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p`num'i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp19`num'.dta", nogen 

sort y1 yy1

merge y1 yy1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

gen year=19`num'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen PP3=0 
replace PP3=1 if (x3319==1 | x3319==2 | x3319==11 | x3319==12)
replace PP3=2 if (x3319==3 | x3319==4 | x3319==6 | x3319==40 | x3319==-7)

gen PP2=0 
replace PP2=1 if (x3219==1 | x3219==2 | x3219==11 | x3219==12)
replace PP2=2 if (x3219==3 | x3219==4 | x3219==6 | x3219==40 | x3219==-7)

egen sumPP3PPwgt=sum((PP3==1)*wgt)
egen sumPP3SCwgt=sum((PP3==2)*wgt)
gen sumPP3wgt=sumPP3PPwgt+sumPP3SCwgt
gen PP3PPshare=sumPP3PPwgt/sumPP3wgt
gen PP3SCshare=sumPP3SCwgt/sumPP3wgt

egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)+(x3415==1)+(x3419==1)+(x3427==1)))
egen naPPwgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)))
egen naSCwgtsum=sum(wgt*((x3415==1)+(x3419==1)+(x3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+sumPP3wgt+nawgtsum)

gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt+sumPP3wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)3{
	egen sumPP`x'PTwgt = sum(((x3`x'19==1) + (x3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((x3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((x3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((x3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt + sumPP3PTwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt + sumPP3SPwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt + sumPP3Swgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt + sumPP3OCwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

gen SCorpratio = wgtdSshare/(wgtdOCshare + wgtdSshare)
gen OCorpratio = wgtdOCshare/(wgtdOCshare + wgtdSshare)

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==3) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==3) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==3) ///
                    +(x3335>0)*x3335*(x3119==3)+ farmbus*(x3119==3)+ ///
                    (x3416>0)*x3416), by(y1)
					
egen BUScheckSP=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==2) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==2) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==2) ///
                   +(x3335>0)*x3335*(x3119==2) + farmbus*(x3119==2)+ ///
                    (x3424>0)*x3424), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==-7) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==-7) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==-7) ///
                    +(x3335>0)*x3335*(x3119==-7) + farmbus*(x3119==-7)+ ///
                    (x3428>0)*x3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         x3132*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3337!=-1)*x3337+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)+ ///
	   (x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1)+(x3415==1)*x3418*(x3418!=-1)	   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSP= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)
	   
gen profitS= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OCratio + ///
	   (x3419==1)*x3422*(x3422!=-1) ///
	   
gen profitOT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OTratio + ///
	   (x3427==1)*x3430*(x3430!=-1)		   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)

gen profitSCAT= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*0.7+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)	 
	  	  
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSPAT= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)

gen profitSAT= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen profitOCAT= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OCratio*0.7 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OTratio*0.7 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*0.7*0.6+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7*0.6+ ///
         x3132*(x3119==3)*(x3128/10000)*(x3128>0)*0.8*(x3132!=-1)+ ///
	   x3232*(x3219==3)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
	   x3332*(x3319==3)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3415==1)*x3418*0.8*(x3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3407==1)*x3410*(x3410!=-1)*0.8+(x3411==1)*x3414*(x3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	    (x3423==1)*x3426*(x3426!=-1)*0.8

gen profitSATRE= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)*0.8+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)*0.8+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)*0.8+ ///
	   (x3415==1)*x3418*(x3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OCratio*0.7*0.6 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OTratio*0.7*0.6 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	
	rename (x*) (X*)	
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X1930 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}

**********************************
************** 2001 **************
**********************************

foreach num1 of numlist 2001(1)2001 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p01i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp2001.dta", nogen 

gen year=2001

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen type=0
replace type=1 if (x3119==1|x3119==11|x3119==12)
replace type=2 if (x3119==2)
replace type=3 if (x3119==3)
replace type=4 if (x3119==4|x3119==6)
replace type=5 if (x3119==-7|x3119==40)

table x4106 x3119 if x3104==1 [aw=wgt]

gen no_pay="yes" if x4112==-1
replace no_pay="no" if no_pay!="yes"
 
table x4106 if x3104==1 [aw=wgt]
table x4706 if x3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
         + (x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0 
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=x4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=x4`num'11 if x4`num'13==2 
* just keep the weeks worked
replace per`num'=x4`num'11/2 if x4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=x4`num'11/4 if x4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=x4`num'11/(4*3) if x4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if x4`num'13==6 
* annnual
replace per`num'=1 if x4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=x4`num'11 if x4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=x4`num'11*x4`num'10/8 if (x4`num'13==1 & x8021==1) 
replace per`num'=x4`num'11*x4`num'10/7 if (x4`num'13==1 & x8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=x4`num'11/(4*2) if x4`num'13==12
* bimonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if x4`num'13==14
* by the piece, by the job
replace per`num'=x4`num'11*x4`num'10 if x4`num'13==18
* by hour 
}

* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*x4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*x4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & paid_wage_dummy_`num'==1
count if x4`num'11==0 & paid_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if x4`num'06==1 & x4`num'12>0
gen paid_wage_`num'=per`num'*x4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*x4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & no_wage_dummy_`num'==1
count if x4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}

generate ageR=x14
generate ageS=x19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(x8021==1)
generate genderdummy_S=(x103==1)

gen hsdummy_R=((x5902==1 & x5904==5)+(x5901>12 & x5904==5)) 
gen hsdummy_S=((x6102==1 & x6104==5)+(x6101>12 & x6104==5))

generate cdummy_R=(x5904==1)
generate cdummy_S=(x6104==1)

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_01_new_regress", replace
}

foreach num of numlist 2001/2001 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_01_new_regress"
gen implicat = mod(y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}

foreach num of numlist 2001/2001 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_01_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}

foreach num2 of numlist 2001/2001 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_01_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.

* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

sort y1 yy1
save "`in'/labour_regression_results`num1'", replace
}
}

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort y1 yy1
merge y1 yy1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort y1 yy1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 2001(1)2001 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p01i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp`num'.dta", nogen 

sort y1 yy1

merge y1 yy1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

gen year=`num'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen PP3=0 
replace PP3=1 if (x3319==1 | x3319==2 | x3319==11 | x3319==12)
replace PP3=2 if (x3319==3 | x3319==4 | x3319==6 | x3319==40 | x3319==-7)

gen PP2=0 
replace PP2=1 if (x3219==1 | x3219==2 | x3219==11 | x3219==12)
replace PP2=2 if (x3219==3 | x3219==4 | x3219==6 | x3219==40 | x3219==-7)

egen sumPP3PPwgt=sum((PP3==1)*wgt)
egen sumPP3SCwgt=sum((PP3==2)*wgt)
gen sumPP3wgt=sumPP3PPwgt+sumPP3SCwgt
gen PP3PPshare=sumPP3PPwgt/sumPP3wgt
gen PP3SCshare=sumPP3SCwgt/sumPP3wgt

egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)+(x3415==1)+(x3419==1)+(x3427==1)))
egen naPPwgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)))
egen naSCwgtsum=sum(wgt*((x3415==1)+(x3419==1)+(x3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+sumPP3wgt+nawgtsum)

gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt+sumPP3wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)3{
	egen sumPP`x'PTwgt = sum(((x3`x'19==1) + (x3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((x3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((x3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((x3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt + sumPP3PTwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt + sumPP3SPwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt + sumPP3Swgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt + sumPP3OCwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

gen SCorpratio = wgtdSshare/(wgtdOCshare + wgtdSshare)
gen OCorpratio = wgtdOCshare/(wgtdOCshare + wgtdSshare)

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==3) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==3) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==3) ///
                    +(x3335>0)*x3335*(x3119==3)+ farmbus*(x3119==3)+ ///
                    (x3416>0)*x3416), by(y1)
					
egen BUScheckSP=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==2) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==2) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==2) ///
                   +(x3335>0)*x3335*(x3119==2) + farmbus*(x3119==2)+ ///
                    (x3424>0)*x3424), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==-7) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==-7) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==-7) ///
                    +(x3335>0)*x3335*(x3119==-7) + farmbus*(x3119==-7)+ ///
                    (x3428>0)*x3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         x3132*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3337!=-1)*x3337+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)+ ///
	   (x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1)+(x3415==1)*x3418*(x3418!=-1)	   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSP= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)
	   
gen profitS= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OCratio + ///
	   (x3419==1)*x3422*(x3422!=-1) ///
	   
gen profitOT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OTratio + ///
	   (x3427==1)*x3430*(x3430!=-1)		   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)

gen profitSCAT= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*0.7+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)	 
	  	  
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSPAT= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)

gen profitSAT= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen profitOCAT= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OCratio*0.7 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OTratio*0.7 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*0.7*0.6+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7*0.6+ ///
         x3132*(x3119==3)*(x3128/10000)*(x3128>0)*0.8*(x3132!=-1)+ ///
	   x3232*(x3219==3)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
	   x3332*(x3319==3)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3415==1)*x3418*0.8*(x3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3407==1)*x3410*(x3410!=-1)*0.8+(x3411==1)*x3414*(x3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	    (x3423==1)*x3426*(x3426!=-1)*0.8

gen profitSATRE= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)*0.8+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)*0.8+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)*0.8+ ///
	   (x3415==1)*x3418*(x3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OCratio*0.7*0.6 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OTratio*0.7*0.6 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	
	rename (x*) (X*)	
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X1930 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}

**********************************
************** 2004 **************
**********************************

foreach num1 of numlist 2004(1)2004 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p04i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp2004.dta", nogen 

gen year=2004

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen type=0
replace type=1 if (x3119==1|x3119==11|x3119==12)
replace type=2 if (x3119==2)
replace type=3 if (x3119==3)
replace type=4 if (x3119==4|x3119==6)
replace type=5 if (x3119==-7|x3119==40)

table x4106 x3119 if x3104==1 [aw=wgt]

gen no_pay="yes" if x4112==-1
replace no_pay="no" if no_pay!="yes"
 
table x4106 if x3104==1 [aw=wgt]
table x4706 if x3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
         + (x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0 
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=x4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=x4`num'11 if x4`num'13==2 
* just keep the weeks worked
replace per`num'=x4`num'11/2 if x4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=x4`num'11/4 if x4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=x4`num'11/(4*3) if x4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if x4`num'13==6 
* annnual
replace per`num'=1 if x4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=x4`num'11 if x4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=x4`num'11*x4`num'10/8 if (x4`num'13==1 & x8021==1) 
replace per`num'=x4`num'11*x4`num'10/7 if (x4`num'13==1 & x8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=x4`num'11/(4*2) if x4`num'13==12
* bimonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if x4`num'13==14
* by the piece, by the job
replace per`num'=x4`num'11*x4`num'10 if x4`num'13==18
* by hour 
}

* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*x4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*x4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & paid_wage_dummy_`num'==1
count if x4`num'11==0 & paid_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if x4`num'06==1 & x4`num'12>0
gen paid_wage_`num'=per`num'*x4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*x4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & no_wage_dummy_`num'==1
count if x4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}

generate ageR=x14
generate ageS=x19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(x8021==1)
generate genderdummy_S=(x103==1)

gen hsdummy_R=((x5902==1 & x5904==5)+(x5901>12 & x5904==5)) 
gen hsdummy_S=((x6102==1 & x6104==5)+(x6101>12 & x6104==5))

generate cdummy_R=(x5904==1)
generate cdummy_S=(x6104==1)

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_04_new_regress", replace
}

foreach num of numlist 2004/2004 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_04_new_regress"
gen implicat = mod(y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}

foreach num of numlist 2004/2004 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_04_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}

foreach num2 of numlist 2004/2004 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_04_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.

* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort y1 yy1
save "`in'/labour_regression_results`num1'", replace
}
}

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort y1 yy1
merge y1 yy1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort y1 yy1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 2004(1)2004 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p04i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp`num'.dta", nogen 

sort y1 yy1

merge y1 yy1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

gen year=`num'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen PP3=0 
replace PP3=1 if (x3319==1 | x3319==2 | x3319==11 | x3319==12)
replace PP3=2 if (x3319==3 | x3319==4 | x3319==6 | x3319==40 | x3319==-7)

gen PP2=0 
replace PP2=1 if (x3219==1 | x3219==2 | x3219==11 | x3219==12)
replace PP2=2 if (x3219==3 | x3219==4 | x3219==6 | x3219==40 | x3219==-7)

egen sumPP3PPwgt=sum((PP3==1)*wgt)
egen sumPP3SCwgt=sum((PP3==2)*wgt)
gen sumPP3wgt=sumPP3PPwgt+sumPP3SCwgt
gen PP3PPshare=sumPP3PPwgt/sumPP3wgt
gen PP3SCshare=sumPP3SCwgt/sumPP3wgt

egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)+(x3415==1)+(x3419==1)+(x3427==1)))
egen naPPwgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)))
egen naSCwgtsum=sum(wgt*((x3415==1)+(x3419==1)+(x3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+sumPP3wgt+nawgtsum)

gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt+sumPP3wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)3{
	egen sumPP`x'PTwgt = sum(((x3`x'19==1) + (x3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((x3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((x3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((x3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt + sumPP3PTwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt + sumPP3SPwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt + sumPP3Swgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt + sumPP3OCwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

gen SCorpratio = wgtdSshare/(wgtdOCshare + wgtdSshare)
gen OCorpratio = wgtdOCshare/(wgtdOCshare + wgtdSshare)

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==3) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==3) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==3) ///
                    +(x3335>0)*x3335*(x3119==3)+ farmbus*(x3119==3)+ ///
                    (x3416>0)*x3416), by(y1)
					
egen BUScheckSP=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==2) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==2) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==2) ///
                   +(x3335>0)*x3335*(x3119==2) + farmbus*(x3119==2)+ ///
                    (x3424>0)*x3424), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==-7) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==-7) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==-7) ///
                    +(x3335>0)*x3335*(x3119==-7) + farmbus*(x3119==-7)+ ///
                    (x3428>0)*x3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         x3132*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3337!=-1)*x3337+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)+ ///
	   (x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1)+(x3415==1)*x3418*(x3418!=-1)	   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSP= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)
	   
gen profitS= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OCratio + ///
	   (x3419==1)*x3422*(x3422!=-1) ///
	   
gen profitOT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OTratio + ///
	   (x3427==1)*x3430*(x3430!=-1)		   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)

gen profitSCAT= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*0.7+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)	 
	  	  
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSPAT= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)

gen profitSAT= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen profitOCAT= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OCratio*0.7 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OTratio*0.7 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*0.7*0.6+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7*0.6+ ///
         x3132*(x3119==3)*(x3128/10000)*(x3128>0)*0.8*(x3132!=-1)+ ///
	   x3232*(x3219==3)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
	   x3332*(x3319==3)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3415==1)*x3418*0.8*(x3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3407==1)*x3410*(x3410!=-1)*0.8+(x3411==1)*x3414*(x3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	    (x3423==1)*x3426*(x3426!=-1)*0.8

gen profitSATRE= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)*0.8+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)*0.8+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)*0.8+ ///
	   (x3415==1)*x3418*(x3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OCratio*0.7*0.6 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OTratio*0.7*0.6 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	
	rename (x*) (X*)	
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X1930 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}

**********************************
************** 2007 **************
**********************************

foreach num1 of numlist 2007(1)2007 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p07i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp2007.dta", nogen 

gen year=2007

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen type=0
replace type=1 if (x3119==1|x3119==11|x3119==12)
replace type=2 if (x3119==2)
replace type=3 if (x3119==3)
replace type=4 if (x3119==4|x3119==6)
replace type=5 if (x3119==-7|x3119==40)

table x4106 x3119 if x3104==1 [aw=wgt]

gen no_pay="yes" if x4112==-1
replace no_pay="no" if no_pay!="yes"
 
table x4106 if x3104==1 [aw=wgt]
table x4706 if x3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
         + (x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0 
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0

replace no_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==1 & x4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if x4`num'06==2 & x3104==1 & x4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}


* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=x4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=x4`num'11 if x4`num'13==2 
* just keep the weeks worked
replace per`num'=x4`num'11/2 if x4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=x4`num'11/4 if x4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=x4`num'11/(4*3) if x4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if x4`num'13==6 
* annnual
replace per`num'=1 if x4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=x4`num'11 if x4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=x4`num'11*x4`num'10/8 if (x4`num'13==1 & x8021==1) 
replace per`num'=x4`num'11*x4`num'10/7 if (x4`num'13==1 & x8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=x4`num'11/(4*2) if x4`num'13==12
* bimonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if x4`num'13==14
* by the piece, by the job
replace per`num'=x4`num'11*x4`num'10 if x4`num'13==18
* by hour 
}

* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*x4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*x4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*x4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & paid_wage_dummy_`num'==1
count if x4`num'11==0 & paid_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if x4`num'06==1 & x4`num'12>0
gen paid_wage_`num'=per`num'*x4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*x4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if x4`num'11==-1 & no_wage_dummy_`num'==1
count if x4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}

generate ageR=x14
generate ageS=x19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(x8021==1)
generate genderdummy_S=(x103==1)

gen hsdummy_R=((x5902==1 & x5904==5)+(x5901>12 & x5904==5)) 
gen hsdummy_S=((x6102==1 & x6104==5)+(x6101>12 & x6104==5))

generate cdummy_R=(x5904==1)
generate cdummy_S=(x6104==1)

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_07_new_regress", replace
}

foreach num of numlist 2007/2007 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_07_new_regress"
gen implicat = mod(y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}

foreach num of numlist 2007/2007 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_07_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}

foreach num2 of numlist 2007/2007 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_07_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.

* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*x4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort y1 yy1
save "`in'/labour_regression_results`num1'", replace
}
}

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort y1 yy1
merge y1 yy1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort y1 yy1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 2007(1)2007 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p07i6", clear
rename X* x*
rename Y1 y1 

merge 1:1 y1 using "`in'/rscfp`num'.dta", nogen 

sort y1 yy1

merge y1 yy1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

gen year=`num'

gen PP1=0 
replace PP1=1 if (x3119==1 | x3119==2 | x3119==11 | x3119==12)
replace PP1=2 if (x3119==3 | x3119==4 | x3119==6 | x3119==40 | x3119==-7)

gen PP3=0 
replace PP3=1 if (x3319==1 | x3319==2 | x3319==11 | x3319==12)
replace PP3=2 if (x3319==3 | x3319==4 | x3319==6 | x3319==40 | x3319==-7)

gen PP2=0 
replace PP2=1 if (x3219==1 | x3219==2 | x3219==11 | x3219==12)
replace PP2=2 if (x3219==3 | x3219==4 | x3219==6 | x3219==40 | x3219==-7)

egen sumPP3PPwgt=sum((PP3==1)*wgt)
egen sumPP3SCwgt=sum((PP3==2)*wgt)
gen sumPP3wgt=sumPP3PPwgt+sumPP3SCwgt
gen PP3PPshare=sumPP3PPwgt/sumPP3wgt
gen PP3SCshare=sumPP3SCwgt/sumPP3wgt

egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)+(x3415==1)+(x3419==1)+(x3427==1)))
egen naPPwgtsum=sum(wgt*((x3407==1)+(x3411==1)+(x3423==1)))
egen naSCwgtsum=sum(wgt*((x3415==1)+(x3419==1)+(x3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+sumPP3wgt+nawgtsum)

gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt+sumPP3PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt+sumPP3wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)3{
	egen sumPP`x'PTwgt = sum(((x3`x'19==1) + (x3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((x3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((x3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((x3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt + sumPP3PTwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt + sumPP3SPwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt + sumPP3Swgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt + sumPP3OCwgt)/(sumPP1wgt+sumPP2wgt+sumPP3wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist x* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

gen SCorpratio = wgtdSshare/(wgtdOCshare + wgtdSshare)
gen OCorpratio = wgtdOCshare/(wgtdOCshare + wgtdSshare)

egen BUScheck=sum(0 ///
          + ((x3129>0)*x3129+(x3124>0)*x3124 - (x3127==5)*(x3126>0)*x3126) + ((x3229>0)*x3229+(x3224>0)*x3224 - ///
      (x3227==5)*(x3226>0)*x3226)+ ((x3329>0)*x3329+(x3324>0)*x3324 - (x3327==5)*(x3326>0)*x3326) ///
                     +(x3335>0)*x3335+ farmbus+ (x3408>0)*x3408 ///
                     + (x3412>0)*x3412+(x3416>0)*x3416+(x3420>0)*x3420 ///
                     + (x3424>0)*x3424+(x3428>0)*x3428), by(y1)

** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==3) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==3) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==3) ///
                    +(x3335>0)*x3335*(x3119==3)+ farmbus*(x3119==3)+ ///
                    (x3416>0)*x3416), by(y1)
					
egen BUScheckSP=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==2) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==2) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==2) ///
                   +(x3335>0)*x3335*(x3119==2) + farmbus*(x3119==2)+ ///
                    (x3424>0)*x3424), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==4) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==4) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==4) ///
                    +(x3335>0)*x3335*(x3119==4)+ farmbus*(x3119==4)+ ///
                    (x3420>0)*x3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((x3129>0)*x3129+(x3124>0)*x3124 ///
      -(x3127==5)*(x3126>0)*x3126)*(x3119==-7) ///
         + ((x3229>0)*x3229+(x3224>0)*x3224 ///
      -(x3227==5)*(x3226>0)*x3226)*(x3219==-7) ///
         + ((x3329>0)*x3329+(x3324>0)*x3324 ///
      -(x3327==5)*(x3326>0)*x3326)*(x3319==-7) ///
                    +(x3335>0)*x3335*(x3119==-7) + farmbus*(x3119==-7)+ ///
                    (x3428>0)*x3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         x3132*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3337!=-1)*x3337+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)+ ///
	   (x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1)+(x3415==1)*x3418*(x3418!=-1)	   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSP= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)
	   
gen profitS= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OCratio + ///
	   (x3419==1)*x3422*(x3422!=-1) ///
	   
gen profitOT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))+ ///
	   (x3337!=-1)*x3337*OTratio + ///
	   (x3427==1)*x3430*(x3430!=-1)		   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1)

gen profitSCAT= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*0.7+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)	 
	  	  
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)

gen profitSPAT= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	    (x3423==1)*x3426*(x3426!=-1)

gen profitSAT= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)+ ///
	   (x3415==1)*x3418*(x3418!=-1)
	   
gen profitOCAT= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OCratio*0.7 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7+ ///
	   (x3337!=-1)*x3337*OTratio*0.7 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (x3132*((x3119==4)+(x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==4)+(x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==4)+(x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*0.7*0.6+ ///
	   ((x3419==1)*x3422*(x3422!=-1)+(x3427==1)*x3430*(x3430!=-1))*0.7*0.6+ ///
         x3132*(x3119==3)*(x3128/10000)*(x3128>0)*0.8*(x3132!=-1)+ ///
	   x3232*(x3219==3)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
	   x3332*(x3319==3)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3415==1)*x3418*0.8*(x3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         x3132*(PP1==1)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
         x3232*(PP2==1)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
         x3332*(PP3==1)*(x3328/10000)*(x3328>0)*(x3332!=-1)+ ///
	   (x3407==1)*x3410*(x3410!=-1)+(x3411==1)*x3414*(x3414!=-1)+(x3423==1)*x3426*(x3426!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         x3132*((x3119==1)+(x3119==11))*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*((x3219==1)+(x3219==11))*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*((x3319==1)+(x3319==11))*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	   (x3407==1)*x3410*(x3410!=-1)*0.8+(x3411==1)*x3414*(x3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         x3132*(x3119==2)*(x3128/10000)*(x3128>0)*(x3132!=-1)*0.8+ ///
         x3232*(x3219==2)*(x3228/10000)*(x3228>0)*(x3232!=-1)*0.8+ ///
         x3332*(x3319==2)*(x3328/10000)*(x3328>0)*(x3332!=-1)*0.8+ ///
	    (x3423==1)*x3426*(x3426!=-1)*0.8

gen profitSATRE= 0+ ///
         x3132*(x3119==3)*(x3132!=-1)*(x3128/10000)*(x3128>0)*0.8+ ///
	   x3232*(x3219==3)*(x3232!=-1)*(x3228/10000)*(x3228>0)*0.8+ ///
	   x3332*(x3319==3)*(x3332!=-1)*(x3328/10000)*(x3328>0)*0.8+ ///
	   (x3415==1)*x3418*(x3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (x3132*(x3119==4)*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*(x3219==4)*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*(x3319==4)*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OCratio*0.7*0.6 + ///
	   (x3419==1)*x3422*(x3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (x3132*((x3119==6)+(x3119==40)+(x3119==-7))*(x3128/10000)*(x3128>0)*(x3132!=-1)+ ///
	   x3232*((x3219==6)+(x3219==40)+(x3219==-7))*(x3228/10000)*(x3228>0)*(x3232!=-1)+ ///
	   x3332*((x3319==6)+(x3319==40)+(x3319==-7))*(x3328/10000)*(x3328>0)*(x3332!=-1))*0.7*0.6+ ///
	   (x3337!=-1)*x3337*OTratio*0.7*0.6 + ///
	   (x3427==1)*x3430*(x3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	
	rename (x*) (X*)	
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X1930 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}


**********************************
************** 2010 **************
**********************************

foreach num1 of numlist 2010(1)2010 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p10i6", clear

merge 1:1 Y1 using "`in'/rscfp2010.dta", nogen 

gen year=`num1'


gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen type=0
replace type=1 if (X3119==1|X3119==11|X3119==12)
replace type=2 if (X3119==2)
replace type=3 if (X3119==3)
replace type=4 if (X3119==4|X3119==6)
replace type=5 if (X3119==-7|X3119==40)

table X4106 X3119 if X3104==1 [aw=wgt]

table X4106 if X3401==1 [aw=wgt]

gen no_pay="yes" if X4112==-1
replace no_pay="no" if no_pay!="yes"
 
table X4106 if X3104==1 [aw=wgt]
table X4706 if X3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
          + (X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 - (X3120==1)*(X3122==5)*(X7144==1)*X3121+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}


* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0  
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}

* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=X4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=X4`num'11 if X4`num'13==2 
* just keep the weeks worked
replace per`num'=X4`num'11/2 if X4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=X4`num'11/4 if X4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=X4`num'11/(4*3) if X4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if X4`num'13==6 
* annnual
replace per`num'=1 if X4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=1 if X4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=X4`num'11*X4`num'10/8 if (X4`num'13==1 & X8021==1) 
replace per`num'=X4`num'11*X4`num'10/7 if (X4`num'13==1 & X8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=X4`num'11/(4*2) if X4`num'13==12
* bymonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if X4`num'13==14
* by the piece, by the job
replace per`num'=X4`num'11*X4`num'10 if X4`num'13==18
* by hour 
replace per`num'=2 if X4`num'13==11
* twice per year, byannually
replace per`num'=1 if X4`num'13==22
* twice per year, bi-annually
replace per`num'=(X4`num'11/4)*2 if X4`num'13==31
* twice a month
}


* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*X4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*X4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & paid_wage_dummy_`num'==1
count if X4`num'11==0 & paid_wage_dummy_`num'==1
}



foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if X4`num'06==1 & X4`num'12>0
gen paid_wage_`num'=per`num'*X4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*X4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & no_wage_dummy_`num'==1
count if X4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}


generate ageR=X14
generate ageS=X19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(X8021==1)
generate genderdummy_S=(X103==1) if X103!=0

gen hsdummy_R=((X5902==1 & X5904==5)+(X5901>12 & X5904==5)) 
gen hsdummy_S=((X6102==1 & X6104==5)+(X6101>12 & X6104==5)) if X6101!=0

generate cdummy_R=(X5904==1)
generate cdummy_S=(X6104==1) if X6101!=0

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_10_new_regress", replace
}


foreach num of numlist 2010/2010 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_10_new_regress"
gen implicat = mod(Y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}


foreach num of numlist 2010/2010 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_10_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(Y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}


foreach num2 of numlist 2010/2010 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_10_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(Y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Replace known log hour wages for those with paid employment
replace loghrcomp_predict`num1'=log_hr_wage_paid_`num1' if paid_wage_dummy_`num1'==1 

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.


* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep Y1 YY1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort Y1 YY1
save "`in'/labour_regression_results`num1'", replace
}
}


local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort Y1 YY1
merge Y1 YY1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort Y1 YY1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 10(1)10 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p10i6", clear

merge 1:1 Y1 using "`in'/rscfp20`num'.dta", nogen


sort Y1 YY1

merge Y1 YY1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

rename Y1 y1 
rename YY1 yy1 

gen year=20`num'

gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen PP2=0 
replace PP2=1 if (X3219==1 | X3219==2 | X3219==11 | X3219==12)
replace PP2=2 if (X3219==3 | X3219==4 | X3219==6 | X3219==40 | X3219==-7)


egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)+(X3415==1)+(X3419==1)+(X3427==1)))
egen naPPwgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)))
egen naSCwgtsum=sum(wgt*((X3415==1)+(X3419==1)+(X3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+nawgtsum)

* To be applied to other actively managed business 
gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)2{
	egen sumPP`x'PTwgt = sum(((X3`x'19==1) + (X3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((X3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((X3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((X3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt)/(sumPP1wgt+sumPP2wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(y1)
					
** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==3) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==3) ///
                    +(X3335>0)*X3335*(X3119==3)+ farmbus*(X3119==3)+ ///
                    (X3416>0)*X3416), by(y1)
					
egen BUScheckactSP=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==2) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==2) ///
                    +(X3335>0)*X3335*(X3119==2)+ farmbus*(X3119==2)), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==-7) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==-7) ///
	   + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==6) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==6) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==40) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==40) ///
                    +(X3335>0)*X3335*(X3119==-7)+(X3335>0)*X3335*(X3119==6)+(X3335>0)*X3335*(X3119==40)+ farmbus*(X3119==-7)+ farmbus*(X3119==6)+ farmbus*(X3119==40)+ ///
                    (X3428>0)*X3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         X3132*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
           (X3337!=-1)*X3337+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)+ ///
	   (X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1)+(X3415==1)*X3418*(X3418!=-1)   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)

gen profitactSP= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)
	   
gen profitS= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OCratio + ///
	   (X3419==1)*X3422*(X3422!=-1) ///
	   
gen profitOT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OTratio + ///
	   ((X3427==1)*X3430*(X3430!=-1))	   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSCAT= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*0.7+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)  
	   
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSPAT= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)

gen profitSAT= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen profitOCAT= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OCratio*0.7 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OTratio*0.7 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*0.7*0.6+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7*0.6+ ///
         X3132*(X3119==3)*(X3128/10000)*(X3128>0)*0.8*(X3132!=-1)+ ///
	   X3232*(X3219==3)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3415==1)*X3418*0.8*(X3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3407==1)*X3410*(X3410!=-1)*0.8+(X3411==1)*X3414*(X3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8

gen profitSATRE= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)*0.8+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)*0.8+ ///
	   (X3415==1)*X3418*(X3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OCratio*0.7*0.6 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OTratio*0.7*0.6 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}

	cap rename (PAYPEN* PAYHI* PAYILN* VEH_INST PAYVEH*) (paypen* payhi* payiln* veh_inst payveh*) 
	cap rename (j*) (J*)
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830  X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}


**********************************
************** 2013 **************
**********************************

foreach num1 of numlist 2013(1)2013 { 
* Useful dummies to be used later


local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p13i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "`in'/rscfp`num1'.dta", nogen
rename y1 Y1

gen year=`num1'


gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen type=0
replace type=1 if (X3119==1|X3119==11|X3119==12)
replace type=2 if (X3119==2)
replace type=3 if (X3119==3)
replace type=4 if (X3119==4|X3119==6)
replace type=5 if (X3119==-7|X3119==40)

table X4106 X3119 if X3104==1 [aw=wgt]

table X4106 if X3401==1 [aw=wgt]

gen no_pay="yes" if X4112==-1
replace no_pay="no" if no_pay!="yes"
 
table X4106 if X3104==1 [aw=wgt]
table X4706 if X3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
          + (X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 - (X3120==1)*(X3122==5)*(X7144==1)*X3121+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}


* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0  
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}

* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=X4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=X4`num'11 if X4`num'13==2 
* just keep the weeks worked
replace per`num'=X4`num'11/2 if X4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=X4`num'11/4 if X4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=X4`num'11/(4*3) if X4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if X4`num'13==6 
* annnual
replace per`num'=1 if X4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=1 if X4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=X4`num'11*X4`num'10/8 if (X4`num'13==1 & X8021==1) 
replace per`num'=X4`num'11*X4`num'10/7 if (X4`num'13==1 & X8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=X4`num'11/(4*2) if X4`num'13==12
* bymonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if X4`num'13==14
* by the piece, by the job
replace per`num'=X4`num'11*X4`num'10 if X4`num'13==18
* by hour 
replace per`num'=2 if X4`num'13==11
* twice per year, byannually
replace per`num'=1 if X4`num'13==22
* twice per year, bi-annually
replace per`num'=(X4`num'11/4)*2 if X4`num'13==31
* twice a month
}


* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*X4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*X4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & paid_wage_dummy_`num'==1
count if X4`num'11==0 & paid_wage_dummy_`num'==1
}



foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if X4`num'06==1 & X4`num'12>0
gen paid_wage_`num'=per`num'*X4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*X4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & no_wage_dummy_`num'==1
count if X4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}


generate ageR=X14
generate ageS=X19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(X8021==1)
generate genderdummy_S=(X103==1) if X103!=0

gen hsdummy_R=((X5902==1 & X5904==5)+(X5901>12 & X5904==5)) 
gen hsdummy_S=((X6102==1 & X6104==5)+(X6101>12 & X6104==5)) if X6101!=0

generate cdummy_R=(X5904==1)
generate cdummy_S=(X6104==1) if X6101!=0

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_13_new_regress", replace
}


foreach num of numlist 2013/2013 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_13_new_regress"
gen implicat = mod(Y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}


foreach num of numlist 2013/2013 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_13_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(Y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}


foreach num2 of numlist 2013/2013 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_13_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(Y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Replace known log hour wages for those with paid employment
replace loghrcomp_predict`num1'=log_hr_wage_paid_`num1' if paid_wage_dummy_`num1'==1 

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.


* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep Y1 yy1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 
rename yy1 YY1 
local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort Y1 YY1
save "`in'/labour_regression_results`num1'", replace
}
}


local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort Y1 YY1
merge Y1 YY1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort Y1 YY1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 13(1)13 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p13i6", clear
rename Y1 y1
rename x* X*
merge 1:1 y1 using "`in'/rscfp2013.dta", nogen
rename (y1 yy1) (Y1 YY1)


sort Y1 YY1

merge Y1 YY1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

rename Y1 y1 
rename YY1 yy1 

gen year=20`num'

gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen PP2=0 
replace PP2=1 if (X3219==1 | X3219==2 | X3219==11 | X3219==12)
replace PP2=2 if (X3219==3 | X3219==4 | X3219==6 | X3219==40 | X3219==-7)


egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)+(X3415==1)+(X3419==1)+(X3427==1)))
egen naPPwgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)))
egen naSCwgtsum=sum(wgt*((X3415==1)+(X3419==1)+(X3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+nawgtsum)

* To be applied to other actively managed business 
gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)2{
	egen sumPP`x'PTwgt = sum(((X3`x'19==1) + (X3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((X3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((X3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((X3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt)/(sumPP1wgt+sumPP2wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(y1)
					
** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==3) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==3) ///
                    +(X3335>0)*X3335*(X3119==3)+ farmbus*(X3119==3)+ ///
                    (X3416>0)*X3416), by(y1)
					
egen BUScheckactSP=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==2) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==2) ///
                    +(X3335>0)*X3335*(X3119==2)+ farmbus*(X3119==2)), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==-7) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==-7) ///
	   + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==6) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==6) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==40) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==40) ///
                    +(X3335>0)*X3335*(X3119==-7)+(X3335>0)*X3335*(X3119==6)+(X3335>0)*X3335*(X3119==40)+ farmbus*(X3119==-7)+ farmbus*(X3119==6)+ farmbus*(X3119==40)+ ///
                    (X3428>0)*X3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         X3132*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
           (X3337!=-1)*X3337+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)+ ///
	   (X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1)+(X3415==1)*X3418*(X3418!=-1)   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)

gen profitactSP= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)
	   
gen profitS= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OCratio + ///
	   (X3419==1)*X3422*(X3422!=-1) ///
	   
gen profitOT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OTratio + ///
	   ((X3427==1)*X3430*(X3430!=-1))	   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSCAT= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*0.7+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)  
	   
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSPAT= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)

gen profitSAT= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen profitOCAT= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OCratio*0.7 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OTratio*0.7 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*0.7*0.6+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7*0.6+ ///
         X3132*(X3119==3)*(X3128/10000)*(X3128>0)*0.8*(X3132!=-1)+ ///
	   X3232*(X3219==3)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3415==1)*X3418*0.8*(X3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3407==1)*X3410*(X3410!=-1)*0.8+(X3411==1)*X3414*(X3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8

gen profitSATRE= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)*0.8+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)*0.8+ ///
	   (X3415==1)*X3418*(X3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OCratio*0.7*0.6 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OTratio*0.7*0.6 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}

	cap rename (PAYPEN* PAYHI* PAYILN* VEH_INST PAYVEH*) (paypen* payhi* payiln* veh_inst payveh*) 
	cap rename (j*) (J*)
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}


**********************************
************** 2016 **************
**********************************

foreach num1 of numlist 2016(1)2016 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"
**# Bookmark #1

use "`in'/p16i6", clear

merge 1:1 Y1 using "`in'/rscfp2016.dta", nogen 

gen year=`num1'


gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen type=0
replace type=1 if (X3119==1|X3119==11|X3119==12)
replace type=2 if (X3119==2)
replace type=3 if (X3119==3)
replace type=4 if (X3119==4|X3119==6)
replace type=5 if (X3119==-7|X3119==40)

table X4106 X3119 if X3104==1 [aw=wgt]

table X4106 if X3401==1 [aw=wgt]

gen no_pay="yes" if X4112==-1
replace no_pay="no" if no_pay!="yes"
 
table X4106 if X3104==1 [aw=wgt]
table X4706 if X3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
          + (X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 - (X3120==1)*(X3122==5)*(X7144==1)*X3121+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}


* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0  
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}

* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=X4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=X4`num'11 if X4`num'13==2 
* just keep the weeks worked
replace per`num'=X4`num'11/2 if X4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=X4`num'11/4 if X4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=X4`num'11/(4*3) if X4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if X4`num'13==6 
* annnual
replace per`num'=1 if X4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=1 if X4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=X4`num'11*X4`num'10/8 if (X4`num'13==1 & X8021==1) 
replace per`num'=X4`num'11*X4`num'10/7 if (X4`num'13==1 & X8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=X4`num'11/(4*2) if X4`num'13==12
* bymonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if X4`num'13==14
* by the piece, by the job
replace per`num'=X4`num'11*X4`num'10 if X4`num'13==18
* by hour 
replace per`num'=2 if X4`num'13==11
* twice per year, byannually
replace per`num'=1 if X4`num'13==22
* twice per year, bi-annually
replace per`num'=(X4`num'11/4)*2 if X4`num'13==31
* twice a month
}


* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*X4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*X4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & paid_wage_dummy_`num'==1
count if X4`num'11==0 & paid_wage_dummy_`num'==1
}



foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if X4`num'06==1 & X4`num'12>0
gen paid_wage_`num'=per`num'*X4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*X4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & no_wage_dummy_`num'==1
count if X4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}


generate ageR=X14
generate ageS=X19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(X8021==1)
generate genderdummy_S=(X103==1) if X103!=0

gen hsdummy_R=((X5931==8)+(X5931==9)) 
gen hsdummy_S=((X6111==8)+(X6111==9)) if X6111!=0

generate cdummy_R=(X5931>=12)
generate cdummy_S=(X6111>=12) if X6111!=0

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_16_new_regress", replace
}


foreach num of numlist 2016/2016 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_16_new_regress"
gen implicat = mod(Y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}


foreach num of numlist 2016/2016 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_16_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(Y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}


foreach num2 of numlist 2016/2016 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_16_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(Y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Replace known log hour wages for those with paid employment
replace loghrcomp_predict`num1'=log_hr_wage_paid_`num1' if paid_wage_dummy_`num1'==1 

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.


* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep Y1 YY1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort Y1 YY1
save "`in'/labour_regression_results`num1'", replace
}
}


local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort Y1 YY1
merge Y1 YY1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort Y1 YY1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 16(1)16 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p16i6", clear

merge 1:1 Y1 using "`in'/rscfp2016.dta", nogen


sort Y1 YY1

merge Y1 YY1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

rename Y1 y1 
rename YY1 yy1 

gen year=20`num'

gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen PP2=0 
replace PP2=1 if (X3219==1 | X3219==2 | X3219==11 | X3219==12)
replace PP2=2 if (X3219==3 | X3219==4 | X3219==6 | X3219==40 | X3219==-7)


egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)+(X3415==1)+(X3419==1)+(X3427==1)))
egen naPPwgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)))
egen naSCwgtsum=sum(wgt*((X3415==1)+(X3419==1)+(X3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+nawgtsum)

* To be applied to other actively managed business 
gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)2{
	egen sumPP`x'PTwgt = sum(((X3`x'19==1) + (X3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((X3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((X3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((X3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt)/(sumPP1wgt+sumPP2wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(y1)
					
** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==3) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==3) ///
                    +(X3335>0)*X3335*(X3119==3)+ farmbus*(X3119==3)+ ///
                    (X3416>0)*X3416), by(y1)
					
egen BUScheckactSP=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==2) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==2) ///
                    +(X3335>0)*X3335*(X3119==2)+ farmbus*(X3119==2)), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==-7) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==-7) ///
	   + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==6) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==6) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==40) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==40) ///
                    +(X3335>0)*X3335*(X3119==-7)+(X3335>0)*X3335*(X3119==6)+(X3335>0)*X3335*(X3119==40)+ farmbus*(X3119==-7)+ farmbus*(X3119==6)+ farmbus*(X3119==40)+ ///
                    (X3428>0)*X3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         X3132*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
           (X3337!=-1)*X3337+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)+ ///
	   (X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1)+(X3415==1)*X3418*(X3418!=-1)   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)

gen profitactSP= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)
	   
gen profitS= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OCratio + ///
	   (X3419==1)*X3422*(X3422!=-1) ///
	   
gen profitOT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OTratio + ///
	   ((X3427==1)*X3430*(X3430!=-1))	   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSCAT= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*0.7+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)  
	   
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSPAT= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)

gen profitSAT= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen profitOCAT= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OCratio*0.7 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OTratio*0.7 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*0.7*0.6+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7*0.6+ ///
         X3132*(X3119==3)*(X3128/10000)*(X3128>0)*0.8*(X3132!=-1)+ ///
	   X3232*(X3219==3)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3415==1)*X3418*0.8*(X3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3407==1)*X3410*(X3410!=-1)*0.8+(X3411==1)*X3414*(X3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8

gen profitSATRE= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)*0.8+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)*0.8+ ///
	   (X3415==1)*X3418*(X3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OCratio*0.7*0.6 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OTratio*0.7*0.6 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
		cap rename (PAYPEN* PAYHI* PAYILN* VEH_INST PAYVEH*) (paypen* payhi* payiln* veh_inst payveh*) 
cap rename (j*) (J*)
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}


**********************************
************** 2019 **************
**********************************

foreach num1 of numlist 2019(1)2019 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p19i6", clear
rename Y1 y1 
rename x* X*
merge 1:1 y1 using "`in'/rscfp2019.dta", nogen 
rename (y1 yy1) (Y1 YY1)
gen year=`num1'


gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen type=0
replace type=1 if (X3119==1|X3119==11|X3119==12)
replace type=2 if (X3119==2)
replace type=3 if (X3119==3)
replace type=4 if (X3119==4|X3119==6)
replace type=5 if (X3119==-7|X3119==40)

table X4106 X3119 if X3104==1 [aw=wgt]

table X4106 if X3401==1 [aw=wgt]

gen no_pay="yes" if X4112==-1
replace no_pay="no" if no_pay!="yes"
 
table X4106 if X3104==1 [aw=wgt]
table X4706 if X3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
          + (X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 - (X3120==1)*(X3122==5)*(X7144==1)*X3121+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}


* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0  
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}

* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=X4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=X4`num'11 if X4`num'13==2 
* just keep the weeks worked
replace per`num'=X4`num'11/2 if X4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=X4`num'11/4 if X4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=X4`num'11/(4*3) if X4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if X4`num'13==6 
* annnual
replace per`num'=1 if X4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=1 if X4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=X4`num'11*X4`num'10/8 if (X4`num'13==1 & X8021==1) 
replace per`num'=X4`num'11*X4`num'10/7 if (X4`num'13==1 & X8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=X4`num'11/(4*2) if X4`num'13==12
* bymonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if X4`num'13==14
* by the piece, by the job
replace per`num'=X4`num'11*X4`num'10 if X4`num'13==18
* by hour 
replace per`num'=2 if X4`num'13==11
* twice per year, byannually
replace per`num'=1 if X4`num'13==22
* twice per year, bi-annually
replace per`num'=(X4`num'11/4)*2 if X4`num'13==31
* twice a month
}


* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*X4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*X4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & paid_wage_dummy_`num'==1
count if X4`num'11==0 & paid_wage_dummy_`num'==1
}



foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if X4`num'06==1 & X4`num'12>0
gen paid_wage_`num'=per`num'*X4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*X4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & no_wage_dummy_`num'==1
count if X4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}


generate ageR=X14
generate ageS=X19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(X8021==1)
generate genderdummy_S=(X103==1) if X103!=0

gen hsdummy_R=((X5931==8)+(X5931==9)) 
gen hsdummy_S=((X6111==8)+(X6111==9)) if X6111!=0

generate cdummy_R=(X5931>=12)
generate cdummy_S=(X6111>=12) if X6111!=0

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_19_new_regress", replace
}


foreach num of numlist 2019/2019 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_19_new_regress"
gen implicat = mod(Y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}


foreach num of numlist 2019/2019 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_19_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(Y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}


foreach num2 of numlist 2019/2019 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_19_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(Y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Replace known log hour wages for those with paid employment
replace loghrcomp_predict`num1'=log_hr_wage_paid_`num1' if paid_wage_dummy_`num1'==1 

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.


* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep Y1 YY1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort Y1 YY1
save "`in'/labour_regression_results`num1'", replace
}
}


local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort Y1 YY1
merge Y1 YY1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort Y1 YY1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 19(1)19 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p19i6", clear
rename Y1 y1 
rename x* X*
merge 1:1 y1 using "`in'/rscfp20`num'.dta", nogen 
rename (y1 yy1) (Y1 YY1)

sort Y1 YY1

merge Y1 YY1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

rename Y1 y1 
rename YY1 yy1 

gen year=20`num'

gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen PP2=0 
replace PP2=1 if (X3219==1 | X3219==2 | X3219==11 | X3219==12)
replace PP2=2 if (X3219==3 | X3219==4 | X3219==6 | X3219==40 | X3219==-7)


egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)+(X3415==1)+(X3419==1)+(X3427==1)))
egen naPPwgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)))
egen naSCwgtsum=sum(wgt*((X3415==1)+(X3419==1)+(X3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+nawgtsum)

* To be applied to other actively managed business 
gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)2{
	egen sumPP`x'PTwgt = sum(((X3`x'19==1) + (X3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((X3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((X3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((X3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt)/(sumPP1wgt+sumPP2wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(y1)
					
** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==3) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==3) ///
                    +(X3335>0)*X3335*(X3119==3)+ farmbus*(X3119==3)+ ///
                    (X3416>0)*X3416), by(y1)
					
egen BUScheckactSP=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==2) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==2) ///
                    +(X3335>0)*X3335*(X3119==2)+ farmbus*(X3119==2)), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==-7) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==-7) ///
	   + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==6) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==6) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==40) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==40) ///
                    +(X3335>0)*X3335*(X3119==-7)+(X3335>0)*X3335*(X3119==6)+(X3335>0)*X3335*(X3119==40)+ farmbus*(X3119==-7)+ farmbus*(X3119==6)+ farmbus*(X3119==40)+ ///
                    (X3428>0)*X3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         X3132*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
           (X3337!=-1)*X3337+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)+ ///
	   (X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1)+(X3415==1)*X3418*(X3418!=-1)   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)

gen profitactSP= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)
	   
gen profitS= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OCratio + ///
	   (X3419==1)*X3422*(X3422!=-1) ///
	   
gen profitOT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OTratio + ///
	   ((X3427==1)*X3430*(X3430!=-1))	   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSCAT= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*0.7+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)  
	   
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSPAT= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)

gen profitSAT= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen profitOCAT= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OCratio*0.7 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OTratio*0.7 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*0.7*0.6+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7*0.6+ ///
         X3132*(X3119==3)*(X3128/10000)*(X3128>0)*0.8*(X3132!=-1)+ ///
	   X3232*(X3219==3)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3415==1)*X3418*0.8*(X3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3407==1)*X3410*(X3410!=-1)*0.8+(X3411==1)*X3414*(X3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8

gen profitSATRE= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)*0.8+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)*0.8+ ///
	   (X3415==1)*X3418*(X3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OCratio*0.7*0.6 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OTratio*0.7*0.6 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	cap rename (PAYPEN* PAYHI* PAYILN* VEH_INST PAYVEH*) (paypen* payhi* payiln* veh_inst payveh*) 
	
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}

**********************************
************** 2022 **************
**********************************

foreach num1 of numlist 2022(1)2022 { 
* Useful dummies to be used later

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p22i6", clear
rename Y1 y1 
rename x* X*
merge 1:1 y1 using "`in'/rscfp2022.dta", nogen 
rename (y1 yy1) (Y1 YY1)
gen year=`num1'


gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen type=0
replace type=1 if (X3119==1|X3119==11|X3119==12)
replace type=2 if (X3119==2)
replace type=3 if (X3119==3)
replace type=4 if (X3119==4|X3119==6)
replace type=5 if (X3119==-7|X3119==40)

table X4106 X3119 if X3104==1 [aw=wgt]

table X4106 if X3401==1 [aw=wgt]

gen no_pay="yes" if X4112==-1
replace no_pay="no" if no_pay!="yes"
 
table X4106 if X3104==1 [aw=wgt]
table X4706 if X3104==1 [aw=wgt]

* Define value of business and look at those businesses with positive equity, where the 
* respondent/spouse work - the _guar variable corresponds to the variable used in 
* previous total equity calculations but for the first business

gen BUScheck_guar=0 ///
          + (X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126 - (X3120==1)*(X3122==5)*(X7144==1)*X3121+farmbus

* Create a dummy to identify those who own and actively manage a business, work in it and 
* do not report taking wages from the business

* RESPONDENT  
foreach num of numlist 1/1  {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt] 
}


* By business type for respondent

foreach num of numlist 1/1  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}


* SPOUSE
foreach num of numlist 7/7 {  
gen no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
replace no_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 

replace no_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
tab no_wage_dummy_`num' [aw=wgt]
}
* By LFO for spouse

foreach num of numlist 7/7  {  
gen no_wage_dummy_pt_`num'=1 if no_wage_dummy_`num'==1 & type==1
gen no_wage_dummy_sp_`num'=1 if no_wage_dummy_`num'==1 & type==2
gen no_wage_dummy_s_`num'=1 if no_wage_dummy_`num'==1 & type==3
gen no_wage_dummy_oc_`num'=1 if no_wage_dummy_`num'==1 & type==4
gen no_wage_dummy_ot_`num'=1 if no_wage_dummy_`num'==1 & type==5

tab no_wage_dummy_pt_`num' [aw=wgt] 
tab no_wage_dummy_sp_`num' [aw=wgt]
tab no_wage_dummy_s_`num' [aw=wgt] 
tab no_wage_dummy_oc_`num' [aw=wgt]
tab no_wage_dummy_ot_`num' [aw=wgt]
}

* CREATE A DUMMY FOR THOSE WHO REPORT OWNING A BUSINESS AND ACTIVELY MANAGING IT, WORKING IN IT
* AND TAKING OUT WAGES/SALARY

* RESPONDENT 
foreach num of numlist 1/1  {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0

tab paid_wage_dummy_`num' [aw=wgt]
}


* SPOUSE 
foreach num of numlist 7/7 {
gen paid_wage_dummy_`num'=1 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12>0 & BUScheck_guar>0  
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==1 & X4`num'12==-1 & BUScheck_guar>0 
replace paid_wage_dummy_`num'=0 if X4`num'06==2 & X3104==1 & X4`num'25==5 & BUScheck_guar>0
tab paid_wage_dummy_`num' [aw=wgt]
}

* drop hours_worked
foreach num of numlist 1/1 7/7 {
* Hours worked

gen hours_worked_`num'=X4`num'10
} 

foreach num of numlist 1/1 7/7 {
* Generate frequency variable for those entrepreneurs who get paid salaries and wages
gen per`num'=.
replace per`num'=X4`num'11 if X4`num'13==2 
* just keep the weeks worked
replace per`num'=X4`num'11/2 if X4`num'13==3 
* divide the number of weeks by 2 to get byweekly 
replace per`num'=X4`num'11/4 if X4`num'13==4 
* divide the number of weeks by 4 weeks in a month to get monthly
replace per`num'=X4`num'11/(4*3) if X4`num'13==5 
* divide by number of weeks in a quarter to get quarterly
replace per`num'=1 if X4`num'13==6 
* annnual
replace per`num'=1 if X4`num'13==-7 
* unknown frequency, keep as a one time payment
replace per`num'=1 if X4`num'13==8 
* edited to weekly, so keep the number of weeks actually worked
replace per`num'=X4`num'11*X4`num'10/8 if (X4`num'13==1 & X8021==1) 
replace per`num'=X4`num'11*X4`num'10/7 if (X4`num'13==1 & X8021==2) 
* daily, divide by number of hours in a day
replace per`num'=0 if per`num'==.
replace per`num'=X4`num'11/(4*2) if X4`num'13==12
* bymonthly (4 weeks in a month, but paid only every 2 weeks)
replace per`num'=1 if X4`num'13==14
* by the piece, by the job
replace per`num'=X4`num'11*X4`num'10 if X4`num'13==18
* by hour 
replace per`num'=2 if X4`num'13==11
* twice per year, byannually
replace per`num'=1 if X4`num'13==22
* twice per year, bi-annually
replace per`num'=(X4`num'11/4)*2 if X4`num'13==31
* twice a month
}


* Compute total wages paid regardless of LFO
foreach num of numlist 1/1 7/7 {
* active managers (self-employed)
gen wage_paid_`num'=per`num'*X4`num'12 if paid_wage_dummy_`num'==1
egen total_wage_paid_`num'=sum(wgt*wage_paid_`num')
mean total_wage_paid_`num'
}

gen total_wage_paid=total_wage_paid_1+total_wage_paid_7
mean total_wage_paid

* Compute total wages by form of organization

foreach num of numlist 1/1 7/7 {
* active managers (self-employed) 
gen wage_paid_`num'_pt=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==1
gen wage_paid_`num'_sp=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==2
gen wage_paid_`num'_s=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==3
gen wage_paid_`num'_oc=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==4
gen wage_paid_`num'_ot=per`num'*X4`num'12 if paid_wage_dummy_`num'==1 & type==5

egen total_wage_paid_`num'_pt=sum(wgt*wage_paid_`num'_pt)
egen total_wage_paid_`num'_sp=sum(wgt*wage_paid_`num'_sp)
egen total_wage_paid_`num'_s=sum(wgt*wage_paid_`num'_s)
egen total_wage_paid_`num'_oc=sum(wgt*wage_paid_`num'_oc)
egen total_wage_paid_`num'_ot=sum(wgt*wage_paid_`num'_ot)

mean total_wage_paid_`num'_pt total_wage_paid_`num'_sp total_wage_paid_`num'_s total_wage_paid_`num'_oc total_wage_paid_`num'_ot
}

gen total_wage_paid_pt=total_wage_paid_1_pt+total_wage_paid_7_pt
gen total_wage_paid_sp=total_wage_paid_1_sp+total_wage_paid_7_sp
gen total_wage_paid_s=total_wage_paid_1_s+total_wage_paid_7_s
gen total_wage_paid_oc=total_wage_paid_1_oc+total_wage_paid_7_oc
gen total_wage_paid_ot=total_wage_paid_1_ot+total_wage_paid_7_ot

mean total_wage_paid_pt  total_wage_paid_sp total_wage_paid_s total_wage_paid_oc total_wage_paid_ot
gen total_wage_paid_alltype=total_wage_paid_pt +total_wage_paid_sp +total_wage_paid_s +total_wage_paid_oc +total_wage_paid_ot
mean total_wage_paid_alltype

* Generate a variable for the hourly rate of the paid self-employed managers

foreach num of numlist 1/1 7/7 {
gen hr_wage_paid_`num'=wage_paid_`num'/(hours_worked_`num'*X4`num'11)
gen log_hr_wage_paid_`num'=log(hr_wage_paid_`num')
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & paid_wage_dummy_`num'==1
count if X4`num'11==0 & paid_wage_dummy_`num'==1
}



foreach num of numlist 1/1 7/7 {
count if hr_wage_paid_`num'==. & paid_wage_dummy_`num'==1
}

***********************************************************************************************
***********************************************************************************************
* Running regressions for no_wage_paid observations
***********************************************************************************************

* Create a dummy variable for not self-employed - in paid employment, i.e. work for someone else 
* and paid positive wages

foreach num of numlist 1/1 7/7 {
gen paid_emplt_dummy_`num'=1 if X4`num'06==1 & X4`num'12>0
gen paid_wage_`num'=per`num'*X4`num'12 if paid_emplt_dummy_`num'==1
gen paid_hr_wage_`num'=paid_wage_`num'/(hours_worked_`num'*X4`num'11) if paid_emplt_dummy_`num'==1 
gen log_paid_hr_wage_`num'=log(paid_hr_wage_`num') if paid_emplt_dummy_`num'==1
}

foreach num of numlist 1/1 7/7 {
count if X4`num'11==-1 & no_wage_dummy_`num'==1
count if X4`num'11==0 & no_wage_dummy_`num'==1
}


foreach num of numlist 1/1 7/7 {
count if hours_worked_`num'==-1 & no_wage_dummy_`num'==1
count if hours_worked_`num'==0 & no_wage_dummy_`num'==1
}


generate ageR=X14
generate ageS=X19 

generate agesqrR=ageR^2 
generate agesqrS=ageS^2 

generate genderdummy_R=(X8021==1)
generate genderdummy_S=(X103==1) if X103!=0

gen hsdummy_R=((X5931==8)+(X5931==9)) 
gen hsdummy_S=((X6111==8)+(X6111==9)) if X6111!=0

generate cdummy_R=(X5931>=12)
generate cdummy_S=(X6111>=12) if X6111!=0

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/main_22_new_regress", replace
}


foreach num of numlist 2022/2022 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"


use "`in'/main_22_new_regress"
gen implicat = mod(Y1, 10)

* Run regression itself for a RESPONDENT

sort implicat
statsby "regress log_paid_hr_wage_1 ageR agesqrR genderdummy_R hsdummy_R cdummy_R" _b, by(implicat) clear

xpose, clear varname
renpfix v bR
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_1", replace
save "`in'/myusingbetasR_1", replace
}


foreach num of numlist 2022/2022 {

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

use "`in'/main_22_new_regress", clear 

* Run regression itself for a SPOUSE
gen implicat = mod(Y1, 10)
sort implicat

* rename ageS ageR
* rename agesqrS agesqrR
* rename genderdummy_S genderdummy_R
* rename hsdummy_S hsdummy_R
* rename cdummy_S cdummy_R

statsby "regress log_paid_hr_wage_7 ageS agesqrS genderdummy_S hsdummy_S cdummy_S" _b, by(implicat) clear

xpose, clear varname
renpfix v bS
drop if _varname=="implicat"
gen str20 varnameR=substr(_varname, 3,.)
sort varnameR
drop _varname

rename bS1 bR1
rename bS2 bR2
rename bS3 bR3
rename bS4 bR4
rename bS5 bR5

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"

save "`in'/betasR_7", replace
save "`in'/myusingbetasR_7", replace
}


foreach num2 of numlist 2022/2022 {
foreach num1 of numlist 1/1 7/7{

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/main_22_new_regress", clear
merge using "`in'/myusingbetasR_`num1'"
tab _merge
drop _merge

gen implicat = mod(Y1, 10)

* Substituting in wages for missing values for those who do not report obtaining wages
* using the coefficients from regression for logwage

gen loghrcomp_predict`num1'=.

rename ageS age7
rename agesqrS agesqr7
rename genderdummy_S genderdummy_7
rename hsdummy_S hsdummy_7
rename cdummy_S cdummy_7

 
rename ageR age1
rename agesqrR agesqr1
rename genderdummy_R genderdummy_1
rename hsdummy_R hsdummy_1
rename cdummy_R cdummy_1

* Use coefficients for each implicat separately 
foreach num of numlist 1/5 {
replace loghrcomp_predict`num1'=agesqr`num1'*bR`num'[2]+cdummy_`num1'*bR`num'[3]+bR`num'[4]+genderdummy_`num1'*bR`num'[5]+hsdummy_`num1'*bR`num'[6]+age`num1'*bR`num'[1] ///
if (implicat==`num' & no_wage_dummy_`num1'==1) 
}

* Replace known log hour wages for those with paid employment
replace loghrcomp_predict`num1'=log_hr_wage_paid_`num1' if paid_wage_dummy_`num1'==1 

* Transforming logwages into unlogged wages
gen hrcomp_predict`num1'=exp(loghrcomp_predict`num1')

* Replace the variable with known wages
replace hrcomp_predict`num1'=0 if no_wage_dummy_`num1'!=1 
replace hrcomp_predict`num1'=0 if hrcomp_predict`num1'==.


* edit hrcomp_predict paid_hr_wage_`num'1 if paid_emplt_dummy_`num1'==1

* Summing over the values of wages for self-employed managers with unpaid wages
* Multiplying by their total hours 

gen setotalwage`num1'=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_`num1'==1)

gen setotalwage`num1'_pt=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_pt_`num1'==1)

gen setotalwage`num1'_sp=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_sp_`num1'==1) 

gen setotalwage`num1'_s=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_s_`num1'==1)

gen setotalwage`num1'_oc=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_oc_`num1'==1) 

gen setotalwage`num1'_ot=hrcomp_predict`num1'*hours_worked_`num1'*X4`num1'11*(no_wage_dummy_ot_`num1'==1)

drop type
keep Y1 YY1 hrcomp_predict`num1' setotalwage`num1' setotalwage`num1'_pt ///
setotalwage`num1'_sp setotalwage`num1'_s setotalwage`num1'_oc setotalwage`num1'_ot 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
save "`in'/labour_regression_results`num1'", replace
sort Y1 YY1
save "`in'/labour_regression_results`num1'", replace
}
}


local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment"
use "`in'/labour_regression_results1.dta", clear
sort Y1 YY1
merge Y1 YY1 using "`in'/labour_regression_results7" 

gen hrcomp_predict=hrcomp_predict1+hrcomp_predict7
gen setotalwage=setotalwage1+setotalwage7
gen setotalwage_pt=setotalwage1_pt+setotalwage7_pt
gen setotalwage_sp=setotalwage1_sp+setotalwage7_sp
gen setotalwage_s=setotalwage1_s+setotalwage7_s
gen setotalwage_oc=setotalwage1_oc+setotalwage7_oc
gen setotalwage_ot=setotalwage1_ot+setotalwage7_ot


sort Y1 YY1
drop _merge
save "`in'/labour_regression_results", replace


foreach num of numlist 22(1)22 { 

local in  "C:\Users\mguha\Dropbox\Equity&WealthIneq\data\scf"
local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\output"

use "`in'/p22i6", clear
rename Y1 y1 
rename x* X*
merge 1:1 y1 using "`in'/rscfp20`num'.dta", nogen 
rename (y1 yy1) (Y1 YY1)

sort Y1 YY1

merge Y1 YY1 using "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\labor_adjustment/labour_regression_results", sort

rename Y1 y1 
rename YY1 yy1 

gen year=20`num'

gen PP1=0 
replace PP1=1 if (X3119==1 | X3119==2 | X3119==11 | X3119==12)
replace PP1=2 if (X3119==3 | X3119==4 | X3119==6 | X3119==40 | X3119==-7)

gen PP2=0 
replace PP2=1 if (X3219==1 | X3219==2 | X3219==11 | X3219==12)
replace PP2=2 if (X3219==3 | X3219==4 | X3219==6 | X3219==40 | X3219==-7)


egen sumPP2PPwgt=sum((PP2==1)*wgt)
egen sumPP2SCwgt=sum((PP2==2)*wgt)
gen sumPP2wgt=sumPP2PPwgt+sumPP2SCwgt
gen PP2PPshare=sumPP2PPwgt/sumPP2wgt
gen PP2SCshare=sumPP2SCwgt/sumPP2wgt

egen sumPP1PPwgt=sum((PP1==1)*wgt)
egen sumPP1SCwgt=sum((PP1==2)*wgt)
gen sumPP1wgt=sumPP1PPwgt+sumPP1SCwgt
gen PP1PPshare=sumPP1PPwgt/sumPP1wgt
gen PP1SCshare=sumPP1SCwgt/sumPP1wgt

egen nawgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)+(X3415==1)+(X3419==1)+(X3427==1)))
egen naPPwgtsum=sum(wgt*((X3407==1)+(X3411==1)+(X3451==1)))
egen naSCwgtsum=sum(wgt*((X3415==1)+(X3419==1)+(X3427==1)))
gen PPnashare=naPPwgtsum/nawgtsum
gen SCnashare=naSCwgtsum/nawgtsum

gen wgtdPPnashare=(sumPP1PPwgt+sumPP2PPwgt+ ///
			naPPwgtsum)/(sumPP1wgt+sumPP2wgt+nawgtsum)

* To be applied to other actively managed business 
gen wgtdPPshare=(sumPP1PPwgt+sumPP2PPwgt)/ ///
				(sumPP1wgt+sumPP2wgt)

gen wgtdSCshare=1-wgtdPPshare

foreach x of numlist 1(1)2{
	egen sumPP`x'PTwgt = sum(((X3`x'19==1) + (X3`x'19==11))*wgt)
	egen sumPP`x'SPwgt = sum((X3`x'19==2)*wgt)
	egen sumPP`x'Swgt = sum((X3`x'19==3)*wgt)
	egen sumPP`x'OCwgt = sum((X3`x'19==4)*wgt)
		}
		
gen wgtdPTshare = (sumPP1PTwgt + sumPP2PTwgt)/(sumPP1wgt+sumPP2wgt)		 
gen wgtdSPshare = (sumPP1SPwgt + sumPP2SPwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdSshare = (sumPP1Swgt + sumPP2Swgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOCshare = (sumPP1OCwgt + sumPP2OCwgt)/(sumPP1wgt+sumPP2wgt)
gen wgtdOTshare = 1- (wgtdPTshare + wgtdSPshare + wgtdSshare + wgtdOCshare)

foreach var of varlist X* {
	replace `var' = round(`var') if `var' !=0 & `var' !=1
}

egen BUScheck=sum(0 ///
          + ((X3129>0)*X3129+(X3124>0)*X3124 - (X3127==5)*(X3126>0)*X3126) + ((X3229>0)*X3229+(X3224>0)*X3224 - ///
      (X3227==5)*(X3226>0)*X3226) ///
                     + (X3335>0)*X3335+ farmbus+ (X3408>0)*X3408 ///
                     + (X3412>0)*X3412+(X3416>0)*X3416+(X3420>0)*X3420 ///
                     + (X3452>0)*X3452+(X3428>0)*X3428), by(y1)
					
** SUBCATEGORIES OF BUSINESS 

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
					
egen BUScheckS=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==3) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==3) ///
                    +(X3335>0)*X3335*(X3119==3)+ farmbus*(X3119==3)+ ///
                    (X3416>0)*X3416), by(y1)
					
egen BUScheckactSP=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==2) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==2) ///
                    +(X3335>0)*X3335*(X3119==2)+ farmbus*(X3119==2)), by(y1)
					
egen BUScheckOC=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==4) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==4) ///
                    +(X3335>0)*X3335*(X3119==4)+ farmbus*(X3119==4)+ ///
                    (X3420>0)*X3420), by(y1)
					
egen BUScheckOT=sum(0 ///
         + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==-7) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==-7) ///
	   + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==6) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==6) ///
	  + ((X3129>0)*X3129+(X3124>0)*X3124 ///
      -(X3127==5)*(X3126>0)*X3126)*(X3119==40) ///
         + ((X3229>0)*X3229+(X3224>0)*X3224 ///
      -(X3227==5)*(X3226>0)*X3226)*(X3219==40) ///
                    +(X3335>0)*X3335*(X3119==-7)+(X3335>0)*X3335*(X3119==6)+(X3335>0)*X3335*(X3119==40)+ farmbus*(X3119==-7)+ farmbus*(X3119==6)+ farmbus*(X3119==40)+ ///
                    (X3428>0)*X3428), by(y1)
			
 * Compute unadjusted profits 
 
gen profit=0+ ///
         X3132*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
           (X3337!=-1)*X3337+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)+ ///
	   (X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1)+(X3415==1)*X3418*(X3418!=-1)   

** PROFITS BY SUBCATEGORY


gen profitPT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)+(X3451==1)*X3454*(X3454!=-1)

gen profitactSP= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)
	   
gen profitS= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen OCratio = wgtdOCshare/(wgtdOCshare + wgtdOTshare)
gen OTratio = wgtdOTshare/(wgtdOCshare + wgtdOTshare)

gen profitOC= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OCratio + ///
	   (X3419==1)*X3422*(X3422!=-1) ///
	   
gen profitOT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1))+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3337!=-1)*X3337*OTratio + ///
	   ((X3427==1)*X3430*(X3430!=-1))	   
	   
** Compute tax adjusted profits, total and subcat 

gen profitPPAT= 0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSCAT= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*0.7+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)  
	   
gen profitAT = profitPPAT + profitSCAT 
drop profitPPAT

* Subcats 


gen profitPTAT= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1)

gen profitSPAT= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)

gen profitSAT= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)+ ///
	   (X3415==1)*X3418*(X3418!=-1)
	   
gen profitOCAT= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OCratio*0.7 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7 ///	   

gen profitOTAT= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7+ ///
	   (X3337!=-1)*X3337*OTratio*0.7 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7
	   
** Profits adjusted by retained earnings 

gen profitSCATRE= 0+ ///
         (X3132*((X3119==4)+(X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==4)+(X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*0.7*0.6+ ///
	   ((X3419==1)*X3422*(X3422!=-1)+(X3427==1)*X3430*(X3430!=-1))*0.7*0.6+ ///
         X3132*(X3119==3)*(X3128/10000)*(X3128>0)*0.8*(X3132!=-1)+ ///
	   X3232*(X3219==3)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3415==1)*X3418*0.8*(X3418!=-1)

gen profitPPATRE=0.8*(0+ ///
         X3132*(PP1==1)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
         X3232*(PP2==1)*(X3228/10000)*(X3228>0)*(X3232!=-1)+ ///
	   (X3407==1)*X3410*(X3410!=-1)+(X3411==1)*X3414*(X3414!=-1))
	   
gen profitATRE=profitPPATRE+profitSCATRE

** subcategory 

gen profitPTATRE= 0+ ///
         X3132*((X3119==1)+(X3119==11))*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*((X3219==1)+(X3219==11))*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8+ ///
	   (X3407==1)*X3410*(X3410!=-1)*0.8+(X3411==1)*X3414*(X3414!=-1)*0.8

gen profitSPATRE= 0+ ///
         X3132*(X3119==2)*(X3128/10000)*(X3128>0)*(X3132!=-1)*0.8+ ///
         X3232*(X3219==2)*(X3228/10000)*(X3228>0)*(X3232!=-1)*0.8

gen profitSATRE= 0+ ///
         X3132*(X3119==3)*(X3132!=-1)*(X3128/10000)*(X3128>0)*0.8+ ///
	   X3232*(X3219==3)*(X3232!=-1)*(X3228/10000)*(X3228>0)*0.8+ ///
	   (X3415==1)*X3418*(X3418!=-1)*0.8
	   
gen profitOCATRE= 0+ ///
         (X3132*(X3119==4)*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*(X3219==4)*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OCratio*0.7*0.6 + ///
	   (X3419==1)*X3422*(X3422!=-1)*0.7*0.6 ///	   

gen profitOTATRE= 0+ ///
         (X3132*((X3119==6)+(X3119==40)+(X3119==-7))*(X3128/10000)*(X3128>0)*(X3132!=-1)+ ///
	   X3232*((X3219==6)+(X3219==40)+(X3219==-7))*(X3228/10000)*(X3228>0)*(X3232!=-1))*0.7*0.6+ ///
	   (X3337!=-1)*X3337*OTratio*0.7*0.6 + ///
	   (X3427==1)*X3430*(X3430!=-1)*0.7*0.6

*** Adjustment for labour 

gen profitATRELA=profitATRE-setotalwage
gen profitPTATRELA=profitPTATRE-setotalwage_pt
gen profitSPATRELA=profitSPATRE-setotalwage_sp
gen profitSATRELA=profitSATRE-setotalwage_s
gen profitOCATRELA=profitOCATRE-setotalwage_oc
gen profitOTATRELA=profitOTATRE-setotalwage_ot
			
foreach var of varlist BUSch* profit* {
	replace `var' = round(`var') 
	}
	cap rename (PAYPEN* PAYHI* PAYILN* VEH_INST PAYVEH*) (paypen* payhi* payiln* veh_inst payveh*) 
	cap rename (j*) (J*)
  keep year y1 yy1 J101 asset debt networth fin tpay houses homeeq oresre resdbt ssretinc transfothinc nnresre vehic veh_inst othfin equity othnfin payins paypen* mortpay payveh* payhi* payiln* conspay revpay income married bussefarminc wgt bus actbus X3103 wageinc X5714 X5712 X6765 intdivinc kginc nonactbus X5704 X1224 X8022 X104 X110 X116 X122 X128 X134 X204 X210 X216 X222 X1225 X1730 X1830 X5706 X5708 X7021 X5710 BUScheck* profit* 


save "`out'/wealth_wip_stats_type", replace
use "`out'/wealth_stats_type", clear
append using "`out'/wealth_wip_stats_type"
save "`out'/wealth_stats_type", replace

}

order year y1 yy1

replace BUScheckSP = BUScheckactSP if BUScheckSP==.

gen accred = .
replace accred = 1 if networth - houses > 1000000 
replace accred = 1 if accred==. & married==1 & income>300000 
replace accred = 1 if accred==. & married==2 & income>200000 
replace accred = 0 if accred ==.

local out  "C:\Users\mguha\Dropbox\Equity&WealthIneq\Maitreyee\data"
save "`out'\coefdata_adjusted.dta", replace 