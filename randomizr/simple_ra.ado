****Randomizr Stata Port*************
****Module 0:************************ 
****Simple Random Assignment*********
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****25july2018************************
*****version 1.6********************
***john.ternovski@yale.edu***********

program define simple_ra
	version 12
	syntax [namelist(max=1 name=assignment)] [if] [in], [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [num_arms(numlist max=1 >0)] [conditions(string)] [check_inputs] [replace]

//determine if condition names are strings or numbers
//if strings, then use strings as numbers
//if numbers, use as treatment values
if !missing(`"`conditions'"') {
	tempname stringparse
	local `stringparse'=subinstr(`"`conditions'"'," ","",.)
	cap confirm num ``stringparse''
	if _rc {
		local withlabel=1
	}
}

//get condition number
if missing(`"`prob'"') & missing(`"`prob_each'"') & missing(`"`num_arms'"') {
	local num_arms=2
}
if !missing(`"`prob'"') {
	local num_arms=2
}
if !missing(`"`prob_each'"') {
	local num_arms=wordcount(`"`prob_each'"')
}
if !missing(`"`conditions'"') & missing(`"`num_arms'"') {
	local num_arms=wordcount(`"`conditions'"')
}
	
//set indexing
if `num_arms'==2 & (!missing(`"`withlabel'"') | missing(`"`conditions'"')) {
	local index0=1
}

// Error checking
	if "`check_inputs'"=="" {
		//check for incompatible combinations of commands
		local commandlist="prob prob_each"
		local commandnum=0
		foreach n in `commandlist' {
			local commandnum=`commandnum'+ !missing(`"``n''"')
		}
		if `commandnum'>1 {
			disp as error "ERROR: Please specify only one of prob and prob_each."
			exit 1
		}
	}

	// Probabilities add up to 1
	if !missing(`"`prob_each'"'){
		tempname probs
		matrix input `probs' = (`prob_each')
		mata : st_local("sum",strofreal(rowsum(st_matrix(st_local("probs")))))
		if 1!=`sum' {
			disp as error "ERROR: The sum of the probabilities of assignment to each condition (prob_each) must equal 1."
			exit 2
		}
	}
	
	if !missing(`"`prob_each'"') & !missing(`"`conditions'"') {
		if `num_arms'>wordcount(`"`conditions'"') |  `num_arms'<wordcount(`"`conditions'"') {
			disp as error "ERROR:  If prob_each and conditions are specified together, they must be of the same length."
			exit 4
		}
	}
	
	if !missing(`"`conditions'"') {
		if `num_arms'<wordcount(`"`conditions'"') {
			disp as error "ERROR: You specified too many condition names given the number of treatment arms"
			exit 5
		}
	}
	
	if !missing(`"`conditions'"') {
		if `num_arms'>wordcount(`"`conditions'"') {
			disp as error "ERROR: You specified too few condition names given the number of treatment arms"
			exit 6
		}
	}
	
	//check if number of treatment arms and number of condition names match
	if !missing(`"`prob'"') & !missing(`"`conditions'"') {
		if wordcount(`"`conditions'"') != 2 {
			disp as error "ERROR: If prob and conditions are specified together, conditions must be of length 2."
			exit 7
		}
	}
	
	//check condition names are unique 
	if !missing(`"`conditions'"') {
		foreach n in `conditions' {
			if strpos(`"`conditions'"',`"`n'"')!=strrpos(`"`conditions'"',`"`n'"') {
				disp as error "ERROR: All condition names have to be unique."
				exit 8
			}
		}
}

//replace assignment variable and label if replace is specified
if `"`replace'"'!="" {
	cap drop `assignment'
	cap label drop `assignment'
}

//get N
qui count `if' `in'
local N=`r(N)'



//get prob vector
if !missing(`"`prob'"') & missing(`"`prob_each'"') {
	local num_arms = 2
	local prob_miss = 1 - `prob'
	local prob_vector `"`prob_miss' `prob'"'
}

if missing(`"`prob'"') & missing(`"`prob_each'"') {
	local prob_arm = 1/`num_arms'
	forval i=1/`num_arms' {
		local prob_vector `"`prob_vector' `prob_arm'"'
	}
}

if !missing(`"`prob_each'"') {
	local num_arms = wordcount(`"`prob_each'"')
	local prob_vector `prob_each'
}

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

//set up for mata input
tempname p id 
matrix input `p'=(`prob_vector')
gen `id'=_n 
qui putmata `id' `if' `in', replace

//randomize
mata: treat = rdiscrete(strtoreal(st_local("N")),1,st_matrix(st_local("p")))
getmata `assignment'=treat, id(`id') 

//change values to correspond to custom conditions values
if missing(`"`withlabel'"') & !missing(`"`conditions'"') {
	tempvar assignment_old
	rename `assignment' `assignment_old'
	qui gen `assignment'=.
	forval i=1/`num_arms' {
		local cname`i' : word `i' of `conditions'
		qui replace `assignment'=`cname`i'' if `assignment_old'==`i'
	}
}

//reindex if necessary
if `"`index0'"'=="1" {
	qui replace `assignment'=`assignment'-1
}


//label treatment conditions if necessary
if `"`withlabel'"'=="1" {
	tokenize `"`conditions'"'
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












*Age quod agis
