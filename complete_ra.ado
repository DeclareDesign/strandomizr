****Randomizr Stata Port*************
****Module 1:************************ 
****Complete Random Assignment*******
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****02jul2017************************
*****version 1.0*********************
***john.ternovski@yale.edu***********
program define complete_ra, rclass
	version 15
	syntax [namelist(max=1 name=assignment)] [if], [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [num_arms(numlist max=1 >0)] [condition_names(string)] [m(numlist max=1 >=0)] [m_each(numlist >=0)] [check_inputs] [replace]

///TO DO LIST
///-add "in" functionality
///-fix all the if bugs
///-the treatment variable/label auto-detector
///-get rid of tokenize for matrix inputs 
///-add tempnames for all matrices, locals and vars
	
	
	
//get N
qui count `if'
local N=`r(N)'

//get condition number
if missing(`"`prob'"') & missing(`"`m'"') & missing(`"`prob_each'"') & missing(`"`m_each'"') & missing(`"`num_arms'"') {
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
		tokenize `prob_each'
		tempname probs
		matrix input `probs' = (`*')
		mata : st_local("sum",strofreal(rowsum(st_matrix(st_local("probs")))))
		if 1!=`sum' {
			disp as error "ERROR: Percentages in group_percentages must add up to 1"
			exit
		}
	}
	//exactly one of {m_each, prob_each} is specified
	if !missing(`"`prob_each'"') & !missing(`"`m_each'"') {
		disp as error "ERROR: You must specify either m_each OR prob_each, but not both"
		exit
	}
	
	//incomplete assignment
	if !missing(`"`m_each'"') {
		tokenize `m_each'
		tempname m
		matrix input `m' = (`*')
		mata : st_local("sum",strofreal(rowsum(st_matrix(st_local("m")))))
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
	cap label drop `assignment'

}



//Simple 2 group design, returns zeros and ones

if missing(`"`m_each'"') & missing(`"`prob_each'"') & `num_arms'==2 {
	//Special Case 1: N=1
	if `N'==1 {
		//neither m nor prob is specified
		if missing(`"`m'"') & missing(`"`prob'"') {
			simple_ra `assignment', prob(.5) condition_names(`"`condition_names'"') `replace'
		}
		//Special Case 2: N=1; m is specified
		if `"`m'"'=="0" {
			if !missing(`"`condition_names'"'){
				local cname1 : word 1 of `condition_names'
				gen `assignment'=`"`cname1'"'
			}
			else {
				gen `assignment'=0 //MAKE SURE THIS WORKS RIGHT WITH LABELS
			}
		}
		if `"`m'"'=="1" {
			simple_ra `assignment', prob(.5) condition_names(`"`condition_names'"') `replace'
		}
		
		//Special Case 3: N=1; prob is specified
		if !missing(`"`prob'"') {
			simple_ra `assignment', prob(`prob') condition_names(`"`condition_names'"') `replace'
			
		}
	}

	///WHAT IS CLEAN_CONDITION_NAMES IN R CODE?

	//Two-arm Design 
	if `N'>1 {
		//Two-arm Design Case 1: m is specified
		if !missing(`"`m'"') {
			if `m'==`N' {
				gen `assignment' = 1 `if' //FIX TREATMENT VARIABLE HERE
			}
			
			//functionalize this?
			tempvar rand rank 
			qui gen `rand'=runiform() `if'
			qui egen `rank'=rank(`rand') `if' 
			
			if !missing(`"`customnum'"') {
				local cname1 : word 1 of `condition_names'
				local cname2 : word 2 of `condition_names'
			}
			else {
				local cname1=0
				local cname2=1
			}			
			qui gen `assignment'=`cname1' 
			qui replace `assignment'=`cname2' if `rank'<=`m' /*ADD IF FUNCTIONALITY HERE*/
		}
		//Case 2: Neither m nor prob is specified
		if missing(`"`m'"') & missing(`"`prob'"') {
			local m_floor = floor(`N'/2)
			local m_ceiling = ceil(`N'/2)
			if `m_ceiling' > `m_floor' {
				local prob_fix_up = ((`N'*.5)-`m_floor')/(`m_ceiling' - `m_floor')
			}
			else {
				local prob_fix_up = .5 
			}
			
			*disp `prob_fix_up' //IS PROB FIX UP EVER DIFFERENT FOR A TWO ARM DESIGN? NO RIGHT?
			
			if runiform()<`prob_fix_up' {
				local m=`m_floor'
			}
			else {
				local m=`m_ceiling'
			}
			//functionalize this?
			tempvar rand rank 
			qui gen `rand'=runiform() `if'
			qui egen `rank'=rank(`rand') `if' 
			
			if !missing(`"`customnum'"') {
				local cname1 : word 1 of `condition_names'
				local cname2 : word 2 of `condition_names'
			}
			else {
				local cname1=0
				local cname2=1
			}			
			qui gen `assignment'=`cname1' 
			qui replace `assignment'=`cname2' if `rank'<=`m' /*ADD IF FUNCTIONALITY HERE*/
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
			//functionalize this?
			tempvar rand rank 
			qui gen `rand'=runiform() `if'
			qui egen `rank'=rank(`rand') `if' 
			if !missing(`"`customnum'"') {
				local cname1 : word 1 of `condition_names'
				local cname2 : word 2 of `condition_names'
			}
			else {
				local cname1=0
				local cname2=1
			}			
			qui gen `assignment'=`cname1' 
			qui replace `assignment'=`cname2' if `rank'<=`m' /*ADD IF FUNCTIONALITY HERE*/
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
	//CLEAN UP THIS SECTION
	if !missing(`"`prob_each'"') {
		matrix input prob_each=(`prob_each')
		mata: m_each_floor=floor(st_matrix("prob_each")*strtoreal(st_local("N")))
		mata: N_remainder=strofreal(strtoreal(st_local("N"))-rowsum(m_each_floor))
		mata: st_local("N_remainder",N_remainder)
		mata: st_matrix("m_each_floor",m_each_floor)
				
		//rankng function 
		tempvar rand rank 
		qui gen `rand'=runiform() `if'
		qui egen `rank'=rank(`rand') `if'  
		
		if `N_remainder'>0 {
			mata: prob_each_fix_up=((st_matrix("prob_each")*strtoreal(st_local("N"))) - m_each_floor)/strtoreal(N_remainder)
			mata: st_matrix("prob_each_fix_up", prob_each_fix_up)
			
			gen `assignment'=1 if `rank'<=m_each_floor[1,1]
			//setting up while loop
			local begin=m_each_floor[1,1]
			local end=(m_each_floor[1,1]+m_each_floor[1,2])
			local i=2
			local length=wordcount(`"`prob_each'"') 
			
			//while loop for assigning treatment
			while `i'!=(`length'+1) {
				qui replace assignment=`i' if `rank'>`begin' & `rank'<=`end'
				local i=`i'+1
				local begin=`end'
				local end=`begin'+m_each_floor[1,`i']
			}	
			
			//assign remainder
			mata: st_matrix("remain_asn",rdiscrete(strtoreal(N_remainder),1,prob_each_fix_up))
			*local output=`remain_asn'
			*return scalar output= `output'
			*disp `begin' `end'
			local i=1
			local end=`begin'+1
			while `i'!=(1+`N_remainder') {
				qui replace assignment=remain_asn[`i',1] if `rank'>`begin' & `rank'<=`end'
				local i=`i'+1
				local begin=`end'
				local end=`begin'+`i'
			}
			
			
		}
		else {
			//setting up while loop
			local begin=m_each_floor[1,1]
			local end=(m_each_floor[1,1]+m_each_floor[1,2])
			local i=2
			local length=wordcount(`"`prob_each'"') 
			
			//while loop for assigning treatment
			while `i'!=(`length'+1) {
				qui replace assignment=`i' if `rank'>`begin' & `rank'<=`end'
				local i=`i'+1
				local begin=`end'
				local end=`begin'+m_each_floor[1,`i']
			}	
		}
		
		
	}

	if !missing(`"`m_each'"') {
		//rankng function 
		tempvar rand rank 
		gen `rand'=runiform() `if'
		egen `rank'=rank(`rand') `if'  

		//setting up while loop

		tokenize `m_each'
		local begin=`1'
		local end=(`1'+`2')
		local i=2
		gen `assignment'=1 if `rank'<=`begin'
		local length=wordcount(`"`*'"') 

		//while loop for assigning treatment
		while `i'!=(`length'+1) {
			local end=`begin'+``i''
			replace `assignment'=`i' if `rank'>`begin' & `rank'<=`end'
			local i=`i'+1
			local begin=`end'

		}	
	}
}

//change values to correspond to custom condition_names values
if missing(`"`withlabel'"') & !missing(`"`condition_names'"') {
	tempvar assignment_old
	rename `assignment' `assignment_old'
	qui gen `assignment'=.
	forval i=1/`num_arms' {
		local cname`i' : word `i' of `condition_names'
		replace `assignment'=`cname`i'' if `assignment_old'==`i'
	}
}

//label treatment conditions if necessary
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

	
/*	




if !missing(`"`prob'"') & missing(`"`prob_each'"') {
	local num_arms = 2
	local prob_miss = 1 - `prob'
	local prob_cum = `prob_miss' + `prob' 
	local prob_vector `"`prob_miss' `prob_cum'"'
}

if missing(`"`prob'"') & missing(`"`prob_each'"') {
	local prob_arm = 1/`num_arms'
	local prob_cum = `prob_arm'
	local prob_vector = `prob_cum'
	forval i=2/`num_arms' {
		local prob_cum=`prob_cum'+`prob_arm'
		local prob_vector `"`prob_vector' `prob_cum'"'
	}
}

if !missing(`"`prob_each'"') {
	local num_arms = wordcount(`"`prob_each'"')
	tokenize `prob_each'
	local prob_cum = `1'
	local prob_vector = `prob_cum'
	forval i=2/`num_arms' {
		local prob_cum = `prob_cum' + ``i''
		local prob_vector `"`prob_vector' `prob_cum'"'
	}
}



tokenize `prob_vector'
qui gen `assignment'=0 if `stnd_rand'<`1'
forval i=2/`num_arms'{
	qui replace `assignment'=`i'-1 if `stnd_rand'>=`1' & `stnd_rand'<`2'
	macro shift
}	

tokenize `"`condition_names'"'
label define `assignment' 0 `"`1'"'
macro shift
local lengthminusone=`num_arms'-1
forval i=1/`lengthminusone' {
	label define `assignment' `i' `"`1'"', add
	macro shift
}
label val `assignment' `assignment'

end




/*	
*set default condition names
if missing(`"`condition_names'"') {
	local condition_names "0 1"
}

*get N
qui count `if'
local N=`r(N)'

*INSERT ERROR CHECKING HERE MAYBE*

*/


/*
#' complete_ra implements a random assignment procedure in which fixed numbers of units are assigned to treatment conditions. The canonical example of complete random assignment is a procedure in which exactly m of N units are assigned to treatment and N-m units are assigned to control.\cr \cr
#' Users can set the exact number of units to assign to each condition with m or m_each. Alternatively, users can specify probabilities of assignment with prob or prob_each and complete_ra will infer the correct number of units to assign to each condition.
#' In a two-arm design, complete_ra will either assign floor(N*prob) or ceiling(N*prob) units to treatment, choosing between these two values to ensure that the overall probability of assignment is exactly prob.
#' In a multi-arm design, complete_ra will first assign floor(N*prob_each) units to their respective conditions, then will assign the remaining units using simple random assignment, choosing these second-stage probabilties so that the overall probabilities of assignment are exactly prob_each.\cr \cr
#' In most cases, users should specify N and not more than one of m, m_each, prob, prob_each, or num_arms. \cr \cr
#' If only N is specified, a two-arm trial in which N/2 units are assigned to treatment is assumed. If N is odd, either floor(N/2) units or ceiling(N/2) units will be assigned to treatment.
#'
#'
#' @param N The number of units. N must be a positive integer. (required)
#' @param m Use for a two-arm design in which m units are assigned to treatment and N-m units are assigned to control. (optional)
#' @param m_each Use for a multi-arm design in which the values of m_each determine the number of units assigned to each condition. m_each must be a numeric vector in which each entry is a nonnegative integer that describes how many units should be assigned to the 1st, 2nd, 3rd... treatment condition. m_each must sum to N. (optional)
#' @param prob Use for a two-arm design in which either floor(N*prob) or ceiling(N*prob) units are assigned to treatment. The probability of assignment to treatment is exactly prob because with probability 1-prob, floor(N*prob) units will be assigned to treatment and with probability prob, ceiling(N*prob) units will be assigned to treatment. prob must be a real number between 0 and 1 inclusive. (optional)
#' @param prob_each Use for a multi-arm design in which the values of prob_each determine the probabilties of assignment to each treatment condition. prob_each must be a numeric vector giving the probability of assignment to each condition. All entries must be nonnegative real numbers between 0 and 1 inclusive and the total must sum to 1. Because of integer issues, the exact number of units assigned to each condition may differ (slightly) from assignment to assignment, but the overall probability of assignment is exactly prob_each. (optional)
#' @param num_arms The number of treatment arms. If unspecified, num_arms will be determined from the other arguments. (optional)
#' @param condition_names A character vector giving the names of the treatment groups. If unspecified, the treatment groups will be named 0 (for control) and 1 (for treatment) in a two-arm trial and T1, T2, T3, in a multi-arm trial. An execption is a two-group design in which num_arms is set to 2, in which case the condition names are T1 and T2, as in a multi-arm trial with two arms. (optional)
#' @param check_inputs logical. Defaults to TRUE.
#'
#' @return A vector of length N that indicates the treatment condition of each unit. Is numeric in a two-arm trial and a factor variable (ordered by condition_names) in a multi-arm trial.
#' @export
#'
#' @importFrom stats rbinom
#'
#' @examples
#' # Two-arm Designs
#' Z <- complete_ra(N = 100)
#' table(Z)
#'
#' Z <- complete_ra(N = 100, m = 50)
#' table(Z)
#'
#' Z <- complete_ra(N = 100, prob = .111)
#' table(Z)
#'
#' Z <- complete_ra(N = 100, condition_names = c("control", "treatment"))
#' table(Z)
#'
#'
#' # Multi-arm Designs
#' Z <- complete_ra(N = 100, num_arms = 3)
#' table(Z)
#'
#' Z <- complete_ra(N = 100, m_each = c(30, 30, 40))
#' table(Z)
#'
#' Z <- complete_ra(N = 100, prob_each = c(.1, .2, .7))
#' table(Z)
#'
#' Z <- complete_ra(N = 100, condition_names = c("control", "placebo", "treatment"))
#' table(Z)
#'
#' # Special Cases
#' # Two-arm trial where the condition_names are by default "T1" and "T2"
#' Z <- complete_ra(N = 100, num_arms = 2)
#' table(Z)
#'
#' # If N = m, assign with 100% probability...
#' complete_ra(N=2, m=2)
#'
#' # except if N = m = 1, in which case assign with 50% probability
#' complete_ra(N=1, m=1)
#'
#'
*/

*end
*Age quod agis