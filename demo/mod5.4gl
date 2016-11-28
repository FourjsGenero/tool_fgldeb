DEFINE mod INTEGER

FUNCTION mod5()
  DISPLAY "in mod5"
END FUNCTION

#FIXME see main.4gl
FUNCTION set_mod(val)
 define val Integer
  --define abc RECORD
  --  var2 Integer,
  --  var1 String
  --END RECORD
 LET mod=val
 RETURN mod
END FUNCTION
