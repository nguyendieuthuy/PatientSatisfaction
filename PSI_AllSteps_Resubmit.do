* 		File Description
*************************************************
*Author: Thuy Nguyen
*Date created: 12/01/2017
*Date modified: 12/15/2017
*Purpose: step 2: merging data

clear
cap clear matrix
/*Working Directories*/
* change to your working directory
* you need intermediate_results, plot, source, log, data folders

global basedir "/N/dc2/scratch/thdnguye/PSI"
global intdir "${basedir}/intermediate_results"
global plotdir "${basedir}/writeup/plot"
global tabledir "${basedir}/writeup/table"
global sourcedir "${basedir}/source"
global logdir "${basedir}/log"
global datadir "${basedir}/data"

/* Start log */
capture log close
log using "${logdir}/PSI_allsteps_2017_2018.log", replace

clear
cd "${basedir}"

clear
set matsize 11000
clear mata
set maxvar 32767

***************************************************************************
* reading files and explore the data dictionary
***************************************************************************
//

//2017
use   "${datadir}/bang_hoi_nguoi_benh_skvn_round3_stata14.dta",clear
codebook k6
codebook k6 if mabv==60103 
sum

gen year=2017
sort uid year
tab mabv
tab khoaphong
ren k5 respondent
ren k8 tg_nam_vien
tab k2
tab i6,nolabel
tab i6b
tab i6 i6b
ren k6 age
ren k7 gender
ren g1 b2 
ren g2 g1 
ren h1 g2
ren e1 e2
ren e1a e2a
ren e0 e1  
ren i6 d_ngheo
codebook mabn mabv khoaphong
sort mabn year
drop uid
save "${intdir}/PSI_hlnb2017.dta",replace


// 2018
use   "${datadir}/hlnb_2018.dta",clear
*codebook
ren c11 c1
ren h1 h3  /* overall patient satisfaction*/
gen year=2018
tab benhvien, nolabel
ren benhvien mabv
tostring sid, gen(mabn)
sort mabn year
drop uid _age18 _age1824 _age2534 _age3544 _age4554 _age5464 _age6574 _age7584 ///
_age85 _tg_nam_vien1 _tg_nam_vien3 _tg_nam_vien37 _tg_nam_vien7 edu1 edu2 edu3 ///
edu4 edu5 edu6 edu7 employ1 employ2 employ3 employ4 employ5 employ6 employ7 employ8 d_ngheo gender loaiphong

ren k4 gender
decode khoaphong, gen(khoaphongcode)
ren khoaphong khoaphong_num
ren khoaphongcode khoaphong
tab khoaphong, nolabel
ren k1 respondent
ren k7 k1
ren k8 k4
ren k6 location
ren k3 k6
ren location k3
ren k5 k8 
recode i1 (2= 0)
tab i1
recode i3 (2= 0)
tab i3
recode k2 (1 = 0) (2= 1)
tab i3
tab i6,nolabel
tab i6b,nolabel
tab k3
recode i6  (2= 0)
tab i6
ren i6 d_ngheo
tab i6 i6b
recode e2a (2=0)
codebook mabn mabv khoaphong
compress
save "${intdir}/PSI_hlnb2018.dta",replace

//  matching 2 datasets
use  "${intdir}/PSI_hlnb2018.dta",clear
merge m:1 mabn year using  "${intdir}/PSI_hlnb2017.dta", nogen ///
	keepusing(h3 a1 a2 b1 b2 c0 c1 c2 d1 d2 e1 e2 e2a g1 g2  mabn mabv khoaphong year ///
	respondent k1  k4 k3 i1 i3 k2 d_ngheo  age tg_nam_vien gender )

codebook mabn mabv khoaphong 
save "${intdir}/PSI_hlnb2017_2018.dta",replace

// generate variables
use "${intdir}/PSI_hlnb2017_2018.dta",clear
tab e2a, nolabel 

replace e2a=5 if e2a==0

foreach var in a1 a2 b1 b2 c1 c2 d1 d2 e1 e2a g1 g2 {
gen `var'_45=0
replace `var'_45=1 if `var'==5| `var'==4
gen `var'_5=`var'==5
gen `var'_345=0
replace `var'_345=1 if `var'==5| `var'==4| `var'==3
}

recode e2a (5=1) (1=0)
tab e2a  // 1: no need to pay; 0 need to pay; higher score is better


    gen answer99 = 1 
foreach var in a1 a2 b1 b2 c1 c2 d1 d2 e1 e2a g1 g2 {
tab `var'
replace answer99= 0 if `var'==-99
}
tab answer99
	    



ren c0 loaiphong
recode loaiphong (1=0) (2 =1)

tab k1,gen(EDU)
tab k4,gen(OCU)
	gen respondent1=respondent==1
	tab respondent1
	
	 tab year,gen(YR) 
	 tab k3,gen(area)
	 gen rural = 0
	 replace rural =1 if area4==1 | area5==1 |area6==1
	label var rural "\hspace*{1em}Rural [0-1]"
	label var area2 "\hspace*{1em}Central city"
	label var area3 "\hspace*{1em}Provincial city"
	label var area4 "\hspace*{1em}Suburban"
	label var area5 "\hspace*{1em}Rural"
	label var area6 "\hspace*{1em}Remote areas"
	label var k1 "\hspace*{1em}Patient answered"
	
// descriptive table
	foreach var in h3 a1_45 a2_45 b1_45 b2_45 c1_45 c2_45 d1_45 d2_45 e1_45 e2a_45 g1_45 g2_45 ///
	 age gender  k3 k2 EDU9 EDU8 EDU7 EDU6 EDU5 EDU4 EDU3 ///
	 OCU2 OCU3 OCU4 OCU5 OCU6 OCU7 OCU8 respondent i1 d_ngheo tg_nam_vien loaiphong {
	 drop if `var'<0
	 }
	 
	 
	 
	 
	tab age
	replace age=year-age if age==1966
	drop if age<18

	gen expectation70=0
	replace expectation70=1 if h3>=70
	gen expectation80=0
	replace expectation80=1 if h3>=80
	gen expectation90=0
	replace expectation90=1 if h3>=90	
	gen expectation100=0
	replace expectation100=1 if h3>=100
	
	gen ltg_nam_vien=log(tg_nam_vien)
	gen days0_3 = 0
	replace days0_3=1 if tg_nam_vien<=3
	gen days4_7 = 0
	replace days4_7=1 if tg_nam_vien>3 & tg_nam_vien < =7
	gen days8_20 = 0
	replace days8_20=1 if tg_nam_vien>7 & tg_nam_vien <= 20
	gen days21_more = 0
	replace days21_more=1 if tg_nam_vien>20 & tg_nam_vien != .


	gen age18_29 = 0
	replace age18_29=1 if age<30
	gen age30_39 = 0
	replace age30_39=1 if age<40 & age >=30
	gen age40_49 = 0
	replace age40_49=1 if age<50 & age >= 40
	gen age50_59 = 0
	replace age50_59=1 if age<60 & age >= 50
	gen age60_more = 0
	replace age60_more=1 if age >= 60
	gen age50_more = 0
	replace age50_more=1 if age >= 50
			
		
	bysort  mabv: sum h3 
	recode gender (2 = 0)

	logit c1_45   gender age k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3 OCU5 OCU6 OCU7 OCU8  rural i1  d_ngheo tg_nam_vien ///
	 loaiphong YR2 i.mabv  , robust cluster( mabv)  


	logit e2a_45   gender age k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3 OCU5 OCU6 OCU7 OCU8  rural i1  d_ngheo tg_nam_vien ///
	 loaiphong YR2 i.mabv  , robust cluster( mabv)  
	bysort mabv: sum (e2a_45)
	
	
	logit expectation70   gender age k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3 OCU5 OCU6 OCU7 OCU8  rural i1  d_ngheo tg_nam_vien ///
	 loaiphong YR2 i.mabv if answer99==1 , robust cluster( mabv)  
 	gen include=e(sample)==1	
	
	keep if include==1
	tab include if answer99==1
	

	label var age50_more "\hspace*{1em}Aged 50 or more [0-1]"	
	label var days0_3 "\hspace*{1em}Length of stay (0-3 days) [0-1]"	
	label var days4_7 "\hspace*{1em}Length of stay (4-7 days) [0-1]"	
	label var days8_20 "\hspace*{1em}Length of stay (8-20 days) [0-1]"	
	label var days21_more "\hspace*{1em}Length of stay ($\geq$21) [0-1]"	

	label var age18_29 "\hspace*{1em}Age (18-29) [0-1]"	
	label var age30_39 "\hspace*{1em}Age (30-39) [0-1]"	
	label var age40_49 "\hspace*{1em}Age (40-49) [0-1]"	
	label var age50_59 "\hspace*{1em}Age (50-59) [0-1]"	
	label var age60_more "\hspace*{1em}Age ($\geq$60) [0-1]"	
	label var age50_more "\hspace*{1em}Age ($\geq$50) [0-1]"	

	label var expectation70 "\hspace*{1em}$\geq$70 of expectation [0-1]"	
	label var expectation80 "\hspace*{1em}$\geq$80 of expectation [0-1]"	
	label var expectation90 "\hspace*{1em}$\geq$90 of expectation [0-1]"	
	label var expectation100 "\hspace*{1em}$\geq$100 of expectation [0-1]"	
	label var respondent1 "\hspace*{1em}Patient answered [0-1]"
	label var h3 "\hspace*{1em}Percent of overall expectation [0-200]"
	label var a1_45 "\hspace*{1em}Access to medical staff (4,5) [0-1]"
	label var a2_45 "\hspace*{1em}Facility maps/directions (4,5) [0-1]"
	label var b1_45 "\hspace*{1em}Transparency in treatment information (4,5) [0-1]"
	label var b2_45 "\hspace*{1em}Transparency in medicines \& costs (4,5) [0-1]"
	label var c1_45 "\hspace*{1em}Bed \& associaries (4,5) [0-1]"
	label var c2_45 "\hspace*{1em}Hospital restrooms (4,5) [0-1]"
	label var d1_45 "\hspace*{1em}Attitudes of medical staff (4,5) [0-1]"
	label var d2_45 "\hspace*{1em}Expertise of medical staff (4,5) [0-1]"
	label var e1_45 "\hspace*{1em}Treatment costs (4,5) [0-1]"
	label var e2a_45 "\hspace*{1em}Informal payments not requested [0-1]"
	label var g1_45 "\hspace*{1em}Medical deliveries \& instructions (4,5) [0-1]"
	label var g2_45 "\hspace*{1em}Results of treatment (4,5) [0-1]"

	label var a1 "\hspace*{1em}Access to medical staff [1-5]"
	label var a2 "\hspace*{1em}Facility maps/directions [1-5]"
	label var b1 "\hspace*{1em}Transparency in treatment information [1-5]"
	label var b2 "\hspace*{1em}Transparency in medicines \& costs [1-5]"
	label var c1 "\hspace*{1em}Bed \& associaries [1-5]"
	label var c2 "\hspace*{1em}Hospital restrooms [1-5]"
	label var d1 "\hspace*{1em}Attitudes of medical staff [1-5]"
	label var d2 "\hspace*{1em}Expertise of medical staff [1-5]"
	label var e1 "\hspace*{1em}Treatment costs [1-5]"
	label var e2a "\hspace*{1em}Informal payments not requested [0-1]"
	label var g1 "\hspace*{1em}Medical deliveries \& instructions [1-5]"
	label var g2 "\hspace*{1em}Results of treatment [1-5]"
	
	
	label var YR2 "\hspace*{1em}2018 [0-1]"
	label var gender "\hspace*{1em}Male [0-1]"
	label var age "\hspace*{1em}Age [18-99]"
	label var k2 "\hspace*{1em}Race (Kinh) [0-1]"	
	label var k3 "\hspace*{1em}Living area"
	label var EDU9 "\hspace*{1em}Postgraduate education [0-1]"
	label var EDU8 "\hspace*{1em}College [0-1]"
	label var EDU7 "\hspace*{1em}Vocational training [0-1]"
	label var EDU6 "\hspace*{1em}High school [0-1]"
	label var EDU5 "\hspace*{1em}Secondary school [0-1]"
	label var EDU4 "\hspace*{1em}Elementary school [0-1]"
	label var EDU3 "\hspace*{1em}No education [0-1]"
	label var OCU2 "\hspace*{1em}Farmer/fisher/salt farmer [0-1]"
	label var OCU3 "\hspace*{1em}Government sector [0-1]"
	label var OCU4 "\hspace*{1em}Private companies/FDI [0-1]"
	label var OCU5 "\hspace*{1em}Small business [0-1]"
	label var OCU6 "\hspace*{1em}Hourly worker [0-1]"
	label var OCU7 "\hspace*{1em}Retired, social beneficiaries [0-1]"
	label var OCU8 "\hspace*{1em}Unemployed, students [0-1]"

	label var i1 "\hspace*{1em}Health insurance [0-1]"
	label var i3 "\hspace*{1em}Covered by insurance [0-1]"
	label var d_ngheo "\hspace*{1em}Poor [0-1]"
	label var tg_nam_vien "\hspace*{1em}Days of hospital stay, days/stay"
	label var loaiphong "\hspace*{1em}Extra service fees [0-1]"
	

	keep h3 expectation80 expectation90 expectation100 ///
		d1 d2 a1 g1 c1 c2  a2 ///
		e1 b2 e2a    k3 expectation70 expectation80 expectation90 expectation100  ///
		age gender k2 EDU9 EDU8 EDU7 EDU6 EDU5 EDU4 EDU3 ///
		OCU2 OCU3 OCU4 OCU5 OCU6 OCU7 OCU8 rural respondent1 i1 d_ngheo tg_nam_vien loaiphong   ///
		a1_45 a2_45 b1_45 b2_45 c1_45 c2_45 d1_45 d2_45 e1_45 e2a_45 g1_45 g2_45 ///
		age50_more k2 EDU9 EDU8 EDU7 OCU2 OCU3 OCU5 OCU6 OCU7 OCU8  rural i1 ///
		d_ngheo days4_7 days8_20 days21_more loaiphong YR2 mabv include 
		 // keep the variables for replicate the results
		 
		 
	save "${intdir}/PSI_hlnb2017_2018_final_set.dta",replace 
	
	
	// produce tables 
	
	use "${intdir}/PSI_hlnb2017_2018_final_set.dta",clear	
		
	global vars h3 expectation80 expectation90 expectation100 ///
		d1 d2 a1 g1 c1 c2  a2 ///
		e1 b2 e2a      ///
		age gender k2 EDU9 EDU8 EDU7 EDU6 EDU5 EDU4 EDU3 ///
		OCU2 OCU3 OCU4 OCU5 OCU6 OCU7 OCU8 rural respondent1 i1 d_ngheo tg_nam_vien loaiphong   

	sum h3 a1_45 a2_45 b1_45 b2_45 c1_45 c2_45 d1_45 d2_45 e1_45 e2a_45 g1_45 g2_45 ///
	 age gender  k3  EDU9 EDU8 EDU7 EDU6 EDU5 EDU4 EDU3 ///
	 OCU2 OCU3 OCU4 OCU5 OCU6 OCU7 OCU8 rural respondent1 i1 d_ngheo tg_nam_vien loaiphong   

	 	
		estpost tabstat $vars,  statistics( mean sd p50 min max n) columns(s)
		eststo SUM_all
		eststo all: estpost summarize  $vars  ///
		if YR2==0 | YR2==1, detail 
		eststo post: estpost summarize $vars   ///
		if YR2==1 , detail
		eststo before:   estpost summarize $vars  ///
		if YR2==0, detail
		eststo diff: estpost ttest $vars   ///
		if YR2==0 | YR2==1 , by(YR2) unequal 
	 			
		esttab SUM_all using "${tabledir}/PSI_summary2017_2018.tex",  ///
		replace nonum f label ///
		cell((mean(label(Mean) fmt(a2)) sd(par label("Std. Dev") fmt(a2)) p50(label(Median) fmt(a2)) min(label(Min)) max(label(Max)) )) ///
		mgroup("All Physicians:", pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{l}{) suffix(}) span erepeat(\cmidrule(lr){@span}) ) 
	
		esttab all  before post  diff using "${tabledir}/PSI_balancetable2017_2018.tex", replace ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		label booktabs f plain ///
		cells("mean(pattern(1 1 1 0 ) fmt(a2)) b(star pattern(0 0 0 1) fmt(a2))" sd(pattern(1 1 1 0) par fmt(a2))) ///
		collabels(none)  ///
		stats(N, fmt(%18.0g) labels("\midrule Observations")) ///
		mgroup("All patients"  "2017" "2018" "Difference" , pattern(1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}) )
	
 	

// regression models
	use "${intdir}/PSI_hlnb2017_2018_final_set.dta",clear	

foreach var in h3  {
	reg `var'   gender age50_more k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3 OCU5 OCU6 OCU7 OCU8  rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 i.mabv if include==1 , robust cluster( mabv)  
		estadd fitstat
		estadd ysumm
		estadd local hospitalfe "Yes"
		eststo `var'1
	reg `var' i1 days4_7 days8_20 days21_more loaiphong d_ngheo YR2 i.mabv if include==1 , robust cluster( mabv)  
		estadd fitstat
		estadd ysumm
		estadd local hospitalfe "Yes"
		eststo `var'2
	}



foreach var in expectation70 expectation80 expectation90 expectation100 ///
a1_45 a2_45 b1_45 b2_45 c1_45 c2_45 d1_45 d2_45 e1_45 e2a_45 g1_45 g2_45 {
	logit `var'   gender  age50_more k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3  OCU5 OCU6 OCU7 OCU8 rural YR2 if include==1 , robust cluster( mabv)  
		estadd fitstat
		estadd ysumm
		estadd local hospitalfe "No"
		eststo PSI`var'1
		eststo PSI`var'1			
	logit `var'   gender age50_more k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3  OCU5 OCU6 OCU7 OCU8 rural i1  d_ngheo YR2 if include==1 , robust cluster( mabv)  
		estadd fitstat
		estadd ysumm
		estadd local hospitalfe "No"
		eststo PSI`var'2
		eststo PSI`var'2	
	logit `var'   gender  age50_more k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3  OCU5 OCU6 OCU7 OCU8 rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 if include==1 , robust cluster( mabv)  
		estadd fitstat
		estadd ysumm
		estadd local hospitalfe "No"
		eststo PSI`var'3
		eststo PSI`var'3	
	logit `var'   gender  age50_more k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3  OCU5 OCU6 OCU7 OCU8 rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 i.mabv if include==1 , robust cluster( mabv)  
		estadd fitstat
		estadd ysumm
		estadd local hospitalfe "No"
		eststo PSI`var'4
		eststo PSI`var'4	
	}

	logit c1_45  gender  age50_more k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3  OCU5 OCU6 OCU7 OCU8 rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 i.mabv if include==1 , robust cluster( mabv)  
		estadd fitstat

	// OLS models
	esttab  h32 h31 ///
	 using "${tabledir}/PSI_OLS_rate.tex",   ///
	keep( gender  age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order(i1 days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender  age50_more k2     YR2 ) ///
		starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N r2_adj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SD" "Observation" "Adj R-squared"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	

	   
	   // Logit models
		
 	esttab  PSIexpectation804 PSIexpectation904 ///
	 PSIexpectation1004  ///
	 using "${tabledir}/PSI_LOGITexpectation80_100.tex", eform ///
	keep( gender  age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order(i1 days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender  age50_more k2     YR2 ) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N r2_mfadj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SD" "Observation" "McFadden's Adj R-squared"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	


	esttab  PSIc1_454 PSIc2_454  PSIa2_454 ///
	 using "${tabledir}/PSI_LOGITFACILITY.tex", eform ///
	keep( gender  age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order( i1 days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender  age50_more k2     YR2 ) ///
		starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N  r2_mfadj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SD" "Observation" "McFadden's Adj R-squared"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	


	esttab PSId1_454 PSId2_454 PSIa1_454 PSIg1_454   ///
	 using "${tabledir}/PSI_LOGITSTAFF.tex", eform ///
	keep( gender age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order(i1 days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender  age50_more k2     YR2 ) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N r2_mfadj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SE" "Observation" "R2"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	

	esttab PSIe1_454  PSIb2_454  PSIe2a_454  ///
	 using "${tabledir}/PSI_LOGITCOST.tex", eform ///
	keep( gender age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo  days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order( i1  days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender age50_more k2     YR2 ) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N r2_mfadj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SD" "Observation" "McFadden's Adj R-squared"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	
	    

	    
	    // ordered logit models
 
	    
foreach var in a1 a2 b1 b2 c1 c2 d1 d2 e1 e2a g1 g2 {
	ologit `var'   gender  age50_more k2 EDU9 EDU8 EDU7  ///
	 OCU2 OCU3  OCU5 OCU6 OCU7 OCU8 rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 i.mabv if include==1 , robust cluster( mabv)  
		estadd ysumm
		estadd local hospitalfe "No"
		eststo PSI`var'O4
	}
	    

	    	esttab  PSIc1O4 PSIc2O4  PSIa2O4 ///
	 using "${tabledir}/PSI_OLOGITFACILITY.tex", eform ///
	keep( gender  age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order( i1 days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender  age50_more k2     YR2 ) ///
		starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N  r2_mfadj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SD" "Observation" "McFadden's Adj R-squared"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	


	esttab PSId1O4 PSId2O4 PSIa1O4 PSIg1O4   ///
	 using "${tabledir}/PSI_OLOGITSTAFF.tex", eform ///
	keep( gender age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order(i1 days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender  age50_more k2     YR2 ) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N r2_mfadj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SE" "Observation" "R2"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	

	esttab PSIe1O4  PSIb2O4  PSIe2aO4  ///
	 using "${tabledir}/PSI_OLOGITCOST.tex", eform ///
	keep( gender age50_more k2 EDU9 EDU8 EDU7  ///
	  OCU3  OCU5  OCU2 OCU6 OCU7 OCU8  rural i1  d_ngheo  days4_7 days8_20 days21_more loaiphong YR2 ) ///
	order( i1  days4_7 days8_20 days21_more loaiphong d_ngheo   rural OCU3  OCU5  OCU2 OCU6 OCU7 OCU8 ///
	EDU9 EDU8 EDU7 gender age50_more k2     YR2 ) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) label ///
	    booktabs b(a2) se(a2) eqlabels(none) alignment(S S) ///
	    stats(ymean ysd N r2_mfadj hospitalfe  , fmt(%3.2f %3.2f 0 %3.2f ) ///
	    layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	    label("\hline \hline Dep. Variable Mean" "Dep. Variable SD" "Observation" "McFadden's Adj R-squared"   "Hospital FEs" )) ///
	    f substitute(\_ _) ///
	    noline collabels(none) ///
	    nogaps compress nomtitles ///
	    replace	
	    
