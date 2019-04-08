IMPORT FGL simplemenu
MAIN
  DEFINE c base.Channel
  LET c=base.Channel.create()
  CALL c.setDelimiter("")
  CALL c.openFile("simple.pid","w")
  CALL c.write(fgl_getpid())
  CALL c.close()
  CALL sub()
END MAIN

PRIVATE FUNCTION sub()
  CALL subsub()
END FUNCTION

PRIVATE FUNCTION subsub()
  CALL simple_menu("simple") RETURNING status,status
END FUNCTION
