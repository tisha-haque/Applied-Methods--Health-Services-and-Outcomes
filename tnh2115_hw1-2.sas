* 
Tisha Haque
tnh2115
HW 1;


libname A  "/home/u45142172/sasuser.v94/CEOR Spring 2021";


proc format;
value age_cat2_new 1='<50' 2='50-59' 3='60-69' 4='70-79' 5='>/=80';
value race_2_new 1='Non-Spanish: White' 2='Non-Spanish: Black' 3='Hispanic' 4='Non-Spanish:Other' 5='Unknown';
value INSURANCE_STATUS_new 0='Not Insured' 1='Private Insurance' 2='Medicaid' 3='Medicare'  9='Other/Unknown'; 
value income_new 1='< $30,000' 2='$30,000 - $35,999' 3='$36,000 - $45,999' 4='$46,000 +' 9='Not Available';
value urban_rural_new 0='Metropolitan' 1='Urban' 2='Rural' 9='Unknown';
value cdcc_new 0='0' 1='1' 2='>=2' 9='Unknown';
value Stage_group_cat 1='I' 2='IA' 3='IB' 4='II' ;
value LND 0='No' 1='Yes';
value FACILITY_LOCATION_cat 1='Eastern' 2='South' 3='Midwest' 4='West';
value facility_type 1='Academic/Research Program'  0='Non-Academic program';
value Beam 1='Yes' 0='No';
value grade_new 1='Well' 2='Moderate' 3='Poorly' 9='Unknown';
value death 0="Alive" 1="Dead";
run;

*Background;
*what's in the analytic dataset;

proc contents data = A.Beam;run;
proc print data = A.Beam(obs = 10);
format age_cat2_new age_cat2_new. race_2_new race_2_new. INSURANCE_STATUS_new INSURANCE_STATUS_new. income_new income_new. 
       urban_rural_new urban_rural_new. Stage_group_cat Stage_group_cat. LND LND. FACILITY_LOCATION_cat FACILITY_LOCATION_cat.
       facility_type facility_type. Beam Beam. grade_new grade_new. death death.;
run;

/*One-way frequecy table*/

proc freq data = A.Beam;
table age_cat2_new race_2_new INSURANCE_STATUS_new income_new cdcc_new
       urban_rural_new Stage_group_cat   FACILITY_LOCATION_cat 
       facility_type   grade_new LND Beam death;
format age_cat2_new age_cat2_new. race_2_new race_2_new. INSURANCE_STATUS_new INSURANCE_STATUS_new. income_new income_new. cdcc_new cdcc_new.
       urban_rural_new urban_rural_new. Stage_group_cat Stage_group_cat. LND LND. FACILITY_LOCATION_cat FACILITY_LOCATION_cat.
       facility_type facility_type. Beam Beam. grade_new grade_new. death death.;
run;

*Risk of death by beam;

/*Two-way frequency*/
proc freq data = A.Beam;
table  beam*death;
format beam beam. death death.;
run;
*calculate the OR and RR;

proc freq data = A.Beam;
	tables beam*death /  relrisk;
    format beam beam. death death.;
run;

/*Modelling for OR or RR, self define referent group in class statement*/

proc logistic data = A.Beam;
	class beam (ref='0') / param=ref;
	model death (event='1') = beam;
run;

proc genmod data = A.Beam;
	class beam (ref='0') / param=ref;
	model death (event='1') = beam/dist=poisson link=log;
    estimate "beam No"             beam 0/exp ; 
    estimate "beam Yes"            beam 1/exp ; 
run;


*Question 1a;
data beam;
set A.Beam;
if beam=0 then beam=2;
run;
proc freq data = Beam;
	tables beam*death /  relrisk;
run;

* The percentage of subjects who died given that they had the beam : 9.45%.
The percentage of subjects who died given that they didn't have the beam: 5.85%;

*Question 1b;

data beam;
set A.Beam;
if beam=0 then beam=2;
run;
proc freq data = Beam;
	tables beam*death /  relrisk;
run;

*The risk ratio is 2.407 with a 95% confidence interval of (1.8461, 3.1395) 
This means that the risk of death among those who had external beam radiation after 
hysterectomy was 2.407 times the risk of death among those who did not have external 
beam radiation after hysterectomy. We are 95% confident that the true risk ratio is 
between 1.8461 and 3.1395.;

* Question 2;
/*Evaluating the confouding of beam-DEATH*/

*A) Variable associated with outcome ?;
proc freq data = A.Beam;
table  (age_cat2_new cdcc_new Stage_group_cat facility_type)* death/chisq;
format age_cat2_new age_cat2_new. cdcc_new cdcc_new. Stage_group_cat Stage_group_cat. 
       facility_type facility_type. death death.;
run;


proc logistic data = A.Beam;
	class age_cat2_new (ref='1')/ param=ref;
	model death (event='1') = age_cat2_new;
run;
proc logistic data = A.Beam;
	class cdcc_new (ref='0') / param=ref;
	model death (event='1') = cdcc_new;
run;
proc logistic data = A.Beam;
	class Stage_group_cat (ref='1') / param=ref;
	model death (event='1') = Stage_group_cat;
run;
proc logistic data = A.Beam;
	class facility_type (ref='1') / param=ref;
	model death (event='1') = facility_type;
run;

*B) Variable associated with exposure?;
proc freq data = A.Beam;
table  (age_cat2_new cdcc_new Stage_group_cat facility_type)* beam/chisq;
format age_cat2_new age_cat2_new. cdcc_new cdcc_new. Stage_group_cat Stage_group_cat. 
       facility_type facility_type. beam beam.;
run;
proc logistic data = A.Beam;
	class age_cat2_new (ref='1')/ param=ref;
	model beam (event='1') = age_cat2_new;
run;
proc logistic data = A.Beam;
	class cdcc_new (ref='0') / param=ref;
	model beam (event='1') = cdcc_new;
run;
proc logistic data = A.Beam;
	class Stage_group_cat (ref='1') / param=ref;
	model beam (event='1') = Stage_group_cat;
run;
proc logistic data = A.Beam;
	class facility_type (ref='1') / param=ref;
	model beam (event='1') = facility_type;
run;


*3)Is the varailbe on the pathway between exposure and outcome?;
*Subject-matter knowledge;
















