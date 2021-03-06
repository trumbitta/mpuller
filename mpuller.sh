#!/usr/bin/env bash
#mpuller v0.1
#
#Copyright 2012 William Ghelfi (trumbitta @ github)
#Licensed under the Apache License v2.0
#http://www.apache.org/licenses/LICENSE-2.0
#

#
# A lot of this is based on options.bash by Daniel Mills.
# @see https://github.com/e36freak/tools/blob/master/options.bash

# Preamble {{{

# Defaults
ME="mpuller"
CACHE_DIR="${HOME}/.${ME}/cache"
LAUNCH_DIR=`pwd`
BRANCH_TO_USE="master"
GIT_COMMAND_OPTS="-q"
MAVEN_COMMAND_OPTS="-q"

# Exit immediately on error
set -e

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# Defaults
force=0
quiet=0
verbose=0
interactive=0
args=()

# }}}
# Helpers {{{

out() {
  ((quiet)) && return

  local message="$@"
  if ((piped)); then
    message=$(echo $message | sed '
      s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
      s/✖/Error:/g;
      s/✔/Success:/g;
    ')
  fi
  printf '%b\n' "$message";
}
die() { out "$@"; exit 1; } >&2
err() { out " \033[1;31m✖\033[0m  $@"; } >&2
success() { out " \033[1;32m✔\033[0m  $@"; }

# Verbose logging
log() { (($verbose)) && out "$@"; }

# Notify on function success
notify() { [[ $? == 0 ]] && success "$@" || err "$@"; }

# Escape a string
escape() { echo $@ | sed 's/\//\\\//g'; }

# Unless force is used, confirm with user
confirm() {
  (($force)) && return 1;

  read -p "$1 [Y/n] " -n 1;
  [[ ( $REPLY =~ ^[Yy]$ ) || ( $REPLY == "" ) ]];
}

# }}}
# Script logic -- TOUCH THIS {{{

version="$0 v0.1"

# A list of all variables to prompt in interactive mode. These variables HAVE
# to be named exactly as the longname option definition in usage().
interactive_opts=(username password)

# Print usage
usage() {
  echo -n "$0 [OPTION]... [FILE]...

Description of this script.

 Options:
  -u, --username    Username for script
  -p, --password    Input user password, it's recommended to insert
                    this through the interactive option
  -f, --force       Skip all user interaction
  -i, --interactive Prompt for values
  -q, --quiet       Quiet (no output)
  -v, --verbose     Output more
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Set a trap for cleaning up in case of errors or when script exits.
rollback() {
  die "Unexpected failure."
}

init_cache() {
    if [[ ! -d ${CACHE_DIR} ]]; then
        err "${CACHE_DIR} not found, creating..."
        mkdir -p ${CACHE_DIR} && \
        success "... done."
    fi
}

maven_read_from_pom() {
  pom_data=$(mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=$1 | grep -v "\[")
}

pom_snippet_build() {

  out "Building POM snippet..."

  local pom_data=""

  maven_read_from_pom "project.groupId"
  POM_SNIPPET_GROUPID=${pom_data}

  maven_read_from_pom "project.artifactId"
  POM_SNIPPET_ARTIFACTID=${pom_data}

  maven_read_from_pom "project.version"
  POM_SNIPPET_VERSION=${pom_data}

  success "... done."
}

pom_snippet_print() {
  cat <<EOM
<dependency>
    <groupId>${POM_SNIPPET_GROUPID}</groupId>
    <artifactId>${POM_SNIPPET_ARTIFACTID}</artifactId>
    <version>${POM_SNIPPET_VERSION}</version>
</dependency>
EOM
}

pom_snippet_copy_to_clipboard() {
  out "Copying POM snippet to clipboard..."
  pom_snippet_print | xclip -selection clipboard
  success "... done."
}

# Actions

do_cache-clean() {
  if ! confirm "BEWARE! I'm going to delete the whole ${CACHE_DIR} !"; then
      out "\n"
      err "Deletion aborted. Exiting.\n"
      return
  fi
  out "\nDeleting ${CACHE_DIR}..."
  rm -rf ${CACHE_DIR}
  success "... done."
}

do_install() {
    init_cache
    cd ${CACHE_DIR}
    local repo_name=${repo_to_install##*/}
    local repo_name=${repo_name%.*}

    if [[ -d ${repo_name} ]]; then
        success "${repo_name} already exists, updating..."
        cd ${repo_name}
        git checkout ${GIT_COMMAND_OPTS} master
        git pull ${GIT_COMMAND_OPTS} && \
        success "... done."
    else
        err "${repo_name} not yet cached, cloning..."
        git clone ${GIT_COMMAND_OPTS} ${repo_to_install} && \
        success "... done."
        cd ${repo_name}
    fi

    git checkout ${GIT_COMMAND_OPTS} $BRANCH_TO_USE

    out "Installing..."
    mvn clean install ${MAVEN_COMMAND_OPTS} -DskipTests && \
    success "... done."

    pom_snippet_build
    pom_snippet_print
    pom_snippet_copy_to_clipboard
}

# Put your script here
main() {

  ((verbose)) && {
    MAVEN_COMMAND_OPTS=""
    GIT_COMMAND_OPTS=""
  }

  case $action in
    install)
      do_install "${repo_to_install}" ;;
    cache-clean)
      do_cache-clean ;;
    *) err "invalid action: $action" ;;
  esac

}

# }}}
# Boilerplate {{{

# Prompt the user to interactively enter desired variable values. 
prompt_options() {
  local desc=
  local val=
  for val in ${interactive_opts[@]}; do

    # Skip values which already are defined
    [[ $(eval echo "\$$val") ]] && continue

    # Parse the usage description for spefic option longname.
    desc=$(usage | awk -v val=$val '
      BEGIN {
        # Separate rows at option definitions and begin line right before
        # longname.
        RS="\n +-([a-zA-Z0-9], )|-";
        ORS=" ";
      }
      NR > 3 {
        # Check if the option longname equals the value requested and passed
        # into awk.
        if ($1 == val) {
          # Print all remaining fields, ie. the description.
          for (i=2; i <= NF; i++) print $i
        }
      }
    ')
    [[ ! "$desc" ]] && continue

    echo -n "$desc: "

    # In case this is a password field, hide the user input
    if [[ $val == "password" ]]; then
      stty -echo; read password; stty echo
      echo
    # Otherwise just read the input
    else
      eval "read $val"
    fi
  done
}

# Read the command and set stuff
while [[ $1 = ?* ]]; do
  case $1 in
    cache-clean)
      action=$1
      shift
      break ;;
    install)
        action=$1
        shift
        [[ $# -eq 0 ]] && err "you must specify a repository to install" && die
        repo_to_install=$1
        shift
        break ;;
    *) die "invalid option: $1" ;;
  esac
  shift
done

# Print help if no arguments were passed.
[[ $# -eq 0 && -z "${action}" ]] && set -- "--help"

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;
    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Set our rollback function for unexpected exits.
trap rollback INT TERM EXIT

# A non-destructive exit for when the script exits naturally.
safe_exit() {
  trap - INT TERM EXIT
  exit
}

# }}}
# Main loop {{{

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safe_exit ;;
    -V|--version) out "$version"; safe_exit ;;
    -b|--branch) shift; BRANCH_TO_USE=$1 ;;
#    -u|--username) shift; username=$1 ;;
#    -p|--password) shift; password=$1 ;;
    -v|--verbose) verbose=1 ;;
#    -q|--quiet) quiet=1 ;;
#    -i|--interactive) interactive=1 ;;
#    -f|--force) force=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: $1" ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

# }}}
# Run it {{{

# Uncomment this line if the script requires root privileges.
# [[ $UID -ne 0 ]] && die "You need to be root to run this script"

if ((interactive)); then
  prompt_options
fi

# You should delegate your logic from the `main` function
main

# This has to be run last not to rollback changes we've made.
safe_exit

# }}}
