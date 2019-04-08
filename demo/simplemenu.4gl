FUNCTION simple_menu(param)
  DEFINE param String
  DEFINE cmd Integer
  DEFINE cmdstr,hallo String
  DEFINE ret,m String
  LET hallo=param
  MENU "hallo"
    COMMAND "test"
      LET cmd=1
      LET cmdstr="test"
      DISPLAY "ret is",ret
    COMMAND "exit"
      LET cmd=2
      LET cmdstr="exit"
      EXIT MENU
  END MENU
  RETURN cmdstr,cmd
END FUNCTION
