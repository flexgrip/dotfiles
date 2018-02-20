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

# Composer apps
set -U fish_user_paths "$HOME/.composer/vendor/bin" $fish_user_paths

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

# funneldash-bot artisan/ngrok
alias fdbot  "cd ~/Projects/funneldash-bot"
# alias fdbotup  "cd ~/Projects/funneldash-bot; php artisan serve --host 0.0.0.0 --port 8080 & tab ~/Projects/funneldash-bot ngrok start app bot"
function fdbotup
    tab ~/Projects/funneldash-bot php artisan serve --host 0.0.0.0 --port 8080
    and tab ~/Projects/funneldash-bot ngrok start app bot
end

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

eval (python -m virtualfish)

functions -c fish_prompt _old_fish_prompt
function fish_prompt
  if set -q VIRTUAL_ENV
    echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
  end
  _old_fish_prompt
end

function fish_right_prompt
    # last status
    test $status != 0
    and printf (set_color red)"⏎ "

    if git rev-parse ^/dev/null
        # Magenta if branch detached else green
        git branch -qv | grep "\*" | string match -rq detached
        and set_color brmagenta
        or set_color brgreen

        # Need optimization on this block (eliminate space)
        git name-rev --name-only HEAD

        # Merging state
        git merge -q ^/dev/null
        or printf ':'(set_color red)'merge'
        printf ' '

        # Symbols
        for i in (git branch -qv --no-color|grep \*|cut -d' ' -f4-|cut -d] -f1|tr , \n)\
 (git status --porcelain | cut -c 1-2 | uniq)
            switch $i
                case "*[ahead *"
                    printf (set_color magenta)⬆' '
                case "*behind *"
                    printf (set_color magenta)⬇' '
                case "."
                    printf (set_color green)✚' '
                case " D"
                    printf (set_color red)✖' '
                case "*M*"
                    printf (set_color blue)✱' '
                case "*R*"
                    printf (set_color brmagenta)➜' '
                case "*U*"
                    printf (set_color bryellow)═' '
                case "??"
                    printf (set_color brwhite)◼' '
            end
        end
    end
end

# Open new iTerm and Terminal tabs from the command line
#
# Author: Justin Hileman (http://justinhileman.com)
#
# Usage:
#     tab                   Opens the current directory in a new tab
#     tab [PATH]            Open PATH in a new tab
#     tab [CMD]             Open a new tab and execute CMD
#     tab [PATH] [CMD] ...  You can prolly guess

function tab -d "Open the current directory in a new tab"
  set -l cmd ""
  set -l cdto (pwd)

  if test (count $argv) -gt 0
    pushd . >/dev/null
    if test -d $argv[1]
      cd $argv[1]
      set cdto (pwd)
      set -e argv[1]
    end
    popd >/dev/null
  end

  if test (count $argv) -gt 0
    set cmd "; $argv"
  end

  switch $TERM_PROGRAM

  case 'iTerm.app'
    osascript 2>/dev/null -e "
      tell application \"iTerm\"
        tell current window
	  create tab with default profile
          tell the current session
            write text \"cd \\\"$cdto\\\"$cmd\"
          end tell
        end tell
      end tell
    "

  case 'Apple_Terminal'
    osascript 2>/dev/null -e "
      tell application \"Terminal\"
        activate
        tell application \"System Events\" to keystroke \"t\" using command down
        repeat while contents of selected tab of window 1 starts with linefeed
          delay 0.01
        end repeat
        do script \"cd \\\"$cdto\\\"$cmd\" in window 1
      end tell
    "

  case '*'
    echo "Unknown terminal: $TERM_PROGRAM" >&2
  end
end

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
