#!/bin/bash

apt-get update -y
apt-get upgrade -y

apt-get install squid

rm /etc/squid/conf.d/* -v

install -o proxy -g proxy -d /var/cache/squid

cat << EOF > /etc/squid/squid.conf
# Listen on port 80, not 3128
# 'accel' tells squid that it's a reverse proxy
# 'defaultsite' sets the hostname that will be used if none is provided
# 'vhost' tells squid that it'll use name-based virtual hosting. I'm not
#   sure if this is actually needed.
# http_port 80 accel defaultsite=mirror.lowell.lan vhost
http_access allow all

acl Purge method PURGE
http_access allow localhost Purge
http_access deny Purge

# http_port 3128 accel
# http_port 127.0.0.1:3128 accel act-as-origin
http_port 0.0.0.0:3128 accel act-as-origin

reply_header_add X-Accel-Buffering no

# Create a disk-based cache of up to 25GB in size:
# (10000 is the size in MB. 16 and 256 seem to set how many subdirectories
#  are created, and are default values.)
cache_dir ufs /var/cache/squid 25000 16 256

# Use the LFUDA cache eviction policy -- Least Frequently Used, with
#  Dynamic Aging. http://www.squid-cache.org/Doc/config/cache_replacement_policy/
# It's more important to me to keep bigger files in cache than to keep
# more, smaller files -- I am optimizing for bandwidth savings, not latency.
cache_replacement_policy heap LFUDA

# Do unholy things with refresh_pattern.
# The top two are new lines, and probably aren't everything you would ever
# want to cache -- I don't account for VM images, .deb files, etc.
# They're cached for 129600 minutes, which is 90 days.
# refresh-ims and override-expire are described in the configuration here:
#  http://www.squid-cache.org/Doc/config/refresh_pattern/
# but basically, refresh-ims makes squid check with the backend server
# when someone does a conditional get, to be cautious.
# override-expire lets us override the specified expiry time. (This is
#  illegal per the RFC, but works for our specific purposes.)
# You will probably want to tune this part.
#
# refresh_pattern [-i]      regex    min percent max [options]
refresh_pattern -i  INDEX.tar.gz$      0 100%       1440 # For alpine linux
refresh_pattern -i          .rpm$ 129600 100%     129600 refresh-ims override-expire
refresh_pattern -i          .iso$ 43200  100%     43200  refresh-ims override-expire
refresh_pattern -i         .vbox$ 43200  100%     43200  refresh-ims override-expire
refresh_pattern -i          .deb$ 1440    20%       4320 refresh-ims override-expire
refresh_pattern -i  .pkg.tar.zst$ 129600 100%     129600 refresh-ims override-expire
refresh_pattern -i          .apk$ 1440   100%     1440   refresh-ims override-expire
refresh_pattern -i       .tar.xz$ 1440   100%     1440   refresh-ims override-expire
refresh_pattern -i       .tar.gz$ 1440   100%     1440   refresh-ims override-expire
refresh_pattern             ^ftp: 1440    20%      10080
refresh_pattern          ^gopher: 1440     0%       1440
refresh_pattern -i (/cgi-bin/|\?) 0        0%          0
refresh_pattern                 . 0       20%       4320

# This is OH SO IMPORTANT: squid defaults to not caching objects over
# 4MB, which may be a reasonable default, but is awful behavior on our
# pseudo-mirror. Let's make it 16GB:
maximum_object_size 16 GB

# ssl-bump bump all

# Now, let's set up several mirrors. These work sort of like Apache
# name-based virtual hosts -- you get different content depending on
# which hostname you use in your request, even on the same IP. This lets
# us mirror more than one distro on the same machine.

# cache_peer is used here to set an upstream origin server:
#   'mirror.us.as6453.net' is the hostname of the mirror I connect to.
#   'parent' tells squid that that this is a 'parent' server, not a peer
#    '80 0' sets the HTTP port (80) and ICP port (0)
#    'no-query' stops ICP queries, which should only be used between squid servers
#    'originserver' tells squid that this is a server that originates content,
#      not another squid server.
#    'name=as6453' tags it with a name we use on the next line.
# cache_peer_domain is used for virtual hosting.
#    'as6453' is the name we set on the previous line (for cache_peer)
#    subsequent words are virtual hostnames it answers to. (This particular
#     mirror has Fedora and Debian content mirrored.) These are the hostnames
#     you set up and will use to access content.
# Taken together, these two lines tell squid that, when it gets a request for
#  content on fedora-mirror.lowell.lan or debian-mirror.lowell.lan, it should
#  route the request to mirror.us.as6453.net and cache the result.
cache_peer mirror.dotsrc.org parent 80 0 no-query originserver name=dotsrc
# cache_peer mirror.dotsrc.org parent 443 0 no-query originserver ssl name=dotsrc
EOF

systemctl enable squid
