#!/bin/bash
# My first script
# remote-host

# GITEA=https://dl.gitea.io/gitea/1.6.2/gitea-1.6.2-linux-arm-7
# ARIA=/var/lib/dietpi/dietpi-software/installed
# EPAD=https://github.com/ether/etherpad-lite.git
ZSHURL=https://raw.githubusercontent.com/msongz/oh-my-zsh/master/tools/install.sh
ZSHSUGG=https://github.com/zsh-users/zsh-autosuggestions.git
ZSHSYNX=https://github.com/zsh-users/zsh-syntax-highlighting.git
# POWERLEVEL9K=https://github.com/bhilburn/powerlevel9k.git
RSSHUB=https://github.com/DIYgod/RSSHub.git
RSLS=resilio-sync_x64.tar.gz
RSLK=linux-x64
# NGROK=https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
# RETRO=https://github.com/RetroPie/RetroPie-Setup.git
FRPLINK=https://github.com/fatedier/frp/releases/download/v0.22.0/frp_0.22.0_linux_amd64.tar.gz





################### zsh
echo "-------------zsh screen git curl"

if ! dpkg -l git &> /dev/null
then
	sudo apt-get install git -y
fi


sudo apt-get install curl -y


if ! dpkg -l zsh &> /dev/null
then
	sudo apt-get install zsh -y
fi

echo "-------------oh-my-zsh"

sh -c "$(wget $ZSHURL -O -)"

echo "-------------zshrc"

sed -i "s/# export PATH=\$HOME\/bin/export PATH=\$HOME\/bin\:\/sbin\:\/usr\/sbin\//g" $HOME/.zshrc
sed -i "s/# export LANG/export LANG/g" $HOME/.zshrc
sed -i "s/git$/git colorize sudo extract zsh-autosuggestions z zsh-syntax-highlighting/g" $HOME/.zshrc
# sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel9k\/powerlevel9k\"/g" $HOME/.zshrc
sed -i "s/^alias/#alias/g" $HOME/.zshrc
# sed -i "s/^\/DietPi/#\/DietPi/g" $HOME/.zshrc
# sed -i "s/^\. \/DietPi/#\. \/DietPi/g" $HOME/.zshrc
# sed -i "s/^source ~\/\.iterm2/#source ~\/\.iterm2/g" $HOME/.zshrc
sed -i "s/^echo/#echo/g" $HOME/.zshrc

echo -e "alias json=\"python -m json.tool\" css=\"sudo systemctl stop\" csr=\"sudo systemctl restart\" cst=\"sudo systemctl status\" f/=\"find / -type f -iname\" f.=\"find . -type f -iname\" p=\"pidof\" k=\"kill -9\" rr=\"sudo reboot\" is=\"sudo apt-get install\" up=\"sudo apt-get update\" ud=\"sudo apt-get upgrade\" sd=\"sudo poweroff\" hh=\"htop\"" >> $HOME/.zshrc

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

################### nodejs
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get install -y nodejs




# rc.local
#echo "-------------rc.local"
#echo -e "#!/bin/sh -e\naria2c --conf-path=/home/pi/.aria2/aria2.conf &\nsu - root -c '/home/pi/rslsync --webui.listen 0.0.0.0:8888' &\nsu - pi -c 'python -m SimpleHTTPServer 8080' &\nexit 0" | sudo tee /etc/rc.local


#################### resilio

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


################### frp

echo "-------------frp"

if [ ! -d $HOME/frp ]; then
  mkdir -p $HOME/frp && wget -qO- $FRPLINK | tar zxv -C $HOME/frp --strip-components=1


echo -e "[common]
server_addr = msongz.ml
server_port = 7000

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000

[web]
type = http
local_port = 80
custom_domains = msongz.ml" | sudo tee $HOME/frp/frpc.ini

echo -e "[Unit]
Description=frp
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=3
User=root
WorkingDirectory=$HOME/frp
ExecStart=$HOME/frp/frpc -c $HOME/frp/frpc.ini

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/frp.service

sudo systemctl enable frp.service
fi

################### rsshub

echo "-------------rsshub"

if [ ! -d $HOME/RSSHub ]; then

git clone $RSSHUB


# npm config set registry https://registry.npm.taobao.org

npm i -g npm

cd $HOME/RSSHub && npm install
cd $HOME

echo -e "[Unit]
Description=rsshub

[Service]
User=root
WorkingDirectory=$HOME/RSSHub
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/rss.service

sudo systemctl enable rss.service
fi


echo "-------------source"

# source $HOME/.zshrc
env zsh



