****Randomizr Stata Port*************
****Module 2:************************ 
****Block Random Assignment**********
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****05aug2017************************
*****version 1.7*********************
***john.ternovski@yale.edu***********
program define block_ra, rclass sortpreserve
	version 15
	syntax [namelist(max=1 name=assignment)] [if], block_var(varname) [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [block_m(numlist >=0)] [block_m_each(string)] [block_prob(numlist >=0 <=1)] [block_prob_each(string)] [num_arms(numlist max=1 >0)] [condition_names(string)] [m(numlist max=1 >=0 int)] [skip_check_inputs] [replace]


//Fixing ifs 
if !missing(`"`if'"') {
	local andif=`"&"'+substr(`"`if'"',3,.)
}
marksample touse 

//get number of blocks   
tempvar blockint
egen `blockint'=group(`block_var')
qui levelsof `block_var', local(blocklevel) 
local blockN=wordcount(`"`blocklevel'"')

//get N in each block
tempname Nmatrix
matrix define `Nmatrix'=J(`blockN',1,.)
forval i=1/`blockN' {
	qui count `in' if `touse'==1 & `blockint'==`i' `andif'
	matrix `Nmatrix'[`i',1]=`r(N)'
}

//error checking
if "`skip_check_inputs'"=="" {
	
	//exactly one of {block_m_each, block_prob_each} is specified
	if (!missing(`"`block_prob_each'"') & !missing(`"`block_m_each'"')) | (!missing(`"`prob'"') & !missing(`"`m'"')) {
		disp as error "ERROR: You must specify either m OR prob, but not both"
		exit
	} 
	/*loop to go through every permutation???*/
	
	//check matrices are correct 
	if !missing(`"`block_m_each'"') {
		tempname testmatrix testrows
		cap matrix define `testmatrix'=`block_m_each'
		if _rc {
			disp as error "ERROR: Invalid block_m_each matrix"
			exit
		}
		scalar `testrows'=rowsof(`testmatrix')
		if `blockN'!=`testrows' {
			disp as error "ERROR: Rows of block_m_each must equal number of blocks."
			exit
		}
		mata : st_matrix("rowsums",rowsum(st_matrix(st_local("testmatrix"))))
		forval i=1/`blockN' {
			if rowsums[`i',1]!=`Nmatrix'[`i',1] {
				disp as error "ERROR: Each row of block_m_each must add up to the N in the corresponding group."
				exit 666
			}
		}
	}
	
	if !missing(`"`block_prob_each'"') {
		tempname testmatrix testrows
		matrix define `testmatrix'=`block_prob_each'
		if _rc {
			disp as error "ERROR: Invalid block_prob_each matrix"
			exit
		}
		scalar `testrows'=rowsof(`testmatrix')
		if `blockN'!=`testrows' {
			disp as error "ERROR: Rows of block_prob_each must equal number of blocks."
			exit
		}
		mata : st_matrix("rowsums",rowsum(st_matrix(st_local("testmatrix"))))
		forval i=1/`blockN' {
			if rowsums[`i',1]!=1 {
				disp as error "ERROR: Each row of block_prob_each must add up to 1."
				exit 666
			}
		}

	}
	
	//m cannot be greater than N
	if !missing(`"`m'"') {
		forval i=1/`blockN' {
			if `m'>`Nmatrix'[`i',1] {
				disp as error "Error: M cannot be greater than the size of any block"
				exit 666
			}
		}
	}
	
	if !missing(`"`block_m'"') {
		if wordcount(`"`block_m'"')!=`blockN' {
			disp as error "ERROR: The number of elements in block_m has to equal the number of blocks"
			exit
		}
		forval i=1/`blockN' {
			local item : word `i' of `block_m'
			if `item'>`Nmatrix'[`i',1] {
				disp as error "ERROR: Each element of block_m cannot exceed the size of the corresponding block"
				exit 666
			}
		}
		
	}
	
	if !missing(`"`block_prob'"') {
		if wordcount(`"`block_prob'"')!=`blockN' {
			disp as error "ERROR: The number of elements in block_prob has to equal the number of blocks"
			exit
		}		
	}
	
	//DO WE NEED THIS??? MAYBE WARNING INSTEAD OF ERROR? 
	//insufficient number of condition names for the number of conditions specified	
	/*
	if (!missing(`"`m'"') | !missing(`"`num_arms'"')) & !missing(`"`condition_names'"') {
		local margs=wordcount(`"`m_each'"')
		local cargs=wordcount(`"`condition_names'"')
		if `margs'>`cargs' | `num_arms'>`cargs' {
			disp as error "ERROR: You specified too few condition names"
			exit 
		}
	}
	*/
	disp "Error checking complete"
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

//set default if all options missing
if missing(`"`prob'"') & missing(`"`m'"') & missing(`"`block_prob'"') & missing(`"`block_m'"') & missing(`"`prob_each'"') & missing(`"`block_m_each'"') & missing(`"`block_prob_each'"') &  missing(`"`num_arms'"') & missing(`"`condition_names'"') {
	local num_arms=2
}




//Case 0 m is specified 
if !missing(`"`m'"') {
	bysort `block_var': complete_ra `assignment' `if', `replace' m(`m') skip_check_inputs
}
//Case 1 block_m or block_prob is specified
if !missing(`"`block_m'"') {
	qui gen `assignment'=.
	tempname assignmenttemp
	forval i=1/`blockN' {
		local item : word `i' of `block_m'
		complete_ra `assignmenttemp' if `blockint'==`i' `andif', `replace' m(`item') skip_check_inputs
		qui replace `assignment'=`assignmenttemp' if `blockint'==`i' `andif'
	}
}

//Case 1.5 block_prob is specified 
if !missing(`"`block_prob'"') {
	qui gen `assignment'=.
	tempname assignmenttemp
	forval i=1/`blockN' {
		local item : word `i' of `block_prob'
		complete_ra `assignmenttemp' if `blockint'==`i' `andif', `replace' prob(`item') skip_check_inputs
		qui replace `assignment'=`assignmenttemp' if `blockint'==`i' `andif'
	}
}

//Case 2: prob or num_arms or prob_each
if !missing(`"`prob'"') {
	bysort `block_var': complete_ra `assignment' `if', `replace' prob(`prob')
}
if !missing(`"`num_arms'"') {
	bysort `block_var': complete_ra `assignment' `if', `replace' num_arms(`num_arms')
}
if !missing(`"`prob_each'"') {
	bysort `block_var': complete_ra `assignment' `if', `replace' prob_each(`prob_each')
}

//Case 3 use block_m_each
if !missing(`"`block_m_each'"') {
	//setting up vars and dimensions
	qui gen `assignment'=.
	tempname assignmenttemp blockMmatrix
	matrix define `blockMmatrix'=`block_m_each'
	local num_arms=colsof(`blockMmatrix')
	
	//loop through all blocks
	forval i=1/`blockN' {
	
		//first get all elements in each row
		local element 
		local m_each
		forval j=1/`num_arms' {
			local element=`blockMmatrix'[`i',`j']
			local m_each `m_each' `element'
		}
		
		complete_ra `assignmenttemp' if `blockint'==`i' `andif', `replace' m_each(`m_each') skip_check_inputs
		qui replace `assignment'=`assignmenttemp' if `blockint'==`i' `andif'
	}
}

//Case 4 use block_prob_each
if !missing(`"`block_prob_each'"') {
	//setting up vars and dimensions
	qui gen `assignment'=.
	tempname assignmenttemp blockprobmatrix
	matrix define `blockprobmatrix'=`block_prob_each'
	local num_arms=colsof(`blockprobmatrix')
	
	//loop through all blocks
	forval i=1/`blockN' {
	
		//first get all elements in each row
		local element 
		local prob_each
		forval j=1/`num_arms' {
			local element=`blockprobmatrix'[`i',`j']
			local prob_each `prob_each' `element'
		}
		
		complete_ra `assignmenttemp' if `blockint'==`i' `andif', `replace' prob_each(`prob_each') skip_check_inputs
		qui replace `assignment'=`assignmenttemp' if `blockint'==`i' `andif'
	}
}



end
*
