%macro printit;
    proc print data=&syslast (obs=10);
    run;    
%mend;
