****Randomizr Stata Port*************
****Module 4:************************ 
****Block+Cluster Random Assignment**
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****26aug2017************************
*****version 1.0*********************
***john.ternovski@yale.edu***********
program define block_and_cluster_ra, rclass sortpreserve
	version 15
	syntax [namelist(max=1 name=assignment)] [if] [in], cluster_var(varname) block_var(varname) [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [block_m(numlist >=0)] [block_m_each(string)] [block_prob(numlist >=0 <=1)] [block_prob_each(string)] [num_arms(numlist max=1 >0)] [condition_names(string)] [m(numlist max=1 >=0 int)] [skip_check_inputs] [replace]

///SHOULD WE ERROR IF CLUSTERS ARE IMPERFECTLY NESTED IN BLOCKS??
	
//get number of clusters
tempvar touse
egen `touse'=tag(`cluster_var' `block_var') `if' `in'

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
block_ra `assignmenttemp' if `touse'==1 `andif' `in', `replace' block_var(`block_var') prob_each(`prob_each') prob(`prob') block_m(`block_m') block_m_each(`block_m_each') block_prob(`block_prob') block_prob_each(`block_prob_each') num_arms(`num_arms') condition_names(`condition_names') m(`m') `skip_check_inputs'
bysort `cluster_var': egen `assignment'=max(`assignmenttemp')

//update condition name labels if applicable
//programmer's note--unless we want to make label name global/permanent, can't copy local label this many levels up 
if !missing(`"`condition_names'"') {
	tempname stringparse
	local `stringparse'=subinstr(`"`condition_names'"'," ","",.)
	cap confirm num ``stringparse''
	if _rc {
		qui levelsof `assignment', local(start)
		local start=substr("`start'",1,1)
		tokenize `"`condition_names'"'
		label define `assignment' `start' `"`1'"'
		macro shift
		local startplusone=`start'+1
		qui tab `assignment'
		forval i=`startplusone'/`r(r)' {
			label define `assignment' `i' `"`1'"', add
			macro shift
		}
		label val `assignment' `assignment'
	}
}

 
end
*
