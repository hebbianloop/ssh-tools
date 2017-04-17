#!/bin/bash
## Generate Public/Private Key Pairs for Keyless Login to Remote Host

rseed=0

host=$(hostname)
username=$(whoami)
ssh_home="/Users/$(whoami)/.ssh"
sshagent_file=~/.ssh_agent
privatekey=$ssh_home'/.ssh/id_rsa'

# Parse Options 
## Shift through standard input and assign to variables using option flags
while :; do
    case $1 in
        -h|--help)
        show_help
        exit
        ;;
        -host)
            if [ -n "$2" ]; then
                host=$2
                shift
            else                                                                                                                                                                                                                 
                echo "ERROR: -host requires a non empty option argument.\n" >&2
                exit
            fi
            ;;
        -uname)
            if [ -n "$2" ]; then
                username=$2
                shift
            else
                echo "ERROR: -uname requires a non empty option argument.\n" >&2
                exit
            fi
            ;;
        -sshagent)
            if [ -n "$2" ]; then
                sshagent_file=$2
                shift
            else
                echo "ERROR: -sshagent requires a non empty option argument.\n" >&2
                exit
            fi
            ;;
        -sshdir)
            if [ -n "$2" ]; then
                ssh_home=$2
                shift
            else
                echo "ERROR: -sshdir requires a non empty option argument.\n" >&2
                exit
            fi
            ;;
        -prvkey)
            if [ -n "$2" ]; then
                privatekey=$2
                shift
            else
                echo "ERROR: -prvkey requires a non empty option argument.\n" >&2
                exit
            fi
            ;;                                       
        -?*)
            printf 'Warn: Unknown option (ignored): %s\n' "%1" >&2
            ;;
        *)
            break
    esac
    shift
done

# Define Function
## Print Usage Information
function show_help(){
cat <<EOF

Usage ${0##*/} [-h|--help] [-host ADDRESS] [-uname USERNAME] [-sshagent FILE][-sshdir PATH] [-prvkey FILE]



EOF
}

# Define Function
## This function checks for existence of hidden ssh directory in user home and generates a
## public/private key pair and adds the public key to the authorized keys file.
function stdssh_genaddkeys(){
	[ ! -e $sshhome ] && ssh-keygen
	if [ -e $ssh_home/id_rsa.pub ]; then
		cat $ssh_home/id_rsa.pub >> $ssh_home/authorized_keys
		chmod 600 $ssh_home/authorized_keys
	else
		read -p "Enter the full path to your public key (i.e., ~/.ssh/id_rsa.pub:  " publickeypath
		[ -z ${publickeypath} ] && echo "❗️❗️ Error ❗️❗ - Public Key Not Found, check path: $publickeypath" && return 1
		cat ${publickeypath} >> $ssh_home/authorized_keys
		chmod 600 ${publickeypath}
	fi
}
# Define Function
## This function takes a remote host, username, and path to a private key and copies it
## to the home directory on the remote host. 
function stdssh_cpkey(){
	host=${1?:"What is the remote host address? (i.e., 191.168.1.100)"}
	username=${2?:"Please provide a username to access $host"}
	privatekey=${3?:"Please provide full path to private key (i.e., ~/.ssh/id_rsa)"}
	rseed=${RANDOM}
	scp ${privatekey} ${username}@${host}:/tmp/${privatekey}.transfer${rseed}
	ssh ${username}@${host} "mkdir ~/.keys; mv /tmp/$privkey}.transfer.${rseed} ~/.keys/; chmod 400 ~/.keys/${privatekey}.transfer.${rseed}"
}
# Define Function
## 
function stdssh_addagent(){
	privatekey=${1?:"Please provide path to private key (i.e., ~/.ssh/id_rsa)"}
	ssh-agent > ${sshagent_file}
	source ${sshagent_file}
	ssh-add ${privatekey}
}
