#!/bin/bash
# firstly, configure the file  ~/.ssh/config

# username 
# password
# sudo
# machines

#gw="103.10.85.98 -p 154"
#cpu4="192.168.1.156"
#gpu1="192.168.1.153"
#gpu2="192.168.1.155"
gw="shangdi"
cpu4="cpu4"
gpu1="gpu1"
gpu2="gpu2"

admin="netlab"

username=$1
password=$2
if_sudo=$3

count=3
sshcmd="ssh $admin@$gw 'pwd'"
#echo $sshcmd
#eval $sshcmd

targets=("${gw}")

while [ $# -gt $count ];
do
        case $4 in
          "cpu4")
          target=${cpu4}
          ;;
  "gpu1")
          target=${gpu1}
          ;;
  "gpu2")
          target=${gpu2}
          ;;
  esac
  shift
  #let count=count+1
  #echo $target
  targets+=($target)
done

show_usage(){
    appname=$0
    echo "Usage: $appname USERNAME PASSWORD [sudo/non-sudo] cpu4 gpu4 gpu2"
}

create_user(){
  for target in "${targets[@]}";
  do
          echo Adding user on device: $target
          # check user
          check_cmd="ssh $target 'id -u $username  2>&1' | grep -q no"
          if [[ $? == 0 ]];
          then
               echo -- check user:$username not exist
               #createuser
               create_cmd="ssh -t $target 'sudo useradd -d /home/$username -s /bin/bash -m $username'"
               #passwd
               setpwd_cmd="ssh -t $target 'echo -e \"$password\\n$password\\n\"|sudo passwd $username'"
               #set docker
               setdocker_cmd="ssh -t $target 'sudo usermod -aG docker $username'"
               echo -- creating user: $username
               eval $create_cmd
               eval $setpwd_cmd
               eval $setdocker_cmd
               if [ $target != $gw ] && [ $if_sudo == "sudo" ];
               then
                  #add sudo
                  addsudo_cmd="ssh $target 'echo \"$username ALL=(ALL:ALL) ALL\" |sudo tee -a /etc/sudoers'"
                  eval $addsudo_cmd
               echo -- add user $username, set passwd $password, set docker
               fi
          else
               echo -- Sorry, $username exists
          fi

  done
}

while getopts ":h" option; do
        case $option in 
                h)
                        show_usage
                        exit;;
        esac
done

create_user
#read -p "Name:" newuser
#name=$newuser
#useradd -d /home/$name -s /bin/bash -m $name
#
#
#
#read -p "Enter a passwd for $name:[passwd]" pw
#if [ -z "$pw" ]; then
#            pw="passwd"
#fi
#
#ssh user@hostname "user add ;echo $pw| passwd --stdin $name &>/dev/null"
