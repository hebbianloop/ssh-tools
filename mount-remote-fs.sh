#!/bin/bash
# Maintain Mounted Volume on SSHFS

user=''
host='10.1.3.55'
hostalias='CFMI'
mount_this='/'
mount_here='/Volumes'
vpnservername='guvpn.georgetown.edu'

# Define Function
## Help 
function show_help(){

cat <<EOF

Usage: ${0##*/} [-h|--help] [-u|--uname USER] [-h|--host HOST] [-p|--serverdir PATH] 
				[-l|--localdir PATH] [-a|--hostalias STRING] [-v|--vpn SERVERNAME]

A wrapper for sshfs to maintain a persistent connection with a remote filesystem. This program will
mount the directory on HOST (specified by SERVERDIR) into a local directory LOCALDIR/HOSTALIAS.

EOF
} 

while :; do
	case ${1} in
		-h|--help)
		show_help
		exit
		;;
		-v|--vpn)
		vpn='usevpn'
			if [ -n "${2}"]; then
				vpnservername=${2}
				shift
			fi		
		;;		
		-u|--uname)
			if [ -n "${2}"]; then
				user=${2}
				shift
			else
				echo -e "ERROR:  -u --uname requires a non-empty option argument.\n" >&2
				exit
			fi
		;;	
		-h|--host)
			if [ -n "${2}"]; then
				host=${2}
				shift
			else
				echo -e "ERROR:  -h --host requires a non-empty option argument.\n" >&2
				exit
			fi
		;;
		-p|--serverdir)
			if [ -n "${2}"]; then
				mount_this=${2}
				shift
			else
				echo -e "ERROR:  -p --serverdir requires a non-empty option argument.\n" >&2
				exit
			fi
		;;
		-a|--hostalias)
			if [ -n "${2}"]; then
				hostalias=${2}
				shift
			else
				echo -e "ERROR:  -a --hostalias requires a non-empty option argument.\n" >&2
				exit
			fi
		;;
		-l|--localdir)
			if [ -n "${2}"]; then
				mount_here=${2}
				shift
			else
				echo -e "ERROR:  -a --hostalias requires a non-empty option argument.\n" >&2
				exit
			fi
		;;									
        -?*)
            printf '\n ‼️ Warning: Unknown option: %s\n' "${1}" >&2
            exit
            ;;
        *)
            break
	esac
	shift
done

# Define Function
## Assemble input arguments to final formats
function mountremotefs_prepargs(){
	mount_here=${mount_here}/${hostalias}
	echo -e "\n  🗄  Setting up Local Directory to Host Remote File\n"
	mkdir -p $mount_here
}

# Define Function
## Establish Persistent VPN Connection via OpenConnect
function mountremotefs_checkvpn(){
	[ ! -z ${vpn} ] && check-vpn -server ${vpnservername}
}
# Define Function
## Check Existence of SSH Keys, ssh-agent & keychain
function mountremotefs_checksshkeys(){
	# get location of current key
	currentkey=$(ssh-add -L | awk '{print $3}')
	if [ ! -z $currentkey ]; then
		echo -e "\n  🔎 🔑  Found Existing Key Encryption For Automatic Login ($currentkey)"
	else
		if [ -z $(type start_keychain) ]; then
			echo -e "\n ❗️❗️  No Active Encryption Key Detected! Would you like to generate ssh keys for password-less login?\n [Y/N]"
			read proceed
			if [ "{$proceed" = 'Y' ] || [ "{$proceed" = 'y' ]
				echo -e " **  Creating Public/Private RSA Key Pairs with 4096 Bit Length, Secure Passphrase & SSH-Agent Management via Keychain\n\n" 
				setup-sshkeys -uname $user -host $host --rsa -bits 4096 --x11 --keychain
			else
				echo -e "\nssh keys are required for automatic remote log in.. exiting.."
				exit
			fi
		else
			start_keychain
		fi
	fi
}
# Define Function 
##
function mountremotefs_sshfs(){
sshfs ${user}@${host}:$mount_this $mount_here -C -o Ciphers=arcfour,cache=yes,kernel_cache,defer_permissions,reconnect,follow_symlinks,password_stdin	
}

function mountremotefs_run(){
	mountremotefs_prepargs && mountremotefs_checkvpn && mountremotefs_checksshkeys && mountremotefs_sshfs
}

mount