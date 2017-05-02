#!/bin/bash
# Maintain Mounted Volume on SSHFS
##
# user login & server
user=''
host=''
# server mount info
hostalias=''
mount_this='/'
mount_here='/Volumes'
# vpn
vpnservername=''
##
# Define Function
## Help 
function show_help(){

cat <<EOF

Usage: ${0##*/}  -  A wrapper for the Secure Shell File System (sshfs) protocol for maintaining a zombie connection that ressurects upon disconnect.

     Options :: 
                [--help]               print usage 
                [-u|--uname USER]         user name for remote host
                [-h|--host HOST]          host address / host name
                [-p|--serverdir PATH]     directory to be accessed on the remote host
	            [-l|--localdir PATH]      the remote directory will be placed here
                [-a|--hostalias STRING]   name for the local portal to the remote directory
                [-v|--vpn SERVERNAME]     enter this option to tunnel via VPN (address required)

     Example ::

      Connect to a server through a vpn tunnel
               
                ${00##*/} -u guest -h 192.168.1.11 -p / -l /Volumes/ -a awesomeserver -v securvpn.connected.org

EOF
} 
##
while :; do
	case ${1} in
		--help)
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
            printf '\n ‼  ️ Warning: Unknown option: %s\n' "${1}" >&2
            exit
            ;;
        *)
            break
	esac
	shift
done
##
# Define Function
## Assemble input arguments to final formats
function mountremotefs_setup(){
	mount_here=${mount_here}/${hostalias}
	echo -e "\n  🗄  Setting up Local Directory to Host Remote File: $mount_here\n" && [ ! -d ${mount_here} ] && mkdir -p ${mount_here}
	echo -e "\n ⚙  Creating Local Configuration Files\n" && [ ! -e "${HOME}/.ssh/.autosshfs" ] && mkdir -p ${HOME}/.ssh/.autosshfs
}
# Define Function
## Establish Persistent VPN Connection via OpenConnect
function mountremotefs_vpnconnect(){
	[ ! -z ${vpn} ] && vpn-connect to ${vpnservername}
}
# Define Function
## Check Existence of SSH Keys, ssh-agent & keychain
function mountremotefs_checksshkeys(){
	# get location of current key
	currentkey=$(ssh-add -L | awk '{print $3}')
	if [ ! -z $currentkey ]; then
		echo -e "\n  🔎 🔑  Found Existing Key Encryption For Automatic Login ($currentkey)\n"
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
			read -p "**  Enter Path to Private Key to Enable Automatic Logins (~/.ssh/id_rsa)" private_key
			if [ -z ${private_key} ]; then
				private_key="~/.ssh/id_rsa"
			else
				[ ! -e ${private_key} ] && echo -e "\n ❗️❗️  WARNING - ${private_key} not found, sshfs will require password entry for each reconnection.. exiting....\n" && exit
				[ -e ${private_key} ] && echo "\n\n ** Adding Existing Key to Keychain\n" && ssh-add ${private_key}
			fi
		fi
	fi
}
# Define Function
## Remove Zombification Signal & Anchor 
function mountremotefs_banish(){
	echo -e "\n\n 👹  Banishing SSHFS Zombie - Unmounting Remote File System, Deleting Zombie Signal\n"
	rm ${HOME}/.ssh/.autosshfs/${hostalias}.zombie
	umount -v ${mount_here}
	## Add something here to check if umount failed
		#[ "${mount_this}" = "/"] && ssh ${user}@${host} "rm ${mount_this}tmp/$(whoami).$(hostname).sshfs.anchor"
		#[ "${mount_this}" != "/" ] && ssh ${user}@${host} "rm ${mount_this}/$(whoami).$(hostname).sshfs.anchor"
	exit	
}
# Define Function
## Create Anchor To Confirm Working Connection
function mountremotefs_anchor(){
	# Create the anchor in the home directory
	echo -e "\n\n ⚓️  Anchoring Remote File System to Local Host\n"
	local HOSTHOME=$(ssh ${user}@${host} 'echo ${HOME}')
	ssh ${user}@${host} "mkdir -p .ssh/.autosshfs; touch ${HOSTHOME}/.ssh/.autosshfs/$(whoami).$(hostname).${hostalias}.anchor"
	[ "${mount_this}" = "/"] && anchor="${mount_this}tmp/$(whoami).$(hostname).${hostalias}.autosshfs.anchor" && ssh ${user}@${host} "ln -s ${HOSTHOME}/.ssh/.autosshfs/$(whoami).$(hostname).${hostalias}.anchor ${anchor}"
	[ "${mount_this}" != "/" ] && anchor="${mount_this}/$(whoami).$(hostname).${hostalias}.autosshfs.anchor" && ssh ${user}@${host} "ln -s ${HOSTHOME}/.ssh/.autosshfs/$(whoami).$(hostname).${hostalias}.anchor ${anchor}"
}
# Define Function 
## Loop indefinitely while Zombie Signal Exists & Check for Anchor
function mountremotefs_zombie(){
	while [ -e ${HOME}./ssh/.autosshfs/${hostalias}.zombie ]; do
		if [ ! -e ${mount_here}/tmp/$(whoami).$(hostname).${hostalias}.autosshfs.anchor] || [ ! -e ${mount_here}/$(whoami).$(hostname).${hostalias}.autosshfs.anchor]; then
			echo -e "\n\nMissing Anchor - Resurrecting SSHFS Connection - $(date)\n\n"
			$sshfs ${user}@${host}:$mount_this $mount_here -C -o Ciphers=arcfour,cache=yes,kernel_cache,defer_permissions,reconnect,follow_symlinks	
		fi
	done
}

function mountremotefs_run(){
	mountremotefs_mkdir && mountremotefs_checkvpn && mountremotefs_checksshkeys && mountremotefs_sshfs
}

open ${mount_here}