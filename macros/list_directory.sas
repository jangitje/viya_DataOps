%macro list_directory (dir=,outtable=,first=0); 

    %if &first = 0 %then %do;
        /* Initialize */
        data &outtable.;
            length fileName $100 fileSize 8 fileDate 8 fileType $16 path $200;
            format fileDate datetime22.; 
            path = "&dir.";
            fileName = "";
            fileSize = .;
            fileDate = .;
            fileType='';
            is_directory=1;
        run;    
    %end;    

    %macro add_member (path, fileName, fileSize, fileDate);
        data temp;
            length fileName $100 fileSize 8 fileDate 8 fileType $16 path $200;
            path = "&path.";
            fileName = "&fileName.";
            fileSize = round(&fileSize/1024);
            fileDate = &fileDate; 
            fileType = kupcase(kscan(fileName,-1,'.'));
            if fileSize = . then do;
                is_directory = 1;
                path = kstrip(path) !!'/'!! kstrip(fileName);
                fileName = ""; 
                fileType = "";
            end;    
            else is_directory = 0;
        run;  
        proc append base = &outtable. data = temp force nowarn; 
        run;
    %mend;
   

    %local filrf filrf2 rc did memcnt name i;
    %let rc = %sysfunc(filename(filrf,&dir));
    %let did = %sysfunc(dopen(&filrf));      
    %if &did eq 0 %then %do; 
        %return;
        %end;
    %do i = 1 %to %sysfunc(dnum(&did));   
        %let name = %qsysfunc(dread(&did,&i));
        %let rc = %sysfunc(filename(filrf2,%bquote(&dir/&name)));
        %let fid = %sysfunc(fopen(&filrf2));  
        %let fileSize = .; 
        %let fileDate = .; 
        %if %eval(&fid > 0) %then %do;  
            %let fileSize = %sysfunc(inputn(%sysfunc(finfo(&fid, %bquote(File Size (bytes)))), best.));
            %let fileDate = %sysfunc(inputn(%sysfunc(finfo(&fid, %bquote(Last Modified))), datetime.));
        %end;
        %let rc=%sysfunc(fclose(&fid));
        %let rc=%sysfunc(filename(filrf2));     
        %add_member(%bquote(&dir), %bquote(&name), &fileSize, &fileDate);
        %list_directory(dir=%bquote(&dir/&name), outtable=&outtable., first=1)
    %end;
    %let rc=%sysfunc(dclose(&did));
    %let rc=%sysfunc(filename(filrf));     

%mend list_directory;

/* %list_directory(dir=&docs, outtable=metaout);  */
/* proc print data=metaout;
run; */