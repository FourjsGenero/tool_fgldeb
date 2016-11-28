IMPORT FGL mod4
IMPORT FGL mod5
FUNCTION mod3(param)
  DEFINE param String
  DEFINE m Integer
  CALL set_mod(3) RETURNING m
  LET param=param||"in module 3"
  LET param=mod4(param)
  RETURN param
END FUNCTION
