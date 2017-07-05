****Randomizr Stata Port*************
****Module 0:************************ 
****Simple Random Assignment*********
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****02jul2017************************
*****version 1.0*********************
***john.ternovski@yale.edu***********
program define simple_ra
	version 12
	syntax namelist(max=1 name=assignment) [if], [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [num_arms(numlist max=1 >0)] [condition_names(string)] [check_inputs] [replace]
	
	
*set default condition names
if missing(`"`condition_names'"') {
	local condition_names "0 1"
}
*replace assignment variable and label if replace is specified
if `"`replace'"'!="" {
	cap drop `assignment'
	cap label drop `assignment'

}

*get N
qui count `if'
local N=`r(N)'
*generate random variable for random assignment
tempvar rand rank stnd_rand
gen `rand'=runiform() `if'
egen `rank'=rank(`rand') `if' /*using ranks to maximize closeness to the specified probabilities*/
gen `stnd_rand'=(`rank'-1)/`N' `if' 




if !missing(`"`prob'"') & missing(`"`prob_each'"') {
	local num_arms = 2
	local prob_miss = 1 - `prob'
	local prob_cum = `prob_miss' + `prob' 
	local prob_vector `"`prob_miss' `prob_cum'"'
	disp "`prob_vector'"
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
gen `assignment'=0 if `stnd_rand'<`1'
forval i=2/`num_arms'{
	replace `assignment'=`i'-1 if `stnd_rand'>=`1' & `stnd_rand'<`2'
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












*Age quod agis
