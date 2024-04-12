
# linuxmint installのシェルスクリプト(2024-04ver)
# 出来るだけ自動にしたが、ところどころyes no聞かれるのでちょいちょい確認して答えていく必要がある。。。

# let`s install
# curl -O https://raw.githubusercontent.com/leefsice/localset/main/linuxmint-install.sh
# bash -ex linuxmint-install.sh 2>linuxmint-install-error.log

### windowsのdiskpartによるHDDの全セクタ0write
### パーティションなどがおかしくなった場合に、実行すると初期状態にリセットできる。
### それ狙いなら先頭だけ消去できればいいので5秒ぐらいで終わりにして良い。
# diskpart
# list disk
# select disk 1
# list disk
# clean all

USERNAME=$(whoami)
D_GIT_USER_NAME='leefsice'
D_GIT_USER_EMAIL='leefsice@gmail.com'

# デスクトップとか英語化
LANG=C xdg-user-dirs-gtk-update

# ファイアウォールを有効化
sudo ufw enable
sudo ufw default deny
sudo ufw logging on
sudo ufw reload
# sudo ufw status verbose

# リポジトリを日本のサーバーに設定する。[Software Sources] にアクセスし、
# Mirrors の Main (vanessa) と Base (jammy) を日本に変更。
# この時点で日本語入力できる状態だが、辞書ツールなどは動かないので、言語設定から日本語環境を入れておく。
# linuxmint20の場合、設定 - 入力方法 - 日本 - インストールボタン押す　という手順になる
# 一度再起動して、Fcitx設定 - 入力メソッドにMozc、日本語(かな)
# 全体の設定 - 入力メソッドのオンオフ 切り替えるキーを設定
# ついでに、このシェルを流すとDownloadsに顔文字のimeファイルがある状態になるのでインポートしておく
# vivaldiは、debファイルからインストール
# skypeは、ソフトウェアマネージャーから手で
# virtualbox 共有フォルダを設定した後でやる /medir/sf_{dir-name}みたいになる。
# sudo gpasswd --add leefsice vboxsf
# コンソールの設定を変える
# ウインドウの半透明化と、初期のウインドウサイズを大きくする
# port fordingするなら、vboxの設定で、NATのしたのほうにある高度なセッティングの所で行える。基本は80 -> 80とかかな。

# Mozc設定
# Mozcツール - 設定ツール - 一般タブ - キー設定 - 編集ボタン
# henkan - IMEを有効化（直接入力）、ひらがなに入力切替（他3つ）
# muhenkan - IMEを無効化（４つすべて）


# とりあえずホームからスタート！！
cd ~/

# ppa追加時に毎度updateすると時間が掛るため、一気に追加してアップデートする
################# ppa all start

# git
sudo add-apt-repository -y ppa:git-core/ppa

# MongoDB
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# meld
sudo add-apt-repository -y ppa:sicklylife/ppa 

# vscode visual studio code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get update -y
sudo apt-get upgrade -y

################# ppa all end

# SSH key Ed25518 Gen
mkdir ~/.ssh
cd ~/.ssh
ssh-keygen -t ed25519 -C $D_GIT_USER_EMAIL -f id_ed25519_leefsice
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519_leefsice

tee -a ~/.ssh/config <<'EOF' >/dev/null
Host github_leefsice
HostName github.com
User git
IdentityFile ~/.ssh/id_ed25519_leefsice
IdentitiesOnly yes
AddKeysToAgent yes
EOF

# connect check!!
# ssh -T -i ~/.ssh/id_ed25519_leefsice github_leefsice

# 個人と会社を使い分ける際に、sshの設定を元に鍵ファイルを変更する必要がある場合、初回のgit cloneを下記のようにする
# git clone github_leefsice:leefsice/rust-test.git

# 最新型で対応可能なら、使わないこと！！
# SSH key RSA Gen
# ssh-keygen -t rsa -b 4096 -C 'leefsice@gmail.com'
# chmod 600 ~/.ssh/id_rsa

# chrome
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
rm -rf google-chrome-stable_current_amd64.deb

# tooles
sudo apt-get install -y subversion curl vim build-essential

# sdkman for java11
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
# sdk list javaで、どんなものがあるかわかる。amazon linux指定は下記。何も指定しないと最新がインストールされる
# sdk list java
# sdk install java 8.0.202-amzn
sdk install java

# デフォルトエディタがnanoのため、vimとかに変える。。。（選択肢あり）
sudo update-alternatives --config editor

# git install
sudo apt-get install -y git

# git branch console view
cd && wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# git setup
git config --global user.name $D_GIT_USER_NAME
git config --global user.email $D_GIT_USER_EMAIL
git config --global credential.helper 'cache --timeout=1600'

# 必ず、マージコミット作る！！でも、pullの時のmergeはそうしない的な設定
git config --global --add merge.ff false
git config --global --add pull.ff only

# branchなどをリスト表示する時にcat的な表示にする設定
git config --global pager.branch cat
git config --global pager.tag cat

# meld and git setup
# gitのdifftoolでmeldが開くようにする
# sudo add-apt-repository -y -n ppa:sicklylife/ppa 
sudo apt-get install -y meld
cat << EOS >> ~/.gitconfig
[diff]
        tool = meld
[difftool "meld"]
        cmd = meld \$LOCAL \$REMOTE

EOS
# git difftool
# or
# git difftool -d

# vscode (visual studio code)
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y code

## vscode settings copy
cd /tmp
git clone --depth 1 https://github.com/leefsice/localset.git
mkdir -p ~/.config/Code/User
cp ./localset/vscode/* ~/.config/Code/User/

## visual studio code のファイル総数error対策 ここから
sudo cp /etc/sysctl.conf /etc/sysctl.conf_bk2

sudo tee -a /etc/sysctl.conf <<'EOF' >/dev/null

##### original adding #####
fs.inotify.max_user_watches=524288
EOF
sudo sysctl -p
## visual studio code のファイル総数error対策 ここまで


################# 単独でインストールできるもの

# ファイル監視＆コマンド実行用ツール
sudo apt-get install -y inotify-tools
## while inotifywait -qq -e close_write,moved_to,create -r `pwd`; do echo "aaa"; done

# password Generator
sudo apt-get install -y pwgen
pwgen -sy 16 100

## MongoDB 7.0系
## see https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
# echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
# sudo apt-get update
# sudo apt-get install -y mongodb-org=7.0.7 mongodb-org-database=7.0.7 mongodb-org-server=7.0.7 mongodb-mongosh=7.0.7 mongodb-org-mongos=7.0.7 mongodb-org-tools=7.0.7
sudo apt-get install -y mongodb-org
sudo service mongod start
mongod --version
# sudo service mongod stop

# nkf [Network Kanji Filter] の略。文字コード変換に使う -wのオプションは、URF-8に変換する
sudo apt-get install -y nkf
# find -name '*.txt' | xargs nkf --overwrite -w

# 顔文字 Moac向けに約3000パターン
# see https://retiresaki.hatenablog.com/entry/2018/12/13/120300
cd ~/Downloads/ && wget https://download2276.mediafire.com/bdws63jja38g-Js_biM9jiG-QMBBP4Nu3k39abxopK0KHM8GVfoz8bZvTgzksk799wkAojJvGVt8XGXyWv3nSCHvS1IqwAJwmR4LRyafHZdxlRzhBkTbOEBuXkecKXGj8fDDLOqq0twAqAAqu2FDPyee2MVqoo8qfqsCqdUQwMw/4ol2d8u6x2b2d2h/kaomoji.zip
unzip kaomoji.zip
# iconv -f cp932 -t UTF-8 ~/Downloads/kaomoji.txt -o ~/Downloads/kaomoji-change.txt

# フォント：myrica
# https://myrica.estable.jp/
cd ~/Downloads/ && wget https://github.com/tomokuni/Myrica/raw/master/product/Myrica.zip
unzip -O sjis Myrica.zip -d Myrica
cd ~/Downloads/Myrica && sudo mv Myrica.TTC /usr/local/share/fonts/

# Geany text editor
sudo apt-get install -y geany
cd /tmp
git clone --depth 1 https://github.com/codebrainz/geany-themes
mkdir -p ~/.config/geany/colorschemes
cp ./geany-themes/colorschemes/* ~/.config/geany/colorschemes/

# お絵かきソフト　pinta
sudo apt-get install -y pinta

# clusterssh
sudo apt-get install -y clusterssh

# ntp server setup and set timezone（デフォルトだと、timeserver設定が無いので時間がずれる）
# linuxmintはデフォルトでntpとsystemd-timesyncdが入っているので、競合を起こすのでntpを削除してからインストールする
sudo apt-get purge -y ntp
sudo sed -i -e"s/^#NTP=/NTP=ntp.nict.jp/" /etc/systemd/timesyncd.conf
cat /etc/systemd/timesyncd.conf
sudo systemctl restart systemd-timesyncd
timedatectl set-timezone Asia/Tokyo
timedatectl set-ntp true
timedatectl status
# timedatectl -no-pager list-timezones | grep Asia/To

# Protocol Buffersの定義ファイルをフォーマットするために導入
sudo apt-get install -y clang-format

## ubuntu focal docker install (26.0)
sudo apt install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-key.asc] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA0A9C3F273FCD8
sudo add-apt-repository "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker-key.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

## ubuntu docker command no use sudo (require user exit or os reboot)
sudo usermod -aG docker $USER
sudo chmod +x /usr/bin/docker
sudo chmod +x /usr/bin/docker-compose


# ■Ubuntu18.04 nameserver設定 必要であれば設定する！！
# sudo apt-get install -y resolvconf
### sudo tee -a /etc/resolvconf/resolv.conf.d/head << 'EOF' 追記
# sudo tee /etc/resolvconf/resolv.conf.d/head << 'EOF'
## Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
##     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
## 127.0.0.53 is the systemd-resolved stub resolver.
## run "systemd-resolve --status" to see details about the actual nameservers.
# nameserver 127.0.0.1
# EOF
# sudo service resolvconf restart

# keybord config 
## xev | grep -A6 KeyPress
cat << 'EOS' >> ~/.Xmodmap
clear lock
keycode 66 = Control_L
add control = Control_L Control_R
EOS
xmodmap ~/.Xmodmap


# nvm
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/creationix/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"
nvm install node
nvm use node

################# .bashrc start

cat << 'EOS' >> ~/.bashrc
##### original adding #####

# alias
alias d-open="xdg-open ."
alias d-tom='pkill -f tomcat'
# alias d-tom="ps -ef | grep tomcat | grep -v 'grep' | awk {'print \$2'} | xargs kill -9"
alias d-db-start='sudo service mongod start && sudo service mysqld start && /usr/local/redis/src/redis-server > /tmp/redis-server.log 2>&1 &'
alias d-db-stop='sudo service mongod stop && sudo service mysqld stop && pkill -f redis'
alias d-bash-reload='source ~/.bashrc'
alias d-db-m=' mysql -u p2 -p --database=p2_master --default-character-set=utf8mb4'
alias d-ch-per="chmod -R a=rX,u+w $2"
alias d-f-size='du -ahk | sort -hr | head'
alias d-go='~/go/bin/gore'
alias d-r-grep='d-r-grep-func'
alias d-r-replace='d-r-replace-func'
alias d-vscode='code --disable-gpu'

alias d-g-push='git push origin `git rev-parse --abbrev-ref HEAD`'
alias d-g-push-f='git push -f origin `git rev-parse --abbrev-ref HEAD`'
alias d-g-save='d-g-save-func'
alias d-g-sub-update="git submodule update --init --recursive"
alias d-g-clone="git clone --recursive $2"
alias d-g-shallow-clone="git clone --depth 1 $2"
alias d-g-account='git config --local user.name "leefsice" && git config --local user.email leefsice@gmail.com'

# d-watch /tmp/aaa 'echo sss'
function d-watch-func(){
#  inotifywait -e create,delete,modify,move -mr $1 |while read;do while read -t 0.3;do :;done; $2 ;done
  inotifywait -e modify -mr $1 |while read;do while read -t 0.3;do :;done; $2 ;done
}
# git add and commit and push!!
function d-g-save-func() {
  git add --all
  git commit -m 'aaa'
  d-g-push
}
# d-r-grep *.go hoge
function d-r-grep-func() {
  find . -type f -name $1 -print0 | xargs -0 grep $2
}
function d-r-replace-func() {
  # d-r-replace './src' '*.go' github.com/hoge github.com/hoge2
  find $1 -type f -name "$2" -exec sed -i "s|$3|$4|g" {} \;
}
function d-start-func() {
  cd ~/src/git/p2-server/cms
  sudo ls
  d-db-start
}

# setup git branch view
source ~/git-completion.bash
GIT_PS1_SHOWDIRTYSTATE=true
export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '

# nvm use
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm use node

# golang
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
GOROOT="/usr/local/go"

# xmodmap keybord config
xmodmap ~/.Xmodmap

EOS

# インストール後、再起動推奨なので、この時点でロードしない
# source ~/.bashrc

################# .bashrc end

### history sizeがグローバルのbashrcでないと変わらないためこちらに入れる
sudo tee -a /etc/bash.bashrc << 'EOF' > /dev/null

##### original adding #####

# history up
HISTSIZE=50000
HISTFILESIZE=50000
HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '

EOF

### srcからnetbeansをインストールする場合の手順（今だとほぼやらない手順かな）
### ant install for netbeans
# sdk use java java 8.0.202-amzn
# sudo apt-get install -y ant

### ビルドに時間が掛るので注意！！ Total time: 11 minutes 38 seconds 6コアでこの時間だから、しょぼいPCだと1時間は見たほうが良いかも。。。
### netbeans10 vc5
# cd
# git clone --depth 1 https://github.com/apache/incubator-netbeans
# cd incubator-netbeans
# ant -Dcluster.config=full
# sdk use java 11.0.-open

# cd 
# cd incubator-netbeans/nbbuild/netbeans/etc
# d-open
### netbeans_default_options add!!
# -J-Dawt.useSystemAAFontSettings=on -J-Dfile.encoding=UTF-8
# add
# netbeans_jdkhome=/usr/lib/jvm/java-8-openjdk-amd64
# netbeans_jdkhome=/home/leefsice/.sdkman/candidates/java/11.0.1-open

### 起動コマンド
# ant tryme

### MariaDB 10.3 install
# sudo apt-get install -y software-properties-common
# sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
# sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/10.3/ubuntu bionic main'
# sudo apt-get update
# sudo apt-get install -y mariadb-server
# sudo mysql_secure_installation


# mariaDB 10.1? install
# sudo apt-get install -y mariadb-server
# # セキュリティ設定。Localアクセスのみなら全てYesでやってよい。
# # VirtualBoxを使う場合、あとで、リモートアクセス出来るようにmy.confを書き換えること！！
# sudo mysql_secure_installation


### Local Setup
### connect to localhost only. grant with root only.
# use mysql;
# select * from user;
# use mysql
# TRUNCATE TABLE user;
# FLUSH PRIVILEGES;
# GRANT ALL PRIVILEGES ON *.* TO root@localhost identified by 'password111' with grant option;
# GRANT ALL PRIVILEGES ON *.* TO 'yamada'@'localhost' identified by 'password111';
# FLUSH PRIVILEGES;

### VirtualBox Setup
### Virtual Boxでポートフォワーディングしても接続packetが拒否される場合、my.confの設定を確認してリモートアクセスも許可する
# use mysql
# TRUNCATE TABLE user;
# FLUSH PRIVILEGES;
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' identified by 'password111' with grant option;
# GRANT ALL PRIVILEGES ON *.* TO 'yamada'@'localhost' identified by 'password111';
# GRANT ALL PRIVILEGES ON *.* TO 'yamada'@'10.0.2.2' identified by 'password111';
# FLUSH PRIVILEGES;
# sudo vi /etc/mysql/my.cnf
# port = 3306
# # bind-address		= 127.0.0.1
# bind-address = 0.0.0.0

### option pattarn
### testdb Only
# create database testdb;
# #GRANT ALL PRIVILEGES ON `testdb`.* TO 'yamada'@'10.0.2.2' identified by 'password111';
# # all remote access
# #GRANT ALL PRIVILEGES ON `testdb`.* TO 'yamada'@'%' identified by 'password111';
#
# use testdb;
# create table test (
#   `id` int unsigned not null auto_increment comment 'プライマリキーだよ',
#   `c1` varchar(255) not null default 'hoge' comment 'テキストいれるとこだよ',
#   `c2` text,
#   `c3` tinyint,
#   `c4` smallint,
#   `c5` int,
#   `c6` bigint,
#   `c7` datetime,
#   `c8` timestamp,
#   primary key(`id`)
# ) engine=innodb default charset=utf8 comment 'このテーブルはテストテーブル';
# insert into test (c1, c2, c3, c4, c5, c6, c7) values ('hello!!', '2', 3, 4, 5, 6, '2018-02-04');
# insert into test (c1, c2, c3, c4, c5, c6, c7) values ('hello!!222', '2', 3, 4, 5, 6, '2018-02-04');
# insert into test (c1, c2, c3, c4, c5, c6, c7) values ('hello!!333', '2', 3, 4, 5, 6, '2018-02-04');

### MariaDB reset root password
# sudo su -
# /etc/init.d/mysql stop
# killall mysqld_safe
# killall mysqld
# mysqld_safe --skip-grant-tables &
# 
# mysql -uroot
# use mysql;
# update user set password=PASSWORD("mynewpassword") where User='root';
# update user set plugin="mysql_native_password";
# quit;
# 
# /etc/init.d/mysql stop
# kill -9 $(pgrep mysql)
# /etc/init.d/mysql start
# mysql -u root -p


### Redis Install
### version is GCP cloud memorystoreと同じ
# mkdir -p /tmp/redis-make-tmp
# cd /tmp/redis-make-tmp
# wget http://download.redis.io/releases/redis-3.2.11.tar.gz
# tar xzf redis-3.2.11.tar.gz
# cd redis-3.2.11
# make
# cd ../
# mv redis-3.2.11 ~/
# cd ~/redis-3.2.11
# 
# /home/daijiin/redis-3.2.11/src/redis-server > /tmp/redis-server.log 2>&1 &
# /home/daijiin/redis-3.2.11/src/redis-cli


# redis5.0
# sudo ls
# cd /tmp
# wget http://download.redis.io/releases/redis-5.0.5.tar.gz
# echo '2139009799d21d8ff94fc40b7f36ac46699b9e1254086299f8d3b223ca54a375  redis-5.0.5.tar.gz' | shasum -a256 -c
# tar xzf redis-5.0.5.tar.gz
# cd redis-5.0.5
# make
# cd ../
# sudo mv ./redis-5.0.5 /usr/local/redis



### 良く忘れるコマンド集！！

# 300M以上のファイルを検索する
# find /home -size +300M | xargs ls -l | sort -rn

# ログを圧縮して削除する
# tar -zcvf aaa.log.tar.gz aaa.log
# rm -rf aaa.log

# 解凍
# tar -xvf aaa.tar.gz

# sample deamon kidou command
# while true; do date; sleep 1s; done 2>&1 > aaa.log &
