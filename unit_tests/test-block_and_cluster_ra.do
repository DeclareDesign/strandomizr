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


expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m_each(sdafa) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m_each(1\2\3) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m_each(1) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m_each(1,4\4,9) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m_each(1,4\4,0) replace)

expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob_each(sdafa) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob_each(1\2\3) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob_each(1) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob_each(.1,.9\0,1.2) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob_each(.1,.8\0,1) replace)

expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) m(10) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m(1 1 1 10) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m(13) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_m(1 12) replace)

expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob(.1 .9 .3) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob(.1) replace)
expect_error, run(block_and_cluster_ra, blocks(y) clusters(cluster) block_prob_each(.1,.9\0,1) prob(.2) replace)


clear all
set obs 350
gen cluster=runiformint(1,26)
gen y="block_1" if cluster>0 & cluster<=5
replace y="block_2" if cluster>5 & cluster<=10
replace y="block_3" if cluster>10 & cluster<=15
replace y="block_4" if cluster>15 & cluster<=20
replace y="block_5" if cluster>20 & cluster<=26
block_and_cluster_ra, blocks(y) clusters(cluster) replace 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra treat, blocks(y) replace clusters(cluster) 
tab treat y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) m(2) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) num_arms(3) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) prob(.2) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) block_m(1 2 3 4 5) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) block_prob(.2 .5 .4 .5 1) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) prob_each(.2 .2 .6) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) block_prob_each(.2,.2,.6\.1,.1,.8\0,0,1\1,0,0\.3,.3,.4) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
matrix define m=(.2,.2,.6\.1,.1,.8\0,0,1\1,0,0\.3,.3,.4)
block_and_cluster_ra, blocks(y) block_prob_each(m) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) block_m_each(1,1,3\5,0,0\0,4,1\1,2,2\3,0,3) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
matrix define m=(1,1,3\5,0,0\0,4,1\1,2,2\3,0,3)
block_and_cluster_ra, blocks(y) block_m_each(m) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) conditions(a b) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster
block_and_cluster_ra, blocks(y) conditions(2 3) replace clusters(cluster) 
tab assign y, col
bysort y: tab assign cluster





