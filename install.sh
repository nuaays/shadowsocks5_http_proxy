
## 
git clone https://github.com/nuaays/shadowsocks5_http_proxy.git .

## ubuntu 16.04
#### shadowsocks
apt-get install -y python-pip
pip install shadowsocks

cat <<EOF >/etc/shadowsocks.json
{
    "server": "vm.jeyzhang.com",
    "server_port": 2391,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"xxxx",
    "timeout":300,
    "method":"rc4-md5",
    "fast_open": "open",
    "workers": 1
}
EOF


echo 3 > /proc/sys/net/ipv4/tcp_fastopen
#sslocal -c /etc/shadowsocks.json


#### privoxy
useradd privoxy
#wget http://www.silvester.org.uk/privoxy/source/3.0.26%20%28stable%29/privoxy-3.0.26-stable-src.tar.gz
tar -zxvf privoxy-3.0.26-stable-src.tar.gz
cd privoxy-3.0.26-stable
apt-get install -y autoconf make
autoheader && autoconf
./configure
make && make all


cat <<EOF > /usr/local/etc/privoxy/config
user-manual /usr/local/share/doc/privoxy/user-manual/
confdir /usr/local/etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action # Actions that are applied to all sites and maybe overruled later on.
actionsfile default.action   # Main actions file
actionsfile user.action      # User customizations
filterfile default.filter
filterfile user.filter      # User customizations
logfile logfile
listen-address  127.0.0.1:8118
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 0
forward-socks5t   /               127.0.0.1:1080 .
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
EOF


cat <<EOF >> /etc/profile
export http_proxy=http://127.0.0.1:8118
export https_proxy=http://127.0.0.1:8118
export ftp_proxy=http://127.0.0.1:8118
EOF

source /etc/profile


##
nohup sslocal -c /etc/shadowsocks.json /dev/null 2>&1 &
privoxy --user privoxy /usr/local/etc/privoxy/config

