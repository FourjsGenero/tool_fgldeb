IMPORT FGL mod5
FUNCTION mod4(param)
  DEFINE param String
  DEFINE m Integer
  CALL set_mod(4) RETURNING m
  LET param=param||"in module 4"
  RETURN param
END FUNCTION
