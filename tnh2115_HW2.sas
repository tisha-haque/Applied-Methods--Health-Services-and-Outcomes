* 
Tisha Haque
tnh2115
HW 1;

libname A  "/home/u45142172/sasuser.v94/CEOR Spring 2021";

proc format;
value deadf 1 = "dead" 0 = "Alive";
value ivh2f 1="Yes" 0="No";
value pneumof 1= "Yes" 0="No";
value delivery_newf 1= "C-Section" 2="Vaginal" 9="Unknown";
value twinf 1="Yes" 0 = "No";
value inout_newf 1="Born at Duke" 2= "Transport";
run;

%let var_format = dead deadf. ivh2 ivh2f. pneumo pneumof. delivery_new delivery_newf. twin twinf. inout_new inout_newf.;
%let baseline = pneumo delivery_new twin inout_new;

proc freq data = a.hw2_vlbw;
format &var_format.;
table (&baseline.)ivh2/ nopercent nocol chisq; /*Evaluate association between baseline factors and exposure*/
table (&baseline.)dead/ nopercent nocol chisq;   /*Evaluate association between baseline factors and outcome*/
run;

proc tabulate data = a.hw2_vlbw;
format &var_format.;
class  dead ivh2 &baseline.;
table  ivh2 &baseline., 
      dead*(n*f=8. colpctn='%')/box='';
run;

/*1) Report unadjusted crude association (OR) between IVH and DEAD using proc logistic.*/

proc logistic data = a.hw2_vlbw;      
class ivh2 (ref= '0') / param=ref;
model dead (event='1') = ivh2 ;                         
run;

/*unadjOR = 6.116, 95% CI: 3.674, 10.179 

Babies born with Intraventricular hemmorhage have 6.116 times the odds of death compared
to babies born without Intraventricular hemmorhage.*/

/*2) Building a Multivariable regression model Logistic regression model (aOR)
Start with a univariate screen to assess the association between all covariates 
and the outcome, dead. We use the p <0.25 cutoff to determine the non- candidate 
covariates to remove.

Run a univariate test for each covariate against outcome
    If p<.25 then put it on the:   Candidate list
    If p>.25 then put it on the:   Non-Candidate list*/
   
Proc logistic data = a.hw2_vlbw;
model dead (event= '1')= ivh2;
run;

Proc logistic data = a.hw2_vlbw;
model dead (event= '1')= pneumo;
run;

Proc logistic data = a.hw2_vlbw;
model dead (event= '1')= bwt;
run;

Proc logistic data = a.hw2_vlbw;
model dead (event= '1')= gest;
run;

Proc logistic data = a.hw2_vlbw;
model dead (event= '1')= twin;
run;

Proc logistic data = a.hw2_vlbw;
model dead (event= '1')= Delivery_new;
run;

Proc logistic data = a.hw2_vlbw;
model dead (event= '1')= inout_new;
run;


/*CANDIDATE LIST:
ivh2 (p<0.0001) pneumo (p<0.0001) bwt (p<.0001) gest (<.0001) inout_new (p=0.0237)

NON-CANDIDATE LIST:
twin (p= 0.6577) Delivery_new (p=0.3996)*/

/*3) Put all covariates from the Candidate list into a multivariate model;*/

proc logistic data = a.hw2_vlbw;     
class ivh2 (ref= '0') / param=ref;
class pneumo (ref= '0') Inout_new (ref= '1');
model dead (event='1') = ivh2 pneumo Inout_new bwt gest ;                         
run;

/* The beta for ivh2: 1.2416
Adjusted OR: 3.461	95% CL (1.821, 6.579)*/


/*4) Remove covariates from the model if they are not significant (p>.10) 
and not a confounder (removal does not change a coefficient by more than 20%). After running the model, 
only inout_new is (p>.10), so we should remove it since it is not significant. */

proc logistic data = a.hw2_vlbw;     
class ivh2 (ref= '0') / param=ref;
class pneumo (ref= '0') ;
model dead (event='1') = ivh2 pneumo bwt gest ;                         
run;

/* After removing inout_new, our beta for ivh2= 1.2468 (compared to 1.2416) (change less than 20% from previous model)
Adjusted OR: 3.479	95% CL (1.860, 6.509)

5) Add back in Non-candidate variables to see if they are significant */

proc logistic data = a.hw2_vlbw;     
class ivh2 (ref= '0') / param=ref;
class pneumo (ref= '0') Delivery_new (ref= '1') twin (ref='0');
model dead (event='1') = ivh2 pneumo bwt gest Delivery_new twin ;                         
run;


/* Beta of ivh2= 1.3264 (compared to 1.2468) (change less than 20% from previous model)
Adjusted OR: 3.767, 95% CL (1.980, 7.167)

6) Both Delievery_new (p=0.6626) and twin (p- 0.2218) have p-values
greater than p>.10, so we will remove them from the model, one
by one to ensure they dont significantly change the beta value for ivh2.

7) dropping twin */


proc logistic data = a.hw2_vlbw;     
class ivh2 (ref= '0') / param=ref;
class pneumo (ref= '0') Delivery_new (ref= '1') ;
model dead (event='1') = ivh2 pneumo bwt gest Delivery_new ;                         
run;


/* after dropping the twin variable,
Beta of ivh2= 1.2746 (compared to 1.3264) (change less than 20% from previous model)
Adjusted OR: 3.577, 95% CL: 1.897, 6.746 */

/* 8) Dropping Delivery_new */


proc logistic data = a.hw2_vlbw;     
class ivh2 (ref= '0') / param=ref;
class pneumo (ref= '0') ;
model dead (event='1') = ivh2 pneumo bwt gest ;                         
run;

/* After dropping delivery_new, Beta of ivh2= 1.2468 (compared to 1.3264) (change less than 20% from previous model)
Adjusted OR= 3.479 and 95% CI (1,860, 6.509)

This is our final model. After adjusting for pneumothorax, birthweight, and gestational age
we find that babies born with intraventricular hemmorage have 3.479 times the odds
of death compared to babies born without intraventricular hemmorage. */








