net install randomizr, from(https://raw.githubusercontent.com/DeclareDesign/strandomizr/master/)
ssc install ralpha 

**Complete Random Assignment Tests
clear all

//define a few programs
program expect_error
	syntax,run(string)
	cap `run'
	if `"`r(complete)'"'=="1" {
		disp as error "Did not error!" 
		exit
	}
end

program sim_RA, rclass
	syntax, [run(string)] reps(int)
	forval i=0/3 {
		local tr`i'=0
	}
	forval i=1/`reps' {
		qui `run'
		forval i=0/3 {
			qui count if assignment==`i'
			local tr`i'=`tr`i''+`r(N)'
		}
	}
	forval i=0/3 {
		return scalar tr`i'=`tr`i''
		disp "tr`i': " `tr`i'' " or " (`tr`i''/(_N*`reps'))*100 "%"
	}

end
	

//error testing
set obs 100
//prob tests
expect_error, run(complete_ra, prob(1.1) replace)
expect_error, run(complete_ra, prob(-1) replace)
expect_error, run(complete_ra, prob(.1 .2) replace)
expect_error, run(complete_ra, prob(.1) m(2) replace)

//m tests
expect_error, run(complete_ra, m(2 1) replace)
expect_error, run(complete_ra, m(-1) replace)
expect_error, run(complete_ra, m(1000) replace)
expect_error, run(complete_ra, m(.1) replace)

//prob_each tests
expect_error, run(complete_ra, prob_each(.2) replace)
expect_error, run(complete_ra, prob_each(.8 .9) replace)
expect_error, run(complete_ra, prob_each(-1) replace)
expect_error, run(complete_ra, prob_each(1 2) replace)

//m_each tests
expect_error, run(complete_ra, m_each(30 70), prob_each(.3 .7) replace)
expect_error, run(complete_ra, m_each(20 20 20) replace)
expect_error, run(complete_ra, m_each(20 20 60) condition_names(1 2) replace)
expect_error, run(complete_ra, m_each(10 10000) condition_names(1 2) replace)
expect_error, run(complete_ra, m_each(101 -1) replace)
expect_error, run(complete_ra, m_each(10.1 90.9) replace)

//prob_each tests
expect_error, run(complete_ra, prob_each(.2 .7) replace) 
expect_error, run(complete_ra, prob_each(.301 .7) replace) 
expect_error, run(complete_ra, prob_each(.5 .9 -.4) replace) 



//simulations 
clear 
set obs 100
sim_RA, run(complete_ra, replace) reps(1000)
sim_RA, run(complete_ra, m_each(50 50 0) replace) reps(1000)
sim_RA, run(complete_ra, m_each(100 0 0) replace) reps(1000)
sim_RA, run(complete_ra, num_arms(3) replace) reps(10000)
sim_RA, run(complete_ra, prob_each(.1 .9) replace) reps(10000)
sim_RA, run(complete_ra, prob(.1) replace) reps(10000)
sim_RA, run(complete_ra, m(30) replace) reps(10000)

clear 
set obs 13
sim_RA, run(complete_ra, num_arms(3) replace) reps(10000)
sim_RA, run(complete_ra, prob_each(.1 .9) replace) reps(10000)
sim_RA, run(complete_ra, prob_each(.15 .15 .7) replace) reps(10000)
sim_RA, run(complete_ra, m_each(1 10 2) replace) reps(10000)
clear 
set obs 1
sim_RA, run(complete_ra, num_arms(2) replace) reps(10000)
sim_RA, run(complete_ra, num_arms(3) replace) reps(10000)
sim_RA, run(complete_ra, prob_each(.1 .2 .7) replace) reps(10000)
sim_RA, run(complete_ra, prob(.1) replace) reps(10000)
sim_RA, run(complete_ra, m(1) replace) reps(10000)
clear 
set obs 3
sim_RA, run(complete_ra, replace) reps(10000)



//test labels 
clear 
set obs 100
complete_ra, prob_each(.1 .9) replace condition_names(a b)
tab assign
tab assign, nolab
complete_ra, prob_each(.1 .9) replace condition_names(1 2)
tab assign
complete_ra, prob_each(.1 .8 .1) replace condition_names(23 24 25)
tab assign
complete_ra, prob_each(.1 .8 .1) replace condition_names(a b c)
tab assign
tab assign, nolab


//testing speed
/*
//first generate dummy dataset
/*
clear
set obs 1000000
gen y=rnormal()
ralpha 
gen longstring="The quick brown fox jumped over the lazy dog/The quick brown fox jumped over the lazy dog/The quick brown fox jumped over the lazy dog"
gen longstring2=ralpha+"2131294213849#!$@#$#@$2"
forval x=1/100 {
	ralpha l`x'
}
egen longstring3=concat(l1-l100)
save synth_data_million.dta, replace
*/

clear
use synth_data_million.dta
timer clear 1
timer on 1
complete_ra, replace
timer off 1 
timer list 1

clear
use synth_data_million.dta
timer clear 1
timer on 1
gen rand=runiform()
sort rand 
egen treat=seq(), from(0) to(1)
timer off 1 
timer list 1
*/

//first generate dummy dataset
/*
clear
set obs 10000000
gen y=rnormal()
ralpha 
gen longstring="The quick brown fox jumped over the lazy dog/The quick brown fox jumped over the lazy dog/The quick brown fox jumped over the lazy dog"
gen longstring2=ralpha+"2131294213849#!$@#$#@$2"
forval x=1/100 {
	ralpha l`x'
}
egen longstring3=concat(l1-l100)
save synth_data_ten_million.dta, replace
*/

/*
clear
use synth_data_ten_million.dta
timer clear 1
timer on 1
complete_ra, replace
timer off 1 
timer list 1

clear
use synth_data_ten_million.dta
timer clear 1
timer on 1
gen rand=runiform()
sort rand 
egen treat=seq(), from(0) to(1)
timer off 1 
timer list 1
*/



//should i include these?
*set obs 100
*complete_ra treat, num_arms(1) replace 
*complete_ra treat, m_each(100) replace 
*complete_ra treat, condition_names(Treatment) 







/*




complete_ra treat, m(30) condition_names(Control Treatment) replace
tab treat

complete_ra treat, replace
tab treat
complete_ra treat, m(50) replace
tab treat
complete_ra treat, m_each(30 70) condition_names(control treatment) replace
tab treat

set obs 101
complete_ra treat, prob(.34) replace
tab treat
complete_ra treat, prob_each(.34 .66) replace
tab treat

*special case tests
clear
set obs 1
complete_ra treat, m(1) replace
tab treat
complete_ra treat, m(0) replace
tab treat
expect_error, run(complete_ra, m(2) replace)
complete_ra treat, num_arms(2) replace
tab treat
label list
complete_ra treat, num_arms(2) condition_names(a b) replace
tab treat




//multi-arm tests
clear 
set obs 100
complete_ra treat, num_arms(3) replace
tab treat
	
complete_ra treat, m_each(30 30 40) replace
complete_ra treat, m_each(30 30 40) replace condition_names(control placebo treatment)
complete_ra treat, replace condition_names(control placebo treatment)


//special cases 
clear 
set obs 2
complete_ra treat, m_each(1 0 1) condition_names(control placebo treatment) replace

clear
set obs 1
sim_RA, run(complete_ra, replace) reps(1000)

clear 
set obs 100
sim_RA, run(complete_ra, m_each(50 50 0) replace) reps(1000)
sim_RA, run(complete_ra, m_each(100 0 0) replace) reps(1000)


clear 
set obs 13



/*


