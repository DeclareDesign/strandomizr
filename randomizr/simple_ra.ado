****Randomizr Stata Port*************
****Module 0:************************ 
****Simple Random Assignment*********
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****28jul2017************************
*****version 1.5********************
***john.ternovski@yale.edu***********

program define simple_ra, byable(recall, noheader)
	version 15
	syntax namelist(max=1 name=treat) [if] [in], [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [num_arms(numlist max=1 >0)] [condition_names(string)] [check_inputs] [replace] 

//Fixing ifs when have bys
if !missing(`"`if'"') {
	local andif=`"&"'+substr(`"`if'"',3,.)
}

	
//allow byable 
marksample touse
if _byindex()<=1 {	
	//replace assignment variable and label if replace is specified
	if `"`replace'"'!="" {
		cap drop `treat'
		cap label drop `treat'
	}
	qui gen `treat'=.

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
	
//set indexing
if `num_arms'==2 & (!missing(`"`withlabel'"') | missing(`"`condition_names'"')) {
	local index0=1
}

//get N
qui count `in' if `touse'==1 `andif'
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

//set up for mata input
tempname p id treattmp
matrix input `p'=(`prob_vector')
gen `id'=_n 
qui putmata `id' `in' if `touse'==1 `andif' , replace

//randomize
mata: treat = rdiscrete(strtoreal(st_local("N")),1,st_matrix(st_local("p")))
getmata `treattmp'=treat, id(`id') update
qui replace `treat'=`treattmp' if `touse'==1 `andif'


if _bylastcall() {
	//change values to correspond to custom condition_names values
	if missing(`"`withlabel'"') & !missing(`"`condition_names'"') {
		tempvar treat_old
		rename `treat' `treat_old'
		qui gen `treat'=. 
		forval i=1/`num_arms' {
			local cname`i' : word `i' of `condition_names'
			qui replace `treat'=`cname`i'' if `treat_old'==`i'
		}
	}

	//reindex if necessary
	if `"`index0'"'=="1" {
		qui replace `treat'=`treat'-1
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
		label define `treat' `start' `"`1'"'
		macro shift
		local startplusone=`start'+1
		forval i=`startplusone'/`num_arms' {
			label define `treat' `i' `"`1'"', add
			macro shift
		}
		label val `treat' `treat'
	}
}



end












*Age quod agis
