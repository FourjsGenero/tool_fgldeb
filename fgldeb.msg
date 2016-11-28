.1;
  The Debugger main window
  ------------------------
1. Basics:
==========
In this window you can inspect the source code of the debuggee(the program to debug) and perform the debugger standard actions like run/step over/step into or setting a breakpoint at a source code line. Below the source code area there are visible the \'Auto Variables\' and \'Watched Variables\' group boxes.

1.1 Setting a breakpoint <F9>:
------------------------------
Setting/Deleting a breakpoint is just pressing <Enter> or <F9> at the current source code line.

2. Debugger standard stepping actions
=====================================
The hotkeys for these actions are the same as in the Microsoft Visual Studio Debugger, however it is possible to change this by exchanging the fgldeb.4ad Action Default file. (For example to make the hotkeys INFORMIX/BDL compatible)

2.1 Run/Continue <F5>
---------------------
Starts the program if it is not started, or continues the programm,
 if it is already running. 

2.1 Step Over (Next)<F10>
-------------------------
Jumps over the next statement

2.3 Step Into (Step)<F11>
-------------------------
If the current line marker is at a line containing a function call, this command lets the debugger jump to the first instruction of the function.

2.4. Step Out (Fin)<Shift-F11>
-------------------------
Continues the program until the current function was left. Shows a popup window with the result(s) of the function.

2.5. Restart <Ctrl-Shift-F5>
----------------------------
Restarts the debuggee and resets all variables.

3. Auto Variables
=================
fgldeb tries to get the information about the variables at the current line,
and keeps this information visible until new variables arrive.
This reduces the need of the "INSPECT_VARIABLE" dialog.

4. Watched Variables
====================
User defined list of variables to observe. 
Add the variable names with the "INSPECT_VARIABLE" dialog.


5. Dialogs
==========
Dialogs have all a Hotkey beginning with the 'Ctrl' key together with a letter (Except the Add Breakpoint Dialog).The "INSPECT_VARIABLE" dialog and the dialogs for the Local/Global Variables allow to stay open for the standard stepping operations(implemented by a kind of pseudo non modality)
5.1 Inspect Variable(s) <Ctrl-i>
--------------------------------
Tries to get the variable names from the current line and opens up a dialog to input/search variable names and to display their values.
It is possible to inspect multiple variables by using whitespace between the variable names.
The formatting is somewhat different from the original debugger output one gets via "print" commands: fgldeb tries to produce more readable output.
If you type the name of an array, all element are listed by index

5.2 Breakpoints
---------------
Shows a list with all currently defined breakpoints. It is possible to delete/enable/disable a breakpoint or to jump to the source code location of the breakpoint.Another hotkey opens an additional dialog to add breakpoints by typing a function name (or selecting from the function list).  

5.2 Stack Window <Ctrl-s>
-------------------------
Shows a list with the current call stack. It is possible to select a stack frame with <Enter> or <DoubleClick>, then the debugger jumps to the source location inside the call chain and selects also the stack frame for inspecting variables in that level. Hence the auto-variables display also changes.
The next stepping command goes back to the top level/current line .

5.3 Module Window <Ctrl-m>
--------------------------
Shows a list of all (4gl) modules of the debuggee. It is possible to select a module with <Enter> or <DoubleClick>, then fgldeb shows the selected source code module.
The next stepping command goes back to the current line.

5.4 Functions Window <Ctrl-u>
-----------------------------
Shows a list of all functions in the program. You can search a function with <Ctrl-f> and it is possible to jump to the source code location of a function with <Enter> or <DoubleClick>.

5.5 Local Variables <Ctrl-l>
-----------------------------
Shows a list of all local variables in the currently selected stackframe.You can search a variable with <Ctrl-f> and it is possible to inspect a variable further with <Enter> or <DoubleClick> (invokes the "INSPECT_VARIABLE" dialog).

5.6 Global Variables <Ctrl-g>
-----------------------------
Shows a list of all global variables.You can search a variable name with <Ctrl-f> and it is possible to inspect a variable further with <Enter> or <DoubleClick> (invokes the "INSPECT_VARIABLE" dialog).

5.7 Watched Variables <Ctrl-g>
------------------------------
Shows a list of all currently watched variables.You can delete variables by pressing <Del> and add variables by invoking the "INSPECT_VARIABLE" dialog.

5.8 Execute Debugger Command <Control-d>
----------------------------------------
Gives you direct access to the true underlying 'fglrun -d' debugger backend. You can type in all gdb compatible commands in an edit control and get the answer in the window below. Step Into is "s", Step (Next) is "n" .

5.9 Find dialog <Ctrl-f>
------------------------
Searches for a source code line. <F3> continues the search. In most of the dialogs displaying lists, <Ctrl-f> and <F3> are the hotkeys for search and bring up this dialog.

5.10 Add breakpoint in function <Ctrl-F9>
-----------------------------------------
Asks for a function where to add a breakpoint. It is possible to choose from the function list with <Ctrl-u>.

.2;

  The Variable inspector window 
  -----------------------------
1. General possibilities
=========================
In this window one can input multiple variable names in the 
"Variable Name" ButtonEdit and obtain their values.
Variable names must be delimited with spaces. 
By pressing the <Tab> key one can try to complete an incomplete variable name.
If there is only 1 match in the list of available variables, 
fgldeb completes the variable automatically, otherwise it presents a list of 
matching variable names.
By pressing Up/Down or clicking the Button of the ButtonEdit field one can 
browse in the history of variable names already entered.

2. Inspecting records
=====================
If the variable name entered is a record variable, fgldeb displays each member on a separate row. 
(in contradiction to the original "print" output of fglrun -d ) 

3. Inspecting arrays
=====================
If the variable name entered is a 4GL array, 
each element of the array is printed on a seperate row.
By using the Python slices syntax, one can inspect parts of the array.
Example:
Variable name for the array is "a"
a[1:4]
prints the first 4 Elements of the array
a[35:90]
prints the range a[35] until a[90]
a[90:35]
reverses the rows
(Note:you must use digits for the range, you can't use other variable names to index the slice)

4. Add/Delete variables to/from the watch list
=============================================
By clicking "Add Watch" the variable(s) currently displayed in this dialog 
are added to the watch list if they are not already contained in the 
watch list. 
By clicking "Delete Watch" fgldeb tries to delete the variable(s) 
currently displayed from the watch list.


