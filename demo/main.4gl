IMPORT FGL mod2
IMPORT FGL mod5
define mod Integer
define g_arr ARRAY[10000] OF RECORD
--define g_arr ARRAY[10] OF RECORD
  str String,
  itype Integer,
  dt Date
END RECORD
define test Integer

DEFINE myarr2 DYNAMIC ARRAY OF RECORD
  a INTEGER,
  b STRING
END RECORD


main
  define param,p,kind,name String
  define test,test2,argstr String
  define m,i,ok,lineNumber Integer
  define g_frame_no,numargs Integer
  define arr DYNAMIC ARRAY OF String
  define a ARRAY [20,20] OF INTEGER
  --define let Integer
  define abc RECORD
    a ARRAY[20] OF INTEGER,
    var2 Integer,
    var1 String
  END RECORD
  define abcarr ARRAY[20] OF RECORD
    a ARRAY[20] OF INTEGER,
    var2 Integer,
    var1 String
  END RECORD
  DEFINE var_arr DYNAMIC ARRAY OF STRING
  DEFINE stk_arr DYNAMIC ARRAY OF RECORD
    lineNumber Integer
  END RECORD
  LET numargs=num_args()
  FOR i=1 TO numargs
    LET argstr=argstr.append(arg_val(i))
    LET argstr=argstr.append(" ")
  END FOR
  LET g_frame_no=1
  LET i=1
  LET stk_arr[g_frame_no].lineNumber = 2
  IF i=stk_arr [g_frame_no] . lineNumber AND i = 1 THEN
    DISPLAY "hallo"
  END IF

  LET ok=1
  LET a [  i , ok ]   =  2
  LET myarr2 [ i ] . b= " 20 "
  CALL split_vars(", ,abc  ,  def hallo   Du[sau]",var_arr)
  LET abcarr[ i ] . a [ ok ]=4
  CALL int_test( abcarr  [ i ] . a [ ok ] )
  CALL split_vars(" abc , def,arg[i] hallo",var_arr)
  if num_args()>0 then
    for i = 1 TO num_args()
      let param=arg_val(i)
      DISPLAY sfmt("param(%1)=\"%2\"",i,param)
    end for
  else
    let param="hallo"
  end if
  LET m=5
  LET abc.var1="a(\"F  willi\",9,\"hallo\",arr) RET ok,lineNumber"
  LET arr[1]="  FUNCTION  hallo (abc,def) "
  LET arr[2]="    DEFINE a,b INTEGER"
  LET arr[3]="    LET a=3"
  LET arr[4]="    LET b=3"
  LET arr[5]="    RETURN 5"
  LET arr[6]="  END  FUNCTION"
  LET arr[7]="FUNCTION  willi(foo) "
  LET arr[8]="DEFINE foo STRING"
  LET arr[9]="RETURN foo"
  LET arr[10]="end function"
  --breakpoint
  CALL check_function_line(" end main") RETURNING kind,name
  CALL check_function_line(" main") RETURNING kind,name
  CALL find_line_in_srcarr("LET a=3",2,"HALLO",arr) RETURNING ok,lineNumber
  CALL find_line_in_srcarr("LET a=3",3,"hallo",arr) RETURNING ok,lineNumber
  CALL find_line_in_srcarr("LET a=3",4,"hallo",arr) RETURNING ok,lineNumber
  CALL find_line_in_srcarr("LET a=3",9,"hallo",arr) RETURNING ok,lineNumber
  CALL find_line_in_srcarr("FUNCTION  willi",9,"willi",arr) RETURNING ok,lineNumber
  CALL find_line_in_srcarr("FUNCTION  willi",9,"hallo",arr) RETURNING ok,lineNumber
  
  LET g_frame_no=1
  IF g_frame_no+1>= arr.getLength() THEN
    DISPLAY "hallo"
  END IF
  CALL init_garr()
  LET test="{ abc }"
  IF test="{ abc }" THEN
    DISPLAY "hallo"
  END IF
  IF test IS NULL THEN
    DISPLAY "is null"
  END IF
  IF (test+"") IS NULL THEN
    DISPLAY "is null"
  END IF
  LET test="\"ha"
  LET test2="( abc )"
  LET arr[1]="hallo"
  LET arr[2]="goo {2 "
  LET mod=1
  CALL mod5()
  CALL mod2(param) RETURNING p,m
  LET abc.var1=p
  LET abc.var2=m
  FOR i=1 TO 3
   LET arr[i]=i
  END FOR
  IF param="hallo" THEN
    DISPLAY "EXIT 1"
    EXIT PROGRAM 1
  END IF
 LET abc.var2=4
 DISPLAY "EXIT 0"
end main

FUNCTION int_test(intparm)
  DEFINE intparm INTEGER
  DISPLAY "parm is ",intparm
END FUNCTION

FUNCTION split_vars(str,var_arr)
  DEFINE str STRING
  DEFINE var_arr DYNAMIC ARRAY OF STRING
  DEFINE var_count,i,check_newvar INTEGER
  DEFINE singlevar,state,c STRING
  LET var_count=1
  LET singlevar=""
  LET state="startvar"

  FOR i=1 TO str.getLength()
    LET c=str.getCharAt(i)
    LET check_newvar=0
    CASE c
      WHEN "," 
        LET check_newvar=1
      WHEN " "
        LET check_newvar=1
      OTHERWISE
        LET singlevar=singlevar.append(c)
        LET state="invar"
    END CASE
    IF check_newvar AND state="invar" AND singlevar.getLength()>0 THEN
        LET var_arr[var_count]=singlevar
        LET var_count=var_count+1
        LET singlevar=""
        LET state="startvar"
    END IF
  END FOR
  IF state="invar" AND singlevar.getLength()>0 THEN
      LET var_arr[var_count]=singlevar
  END IF
END FUNCTION

{FIXME: see mod5
FUNCTION set_mod(val)
 define val Integer
  --define abc RECORD
  --  var2 Integer,
  --  var1 String
  --END RECORD
 LET mod=val
 RETURN mod
END FUNCTION
}

FUNCTION dummy (foo)
  DEFINE foo,bar String
  LET foo= "hallo"
  if foo="hallo" then
    LET bar="bar"
  end if
END FUNCTION

FUNCTION init_garr()
  DEFINE i Integer
  LET test=3
  FOR i=1 TO 30
    LET g_arr[i].str="string "||i
    LET g_arr[i].itype=i;
    LET g_arr[i].dt=TODAY
  END FOR
END FUNCTION

FUNCTION remove_leading_space(line)
  DEFINE line,c STRING
  DEFINE i INTEGER
  FOR i=1 TO line.getLength()
    LET c=line.getCharAt(i)
    IF c=" " OR c="\t" THEN
      CONTINUE FOR
    ELSE
      LET line=line.subString(i,line.getLength())
      EXIT FOR
    END IF
  END FOR
  RETURN line
END FUNCTION

--this function checks for
--"FUNCTION foo (" on a line or
--"END FUNCTION"
--if it finds the definition, it returns
--"function",<funcName> ,
--in the end case "end","function"
--if not find at all "",""
FUNCTION check_function_line(line)
  DEFINE line STRING
  DEFINE i INTEGER
  DEFINE ident,c STRING
  LET line=remove_leading_space(line)
  LET line=line.toLowerCase()
  IF line.getIndexOf("end",1)=1 THEN
    LET line=line.subString(length("end")+1,line.getLength())
    LET line=remove_leading_space(line)
    IF line.getIndexOf("function",1)=1 OR line.getIndexOf("main",1)=1 THEN
      RETURN "end","function"
    END IF
  ELSE IF line.getIndexOf("function",1)=1 THEN
    LET line=line.subString(length("function")+1,line.getLength())
    LET line=remove_leading_space(line)
    FOR i=1 TO line.getLength()
      LET c=line.getCharAt(i)
      IF c=" " OR c="\t" OR c="(" THEN
        EXIT FOR
      ELSE
        LET ident=ident.append(c)
      END IF
    END FOR
    RETURN "function",ident
  ELSE IF line.getIndexOf("main",1)=1 THEN
    RETURN "function","main"
  END IF
  END IF
  END IF
  RETURN "",""
END FUNCTION

FUNCTION find_line_in_srcarr(line,lineNumber,funcName,arr)
  DEFINE line STRING
  DEFINE lineNumber INTEGER
  DEFINE funcName STRING
  DEFINE arr DYNAMIC ARRAY OF STRING
  DEFINE i,found INTEGER
  DEFINE srcline,kind,func STRING
  
  --normalize the search line and remove trailing blanks
  --DISPLAY "find source line \"",line,"\" in func ",funcName," ,lineno ",lineNumber
  LET funcName=funcName.toLowercase()
  LET line=remove_leading_space(line)
  --search forward
  FOR i=lineNumber TO arr.getLength()
    LET srcline=arr[i]
    --DISPLAY sfmt("line%1:%2",i,srcline)
    IF srcline.getIndexOf(line,1)<> 0 THEN
      --DISPLAY "found at ",i
      RETURN 1,i
    END IF
    CALL check_function_line(srcline) RETURNING kind,func
    IF kind IS NULL THEN
      -- no function stuff detected
      CONTINUE FOR
    END IF
    IF kind="end" THEN
      --DISPLAY "end function found at ",i
      EXIT FOR
    END IF
  END FOR
  FOR i=lineNumber-1 TO 1 STEP -1
    LET srcline=arr[i]
    --DISPLAY sfmt("line%1:%2",i,srcline)
    IF srcline.getIndexOf(line,1)<> 0 THEN
      --DISPLAY "found at ",i
      RETURN 1,i
    END IF
    CALL check_function_line(srcline) RETURNING kind,func
    IF kind IS NULL THEN
      -- no function stuff detected
      CONTINUE FOR
    END IF
    IF kind="function" THEN
      --DISPLAY "function start found at ",i
      EXIT FOR
    END IF
  END FOR
  --finally, search the whole document, look for the right
  --function and try to find the line within there
  FOR i=1 TO arr.getLength()
    LET srcline=arr[i]
    CALL check_function_line(srcline) RETURNING kind,func
    {
    IF kind IS NULL THEN 
      CONTINUE FOR
    END IF
    }
    CASE kind
      WHEN "function"
        IF func=funcName THEN
          --DISPLAY "found function start of ",funcName," at ",i
          LET found=1
        END IF
      WHEN "end"
        IF found THEN
          --DISPLAY "found function end,go out"
          EXIT FOR
        END IF
      OTHERWISE
        IF found AND srcline.getIndexOf(line,1)<> 0 THEN
          --DISPLAY "finally found the line at ",i
          RETURN 1,i
        END IF
    END CASE
  END FOR
  RETURN 0,1
END FUNCTION
