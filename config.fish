# REUSE ALIASES FROM ~/.bash_profile
egrep "^alias " ~/.bash_profile | while read e
        set var (echo $e | sed -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\1/")
        set value (echo $e | sed -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\2/")

        # remove surrounding quotes if existing
        set value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")

    # evaluate variables. we can use eval because we most likely just used "$var"
        set value (eval echo $value)

    # set an alias
    alias $var="$value"
end

# REUSE ENVIRONMENT VARIABLES FROM ~/.bash_profile
egrep "^export " ~/.bash_profile | while read e
    set var (echo $e | sed -E "s/^export ([A-Z0-9_]+)=(.*)\$/\1/")
    set value (echo $e | sed -E "s/^export ([A-Z0-9_]+)=(.*)\$/\2/")

    # remove surrounding quotes if existing
    set value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")

    if test $var = "PATH"
        # replace ":" by spaces. this is how PATH looks for Fish
        set value (echo $value | sed -E "s/:/ /g")

        # use eval because we need to expand the value
        eval set -xg $var $value

        continue
    end

    # evaluate variables. we can use eval because we most likely just used "$var"
    set value (eval echo $value)

    #echo "set -xg '$var' '$value' (via '$e')"

    switch $value
            case '`*`';
            # executable
            set NO_QUOTES (echo $value | sed -E "s/^\`(.*)\`\$/\1/")
            set -x $var (eval $NO_QUOTES)
        case '*'
            # default
            set -xg $var $value
        end
end


# function ls --description 'List contents of directory'
#   command ls -lhFG $argv
# end

function subl --description 'Launches sublime text in a new window'
  command subl -n $argv
end

function grep --description 'Colorful grep that ignores binary file and outputs line number'
  command grep --color=always -I $argv
end

function gf --description 'Do a git fetch'
  command git fetch
end

function git-delete-merged --description 'Delete all local branches that are already merged to current branch (exludes master)'
  command git branch --merged | grep -v "\*" | grep -v "master" | xargs -n 1 git branch -d
  command git remote prune origin
end

# Composer
alias composer "php /usr/local/bin/composer.phar"

# Laravel Spark
set -U fish_user_paths "$HOME/.bin/spark-installer" $fish_user_paths

if test -z "$COMPOSER_BIN_PATH"
  set -gx COMPOSER_BIN_PATH $HOME/.composer/vendor/bin
end
set PATH $COMPOSER_BIN_PATH $PATH

# get composer path
if test -z "$COMPOSER_BIN"
  if type "composer.phar" > /dev/null
    set -gx COMPOSER_BIN (which composer.phar)
  else if type "composer" > /dev/null
    set -gx COMPOSER_BIN (which composer)
  else
    echo "FAILED to find Composer! Please install composer.phar to your PATH."
  end
end

# function embulk
#         bass embulk $argv
# end

function digdag
        bass ~/bin/digdag $argv
end

function webserver
        sudo python -m SimpleHTTPServer $argv
end

# . $HOME/.config/fish/virtual.fish
# . $HOME/.config/fish/prompt.fish

# set -gx HOMEBREW_GITHUB_API_TOKEN #token here#

# Java
# set -gx JAVA_HOME (/usr/libexec/java_home)

### ALIASES FOR WORK ###
# funneldash-app laradock
alias fd  "cd ~/Projects/funneldash-app"
alias fdup "cd ~/Projects/funneldash-app/laradock; docker-compose up -d nginx php-fpm postgres workspace; cd -"
alias fdssh "cd ~/Projects/funneldash-app; docker-compose exec workspace bash"
alias fdstop "cd ~/Projects/funneldash-app/laradock; docker-compose stop; cd -"

function laradock-clean --description 'Remove ALL containers associated with laradock'
  command echo 'Removing ALL containers associated with laradock'
  bass docker ps -a | awk '{ print $1,$2 }' | grep laradock | awk '{print $1}' | xargs -0 -I {} docker rm {}
end

# armasearch laradock
alias asu "cd ~/Projects/armasearch/laradock; docker-compose up -d nginx php-fpm mysql; cd -"
alias ass "cd ~/Projects/armasearch/laradock; docker-compose stop; cd -"
alias as "cd ~/Projects/armasearch/"
alias ase "cd ~/Projects/armasearch/laradock; docker-compose exec workspace bash"


# Allow 256 colors in iTerm2 for pretty vim colors
set -gx CLICOLOR 1
set -gx TERM xterm-color
set fish_term24bit 1

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
