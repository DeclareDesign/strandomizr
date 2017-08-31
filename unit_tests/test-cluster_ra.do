*net install randomizr, from(https://raw.githubusercontent.com/DeclareDesign/strandomizr/master/) replace
*ssc install ralpha 

**Cluster Random Assignment Tests
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
gen cluster=runiformint(1,26)

//prob tests
expect_error, run(cluster_ra, prob(.1) replace)
expect_error, run(cluster_ra, cluster_var(cluster) prob(1.1) replace)
expect_error, run(cluster_ra, cluster_var(cluster) prob(-1) replace)
expect_error, run(cluster_ra, cluster_var(cluster) prob(.1 .2) replace)
expect_error, run(cluster_ra, cluster_var(cluster) prob(.1) m(2) replace)

//m tests
expect_error, run(cluster_ra, cluster_var(cluster) m(2 1) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m(-1) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m(1000) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m(.1) replace)

//prob_each tests
expect_error, run(cluster_ra, cluster_var(cluster) prob_each(.2) replace)
expect_error, run(cluster_ra, cluster_var(cluster) prob_each(.8 .9) replace)
expect_error, run(cluster_ra, cluster_var(cluster) prob_each(-1) replace)
expect_error, run(cluster_ra, cluster_var(cluster) prob_each(1 2) replace)

//m_each tests
expect_error, run(cluster_ra, cluster_var(cluster) m_each(30 70), prob_each(.3 .7) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m_each(20 20 20) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m_each(20 20 60) condition_names(1 2) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m_each(10 10000) condition_names(1 2) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m_each(101 -1) replace)
expect_error, run(cluster_ra, cluster_var(cluster) m_each(10.1 90.9) replace)

//prob_each tests
expect_error, run(cluster_ra, cluster_var(cluster) prob_each(.2 .7) replace) 
expect_error, run(cluster_ra, cluster_var(cluster) prob_each(.301 .7) replace) 
expect_error, run(cluster_ra, cluster_var(cluster) prob_each(.5 .9 -.4) replace) 


//each syntax permutation
clear all
set obs 101
gen cluster=runiformint(1,26)

//basics
cluster_ra, cluster_var(cluster)
tab assign cluster
cluster_ra, cluster_var(cluster) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster)
tab treat cluster
cluster_ra treat, cluster_var(cluster) replace
tab treat cluster
cluster_ra, cluster_var(cluster) replace condition_names(21 22)
tab assign cluster
cluster_ra treat, cluster_var(cluster) replace condition_names(21 22)
tab treat cluster
cluster_ra, cluster_var(cluster) replace condition_names(a b)
tab assign cluster
cluster_ra treat, cluster_var(cluster) replace condition_names(a b)
tab treat cluster

//num_arms
clear all
set obs 101
gen cluster=runiformint(1,26)
cluster_ra, cluster_var(cluster) num_arms(2) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) num_arms(2) 
tab treat cluster
cluster_ra, cluster_var(cluster) num_arms(3) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster) num_arms(3) replace
tab treat cluster
cluster_ra, cluster_var(cluster) num_arms(2) replace condition_names(21 22)
tab assign cluster
cluster_ra treat, cluster_var(cluster) num_arms(2) replace condition_names(21 22)
tab treat cluster
cluster_ra, cluster_var(cluster) num_arms(3) replace condition_names(21 22 23) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) num_arms(3) replace condition_names(21 22 23) 
tab treat cluster
cluster_ra, cluster_var(cluster) num_arms(2) replace condition_names(a b)
tab assign cluster
cluster_ra treat, cluster_var(cluster) num_arms(2) replace condition_names(a b)
tab treat cluster
cluster_ra, cluster_var(cluster) num_arms(3) replace condition_names(a b c)
tab assign cluster
cluster_ra treat, cluster_var(cluster) num_arms(3) replace condition_names(a b c)
tab treat cluster


//m
clear all
set obs 101
gen cluster=runiformint(1,26)

cluster_ra, cluster_var(cluster) m(21) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) m(21) 
tab treat cluster
cluster_ra, cluster_var(cluster) m(21) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster) m(21) replace
tab treat cluster
cluster_ra, cluster_var(cluster) m(21) replace condition_names(8 9)
tab assign cluster
cluster_ra treat, cluster_var(cluster) m(21) replace condition_names(8 9)
tab treat cluster
cluster_ra, cluster_var(cluster) m(21) replace condition_names(a b)
tab assign cluster
cluster_ra treat, cluster_var(cluster) m(21) replace condition_names(a b)
tab treat cluster
	

//prob
clear all
set obs 101
gen cluster=runiformint(1,26)

cluster_ra, cluster_var(cluster) prob(.333333) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob(.33333333) 
tab treat cluster
cluster_ra, cluster_var(cluster) prob(.33333333) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob(.33333333) replace
tab treat cluster
cluster_ra, cluster_var(cluster) prob(.33333333) replace condition_names(21 22)
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob(.33333333) replace condition_names(21 22)
tab treat cluster
cluster_ra, cluster_var(cluster) prob(.33333333) replace condition_names(a b)
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob(.33333333) replace condition_names(a b)
tab treat cluster


//prob_each
clear all
set obs 101
gen cluster=runiformint(1,26)

cluster_ra, cluster_var(cluster) prob_each(.25 .25 .5) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .25 .5) 
tab treat cluster
cluster_ra, cluster_var(cluster) prob_each(.25 .25 .5) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .25 .5) replace
tab treat cluster
cluster_ra, cluster_var(cluster) prob_each(.25 .25 .5) replace condition_names(21 22 23)
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .25 .5) replace condition_names(21 22 23)
tab treat cluster
cluster_ra, cluster_var(cluster) prob_each(.25 .25 .5) replace condition_names(a b c)
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .25 .5) replace condition_names(a b c)
tab treat cluster
clear all
set obs 101
gen cluster=runiformint(1,26)
cluster_ra, cluster_var(cluster) prob_each(.25 .75) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .75) 
tab treat cluster
cluster_ra, cluster_var(cluster) prob_each(.25 .75) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .75) replace
tab treat cluster
cluster_ra, cluster_var(cluster) prob_each(.25 .75) replace condition_names(21 22 23)
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .75) replace condition_names(21 22 23)
tab treat cluster
cluster_ra, cluster_var(cluster) prob_each(.25 .75) replace condition_names(a b c)
tab assign cluster
cluster_ra treat, cluster_var(cluster) prob_each(.25 .75) replace condition_names(a b c)
tab treat cluster


//m_each
clear all
set obs 101
gen cluster=runiformint(1,26)

cluster_ra, cluster_var(cluster) m_each(5 5 16) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(5 5 16) 
tab treat cluster
cluster_ra, cluster_var(cluster) m_each(5 5 16) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(5 5 16) replace
tab treat cluster
cluster_ra, cluster_var(cluster) m_each(5 5 16) replace condition_names(21 22 23)
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(5 5 16) replace condition_names(21 22 23)
tab treat cluster
cluster_ra, cluster_var(cluster) m_each(5 5 16) replace condition_names(a b c)
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(5 5 16) replace condition_names(a b c)
tab treat cluster
clear all
set obs 101
gen cluster=runiformint(1,26)

cluster_ra, cluster_var(cluster) m_each(10 16) 
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(10 16) 
tab treat cluster
cluster_ra, cluster_var(cluster) m_each(10 16) replace
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(10 16) replace
tab treat cluster
cluster_ra, cluster_var(cluster) m_each(10 16) replace condition_names(21 22 23)
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(10 16) replace condition_names(21 22 23)
tab treat cluster
cluster_ra, cluster_var(cluster) m_each(10 16) replace condition_names(a b c)
tab assign cluster
cluster_ra treat, cluster_var(cluster) m_each(10 16) replace condition_names(a b c)
tab treat cluster






//simulations 
clear 
set obs 100
gen cluster=runiformint(1,26)

sim_RA, run(cluster_ra, cluster_var(cluster) replace) reps(1000)
sim_RA, run(cluster_ra, cluster_var(cluster) m_each(10 16 0) replace) reps(1000)
sim_RA, run(cluster_ra, cluster_var(cluster) m_each(26 0 0) replace) reps(1000)
sim_RA, run(cluster_ra, cluster_var(cluster) num_arms(3) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster) prob_each(.1 .9) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster) prob(.1) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster) m(10) replace) reps(10000)

clear 
set obs 13
gen cluster=runiformint(1,26)
sim_RA, run(cluster_ra, cluster_var(cluster)  num_arms(3) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster)  prob_each(.1 .9) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster)  prob_each(.15 .15 .7) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster)  m_each(1 10) replace) reps(10000)

clear 
set obs 1
gen cluster=runiformint(1,26)
sim_RA, run(cluster_ra, cluster_var(cluster)  num_arms(2) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster)  num_arms(3) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster)  prob_each(.1 .2 .7) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster)  prob(.1) replace) reps(10000)
sim_RA, run(cluster_ra, cluster_var(cluster)  m(1) replace) reps(10000)

clear 
set obs 3
gen cluster=runiformint(1,26)
sim_RA, run(cluster_ra, cluster_var(cluster)  replace) reps(10000)



//test labels 
clear 
set obs 100
gen cluster=runiformint(1,26)

cluster_ra, cluster_var(cluster)  prob_each(.1 .9) replace condition_names(a b)
tab assign cluster
tab assign cluster, nolab
cluster_ra, cluster_var(cluster)  prob_each(.1 .9) replace condition_names(1 2)
tab assign cluster
cluster_ra, cluster_var(cluster)  prob_each(.1 .8 .1) replace condition_names(23 24 25)
tab assign cluster
cluster_ra, cluster_var(cluster)  prob_each(.1 .8 .1) replace condition_names(a b c)
tab assign cluster
tab assign cluster, nolab

