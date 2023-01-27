/**
   @file run_main.sas
   @author Jan van Gestel
   @version 0.1
   @date 2023-01-17
   @brief  Job to demo Viya with VS Code, SAS Extension and Jenkins

**/

/**
  Parameters interactive session
  In batch parameter batch=1 is set by Jenkins
 */

%macro params_interactive; 
%global batch target target_data;
%if "&batch" ne "1" %then %do; 
  %let target = /sascode/viya_dataOps;
  %let target_data = /sascode/viya_dataOps;
%end;
%mend;
%params_interactive; 


/**
  Assign libnames, filenames, open CAS session
 */
filename programs "&target./programs";
filename utils "&target./utils";
filename fmacros "&target./macros";
options mautosource sasautos=(fmacros);
options noquotelenmax ;


/**
 Run Hello World job
 */
%include programs(hello_world);


/**
  Return error code
 */
%put &=syserr;
%put &=syscc;
%macro set_rc;
  %if %eval(&syscc le 4) %then %let syscc = 0;
  %put &=syscc;
%mend;
%set_rc;  
