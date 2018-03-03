#!/bin/bash
# My first script


# zsh
echo "-------------zsh screen git"

if ! dpkg -l screen &> /dev/null
then
	sudo apt-get install screen -y
fi

if ! dpkg -l git &> /dev/null
then
	sudo apt-get install git -y
fi

if ! dpkg -l zsh &> /dev/null
then
	sudo apt-get install zsh -y
fi

echo "-------------oh-my-zsh"
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sh -c "$(curl -fsSL http://zerow:3000/songz/omz/raw/branch/master/tools/install.sh)"

echo "-------------sed"
sed -i "s/# export PATH=\$HOME\/bin/export PATH=\$HOME\/bin\:\/sbin\:\/usr\/sbin\//g" $HOME/.zshrc
sed -i "s/git$/git colorize sudo extract zsh-autosuggestions z zsh-syntax-highlighting/g" $HOME/.zshrc
sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g" $HOME/.zshrc
sed -i "s/^alias/#alias/g" $HOME/.zshrc
sed -i "s/^\/DietPi/#\/DietPi/g" $HOME/.zshrc
sed -i "s/^\. \/DietPi/#\. \/DietPi/g" $HOME/.zshrc
sed -i "s/^source ~\/\.iterm2/#source ~\/\.iterm2/g" $HOME/.zshrc
sed -i "s/# export LANG/export LANG/g" $HOME/.zshrc


echo -e "/DietPi/dietpi/login
. /DietPi/dietpi/func/dietpi-globals
alias f/=\"find / -type f -iname\" f.=\"find . -type f -iname\" p=\"pidof\" k=\"kill -9\" rr=\"sudo reboot\" is=\"sudo apt-get install\" up=\"sudo apt-get update\" ud=\"sudo apt-get upgrade\" sd=\"sudo poweroff\"
source ~/.iterm2_shell_integration.zsh" >> $HOME/.zshrc


echo "-------------zsh-autosuggestions"
if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
	git clone http://zerow:3000/songz/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	# git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

echo "-------------zsh-syntax-highlighting"
if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
	# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	git clone http://zerow:3000/songz/syntax.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# aria2
echo "-------------aria2"
mkdir -p $HOME/.config/aria2/ && touch $_/aria2.session $_/aria2.conf

echo -e "#dir=$HOME/Downloads
continue=true
rpc-allow-origin-all=true
max-connection-per-server=10
split=10
max-overall-download-limit=0
max-download-limit=0
max-overall-upload-limit=0
max-upload-limit=0
input-file=$HOME/.config/aria2/aria2.session
save-session=$HOME/.config/aria2/aria2.session
save-session-interval=60
seed-ratio=1
bt-seed-unverified=true
check-certificate=false
load-cookies=true" > $HOME/.config/aria2/aria2.conf


# gitea
echo "-------------gitea"
if [ ! -d $HOME/gitea ]; then
export http_proxy=192.168.1.40:1087 https_proxy=192.168.1.40:1087
mkdir -p $HOME/gitea
wget -O $HOME/gitea/gitea https://dl.gitea.io/gitea/1.4/gitea-1.4-linux-arm-6
chmod +x $HOME/gitea/gitea
echo -e "[Unit]
Description=Gitea (Git with a cup of tea)

[Service]

User=root
WorkingDirectory=$HOME/gitea
ExecStart=$HOME/gitea/gitea web
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/gitea.service

sudo systemctl enable gitea.service
fi
# resilio
echo "-------------resilio"

RSLS=resilio-sync_armhf.tar.gz
LINK=linux-armhf

if [ ! -d $HOME/resilio ]; then
export http_proxy=192.168.1.40:1087 https_proxy=192.168.1.40:1087
mkdir -p $HOME/resilio
wget https://download-cdn.resilio.com/stable/$LINK/$RSLS
tar -xf $RSLS -C $HOME/resilio
sudo touch /etc/systemd/system/resilio.service

echo -e "[Unit]
Description = Resilio (folder sync)
#After=network.target

[Service]
Type = forking
User = root
#Group = root
#WorkingDirectory = $HOME
ExecStart = $HOME/resilio/rslsync --webui.listen 0.0.0.0:8888
Restart = always

[Install]
WantedBy = multi-user.target" | sudo tee /etc/systemd/system/resilio.service

sudo systemctl enable resilio.service
fi


echo "-------------source-list"
echo -e "#deb https://archive.raspberrypi.org/debian/ stretch main ui
deb http://mirrors.ustc.edu.cn/archive.raspberrypi.org/debian/ stretch main ui" > /etc/apt/sources.list.d/raspi.list
# aria2 132
# 62
# nodered 122

################### ngrok


if [ ! -f $HOME/ngrok ]
then
echo "-------------ngrok"

wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip

unzip $HOME/ngrok-stable-linux-arm.zip

mkdir -p $HOME/.ngrok2 && touch $_/ngrok.yml

echo -e "authtoken: 2jWq5RHKhqQmZ9ieHQh8n_FPQFRU67yxYey4NNBWja
web_addr: 0.0.0.0:4040
tunnels:
  httpbin:
    proto: http
    addr: 6800
    bind_tls: true
  demo:
    proto: http
    addr: 3000
    bind_tls: true
    inspect: false
    auth: demo:secret
  songz:
    proto: http
    bind_tls: true
    addr: 8888
  httpbinaa:
    proto: http
    addr: 80
    bind_tls: true" > $HOME/.ngrok2/ngrok.yml

echo -e "[Unit]
Description=ngrok
After=network.target

[Service]

Type=simple
Restart=always
User=root
WorkingDirectory=/root
ExecStart=/root/ngrok start -all
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/ngrok.service

sudo systemctl enable ngrok.service
fi

###################RetroPie


if ! dpkg -l lsb-release &> /dev/null
then
echo "-------------RetroPie"
sudo apt-get install lsb-release -y
fi

if [ ! -d $HOME/RetroPie-Setup ]; then
git clone --depth=1 http://zerow:3000/songz/RetroPie-Setup.git
# git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
fi

cd $HOME/RetroPie-Setup
sudo ./retropie_setup.sh


echo "-------------source"
# source $HOME/.zshrc
env zsh

# finish
echo "-------------finish"

# useful command

#-##### omxplayer looping

# while : ; do for f in * ; do omxplayer --blank --win 0,40,1280,680 --aspect-mode stretch "$f"; done; done

#-#####