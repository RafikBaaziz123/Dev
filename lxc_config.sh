preconfig(){
     #add config if don't exist
     grep -qxF "lxc.net.0.ipv4.gateway = auto" /etc/lxc/default.conf || echo "lxc.net.0.ipv4.gateway = auto" >> /etc/lxc/default.conf
            }

