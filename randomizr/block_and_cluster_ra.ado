****Randomizr Stata Port*************
****Module 4:************************ 
****Block+Cluster Random Assignment**
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****12sep2017************************
*****version 1.1*********************
***john.ternovski@yale.edu***********
program define block_and_cluster_ra, rclass sortpreserve
	version 12
	syntax [namelist(max=1 name=assignment)] [if] [in], clusters(varname) blocks(varname) [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [block_m(numlist >=0)] [block_m_each(string)] [block_prob(numlist >=0 <=1)] [block_prob_each(string)] [num_arms(numlist max=1 >0)] [conditions(string)] [m(numlist max=1 >=0 int)] [skip_check_inputs] [replace]

//error-checking 
if missing(`"`skip_check_inputs'"') {
	//take all available commands and see if more than two are specified 
	local commandlist="prob prob_each block_m block_m_each block_prob block_prob_each num_arms m"
	local commandnum=0
	foreach n in `commandlist' {
		local commandnum=`commandnum'+ !missing(`"``n''"')
	}
	if `commandnum'>1 {
		disp as error "ERROR: You must specify only ONE of the following options: prob, prob_each, block_m, block_m_each, block_prob_each, block_prob, num_arms, m"
		exit 1
	}
	
	//make sure clusters are nested in blocks 
	tempvar clustnum
	egen `clustnum'=group(`clusters') 
	qui tab `clustnum'
	forval i=1/`r(r)' {
		qui tab `blocks' if `clustnum'==`i'
		if `r(r)'>1 {
			disp as error "ERROR: Clusters must be nested within blocks."
			exit 47
		}
	}
}
	
//get number of clusters
tempvar touse
egen `touse'=tag(`clusters' `blocks') `if' `in'

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
block_ra `assignmenttemp' if `touse'==1 `andif' `in', `replace' blocks(`blocks') prob_each(`prob_each') prob(`prob') block_m(`block_m') block_m_each(`block_m_each') block_prob(`block_prob') block_prob_each(`block_prob_each') num_arms(`num_arms') conditions(`conditions') m(`m') `skip_check_inputs'
bysort `clusters': egen `assignment'=max(`assignmenttemp')

//update condition name labels if applicable
//programmer's note--unless we want to make label name global/permanent, can't copy local label this many levels up 
if !missing(`"`conditions'"') {
	tempname stringparse
	local `stringparse'=subinstr(`"`conditions'"'," ","",.)
	cap confirm num ``stringparse''
	if _rc {
		qui levelsof `assignment', local(start)
		local start=substr("`start'",1,1)
		tokenize `"`conditions'"'
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

return scalar complete=1

 
end
*
