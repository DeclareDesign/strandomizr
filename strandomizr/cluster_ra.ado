****Randomizr Stata Port*************
****Module 3:************************ 
****Cluster Random Assignment********
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****26aug2017************************
*****version 1.0*********************
***john.ternovski@yale.edu***********
program define cluster_ra, rclass sortpreserve
	version 15
	syntax [namelist(max=1 name=assignment)], cluster_var(varname) [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [num_arms(numlist max=1 >0)] [condition_names(string)] [m(numlist max=1 >=0 int)] [m_each(numlist >=0 int)] [skip_check_inputs] [replace]

//get number of clusters
tempvar touse
egen `touse'=tag(`cluster_var')

//setting defaults 
//set default condition names
if missing(`"`assignment'"') { 
	local assignment "assignment"
}

//replace assignment variable and label if replace is specified
if `"`replace'"'!="" {
	cap drop `assignment'
	if _N==0 {
		qui set obs `N'
	}
	cap label drop `assignment'

}

tempvar assignmenttemp
complete_ra `assignmenttemp' if `touse'==1, `replace' prob_each(`prob_each') prob(`prob') num_arms(`num_arms') condition_names(`condition_names') m(`m') m_each(`m_each') `skip_check_inputs'

bysort `cluster_var': egen `assignment'=max(`assignmenttemp')

end
*