*net install randomizr, from(https://raw.githubusercontent.com/DeclareDesign/strandomizr/master/) replace
*ssc install ralpha 

**Block Random Assignment Tests
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

clear ado
set obs 13
gen y=1 in 1/5
replace y=2 if y==.
expect_error, run(block_ra, blocks(y) block_m_each(sdafa) replace)
expect_error, run(block_ra, blocks(y) block_m_each(1\2\3) replace)
expect_error, run(block_ra, blocks(y) block_m_each(1) replace)
expect_error, run(block_ra, blocks(y) block_m_each(1,4\4,9) replace)
expect_error, run(block_ra, blocks(y) block_m_each(1,4\4,0) replace)

expect_error, run(block_ra, blocks(y) block_prob_each(sdafa) replace)
expect_error, run(block_ra, blocks(y) block_prob_each(1\2\3) replace)
expect_error, run(block_ra, blocks(y) block_prob_each(1) replace)
expect_error, run(block_ra, blocks(y) block_prob_each(.1,.9\0,1.2) replace)
expect_error, run(block_ra, blocks(y) block_prob_each(.1,.8\0,1) replace)

expect_error, run(block_ra, blocks(y) m(10) replace)
expect_error, run(block_ra, blocks(y) block_m(1 1 1 10) replace)
expect_error, run(block_ra, blocks(y) block_m(13) replace)
expect_error, run(block_ra, blocks(y) block_m(1 12) replace)

expect_error, run(block_ra, blocks(y) block_prob(.1 .9 .3) replace)
expect_error, run(block_ra, blocks(y) block_prob(.1) replace)
expect_error, run(block_ra, blocks(y) block_prob(.1 .9) conditions(a a) replace)
expect_error, run(block_ra, blocks(y) block_prob(.1 .9) conditions(a) replace)
expect_error, run(block_ra, blocks(y) block_prob(.1 .9) conditions(a b c) replace)


clear all
set obs 13
gen y=1 in 1/5
replace y=2 if y==.
block_ra, blocks(y)
tab assign y, col
block_ra, blocks(y) replace
tab assign y, col
block_ra, blocks(y) m(2) replace
tab assign y, col
block_ra, blocks(y) num_arms(3) replace
tab assign y, col
block_ra, blocks(y) prob(.2) replace
tab assign y, col
block_ra, blocks(y) block_m(1 2) replace
tab assign y, col
block_ra, blocks(y) block_prob(.2 .5) replace
tab assign y, col
block_ra, blocks(y) prob_each(.2 .2 .6) replace
tab assign y, col
block_ra, blocks(y) block_prob_each(.2,.2,.6\.1,.1,.8) replace
tab assign y, col
matrix define m=(.2,.2,.6\.1,.1,.8)
block_ra, blocks(y) block_prob_each(m) replace
tab assign y, col
block_ra, blocks(y) block_m_each(1,2,2\4,0,4) replace
tab assign y, col
matrix define m=(1,2,2\4,0,4)
block_ra, blocks(y) block_m_each(m) replace
tab assign y, col
block_ra, blocks(y) conditions(a b) replace  
tab assign y, col
block_ra, blocks(y) conditions(2 3) replace  
tab assign y, col

clear all
set obs 350
gen y=1 in 1/50
replace y=2 in 51/150
replace y=3 if y==.

block_ra, blocks(y) prob_each(.213 .568 .219) replace
tab assign y, col

block_ra, blocks(y) prob(1) replace
tab assign y, col
block_ra, blocks(y) prob(0) replace
tab assign y, col





