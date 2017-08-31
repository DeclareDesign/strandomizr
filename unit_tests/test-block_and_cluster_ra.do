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

set obs 350
gen cluster=runiformint(1,26)
gen y="block_1" if cluster>0 & cluster<=5
replace y="block_2" if cluster>5 & cluster<=10
replace y="block_3" if cluster>10 & cluster<=15
replace y="block_4" if cluster>15 & cluster<=20
replace y="block_5" if cluster>20 & cluster<=26

expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m_each(sdafa))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m_each(1\2\3))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m_each(1))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m_each(1,4\4,9))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m_each(1,4\4,0))

expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_prob_each(sdafa))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_prob_each(1\2\3))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_prob_each(1))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_prob_each(.1,.9\0,1.2))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_prob_each(.1,.8\0,1))

expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) m(10))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m(1 1 1 10))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m(13))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_m(1 12))

expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_prob(.1 .9 .3))
expect_error, run(block_and_cluster_ra, block_var(y) cluster_var(cluster) block_prob(.1))


clear all
set obs 350
gen cluster=runiformint(1,26)
gen y="block_1" if cluster>0 & cluster<=5
replace y="block_2" if cluster>5 & cluster<=10
replace y="block_3" if cluster>10 & cluster<=15
replace y="block_4" if cluster>15 & cluster<=20
replace y="block_5" if cluster>20 & cluster<=26
block_and_cluster_ra, block_var(y) cluster_var(cluster) replace 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra treat, block_var(y) replace cluster_var(cluster) 
tab treat y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) m(2) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) num_arms(3) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) prob(.2) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) block_m(1 2 3 4 5) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) block_prob(.2 .5 .4 .5 1) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) prob_each(.2 .2 .6) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) block_prob_each(.2,.2,.6\.1,.1,.8\0,0,1\1,0,0\.3,.3,.4) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
matrix define m=(.2,.2,.6\.1,.1,.8\0,0,1\1,0,0\.3,.3,.4)
block_and_cluster_ra, block_var(y) block_prob_each(m) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) block_m_each(1,1,3\5,0,0\0,4,1\1,2,2\3,0,3) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
matrix define m=(1,1,3\5,0,0\0,4,1\1,2,2\3,0,3)
block_and_cluster_ra, block_var(y) block_m_each(m) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) condition_names(a b) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, block_var(y) condition_names(2 3) replace cluster_var(cluster) 
tab assign y, col
bysort y: tab assign cluster





