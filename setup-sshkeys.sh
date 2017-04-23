#!/bin/bash
## Generate Public/Private Key Pairs for Keyless Login to Remote Host

rseed=0

host=$(hostname)
username=$(whoami)

ssh_home="/Users/$(whoami)/.ssh"
sshagentfile='~/.ssh_agent'

keytype='rsa'
privkey=$ssh_home'/.ssh/id_'$keytype
pubey=$ssh_home'/.ssh/_id'$keytype'.pub'
x11=''
bits=''
quiet=''

# Parse Options 
## Shift through standard input and assign to variables using option flags
while :; do
    case $1 in
        -h|--help)
        show_help
        exit
        ;;
        -x11)
            x11='permit-x11-forwarding'
        -q)
            quiet='quiet'
        ;;
        -host)
            if [ -n "$2" ]; then
                host=$2
                shift
            else                                                                                                                                                                                                                 
                echo "ERROR: -host requires a non-empty option argument.\n" >&2
                exit
            fi
            ;;
        -uname)
            if [ -n "$2" ]; then
                username=$2
                shift
            else
                echo "ERROR: -uname requires a non-empty option argument.\n" >&2
                exit
            fi
            ;;
        -sshagent)
            if [ -n "$2" ]; then
                sshagentfile=$2
                shift
            else
                echo "ERROR: -sshagent requires a non-empty option argument.\n" >&2
                exit
            fi
            ;;
        -sshdir)
            if [ -n "$2" ]; then
                ssh_home=$2
                shift
            else
                echo "ERROR: -sshdir requires a non-empty option argument.\n" >&2
                exit
            fi
            ;;
        -keytype)
            if [ -n "$2" ]; then
                keytype=$2
                shift
            else
                echo "ERROR -keytype requires a non-empty option argument" >&2
                exit
            fi
            ;;
        -bits)
            if [ -n "$2" ]; then
                bits='-b $2'
                shift
            else
                echo "ERROR -bits requires a non-empty option argument" >&2
                exit
            fi
            ;;                        
        -prvkey)
            if [ -n "$2" ]; then
                privkey='-t '$2
                shift
            else
                echo "ERROR: -prvkey requires a non-empty option argument.\n" >&2
                exit
            fi
            ;;
        -pubkey)
            if [ -n "$2" ]; then
                pubkey=$2
                shift
            else
                echo "ERROR -pubkey requires a non-empty option argument" >&2
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

Use this program to enable secure password-less log in for the ssh protocol.

REQUIRED ARGUMENTS  
    
        -host       address of remote server to set up logins keys
        -uname      username credential for remote server

SSH OPTIONS

        -sshagent   file for ssh-agent 
        -keytype    dsa | ecdsa | ed25519 | rsa | rsa1
        -bits       number of bits for key
        -sshdir     path to .ssh directory (keys stored here)
        -prvkey     filename of private key
        -pubkey     filename of public key
        -x11        permit X11 forwarding 

EOF
}


host=$(hostname)
username=$(whoami)

ssh_home="/Users/$(whoami)/.ssh"
sshagentfile='~/.ssh_agent'

keytype='rsa'
privkey=$ssh_home'/.ssh/id_'$keytype
pubkey=$ssh_home'/.ssh/_id'$keytype'.pub'
x11='no-x11-forwarding'
bits=''

# Define Function
## This function displays options to user and asks for verification
function confirm_input(){
confirm_user_input=$(cat <<EOF
\n
📌 Confirm Input Arguments\n
\n
\t    🖥 HOST            ::      $host\n
\t    👤 USERNAME        ::      $username\n
\n
\t    📁 SSH_HOME        ::      $ssh_home\n
\t    📝 SSHAGENTFILE    ::      $sshagentfile
\n
\t    🔐 KEYTYPE         ::      $keytype\n
\t    ⚙  NUM BITS        ::      $bits\n
\n
\t    🔑 PRIVATEKEY      ::      $privkey\n
\t    🗝 PUBLICKEY       ::      $pubkey\n
\n    
\t    ⚙  X11 AUTH?       ::      $x11\n

EOF
)
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
	privkey=${3?:"Please provide full path to private key (i.e., ~/.ssh/id_rsa)"}
	rseed=${RANDOM}
	scp ${privkey} ${username}@${host}:/tmp/${privkey}.transfer${rseed}
	ssh ${username}@${host} "mkdir ~/.keys; mv /tmp/$privkey}.transfer.${rseed} ~/.keys/; chmod 400 ~/.keys/${privkey}.transfer.${rseed}"
}
# Define Function
## 
function stdssh_addagent(){
	privkey=${1?:"Please provide path to private key (i.e., ~/.ssh/id_rsa)"}
	ssh-agent > ${sshagentfile}
	source ${sshagentfile}
	ssh-add ${privkey}
}

# Begin Program
## Confirm input arguments
if [ ! $q ]; then
    confirm_input
    echo -e $confirm_user_input
    read -p "Proceed? [Y/N]" proceed
fi

if [ "$proceed" = 'Y' ] || [ "$proceed" = 'y'] || [ '$q' = 'quiet' ]