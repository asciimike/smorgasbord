File: README.TXT


Group: XSSH 23l
Mike McDonald mcdonamp@rose-hulman.edu
Jake Schuenke schuenjr@rose-hulman.edu
Jake Sheets sheetsjr@rose-hulman.edu
Matt Spurr	spurrme@rose-hulman.edu

Building the shell: The command "make" runs the make file, generating an executable named xssh.  Running the executable "./xssh" starts the shell.  The command "make clean" will clean all .o files.

Testing the shell: Running ./xssh will bring up the ">> " terminal prompt.  At that point, individual commands can be run, or input files can be loaded and used as testing scripts.  Starting the shell in "./xssh -d 0/1" sets the debug mode.  If you use "./xssh file.txt" will try to open file.txt and run it as a script.

Using the shell: Enter built in commands, such as echo, quit, etc as shown in the XSSH documentation, enter files to be used as scripts, or enter executables that can be run.  Note that executables must include the file path "./xssh" etc.

Design/Implementation features:
1) Builtin struct holds the same useful info that a normal shell contains such as number of arguments, value of the arguments, the name of the command, and the input/output files.
2) Copious use of switch/case statements break up the endless if/elseif/else statements, through the code(string) function and the enumerated type.
3) Similar looping structure that evaluates an expression, executes the instruction, and then moves on to the next instruction allows for easy to read yet powerful code.
4) Currently only single redirects are allowed.
5) Processes can be backgrounded indefinitely using the &, and this was tested using larger programs such as bluefish.
6) Redirection is a bit hairy still.
7) Pipelining exists, but hasn't been extensively tested.

Questions:
1) Are multiple commands allowed on the same line?  Is this even possible?
2) Do comments need to be in line?  Currently we are leaving them as separate lines, which makes sense in a script.
3) How are we going to chain instructions together for pipelines or redirection?
4) How should multiple redirects be handled?

Additional features:
Why command.  Why [question...] answers a question.
Manual 

