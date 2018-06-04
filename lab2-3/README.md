# Project Initialisation

Opening Rubymine projects from the command line
To activate the shell command, go to Tools > Create Command-line Launcher and confirm.

Now you have mine as bash command. Run this to open a project in RubyMine:

COPY
mine path/to/my_project
Booting Rubymine
The mine script will attach the opened project to a current Rubymine instance. If there is none, it will run Rubymine right there on your command line.

To move Rubymine to the background and suppress log messages you can create your own shell script (vim ~/bin/rubymine):

COPY
#!/bin/sh
( mine "$@" & ) > /dev/null 2>&1
By using rubymine, you now can even boot Rubymine from the command line.
