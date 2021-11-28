# Graphical interface tool for fglrun -d

## Description

This tool is a GUI interface for the command-line fglrun -d debugger.

Email comments/suggestions/wishes to : l s a t 4 j s d o t c o m

![Genero FGL Debugger User Interface (GDC)](https://github.com/FourjsGenero/tool_fgldeb/raw/master/docs/fgldeb-screen-001.png)

## Prerequisites

* Genero BDL 2.40+
* Genero Desktop Client 2.40+
* GBC 1.40+
* GNU Make
* optional : Genero Studio 3.20+

## Compilation from command line

1. make clean all

## Compilation in Genero Studio

1. Load the fgldeb.4pw project
2. Build the project

## Usage

### Installation

You don't necessarily need to install fgldeb.
If you did check out this repository you can call
```
$ <path_to_this_repository>/fgldeb <yourprogram> arg 
```
and it uses the fglcomp/fglrun in your PATH to compile and run fgldeb along with your debuggee.
Of course you can add also <path_to_this_repository> in your PATH .

If you have Genero version bigger/equal 3.0 you can use the supplied fgldeb scripts in the "script" dir.
Those scripts are created with fglscriptify and are self extracting,
self compiling 4GL "scripts".
Simply copy this single script somewhere to a direcory contained in the PATH and thats all, you can invoke fgldeb.
All needed assets are contained in this script.
In fact you don't need then the repository anymore.



### Basic invocation

fgldeb's primary use is debugging Genero GUI applications, for text mode there
are some extra instructions. By default the tool assumes you are using the
Genero graphical mode.

Make sure that FGLSOURCEPATH is defined to point to your program sources.

To invoke the GUI debug tool, just run the program with fgldeb instead of fglrun:

```
% fgldeb myprog
```

After that you should be in the main window of fgldeb, and the 1st line (MAIN)
should be highlighted. Press several times the <F10> key and you immediately
step thru the application.

The "auto" variable display shows the values of those variables where the
program flow went thru and hence eliminated the need for looking up variable
by name in the simple cases. 

Look in the top menu to get all available commands or press F1 to get the
most important hotkeys explained.

### Passing arguments to the debuggee

This works like passing arguments to fglrun:

```
% fgldeb myprog arg1 arg2 arg3
```

### Passing arguments to fgldeb

To pass arguments to the fgldb tool, add "--" to the command line. All options
following "--" will be passed to fgldeb.

The next example tries to debug the simple app in text mode in the given
terminal (which should not be the current one):

```
% fgldeb simple arg1 -- -t /dev/ttys0
```

Run "fgldeb" to get all available options.

### Attach to a running fglrun process with fgldeb

Get the process id of the program you want to debug
and invoke fgldeb with the process id

```
% fgldeb -p 12345
```

If you exit fgldeb you have the option either to end the debuggee
or to detach from the debuggee (then the program being debugged continues running).

### Setting FGLSOURCEPATH

The fglrun -d debugger needs to know where to find your program sources, by
setting the FGLSOURCEPATH environment variable.

See [Genero BDL documentation](http://www.4js.com/download/documentation)
for more details about FGLSOURCEPATH.

### Debugging text mode applications ( FGLGUI=0 )

Debugging in text mode is somewhat difficult. To debug a text mode application
with fgldeb its necessary to have a 2nd terminal available.

First start in this 2nd terminal the fgldebttyblock.sh shell script.

It prints out the current terminal device , changes the interrupt character
and sleeps veeery long.

```
% ./fgldebttyblock.sh
tty:/dev/ttys004
```

Now start fgldeb with this tty as additional argument:

```
% fgldeb myapp -- -t /dev/ttys004
```

If the application runs via fgldeb, it's text output appears in the 2nd terminal
and the input for the application has also be put into the 2nd terminal.

If CTRL-C is the standard interrupt key, it is supposed to work also in the 2nd
terminal (that's why fgldebttyblock.sh changes the interrupt key temporarily).

### Switching back into fgldeb if the application is running

If the debuggee is running, one can easily switch into fgldeb by hitting the
interrupt key(usually Control-c) in the terminal where fgldeb was started.

The debugger breaks at the currently executed 4GL instruction.

## Bug fixes:

