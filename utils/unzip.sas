/**
 * @file unzip.sas
 * @author Jan van Gestel
 * @brief Unpack a zip and write the result to target folder
 * @version 0.1
 * @date 2023-01-10
 * 
 * 
 */
options source source2 mprint mlogic;

%let zipfile = target.zip;
%let target = /data/sascode/deployments/tno;


/**
  List all current files in folder recursively
 */
%macro list_files(dir);
  %local filrf rc did memcnt name i;
  %let rc=%sysfunc(filename(filrf,&dir));
  %let did=%sysfunc(dopen(&filrf));      
  %if &did eq 0 %then %do; 
    %return;
  %end;
  %do i = 1 %to %sysfunc(dnum(&did));   
    %let name=%qsysfunc(dread(&did,&i));
    %add_member(&dir/&name);
    %list_files(&dir/&name)
  %end;
  %let rc=%sysfunc(dclose(&did));
  %let rc=%sysfunc(filename(filrf));     
%mend list_files;

%macro add_member (member);
  data temp;
    length memname $256;
    memname = "&member.";
  run;  
  proc append base = memnames data = temp force nowarn; 
  run;
%mend;

/* Initialize */
data work.memnames;
  length memname $256;
  memname = "&target";
run;    

%list_files(&target)

proc sort data = work.memnames out =  work.memnames2 nodupkey;
  by descending memname;
run;

/* 
proc print data = work.memnames2;
run;   
*/

/**
 * Delete all files recursively;
*/
data _null_;
  set memnames2 end = last;
    fname = 'todelete';
    rc = filename(fname, memname);
    rc = fdelete(fname);
    rc = filename(fname);
run;


/**
 * Read the "members" (files) from the ZIP file 
*/
data filelist (keep=memname isFolder);
  length memname $200 isFolder 8;
  rc = filename('inzip',"&zipfile.",'zip');
  fid = dopen('inzip');
  if fid = 0 then
  stop;
  memname = 'macros'; isFolder = 1; output;
  memname = 'programs'; isFolder = 1; output;
  memname = 'json'; isFolder = 1; output;
  memname = 'utils'; isFolder = 1; output;
  memname = 'deployed'; isFolder = 1; output;
  memcount=dnum(fid);
  do i = 1 to memcount;
    memname = kstrip(dread(fid,i));
    /* check for trailing / in folder name */
    isFolder = (first(reverse(trim(memname)))='/');
    put memname= isFolder=;
    output;
  end;
  rc = dclose(fid);
  rc = filename('inzip');
run;
 
/**
 * create a report of the ZIP contents */
*/ 
title "Files in the ZIP file";
proc print data=filelist noobs n;
run;

/**
 * Copy members to files in target directory ;
*/
%let dlcreatedir = %sysfunc(getoption(dlcreatedir));
options dlcreatedir;

data results;
  set filelist;
  keep memname memname_target isFolder;
  length memname_target msg $1024;
  memname_target = "&target./" || kstrip(memname);

  if _N_ = 1 then do;
    rc = libname('mklib',"&target.");
    rc = libname('mklib');
  end;  

  * Create the physical folder; 
  if isFolder = 1 then do;
    rc = libname('mklib',memname_target);
    rc = libname('mklib');
  end;  

  * Extract and copy the file in the zip; 
  else if 0=0 then do;  
    rc = filename('infile', "&zipfile.",'zip',catx(' ','recfm=f','lrecl=512','member=',quote((kstrip(memname)))));
    rc = filename('outfile', memname_target,,'recfm=f lrecl=512');
    rc = fcopy('infile', 'outfile');  
    if rc then do;
      msg = sysmsg();
      put msg; 
    end;   
    rc = filename('infile');
    rc = filename('outfile');
  end;
run;
options &dlcreatedir ;


/**
 * create a report of the UNZIP results 
*/ 
 title "Files in the ZIP file";
 proc print data=results noobs n;
 run;
