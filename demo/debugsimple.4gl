IMPORT os
MAIN
  DEFINE t TEXT
  DEFINE s,cmd STRING
  DEFINE i,idx,pid INT
  CALL os.Path.delete("simple.pid") RETURNING status
  RUN "fglrun simple" WITHOUT WAITING
  FOR i=1 TO 50 
    LOCATE t IN FILE "simple.pid"
    LET s=t
    IF s IS NOT NULL THEN
      IF (idx:=s.getIndexOf("\n",1))>0 THEN
        LET s=s.subString(1,idx-1)
      END IF
      LET pid=s
      IF pid IS NOT NULL THEN
        LET cmd=sfmt("../fgldeb -v -p %1",pid)
        DISPLAY "RUN ",cmd
        RUN cmd
        RETURN
      ELSE
        DISPLAY sfmt("%1: Can't convert '%2'",i,s)
      END IF
    ELSE
      DISPLAY sfmt("%1: did not find pid in simple.pid",i)
    END IF
    SLEEP 1
  END FOR
END MAIN
    
    
