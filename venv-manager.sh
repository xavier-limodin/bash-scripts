#!/bin/bash

export WORKON_HOME=~/Documents/code_repos/Python/venv
export PROJECT_HOME=~/Documents/code_repos/Python/projects
export TEMPLATES_HOME=~/Documents/code_repos/Python/templates
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Virtualenv manager"
TITLE="Enter project name"
MENU="Choose one of the following options:"

OPTIONS=(1 "Open virtualenv"
         2 "Create virtualenv"
         3 "Delete virtualenv")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo "You chose to open venv"
            for project in $(printf "%s\n" $PROJECT_HOME/*)
                do echo "$(basename $project)"
            done
            echo "Choose project from list :"
            read -a project

            if [ -d "$WORKON_HOME/${project[0]}" ]
                then
                    workon ${project[0]}
                    code $PROJECT_HOME/${venvname[0]}/
                else
                    echo "Oops, folder not found, need glasses?"
                    exit 1
            fi
            ;;
        2)
            exec 3>&1
            venvname=$(dialog --backtitle "$BACKTITLE" \
                    --title $TITLE \
                    --inputbox "project name" 0 0 2>&1 1>&3)
            exitcode=$?
            clear
            exec 3>&-

            if [ exitcode==0 ] && [ -n "${venvname[0]}" ]
                then
                    mkproject ${venvname[0]}
                    cp -r $TEMPLATES_HOME/.vscode $PROJECT_HOME/${venvname[0]}/
                    cp -r $TEMPLATES_HOME/.gitignore $PROJECT_HOME/${venvname[0]}/
                    cd $PROJECT_HOME/${venvname[0]}/
                    git init
                    git add .
                    git commit -m 'Initial commit'
                    code $PROJECT_HOME/${venvname[0]}/
                else
                    echo "Oops, something went wrong : $exitcode"
                    exit $exitcode
            fi
            ;;
        3)
            echo "You chose to delete venv"
            echo "Warning, this will remove associated project"
            for virtualenv in $(lsvirtualenv -b)
                do echo "$virtualenv"
            done
            echo "Choose virtualenv from list :"
            read -a virtualenv

            if [ -d "$WORKON_HOME/${virtualenv[0]}" ]
                then
                rmvirtualenv ${virtualenv[0]}
                exitcode=$?
                if [ exitcode!=0 ]
                    then
                        echo "Oops, something went wrong : $exitcode"
                        exit $exitcode
            fi

            if [ -d "$$PROJECT_HOME/${virtualenv[0]}" ]
                then
                    rm -rf "$$PROJECT_HOME/${virtualenv[0]}"
                else
                    echo "Project ${virtualenv[0]} not found"
            fi
            ;;
esac
