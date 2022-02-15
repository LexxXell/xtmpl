#!/bin/sh

xtmpl_dir=$HOME/.local/xtmpl
app_dir=$PWD

usage () {
    echo "Usage:\n\t xtmpl <option>\n"
    echo "Options: \n"
    echo "\tinit\t\t\tInitialize new docker-compose based application.\n"
    echo "\t--install-xtmpl\t\tInstall xtmpl in system bin. SUPERUSER or SUDO need.\n"
    echo "\t--reload-template\tReload local template files.\n"
    echo "\t-dc,\n\t--docker-cleanup"
    echo "\t\t\tsoft\tSoft docker cleanup. Stopped containers, unused images,"
    echo "\t\t\t\tvolumes and networks not related to running containers will be deleted."
    echo "\t\t\thard\tHard docker cleanup. All containers will be stopped. \n\t\t\t\tAll containers, volumes and networks will be deleted.\n"
    echo "\t-h, --help\t\tThis help.\n"
}

xtmpl_install () {
    cp $0 /bin/xtmpl
    chmod +x /bin/xtmpl
}

check_template () {
    if ! [ -d "$xtmpl_dir/template/.git" ]; then
        echo "Template not found...\nCloning..."
        rm -rf $xtmpl_dir/template
        mkdir -p $xtmpl_dir/template
        git clone https://github.com/LexxXell/base_template $xtmpl_dir/template
        cd $xtmpl_dir/template
        git pull --all
        cd -
    fi
}

reload_template () {
    rm -rf $xtmpl_dir/template
    check_template
}

check_app_dir () {
    if ! [ `ls -a $app_dir| wc -l` -eq 2 ]; then 
        echo "The directory is not empty. \nRun 'xtmpl init' in an empty directory."
        exit 1
    fi
}

init () {

    check_template
    check_app_dir

    echo "Specify which containers will be used in your application."

    read -p "Python (y/N)" yn
    case "$yn" in
        y|Y ) branch=$branch"py"
    esac

    read -p "NodeJS (y/N)" yn
    case "$yn" in
        y|Y ) branch=$branch"no"
    esac

    read -p "NGINX (y/N)" yn
    case "$yn" in
        y|Y ) branch=$branch"ng"
    esac

    read -p "PostgreSQL DBMS (y/N)" yn
    case "$yn" in
        y|Y ) branch=$branch"pg"
    esac

    read -p "Redis server (y/N)" yn
    case "$yn" in
        y|Y ) branch=$branch"rd"
    esac

    case "$branch" in
        py ) branch=python ;;
        no ) branch=nodejs ;;
        ng ) branch=nginx ;;
        pg ) branch=postgres ;;
        rd ) branch=redis ;;
    esac

    if [ -n "$branch" ]
    then
        cd $xtmpl_dir/template
        git worktree prune
        git worktree add $app_dir $branch && \
        git worktree prune && \
        cd $app_dir && \
        rm -rf .git && \
        git init && git add --all && git commit -m "First commit" 1> /dev/null
    else
        echo "Nothing is selected. Cancel."
    fi
}

docker_soft_cleanup () {
    echo "Soft cleanup selected!\n"
    echo "Stopped containers, unused images, volumes \nand networks not related to running containers will be deleted.\n"
    read -p "Are you sure? (y/N) " yn
    case "$yn" in
        y|Y )
            echo "Start soft cleanup!"
            docker system prune -a -f 2> /dev/null
            echo "Soft cleanup finished!"
            ;;
        * ) 
            echo "Soft cleanup canceled!"
            ;;
    esac
}

docker_hard_cleanup () {
    echo "Hard cleanup selected!\n"
    echo "All containers will be stopped. \nAll containers, volumes and networks will be deleted.\n"
    read -p "Are you sure? (y/N) " yn
    case "$yn" in
        y|Y )
            echo "Start hard cleanup!"
            docker stop $(docker ps -a -q) 2> /dev/null
            docker rm $(docker ps -a -q) 2> /dev/null
            docker rmi --force $(docker images -a -q) 2> /dev/null
            docker volume rm $(docker volume ls -q) 2> /dev/null
            docker network rm $(docker network ls -q) 2> /dev/null
            echo "Hard cleanup finished!"
            ;;
        * ) 
            echo "Hard cleanup canceled!"
            ;;
    esac
}

if [ -z $* ]
then
    echo "No options found!"
    usage
    exit 1
fi

case $1 in
    init ) init ;;
    --xtmpl-install ) xtmpl_install ;;
    --reload-template ) reload_template ;;
    -dc|--docker-cleanup )
        case $2 in
            soft ) docker_soft_cleanup ;;
            hard ) docker_hard_cleanup ;;
            * ) usage ;;
        esac
        ;;
    -h|--help ) usage ;;
esac