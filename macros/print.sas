%macro print;
    proc print data=&syslast (obs=10);
    run;    
%mend;
