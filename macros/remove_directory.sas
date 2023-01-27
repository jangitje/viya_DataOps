%macro remove_directory (dir=);

%list_directory (dir=&dir., outtable=filesout); 

data _null_;
    set filesout end=last;
    if is_directory =0;
    fname="tempfile";
    rc=filename(fname, kstrip(path) || '/' || kstrip(fileName));
    if rc = 0 and fexist(fname) then
        rc=fdelete(fname);
    rc=filename(fname);
    if last then do;
        rc=filename(fname, kstrip(path));
        if rc = 0 and fexist(fname) then
            rc=fdelete(fname);
        rc=filename(fname);
    end;
run;
%mend;

%remove_directory(dir=%bquote(&dir_to));