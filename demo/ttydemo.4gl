MAIN
  DEFINE fglgui INT
  DEFINE s STRING
  DEFER INTERRUPT
  LET fglgui=fgl_getenv("FGLGUI")
  LET s="FGLGUI=",fglgui
  ERROR s
  MENU "hallo"
    COMMAND "sub"
      MENU "submenu"
        COMMAND "sub1"
          MESSAGE "sub1"
        COMMAND KEY(INTERRUPT) "exit"
          EXIT MENU
      END MENU
    COMMAND KEY(INTERRUPT) "exit"
      EXIT MENU
  END MENU
END MAIN
