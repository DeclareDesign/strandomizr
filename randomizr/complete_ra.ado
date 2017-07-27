****Randomizr Stata Port*************
****Module 1:************************ 
****Complete Random Assignment*******
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****27jul2017************************
*****version 1.5*********************
***john.ternovski@yale.edu***********
program define complete_ra, rclass
	version 15
	syntax [namelist(max=1 name=assignment)] [if] [in], [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [num_arms(numlist max=1 >0)] [condition_names(string)] [m(numlist max=1 >=0 int)] [m_each(numlist >=0 int)] [check_inputs] [replace]

	
///TO DO LIST
///-add tempnames for all matrices, locals and vars
///do ado files have a lot of overhead
///LATER: prob of assignment -- obtain condition probabilities function 

///TABLE OF CONTENTS
//////Main Function - LINE 30
//////Labeling Sub-Function - LINE 348
//////Two-arm Random Assignment Function - LINE 370
//////Multi-arm Random Assignment Function - LINE 393

///MAIN FUNCTION//////////////////////////////////	
//get N
qui count `if' `in'
local N=`r(N)'

//get condition number
if missing(`"`prob'"') & missing(`"`m'"') & missing(`"`prob_each'"') & missing(`"`m_each'"') & missing(`"`num_arms'"') & missing(`"`condition_names'"') {
	local num_arms=2
}
if !missing(`"`prob'"') | !missing(`"`m'"') {
	local num_arms=2
}
if !missing(`"`prob_each'"') {
	local num_arms=wordcount(`"`prob_each'"')
}
if !missing(`"`m_each'"') {
	local num_arms=wordcount(`"`m_each'"')
}
if !missing(`"`condition_names'"') & missing(`"`num_arms'"') {
	local num_arms=wordcount(`"`condition_names'"')
}

//determine if condition names are strings or numbers
//if strings, then use strings as numbers
//if numbers, use as treatment values

if !missing(`"`condition_names'"') {
	tempname stringparse
	local `stringparse'=subinstr(`"`condition_names'"'," ","",.)
	cap confirm num ``stringparse''
	if _rc {
		local withlabel=1
	}
	else {
		local customnum=1
	}
}


//set indexing
if `num_arms'==2 & !missing(`"`withlabel'"') {
	local index0=1
}


	
//error checking
if "`skip_check_inputs'"=="" {
	if !missing(`"`prob_each'"'){
		//probs add up to 1
		tempname probs
		matrix input `probs' = (`prob_each')
		mata : st_local("sum",strofreal(rowsum(st_matrix(st_local("probs")))))
		if 1!=`sum' {
			disp as error "ERROR: Percentages in group_percentages must add up to 1"
			exit
		}
	}
	//exactly one of {m_each, prob_each} is specified
	if (!missing(`"`prob_each'"') & !missing(`"`m_each'"')) | (!missing(`"`prob'"') & !missing(`"`m'"')) {
		disp as error "ERROR: You must specify either m OR prob, but not both"
		exit
	}
	
	//incomplete assignment
	if !missing(`"`m_each'"') {
		tempname m_each_mat
		matrix input `m_each_mat' = (`m_each')
		mata : st_local("sum",strofreal(rowsum(st_matrix(st_local("m_each_mat")))))
		if `N'!=`sum' {
			disp as error "ERROR: Group numbers in m_eache must add up to the total sample size"
			exit
		}
	}
	
	//insufficient number of condition names for the number of conditions specified	
	if !missing(`"`m_each'"') & !missing(`"`condition_names'"') {
		local margs=wordcount(`"`m_each'"')
		local cargs=wordcount(`"`condition_names'"')
		if `margs'>`cargs' {
			disp as error "ERROR: You specified too few condition names"
			exit 
		}
	}

	//m cannot be greater than N
	if !missing(`"`m'"') {
		if `m'>`N' {
			disp as error "ERROR: m must not exceed N."
			exit
		}
	}

}

disp "Error checking complete"


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


//detect if two-arm design
if !missing(`"`m_each'"') & `num_arms'==2 {
	local m : word 1 of `m_each' 
}
if !missing(`"`prob_each'"') & `num_arms'==2 {
	local prob : word 1 of `prob_each'
}


//Simple 2 group design, returns zeros and ones
if /*missing(`"`m_each'"') & missing(`"`prob_each'"') &*/ `num_arms'==2 {
	//Special Case 1: N=1
	if `N'==1 {
		//neither m nor prob is specified
		if missing(`"`m'"') & missing(`"`prob'"') {
			simple_ra `assignment' `if' `in', prob(.5) condition_names(`"`condition_names'"') `replace'
		}
		//Special Case 2: N=1; m is specified
		if `"`m'"'=="0" {
			if !missing(`"`condition_names'"'){
				local cname1 : word 1 of `condition_names'
				gen `assignment'=`"`cname1'"'
			}
			else {
				gen `assignment'=0 
			}
		}
		if `"`m'"'=="1" {
			simple_ra `assignment' `if' `in', prob(.5) condition_names(`"`condition_names'"') `replace'
		}
		
		//Special Case 3: N=1; prob is specified
		if !missing(`"`prob'"') {
			simple_ra `assignment' `if' `in', prob(`prob') condition_names(`"`condition_names'"') `replace'			
		}
		return scalar complete=1
		exit 
	}

	//Two-arm Design 
	if `N'>1 {
		//Two-arm Design Case 1: m is specified
		if !missing(`"`m'"') {
			if `m'==`N' {
				gen `assignment' = 1 `if' `in'
				return scalar complete=1
				exit
			}
			
			//random assignment function
			two_arm_random_assign_func `assignment' `if' `in', customnum(`"`customnum'"') condition_names(`"`condition_names'"') m(`m') 
			
			//labeller function
			ra_labeller `assignment', withlabel(`withlabel') condition_names(`"`condition_names'"') index0(`index0') num_arms(`num_arms') 
			return scalar complete=1
			exit
		}
		
		//Case 2: Neither m nor prob is specified
		if missing(`"`m'"') & missing(`"`prob'"') {
			local m_floor = floor(`N'/2)
			local m_ceiling = ceil(`N'/2)
			if `m_ceiling' > `m_floor' {
				local prob_fix_up = .5 /*with two arm design and 50% assign prob never anything besides .5 or 0 */
				if runiform()<`prob_fix_up' {
					local m=`m_floor'
				}
				else {
					local m=`m_ceiling'
				}
			}
			else {
				local m=`m_floor'
			}

			//random assignment function
			two_arm_random_assign_func `assignment' `if' `in', customnum(`"`customnum'"') condition_names(`"`condition_names'"') m(`m') 
			
			//labeller function
			ra_labeller `assignment', withlabel(`withlabel') condition_names(`"`condition_names'"') index0(`index0') num_arms(`num_arms')
			return scalar complete=1
			exit 			
		}

	//Two-arm Design Case 3: prob is specified
		if !missing(`"`prob'"') {
			local m_floor = floor(`N'*`prob')
			local m_ceiling = ceil(`N'*`prob')
			
			if `m_ceiling'==`N' {
				local m = `m_floor'
			}
			else {
				if `m_ceiling'> `m_floor' {
					local prob_fix_up = ((`N'*`prob')-`m_floor')/(`m_ceiling' - `m_floor')
				}
				else {
					local prob_fix_up = .5 
				}
				if runiform()<`prob_fix_up' {
					local m=`m_floor'
				}
				else {
					local m=`m_ceiling'
				}
			}

		//random assignment function
		two_arm_random_assign_func `assignment' `if' `in', customnum(`"`customnum'"') condition_names(`"`condition_names'"') m(`m') 
		
		//labeller function
		ra_labeller `assignment', withlabel(`withlabel') condition_names(`"`condition_names'"') index0(`index0') num_arms(`num_arms')
		return scalar complete=1
		exit 			
		}
			
	}	
}


//Multi-arm Designs

//Multi-arm Design Case 1: neither prob_each nor m_each specified
if `num_arms'>2 {
	if missing(`"`prob_each'"') & missing(`"`m_each'"')  {
		local prob_arm = 1/`num_arms'
		forval i=1/`num_arms' {
			local prob_vector `"`prob_vector' `prob_arm'"'
		}
		local prob_each `"`prob_vector'"'
	}

	//Multi-arm Design Case 2: prob_each is specified	
	if !missing(`"`prob_each'"') {
		
		//setting up matrices, calculating m_each_floor and N_remainder
		matrix input prob_each=(`prob_each')
		
		mata: m_each_floor=floor(st_matrix("prob_each")*strtoreal(st_local("N")))
		mata: N_remainder=strofreal(strtoreal(st_local("N"))-rowsum(m_each_floor))
		mata: st_local("N_remainder",N_remainder)
		mata: st_matrix("m_each_floor",m_each_floor)
		
		//set up m_each inputs 
		local m_each_vector ""
		local length=wordcount(`"`prob_each'"') 
		forval i=1/`length' {
			local m`i'=m_each_floor[1,`i']
			local m_each_vector `m_each_vector' `m`i'' 
		}
		
		//actual random assignment function 
		tempvar rand rank 
		qui gen `rand'=runiform() `if' `in'
		qui egen `rank'=rank(`rand') `if' `in'
		multi_arm_random_assign_func `assignment' `if' `in', m_each(`m_each_vector') rank(`rank')		
		
		//assign remainder if necessary 
		if `N_remainder'>0 {
			mata: prob_each_fix_up=((st_matrix("prob_each")*strtoreal(st_local("N"))) - m_each_floor)/strtoreal(N_remainder)
			mata: st_matrix("remain_asn",rdiscrete(strtoreal(N_remainder),1,prob_each_fix_up))
	
			local begin=`r(end)'
			local i=1
			local end=`begin'+1
			while `i'!=(1+`N_remainder') {
				qui replace `assignment'=remain_asn[`i',1] if `rank'>`begin' & `rank'<=`end'
				local i=`i'+1
				local begin=`end'
				local end=`begin'+`i'
			}

		}
		return scalar complete=1		
	}

	if !missing(`"`m_each'"') {
		multi_arm_random_assign_func `assignment' `if' `in', m_each(`m_each')
		return scalar complete=1
	}
}


//change values to correspond to custom condition_names values
if missing(`"`withlabel'"') & !missing(`"`condition_names'"') {
	tempvar assignment_old
	rename `assignment' `assignment_old'
	qui gen `assignment'=.
	forval i=1/`num_arms' {
		local cname`i' : word `i' of `condition_names'
		qui replace `assignment'=`cname`i'' if `assignment_old'==`i'
	}
}


//label treatment conditions if necessary
ra_labeller `assignment', withlabel(`withlabel') condition_names(`"`condition_names'"') index0(`index0') num_arms(`num_arms')


end


///LABELING FUNCTION
program define ra_labeller
syntax [namelist(name=assignment)], [withlabel(numlist)] [condition_names(string)] [index0(numlist)] [num_arms(numlist)] 
if `"`withlabel'"'=="1" {
	tokenize `"`condition_names'"'
	if `"`index0'"'=="1" {
		local start=0
	}
	else {
		local start=1
	}
	label define `assignment' `start' `"`1'"'
	macro shift
	local startplusone=`start'+1
	forval i=`startplusone'/`num_arms' {
		label define `assignment' `i' `"`1'"', add
		macro shift
	}
	label val `assignment' `assignment'
}
end 

///TWO ARM RANDOM ASSIGNMENT FUNCTION
program define two_arm_random_assign_func
	version 15
	syntax [namelist(name=assignment)] [if] [in], [customnum(numlist)] [condition_names(string)] [m(numlist)]

tempvar rand rank 
qui gen `rand'=runiform() `if' `in' 
qui egen `rank'=rank(`rand') `if' `in'
if !missing(`"`customnum'"') {
	local cname1 : word 1 of `condition_names'
	local cname2 : word 2 of `condition_names'
}
else {
	local cname1=0
	local cname2=1
}			
qui gen `assignment'=`cname1' `if' `in'
qui replace `assignment'=`cname2' if `rank'<=`m' 

end
*

///MULTI ARM RANDOM ASSIGNMENT FUNCTION
program define multi_arm_random_assign_func, rclass
version 15
syntax namelist(name=assignment) [if] [in], m_each(numlist) [rank(varlist)]
	
if missing(`"`rank'"') {
	tempvar rand rank 
	qui gen `rand'=runiform() `if' `in'
	qui egen `rank'=rank(`rand') `if' `in' 
}

tokenize `m_each'

local begin=`1'
local end=(`1'+`2')
local i=2
qui gen `assignment'=1 if `rank'<=`begin'
local length=wordcount(`"`*'"') 
//while loop for assigning treatment
while `i'!=(`length'+1) {
	local end=`begin'+``i''
	qui replace `assignment'=`i' if `rank'>`begin' & `rank'<=`end'
	local i=`i'+1
	local begin=`end'

}	

return scalar end=`begin'

end
*


*	
