* 
Tisha Haque
tnh2115
HW 3;

libname A  "/home/u45142172/sasuser.v94/CEOR Spring 2021";
*************************
Clean up dataset
*************************;
data a.hw2_vlbw_2;
set a.hw2_vlbw;

if bwt <= 880 then bwt_cat= 1;
else if 880 < bwt <= 1100 then bwt_cat= 2;
else if 1100 < bwt <= 1290 then bwt_cat= 3;
else if 1290 < bwt <= 1580 then bwt_cat= 4;

if gest <= 27 then gest_cat =1;
else if 27< gest <= 29 then gest_cat =2;
else if 29< gest <= 31 then gest_cat =3;
else if 31< gest <= 38 then gest_cat =4;

run;

%let baseline = pneumo delivery_new twin inout_new gest_cat bwt_cat;


*************************************************
Propensity Score Step 1 Logistic Regression Model
*************************************************;
*Include all baseline factors (pre-treatment factors);

*1) No INTERACTION term;

proc logistic data = a.hw2_vlbw_2 plots(only)=roc;
class pneumo (ref= '0') Inout_new (ref= '1') twin(ref='0') delivery_new (ref='1')
bwt_cat (ref= '1') gest_cat (ref= '1')/ param=ref;
model ivh2 (event='1') = pneumo Inout_new bwt_cat gest_cat twin delivery_new/lackfit;
output out=ps_no_interaction predicted=propensity_score;  
run;

* C-Statistics (Area under the curve) = 0.778
Hosmer and Lemeshow Goodness-of-Fit Test P = 0.6723;


proc print data = ps_no_interaction (obs=10);
where ivh2=1;
run; 
/*check propensity score among patients who underwent ivh2*/

proc print data = ps_no_interaction (obs=10);
where ivh2=0;
run; 
/*check propensity score among patients who did not undergo ivh2*/

*2) Any Two-way INTERACTION term;

proc logistic data = a.hw2_vlbw_2; 
class  pneumo (ref= '0') Inout_new (ref= '1') twin(ref='0') delivery_new (ref='1') bwt_cat (ref= '1') gest_cat (ref= '1') 
/ param=ref;
model ivh2 (event='1') = pneumo|Inout_new|bwt_cat|gest_cat|twin|delivery_new@2/lackfit;
output out=ps_any2_interaction predicted=propensity_score;  
  
run;

/*OUTPUT DATASET WITH PREDICTED PROBALITY AS PROPENSITY SCORE*/

*3) Any Two-way INTERACTION term with BACKWARD ELIMINATION SLS = 0.20;
/*A significance level of 0.20 is required for a variable to stay in the model;*/


proc logistic data = a.hw2_vlbw_2 plots(only)=roc; 
class  pneumo (ref= '0') Inout_new (ref= '1') twin(ref='0') delivery_new (ref='1') bwt_cat (ref= '1') gest_cat (ref= '1') / param=ref;
model ivh2 (event='1') = pneumo|Inout_new|bwt_cat|gest_cat|twin|delivery_new@2
                            /selection=backward slstay=0.20 lackfit;
output out=ps_any2b_interaction predicted=propensity_score;   
run;

/*OUTPUT DATASET WITH PREDICTED PROBALITY AS PROPENSITY SCORE*
/*C-statistics = 0.814; Hosmer and Lemeshow Goodness-of-Fit Test P = 0.5612*/

*************************************************************************
We need to decide between PS step 1 model without interaction term 
   and with any two-ways interaction term slstay=0.2
It seems like the latter has a better C-statistics, 
both have acceptable Hosmer and Lemeshow Goodness-of-Fit Test.
Final decision is based on balance statistics. 
************************************************************************;

*(2)PS - Greedy 5 to 1 Matching;

*(2-1) PS no-interation term model;

*1) Create required variables for macro;

data A.ps_no_interaction_2;
set ps_no_interaction;
*variables required for macro: patient identifier named PATIENTN, hospital identifier variable named HID;
        prob=propensity_score;
        PATIENTN=_n_;
        HID = 1;
run; 
/*514 observations and 15 variables*/

*2) call in macro;
%let PATH = /home/u45142172/sasuser.v94/CEOR Spring 2021;
%include "&PATH/GREEDMTCH.sas";
option mprint;

%GREEDMTCH
       (A, 	   /* Library Name */
        ps_no_interaction_2,   /* Data set of all patients*/
        ivh2,    /* Dependent variable that indicates Case or Control; Code 1 for Cases, 0 for Controls*/
        Greedy_matching_1    /* Output file of matched pairs*/
       );

* 
  NOTE: There were 126 observations read from the data set A.MATCH5.
 NOTE: There were 0 observations read from the data set A.MATCH4.
 NOTE: There were 0 observations read from the data set A.MATCH3.
 NOTE: There were 12 observations read from the data set A.MATCH2.
 NOTE: There were 24 observations read from the data set A.MATCH1.
 NOTE: The data set A.GREEDY_MATCHING_1 has 162 observations and 16 variables.
  NOTE: DATA statement used (Total process time):
       real time           0.02 seconds
       user cpu time       0.00 seconds;
 
 
%let PATH = /home/u45142172/sasuser.v94/CEOR Spring 2021;
%include "&PATH/Standardized_Difference.sas";
%let char = pneumo Inout_new bwt_cat gest_cat twin delivery_new;

/*PS-1 no interaction model*/
%stddiff( inds = A.GREEDY_MATCHING_1,                        /*Data set Name*/
     groupvar = ivh2,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

*(2-2) PS any two-way interation term model with slstay = 0.2;

*1) Create required variables for macro;
data A.ps_any2b_interaction_2;
set ps_any2b_interaction;
*variables required for macro: patient identifier named PATIENTN, hospital identifier variable named HID;
        prob=propensity_score;
        PATIENTN=_n_;
        HID = 1;
run; 
/*514 observations and 13 variables*/

*2) call in macro;
%GREEDMTCH
       (A, 	   /* Library Name */
        ps_any2b_interaction_2,   /* Data set of all patients*/
        ivh2,    /* Dependent variable that indicates Case or Control; Code 1 for Cases, 0 for Controls*/
        Greedy_matching_2    /* Output file of matched pairs*/
       );

*
 
 NOTE: There were 126 observations read from the data set A.MATCH5.
 NOTE: There were 0 observations read from the data set A.MATCH4.
 NOTE: There were 0 observations read from the data set A.MATCH3.
 NOTE: There were 10 observations read from the data set A.MATCH2.
 NOTE: There were 8 observations read from the data set A.MATCH1.
 NOTE: The data set A.GREEDY_MATCHING_2 has 144 observations and 16 variables.
 NOTE: DATA statement used (Total process time):
       real time           0.02 seconds
       user cpu time       0.00 seconds;
 
%stddiff( inds = A.Greedy_matching_2,                        /*Data set Name*/
     groupvar = ivh2,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

 /*Table 1 for original cohort*/

proc tabulate data = A.ps_no_interaction_2;
class  ivh2 &baseline.;
table &baseline., 
      ivh2*(n*f=8. colpctn='%')/box='';
run;

proc freq data = A.ps_no_interaction_2;
table (&baseline.)* 
      ivh2/chisq;
run;

%stddiff( inds = A.ps_no_interaction_2,                        /*Data set Name*/
     groupvar = ivh2,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

/*Table 1 for matched cohort based on PS model without interaction term */
proc tabulate data = A.GREEDY_MATCHING_1;
class  ivh2 &baseline.;
table &baseline., 
      ivh2*(n*f=8. colpctn='%')/box='';
run;

proc freq data = A.GREEDY_MATCHING_1;
table (&baseline.)* 
      ivh2/chisq;
run;

%stddiff( inds = A.GREEDY_MATCHING_1,                   /*Data set Name*/
     groupvar = ivh2,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

*(3)PS - IPTW Method;
data ps_IPTW;
set ps_no_interaction;
*calculate IPTW;
if ivh2=1 then IPTW=1/propensity_score;
else if ivh2=0 then IPTW=1/(1-propensity_score);
run;


proc tabulate data = ps_IPTW;
class  ivh2 &baseline.;
weight IPTW;
table &baseline., 
      ivh2*(n*f=8. colpctn='%')/box='';
run;

proc freq data = ps_IPTW;
weight IPTW;
table (&baseline.)*ivh2/chisq;
run;

%stddiff( inds = ps_IPTW,                   /*Data set Name*/
     groupvar = ivh2,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = IPTW,
     stdfmt = 8.4,
     outds = stddiff_result ); 

 ***************************
PS Step 2 Outcome Model
**************************;
*(1) PS Match;
proc logistic data=A.Greedy_matching_1 ;
format ivh2 ivh2.;
class ivh2 (ref='0')/param=ref;
model dead (event='1') =  ivh2;
strata matchto;
run; 

/* aOR=5.00 95%CI: 2.081, 12.013*/



*(2) PS IPTW;
proc surveylogistic data=ps_IPTW;
format ivh2 ivh2.;
class ivh2 (ref='0')/param=ref;
model dead (event='1') =  ivh2;
weight IPTW;
run; 

/*aOR = 2.995 95%CI: 1.543, 5.811*/



***************************
Extra Credit
Other PS Methods
**************************;
***********************************
PS Stratification
***********************************;
*1) Create PS stratum variable( groups dependent on sample size);
proc rank data=ps_no_interaction out=ps_no_interaction_stra5 groups=5; 
 var propensity_score;
 ranks ps_pred_rank;
run; 

*Check the distribution of PS at each stratum ;
proc means data=ps_no_interaction_stra5;
 var propensity_score;
 class ps_pred_rank ivh2;
run;

proc freq data=ps_no_interaction_stra5;
table ivh2*ps_pred_rank/nopercent nocol;
run;

*2) Distribution of selected characteristics by quintile;
proc freq data=ps_no_interaction_stra5;
table ps_pred_rank*ivh2*(pneumo delivery_new twin inout_new gest_cat bwt_cat)/nopercent nocol;
run;

/*No hypothesis testing for the balance*/

*3) Outcome Model for PS stratification <slide24>; 
proc logistic data=ps_no_interaction_stra5;
format ivh2 ivh2.;
class ivh2 (ref='0')/param=ref;
model dead (event='1') =  ivh2 ;
strata ps_pred_rank;
run;
/*aOR = 3.353 95%CI: 1.943, 5.784*/


********************************************************
 PS Regression 
********************************************************;
proc logistic data=ps_no_interaction;
format ivh2 ivh2.;
class ivh2 (ref='0')/param=ref;
model dead (event='1') =  ivh2 propensity_score propensity_score*propensity_score;
run;

/*OR = 3.230, 95%CI: 1.845, 5.653 */

proc freq data = ps_no_interaction;
table ivh2*dead/nopercent nocol;
run;

 
 

 






































