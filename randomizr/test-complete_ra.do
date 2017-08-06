*net install randomizr, from(https://raw.githubusercontent.com/DeclareDesign/strandomizr/master/) replace
*ssc install ralpha 

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
set obs 101
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


//each syntax permutation
clear all
set obs 101
//basics
complete_ra
tab assign
complete_ra, replace
tab assign
complete_ra treat
tab treat
complete_ra treat, replace
tab treat
complete_ra, replace condition_names(21 22)
tab assign
complete_ra treat, replace condition_names(21 22)
tab treat
complete_ra, replace condition_names(a b)
tab assign
complete_ra treat, replace condition_names(a b)
tab treat

	//with ifs
	clear all
	set obs 101
	gen y=1 in 1/50
	complete_ra if y==1
	tab assign y, miss
	complete_ra if y==1, replace
	tab assign y, miss
	complete_ra treat if y==1
	tab treat y, miss
	complete_ra treat if y==1, replace
	tab treat y, miss
	complete_ra if y==1, replace condition_names(21 22)
	tab assign y, miss
	complete_ra treat if y==1, replace condition_names(21 22)
	tab treat y, miss
	complete_ra if y==1, replace condition_names(a b)
	tab assign y, miss
	complete_ra treat if y==1, replace condition_names(a b)
	tab treat y, miss

	//with ins
	clear all
	set obs 101
	gen y=1
	complete_ra in 10/80
	tab assign y, miss
	complete_ra in 10/80, replace
	tab assign y, miss
	complete_ra treat in 10/80
	tab treat y, miss
	complete_ra treat in 10/80, replace
	tab treat y, miss
	complete_ra in 10/80, replace condition_names(21 22)
	tab assign y, miss
	complete_ra treat in 10/80, replace condition_names(21 22)
	tab treat y, miss
	complete_ra in 10/80, replace condition_names(a b)
	tab assign y, miss
	complete_ra treat in 10/80, replace condition_names(a b)
	tab treat y, miss

	//with by
	clear all
	set obs 101
	gen y=1 in 1/10
	replace y=2 if y==.
	bysort y: complete_ra
	tab assign y, miss
	bysort y: complete_ra, replace
	tab assign y, miss
	bysort y: complete_ra treat
	tab treat y, miss
	bysort y: complete_ra treat, replace
	tab treat y, miss
	bysort y: complete_ra, replace condition_names(21 22)
	tab assign y, miss
	bysort y: complete_ra treat, replace condition_names(21 22)
	tab treat y, miss
	bysort y: complete_ra, replace condition_names(a b)
	tab assign y, miss
	bysort y: complete_ra treat, replace condition_names(a b)
	tab treat y, miss
	

//num_arms
clear all
set obs 101
complete_ra, num_arms(2) 
tab assign
complete_ra treat, num_arms(2) 
tab treat
complete_ra, num_arms(3) replace
tab assign
complete_ra treat, num_arms(3) replace
tab treat
complete_ra, num_arms(2) replace condition_names(21 22)
tab assign
complete_ra treat, num_arms(2) replace condition_names(21 22)
tab treat
complete_ra, num_arms(3) replace condition_names(21 22 23) 
tab assign
complete_ra treat, num_arms(3) replace condition_names(21 22 23) 
tab treat
complete_ra, num_arms(2) replace condition_names(a b)
tab assign
complete_ra treat, num_arms(2) replace condition_names(a b)
tab treat
complete_ra, num_arms(3) replace condition_names(a b c)
tab assign
complete_ra treat, num_arms(3) replace condition_names(a b c)
tab treat

	//ifs
	clear all
	set obs 101
	gen y=1 in 1/50
	complete_ra if y==1, num_arms(2) 
	tab assign
	complete_ra treat if y==1 , num_arms(2) 
	tab treat
	complete_ra if y==1, num_arms(3) replace
	tab assign
	complete_ra treat if y==1 , num_arms(3) replace
	tab treat
	complete_ra if y==1, num_arms(2) replace condition_names(21 22)
	tab assign
	complete_ra treat if y==1 , num_arms(2) replace condition_names(21 22)
	tab treat
	complete_ra if y==1, num_arms(3) replace condition_names(21 22 23) 
	tab assign
	complete_ra treat if y==1 , num_arms(3) replace condition_names(21 22 23) 
	tab treat
	complete_ra if y==1, num_arms(2) replace condition_names(a b)
	tab assign
	complete_ra treat if y==1 , num_arms(2) replace condition_names(a b)
	tab treat
	complete_ra if y==1, num_arms(3) replace condition_names(a b c)
	tab assign
	complete_ra treat if y==1 , num_arms(3) replace condition_names(a b c)
	tab treat

	//ins
	clear all
	set obs 101
	gen y=1
	complete_ra in 20/80, num_arms(2) 
	tab assign
	complete_ra treat in 20/80, num_arms(2) 
	tab treat
	complete_ra in 20/80, num_arms(3) replace
	tab assign
	complete_ra treat in 20/80, num_arms(3) replace
	tab treat
	complete_ra in 20/80, num_arms(2) replace condition_names(21 22)
	tab assign
	complete_ra treat in 20/80 , num_arms(2) replace condition_names(21 22)
	tab treat
	complete_ra in 20/80, num_arms(3) replace condition_names(21 22 23) 
	tab assign
	complete_ra treat in 20/80 , num_arms(3) replace condition_names(21 22 23) 
	tab treat
	complete_ra in 20/80, num_arms(2) replace condition_names(a b)
	tab assign
	complete_ra treat in 20/80 , num_arms(2) replace condition_names(a b)
	tab treat
	complete_ra in 20/80, num_arms(3) replace condition_names(a b c)
	tab assign
	complete_ra treat in 20/80 , num_arms(3) replace condition_names(a b c)
	tab treat
	
	//bys
	clear all
	set obs 101
	gen y=1 in 1/10
	replace y=2 if y==.
	bysort y: complete_ra, num_arms(2) 
	tab assign y, miss
	bysort y: complete_ra treat, num_arms(2) 
	tab treat y, miss
	bysort y: complete_ra, num_arms(3) replace
	tab assign y, miss
	bysort y: complete_ra treat, num_arms(3) replace
	tab treat y, miss
	bysort y: complete_ra, num_arms(2) replace condition_names(21 22)
	tab assign y, miss
	bysort y: complete_ra treat, num_arms(2) replace condition_names(21 22)
	tab treat y, miss
	bysort y: complete_ra, num_arms(3) replace condition_names(21 22 23) 
	tab assign y, miss
	bysort y: complete_ra treat, num_arms(3) replace condition_names(21 22 23) 
	tab treat y, miss
	bysort y: complete_ra, num_arms(2) replace condition_names(a b)
	tab assign y, miss
	bysort y: complete_ra treat, num_arms(2) replace condition_names(a b)
	tab treat y, miss
	bysort y: complete_ra, num_arms(3) replace condition_names(a b c)
	tab assign y, miss
	bysort y: complete_ra treat, num_arms(3) replace condition_names(a b c)
	tab treat y, miss
	


//m
clear all
set obs 101
complete_ra, m(27) 
tab assign
complete_ra treat, m(27) 
tab treat
complete_ra, m(27) replace
tab assign
complete_ra treat, m(27) replace
tab treat
complete_ra, m(27) replace condition_names(21 22)
tab assign
complete_ra treat, m(27) replace condition_names(21 22)
tab treat
complete_ra, m(27) replace condition_names(a b)
tab assign
complete_ra treat, m(27) replace condition_names(a b)
tab treat
	//ifs
	clear all
	set obs 101
	gen y=1 in 1/50
	complete_ra if y==1, m(27) 
	tab assign
	complete_ra treat if y==1, m(27) 
	tab treat
	complete_ra if y==1, m(27) replace
	tab assign
	complete_ra treat if y==1, m(27) replace
	tab treat
	complete_ra if y==1, m(27) replace condition_names(21 22)
	tab assign
	complete_ra treat if y==1, m(27) replace condition_names(21 22)
	tab treat
	complete_ra if y==1, m(27) replace condition_names(a b)
	tab assign
	complete_ra treat if y==1, m(27) replace condition_names(a b)
	tab treat
	//ins
	clear all
	set obs 101
	gen y=1
	complete_ra in 20/80, m(27) 
	tab assign
	complete_ra treat in 20/80, m(27) 
	tab treat
	complete_ra in 20/80, m(27) replace
	tab assign
	complete_ra treat in 20/80, m(27) replace
	tab treat
	complete_ra in 20/80, m(27) replace condition_names(21 22)
	tab assign
	complete_ra treat in 20/80, m(27) replace condition_names(21 22)
	tab treat
	complete_ra in 20/80, m(27) replace condition_names(a b)
	tab assign
	complete_ra treat in 20/80, m(27) replace condition_names(a b)
	tab treat
	//bys
	clear all
	set obs 101
	gen y=1 in 1/10
	replace y=2 if y==.
	bysort y: complete_ra, m(27) 
	tab assign y, miss
	bysort y: complete_ra treat, m(27) 
	tab treat y, miss
	bysort y: complete_ra, m(27) replace
	tab assign y, miss
	bysort y: complete_ra treat, m(27) replace
	tab treat y, miss
	bysort y: complete_ra, m(27) replace condition_names(21 22)
	tab assign y, miss
	bysort y: complete_ra treat, m(27) replace condition_names(21 22)
	tab treat y, miss
	bysort y: complete_ra, m(27) replace condition_names(a b)
	tab assign y, miss
	bysort y: complete_ra treat, m(27) replace condition_names(a b)
	tab treat y, miss
	

//prob
clear all
set obs 101
complete_ra, prob(.333333) 
tab assign
complete_ra treat, prob(.33333333) 
tab treat
complete_ra, prob(.33333333) replace
tab assign
complete_ra treat, prob(.33333333) replace
tab treat
complete_ra, prob(.33333333) replace condition_names(21 22)
tab assign
complete_ra treat, prob(.33333333) replace condition_names(21 22)
tab treat
complete_ra, prob(.33333333) replace condition_names(a b)
tab assign
complete_ra treat, prob(.33333333) replace condition_names(a b)
tab treat
	//ifs and bys
	clear all
	set obs 101
	gen y=1 in 1/10
	replace y=2 if y==.
	replace y=3 in 21/30
	bysort y: complete_ra if y!=3, prob(.333333) 
	tab assign y, miss col
	bysort y: complete_ra treat if y!=3, prob(.33333333) 
	tab treat  y, miss col
	bysort y: complete_ra if y!=3, prob(.33333333) replace
	tab assign  y, miss col
	bysort y: complete_ra treat if y!=3, prob(.33333333) replace
	tab treat  y, miss col
	bysort y: complete_ra if y!=3, prob(.33333333) replace condition_names(21 22)
	tab assign  y, miss col
	bysort y: complete_ra treat if y!=3, prob(.33333333) replace condition_names(21 22)
	tab treat  y, miss col
	bysort y: complete_ra if y!=3, prob(.33333333) replace condition_names(a b)
	tab assign  y, miss col
	bysort y: complete_ra treat if y!=3, prob(.33333333) replace condition_names(a b)
	tab treat  y, miss col
	//ins 
	clear all
	set obs 101
	gen y=1 in 1/10
	replace y=2 if y==.
	replace y=3 in 20/30
	complete_ra in 20/80, prob(.333333) 
	tab assign, miss
	complete_ra treat in 20/80, prob(.33333333) 
	tab treat, miss
	complete_ra in 20/80, prob(.33333333) replace
	tab assign, miss
	complete_ra treat in 20/80, prob(.33333333) replace
	tab treat, miss
	complete_ra in 20/80, prob(.33333333) replace condition_names(21 22)
	tab assign, miss
	complete_ra treat in 20/80, prob(.33333333) replace condition_names(21 22)
	tab treat, miss
	complete_ra in 20/80, prob(.33333333) replace condition_names(a b)
	tab assign, miss
	complete_ra treat in 20/80, prob(.33333333) replace condition_names(a b)
	tab treat, miss
		


//prob_each
clear all
set obs 101
complete_ra, prob_each(.25 .25 .5) 
tab assign
complete_ra treat, prob_each(.25 .25 .5) 
tab treat
complete_ra, prob_each(.25 .25 .5) replace
tab assign
complete_ra treat, prob_each(.25 .25 .5) replace
tab treat
complete_ra, prob_each(.25 .25 .5) replace condition_names(21 22 23)
tab assign
complete_ra treat, prob_each(.25 .25 .5) replace condition_names(21 22 23)
tab treat
complete_ra, prob_each(.25 .25 .5) replace condition_names(a b c)
tab assign
complete_ra treat, prob_each(.25 .25 .5) replace condition_names(a b c)
tab treat
clear all
set obs 101
complete_ra, prob_each(.25 .75) 
tab assign
complete_ra treat, prob_each(.25 .75) 
tab treat
complete_ra, prob_each(.25 .75) replace
tab assign
complete_ra treat, prob_each(.25 .75) replace
tab treat
complete_ra, prob_each(.25 .75) replace condition_names(21 22 23)
tab assign
complete_ra treat, prob_each(.25 .75) replace condition_names(21 22 23)
tab treat
complete_ra, prob_each(.25 .75) replace condition_names(a b c)
tab assign
complete_ra treat, prob_each(.25 .75) replace condition_names(a b c)
tab treat
	//ifs and bys
	clear all
	set obs 101
	gen y=1 in 1/10
	replace y=2 if y==.
	replace y=3 in 21/30
	bysort y: complete_ra if y!=3, prob_each(.25 .25 .5) 
	tab assign y, miss col
	bysort y: complete_ra treat  if y!=3, prob_each(.25 .25 .5) 
	tab treat y, miss col
	bysort y: complete_ra  if y!=3, prob_each(.25 .25 .5) replace
	tab assign y, miss col
	bysort y: complete_ra treat  if y!=3, prob_each(.25 .25 .5) replace
	tab treat y, miss col
	bysort y: complete_ra  if y!=3, prob_each(.25 .25 .5) replace condition_names(21 22 23)
	tab assign y, miss col
	bysort y: complete_ra treat  if y!=3, prob_each(.25 .25 .5) replace condition_names(21 22 23)
	tab treat  y, miss col
	bysort y: complete_ra  if y!=3, prob_each(.25 .25 .5) replace condition_names(a b c)
	tab assign  y, miss col
	bysort y: complete_ra treat  if y!=3, prob_each(.25 .25 .5) replace condition_names(a b c)
	tab treat  y, miss col
	bysort y: complete_ra   if y!=3, prob_each(.25 .75) replace
	tab assign  y, miss col
	bysort y: complete_ra treat   if y!=3, prob_each(.25 .75) replace
	tab treat  y, miss col
	bysort y: complete_ra   if y!=3, prob_each(.25 .75) replace condition_names(21 22 23)
	tab assign  y, miss col
	bysort y: complete_ra treat   if y!=3, prob_each(.25 .75) replace condition_names(21 22 23)
	tab treat  y, miss col
	bysort y: complete_ra   if y!=3, prob_each(.25 .75) replace condition_names(a b c)
	tab assign y, miss col
	bysort y: complete_ra treat   if y!=3, prob_each(.25 .75) replace condition_names(a b c)
	tab treat y, miss col
	//ins
	clear all
	set obs 101
	complete_ra in 20/80, prob_each(.25 .25 .5) 
	tab assign
	complete_ra treat in 20/80, prob_each(.25 .25 .5) 
	tab treat
	complete_ra  in 20/80, prob_each(.25 .25 .5) replace
	tab assign
	complete_ra treat  in 20/80, prob_each(.25 .25 .5) replace
	tab treat
	complete_ra  in 20/80, prob_each(.25 .25 .5) replace condition_names(21 22 23)
	tab assign
	complete_ra treat  in 20/80, prob_each(.25 .25 .5) replace condition_names(21 22 23)
	tab treat
	complete_ra  in 20/80, prob_each(.25 .25 .5) replace condition_names(a b c)
	tab assign
	complete_ra treat  in 20/80, prob_each(.25 .25 .5) replace condition_names(a b c)
	tab treat
	clear all
	set obs 101
	complete_ra  in 20/80, prob_each(.25 .75) 
	tab assign
	complete_ra treat  in 20/80, prob_each(.25 .75) 
	tab treat
	complete_ra  in 20/80, prob_each(.25 .75) replace
	tab assign
	complete_ra treat  in 20/80, prob_each(.25 .75) replace
	tab treat
	complete_ra  in 20/80, prob_each(.25 .75) replace condition_names(21 22 23)
	tab assign
	complete_ra treat  in 20/80, prob_each(.25 .75) replace condition_names(21 22 23)
	tab treat
	complete_ra  in 20/80, prob_each(.25 .75) replace condition_names(a b c)
	tab assign
	complete_ra treat  in 20/80, prob_each(.25 .75) replace condition_names(a b c)
	tab treat


//m_each
clear all
set obs 101
complete_ra, m_each(25 25 50) 
tab assign
complete_ra treat, m_each(25 25 50) 
tab treat
complete_ra, m_each(25 25 50) replace
tab assign
complete_ra treat, m_each(25 25 50) replace
tab treat
complete_ra, m_each(25 25 50) replace condition_names(21 22 23)
tab assign
complete_ra treat, m_each(25 25 50) replace condition_names(21 22 23)
tab treat
complete_ra, m_each(25 25 50) replace condition_names(a b c)
tab assign
complete_ra treat, m_each(25 25 50) replace condition_names(a b c)
tab treat
clear all
set obs 101
complete_ra, m_each(25 75) 
tab assign
complete_ra treat, m_each(25 75) 
tab treat
complete_ra, m_each(25 75) replace
tab assign
complete_ra treat, m_each(25 75) replace
tab treat
complete_ra, m_each(25 75) replace condition_names(21 22 23)
tab assign
complete_ra treat, m_each(25 75) replace condition_names(21 22 23)
tab treat
complete_ra, m_each(25 75) replace condition_names(a b c)
tab assign
complete_ra treat, m_each(25 75) replace condition_names(a b c)
tab treat






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


