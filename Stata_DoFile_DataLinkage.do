*************************
* Created by: Ali Mirzazadeh
* For questions or assistance: ali.mirzazadeh@ucsf.edu
*************************


*************************
* Deterministic linkage *
*************************

* Dataset A: Patient Registry (patient_registry.dta)
clear
input str15 Name MRN str8 DOB
"John Smith"    847291 "1/15/80"
"Mary Johnson"  562834 "5/22/75"
"Robert Brown"  913675 "11/8/90"
end

save patient_registry, replace

* Dataset B: Death Records (death_records.dta)
clear
input ID str8 Date_of_Death
562834 "8/15/24"
847291 "3/10/25"
913675 "12/1/24"
end
save death_records, replace

* Since the key variables have different names (MRN and ID),
* rename ID first:
use death_records, clear
rename ID MRN
save death_records, replace

* Deterministic linkage using MRN
use patient_registry, clear
merge 1:1 MRN using death_records, keepusing(Date_of_Death)

list

* Deterministic linkage was performed using an exact match between the
* Patient Registry MRN and the Death Records ID. 
* All records matched uniquely (1:1 linkage).	

******************
* Fuzzy Matching *
******************

* Install once
net install dm0082.pkg

* Dataset A: Patient Registry
clear
input str20 Name str10 DOB
"John Smith"   "1980-01-15"
"Mary Johnson" "1975-05-22"
"Robert Brown" "1990-11-08"
end
gen id_master = _n
save patient_registry, replace

* Dataset B: Death Records
clear
input str20 Full_Name str10 Date_of_Death
"Jon Smith"    "2025-03-10"
"Mary Jonson"  "2024-08-15"
"Robert Brown" "2024-12-01"
end
gen id_using = _n
save death_records, replace

* Since the name variables have different names (Name and Full_Name),
* rename Full_Name first:
use death_records, clear
rename Full_Name Name
save death_records, replace

* Probabilistic linkage
use patient_registry, clear

reclink2 Name using death_records, ///
    idmaster(id_master) ///
    idusing(id_using) ///
    gen(score)

* Keep likely matches
keep if score >= 0.90

* Show final matched records
list Name DOB Date_of_Death score, noobs


*************************
* Probabilistic linkage * 
*************************

* Install once
* net install dm0082.pkg, replace 


* Dataset A: Patient Registry
clear
input str20 Name str10 DOB
"John Smith"   "1980-01-15"
"Mary Johnson" "1975-05-22"
"Robert Brown" "1990-11-08"
end
gen dob_master = date(DOB,"YMD")
format dob_master %td
gen id_master = _n
save patient_registry, replace

* Dataset B: Death Records
clear
input str20 Full_Name str10 DOB str10 Date_of_Death
"Jon Smith"    "1980-01-15" "2025-03-10"
"Mary Jonson"  "1975-06-10" "2024-08-15"
"Robert Brown" "1990-11-08" "2024-12-01"
end
gen dob_using = date(DOB,"YMD")
format dob_using %td
gen id_using = _n
save death_records, replace

* Since the name variables have different names (Name and Full_Name),
* rename Full_Name first:
use death_records, clear
rename Full_Name Name
save death_records, replace

* Probabilistic linkage on Name
use patient_registry, clear
reclink2 Name using death_records, ///
    idmaster(id_master) ///
    idusing(id_using) ///
    gen(name_similarity)

* DOB difference in days
gen dob_diff_days = abs(dob_master - dob_using)

* DOB similarity
* Exact DOB match = 1
* Within 30 days = 0.9
* Otherwise = 0
gen dob_similarity = 0
replace dob_similarity = 1 ///
    if dob_diff_days == 0
replace dob_similarity = 0.9 ///
    if dob_diff_days > 0 & dob_diff_days <= 30

* Combined probabilistic score
gen prob_score = ///
    0.7*name_similarity + ///
    0.3*dob_similarity

* Show all candidate pairs
list Name dob_diff_days ///
     name_similarity dob_similarity ///
     prob_score, noobs

* Keep likely matches
keep if prob_score >= 0.90
list Name DOB UName Date_of_Death ///
     name_similarity dob_similarity ///
     prob_score, noobs

	 
**************************************************
* Fellegi-Sunter probabilistic linkage in Stata
* using dtalink
**************************************************

clear all
set more off

* Install once
ssc install dtalink, replace

**************************************************
* Dataset A: Patient Registry
**************************************************

clear
input long id1 str20 Name str10 DOB_str
1 "John Smith"   "1980-01-15"
2 "Mary Johnson" "1975-05-22"
3 "Robert Brown" "1990-11-08"
end

gen DOB = daily(DOB_str, "YMD")
format DOB %td
drop DOB_str

save patient_registry.dta, replace

**************************************************
* Dataset B: Death Records
**************************************************

clear
input long id2 str20 Full_Name str10 DOB_str str10 Date_of_Death_str
1 "Jon Smith"    "1980-01-15" "2025-03-10"
2 "Mary Jonson"  "1975-06-10" "2024-08-15"
3 "Robert Brown" "1990-11-08" "2024-12-01"
end

gen DOB = daily(DOB_str, "YMD")
gen Date_of_Death = daily(Date_of_Death_str, "YMD")
format DOB Date_of_Death %td
drop DOB_str Date_of_Death_str
save death_records.dta, replace


* rename varaible Full_Name to Name to have the same name in both data 
use death_records.dta, clear
rename Full_Name Name
save death_records.dta, replace

**************************************************
* Probabilistic linkage
**************************************************

use patient_registry.dta, clear
gen Name2=Name
list

* Match patient registry to death records.
* Name 5 -5 -> matching names get +5; nonmatching names get −5.
* DOB 5 0 -> exact DOB match gets +5 points; otherwise 0.
* DOB 3 0 7 -> DOB within 7 days gets +3 points; otherwise 0.
* DOB 2 -2 30 -> DOB within 30 days gets +2 points; otherwise −2.
* Total match score = sum of variable-specific scores.
* cutoff(0) keeps all candidate pairs (minimum possible score = 0).
* calcweights estimates improved Fellegi–Sunter-style weights from the data.
* bestmatch keeps only the highest-scoring match for each record.
* cutoff(0) keeps matches with a score of at least 0.
* describe reports matching details.
* wide stores results in wide format.

dtalink Name 5 -5 DOB 5 0 DOB 3 0 7 DOB 2 -2 30 using death_records.dta, cutoff(0) calcweights bestmatch describe 

* Review the matched output.
list
list if id1 !=.
list if id2 !=.
save linked_pairs.dta, replace

* Keep only matched pairs
use linked_pairs.dta, clear
list
gen ID=id2
keep if _matchflag==1 & id2!=.
list
save linked_pairs_matched.dta, replace

* Merge matched deaths back to patient registry
use patient_registry.dta, clear
gen ID = id1
merge 1:1 ID using "linked_pairs_matched.dta", keepusing(Date_of_Death)
list




