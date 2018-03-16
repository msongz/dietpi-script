#!/bin/bash
# My first script
# zerow

GITEA=https://dl.gitea.io/gitea/1.4/gitea-1.4-linux-arm-6
ARIA=/var/lib/dietpi/dietpi-software/installed
ZSHURL=https://raw.githubusercontent.com/msongz/oh-my-zsh/master/tools/install.sh
ZSHSUGG=https://github.com/zsh-users/zsh-autosuggestions.git
ZSHSYNX=https://github.com/zsh-users/zsh-syntax-highlighting.git
RSLS=resilio-sync_arm.tar.gz
RSLK=linux-arm
NGROK=https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
RETRO=https://github.com/RetroPie/RetroPie-Setup.git

################### zsh
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


sh -c "$(curl -fsSL $ZSHURL)"

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
	# git clone http://zerow:3000/songz/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	git clone $ZSHSUGG $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

echo "-------------zsh-syntax-highlighting"
if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
	git clone $ZSHSYNX $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	# git clone http://zerow:3000/songz/syntax.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi


# rc.local
#echo "-------------rc.local"
#echo -e "#!/bin/sh -e\naria2c --conf-path=/home/pi/.aria2/aria2.conf &\nsu - root -c '/home/pi/rslsync --webui.listen 0.0.0.0:8888' &\nsu - pi -c 'python -m SimpleHTTPServer 8080' &\nexit 0" | sudo tee /etc/rc.local


#################### aria2
echo "-------------aria2"


touch $ARIA/aria2.session

# git clone https://github.com/ziahamza/webui-aria2.git
# sudo apt-get install aria2 -y
# mkdir ~/.aria2
# mkdir -p $HOME/.config/aria2/ && touch $_/aria2.session $_/aria2.conf
# mkdir $HOME/.config/aria2/aria2 && $_/aria2.conf

echo -e "# host is where aria2c is running on
host=localhost
dir=/mnt/dietpi_userdata/downloads

# cleanup_policy
# cleanup-policy=clean_got
# cleanup-percent=90%

# The fallowing options are aria2c options as usual aria2.conf file
# https://aria2.github.io/manual/en/html/aria2c.html

# RPC Options
enable-rpc=true
rpc-listen-all=true
rpc-listen-port=6800
rpc-secret=147852
pause=false
rpc-allow-origin-all=true

# SAVE SESSION
input-file=$ARIA/aria2.session
save-session=$ARIA/aria2.session
save-session-interval=60

# General Options
log=/var/log/aria2.log
log-level=warn

split=10
continue=true
check-integrity=true
check-certificate=false
max-concurrent-downloads=10
max-connection-per-server=10
max-file-not-found=3
max-tries=5
retry-wait=60
ftp-pasv=true
bt-max-peers=13
# listen-port=6881-6999
load-cookies=true

max-overall-upload-limit=0
max-overall-download-limit=0
max-upload-limit=0
max-download-limit=0
seed-ratio=1
seed-time=0

metalink-servers=13
allow-overwrite=false
always-resume=true
auto-file-renaming=false
file-allocation=none" > $ARIA/aria2.conf

#################### gitea
echo "-------------gitea"

if [ ! -d $HOME/gitea ]; then
mkdir -p $HOME/gitea
wget -O $HOME/gitea/gitea $GITEA
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
################### resilio
echo "-------------resilio"


if [ ! -d $HOME/resilio ]; then
mkdir -p $HOME/resilio
wget https://download-cdn.resilio.com/stable/$RSLK/$RSLS
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

################### ngrok


if [ ! -f $HOME/ngrok ]
then
echo "-------------ngrok not enable"


wget $NGROK

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

# sudo systemctl enable ngrok.service

fi

################### RetroPie


if ! dpkg -l lsb-release &> /dev/null
then
echo "-------------RetroPie"
sudo apt-get install lsb-release -y
fi

if [ ! -d $HOME/RetroPie-Setup ]; then
git clone --depth=1 $RETRO
fi

sudo $HOME/RetroPie-Setup/retropie_setup.sh

################### finish

echo "-------------source"
# source $HOME/.zshrc
env zsh


# useful command

# cat Documents/ins.sh | ssh root@pi2 "cat > ins.sh"

# omxplayer looping

# while : ; do for f in * ; do omxplayer --blank --win 0,40,1280,680 --aspect-mode stretch "$f"; done; done

#