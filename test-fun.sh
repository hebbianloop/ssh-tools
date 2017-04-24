#!/bin/bash
# Define Function
## This function displays options to user and asks for verification
function confirm_input(){
    local confirm_user_input=$(cat <<-EOF
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
    \n
    \t    🔑 PRIVATEKEY      ::      $privkey\n
    \t    🗝 PUBLICKEY       ::      $pubkey\n
    \n    
    \t    ⚙  X11 AUTH?       ::      $x11\n
EOF
    )   
echo -e $confirm_user_input
read -p "Proceed? [Y/N]  :: " proceed
}

confirm_input

