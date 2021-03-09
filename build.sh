#!/bin/bash

set -eu

rm -rf openwrt
git clone https://github.com/coolsnowwolf/lede.git openwrt

# customize patches
pushd openwrt
git show -s --format=%h
git am -3 ../patches/*.patch
popd

# add scripts
pushd openwrt
mv ../scripts/check_wan_connect.sh package/base-files/files/etc
chmod +x package/base-files/files/etc/check_wan_connect.sh
sed -i '/exit 0/i\if [[ "$(cat /etc/crontabs/root | grep "/etc/check_wan_connect.sh")" = "" ]]; then echo "#*/15 * * * * /etc/check_wan_connect.sh" >> /etc/crontabs/root; fi' package/lean/default-settings/files/zzz-default-settings
popd

# addition packages
pushd openwrt/package
# luci-theme-argon
rm -rf lean/luci-theme-argon
git clone --depth 1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git lean/luci-theme-argon
sed -i '/uci commit luci/i\uci set luci.main.mediaurlbase="/luci-static/argon"' lean/default-settings/files/zzz-default-settings
# luci-app-argon-config
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git
# luci-app-filebrowser
svn co https://github.com/immortalwrt/openwrt/trunk/package/ctcgfw/luci-app-filebrowser lean/luci-app-filebrowser
svn co https://github.com/immortalwrt/openwrt/trunk/package/ctcgfw/filebrowser lean/filebrowser
# luci-app-oled
git clone --depth 1 https://github.com/NateLol/luci-app-oled.git lean/luci-app-oled
sed -i "s/option enable '0'/option enable '1'/g" lean/luci-app-oled/root/etc/config/oled
# luci-app-openclash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash.git
CPU_MODEL=armv8
mv OpenClash/luci-app-openclash lean
echo '
config openclash 'config'
  option proxy_port '7892'
  option update '0'
  option auto_update '0'
  option auto_update_time '0'
  option cn_port '9090'
  option enable_redirect_dns '1'
  option dns_advanced_setting '1'
  option servers_if_update '0'
  option servers_update '0'
  option log_level 'silent'
  option lan_ac_mode '0'
  option config_path '/etc/openclash/config/config.yaml'
  option core_version 'linux-${CPU_MODEL}'
  option enable_rule_proxy '1'
  option intranet_allowed '1'
  option http_port '7890'
  option socks_port '7891'
  option enable_custom_dns '1'
  option disable_masq_cache '1'
  option enable_custom_clash_rules '0'
  option other_rule_auto_update '1'
  option other_rule_update_week_time '*'
  option other_rule_update_day_time '2'
  option geo_auto_update '1'
  option geo_update_week_time '*'
  option geo_update_day_time '3'
  option auto_restart '1'
  option auto_restart_week_time '*'
  option auto_restart_day_time '5'
  option dns_port '7874'
  option create_config '1'
  option redirect_dns '1'
  option masq_cache '1'
  option operation_mode 'redir-host'
  option en_mode 'redir-host'
  option dns_revert '0'
  option proxy_mode 'rule'
  option dashboard_password 'openwrt'
  option rule_sources 'ConnersHua'
  option rule_source '1'
  option GlobalTV 'GlobalTV'
  option AsianTV 'AsianTV'
  option Proxy 'Proxy'
  option Domestic 'Domestic'
  option Others 'Others'
  option china_ip_route '1'
  option mix_proxies '0'
	option ipv6_enable '0'
	option chnr_auto_update '1'
	option chnr_update_week_time '*'
	option chnr_update_day_time '4'
	option restricted_mode '0'
	option small_flash_memory '0'
	option enable_udp_proxy '0'
	option enable '1'
	option config_reload '1'
	option common_ports '1'
	option interface_name '0'
	option mixed_port '7893'
	option geo_custom_url 'https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb'
	option chnr_custom_url 'https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/CN-ip-cidr.txt'
	option custom_domain_dns_server '127.0.0.1#6053'

config dns_servers
  option type 'udp'
  option ip '8.8.8.8'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option type 'udp'
  option ip '8.8.4.4'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option type 'udp'
  option ip '1.1.1.1'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip '1.0.0.1'
  option type 'udp'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option type 'udp'
  option ip '4.2.2.1'
  option enabled '0'
  option group 'fallback'

config dns_servers
  option type 'udp'
  option ip '4.2.2.2'
  option enabled '0'
  option group 'fallback'

config dns_servers
  option type 'udp'
  option ip '119.29.29.29'
  option enabled '0'

config dns_servers
  option type 'udp'
  option ip '119.28.28.28'
  option enabled '0'

config dns_servers
  option type 'udp'
  option ip '223.5.5.5'
  option enabled '0'

config dns_servers
  option type 'udp'
  option enabled '0'
  option ip '223.6.6.6'

config dns_servers
  option ip '8.8.8.8'
  option type 'tcp'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip '8.8.4.4'
  option type 'tcp'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip '1.1.1.1'
  option type 'tcp'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip '1.0.0.1'
  option type 'tcp'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip '4.2.2.1'
  option type 'tcp'
  option enabled '0'
  option group 'fallback'

config dns_servers
  option ip '4.2.2.2'
  option enabled '0'
  option type 'tcp'
  option group 'fallback'

config dns_servers
  option enabled '0'
  option ip '119.29.29.29'
  option type 'tcp'

config dns_servers
  option enabled '0'
  option ip '119.28.28.28'
  option type 'tcp'

config dns_servers
  option enabled '0'
  option ip '223.5.5.5'
  option type 'tcp'

config dns_servers
  option enabled '0'
  option ip '223.6.6.6'
  option type 'tcp'

config dns_servers
  option ip '8.8.8.8'
  option type 'tls'
	option port '853'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip '8.8.4.4'
  option type 'tls'
	option port '853'
  option enabled '0'
  option group 'fallback'

config dns_servers
  option ip '1.1.1.1'
  option type 'tls'
	option port '853'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip '1.0.0.1'
  option type 'tls'
	option port '853'
  option enabled '0'
  option group 'fallback'

config dns_servers
  option ip 'dns.pub'
	option port '853'
  option type 'tls'
  option enabled '0'

config dns_servers
  option enabled '0'
  option ip 'doh.pub'
	option port '853'
  option type 'tls'

config dns_servers
  option ip '223.5.5.5'
  option type 'tls'
	option port '853'
  option enabled '0'

config dns_servers
  option enabled '0'
  option ip '223.6.6.6'
	option port '853'
  option type 'tls'

config dns_servers
  option ip 'https://1.1.1.1/dns-query'
  option type 'https'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip 'https://8.8.8.8/dns-query'
  option type 'https'
  option group 'fallback'
  option enabled '0'

config dns_servers
  option ip 'https://doh.pub/dns-query'
  option type 'https'
  option enabled '0'

config dns_servers
  option ip 'https://223.5.5.5/dns-query'
  option type 'https'
  option enabled '0'

config dns_servers
  option enabled '1'
  option group 'nameserver'
  option ip '127.0.0.1'
  option port '6053'
  option type 'tcp'

config dns_servers
  option enabled '1'
  option ip '127.0.0.1'
  option port '7053'
  option group 'fallback'
  option type 'tcp'
' >lean/luci-app-openclash/root/etc/config/openclash
mkdir -p base-files/files/etc/openclash/core
curl -L https://github.com/vernesong/OpenClash/releases/download/TUN/clash-linux-${CPU_MODEL}.tar.gz | tar zxf -
mv clash base-files/files/etc/openclash/core/clash_game
chmod +x base-files/files/etc/openclash/core/clash_game
curl -L https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-${CPU_MODEL}.tar.gz | tar zxf -
mv clash base-files/files/etc/openclash/core/clash
chmod +x base-files/files/etc/openclash/core/clash
OPENCLASH_TUN_VERSION=$(sed -n '2p' OpenClash/core_version)
curl -OL https://github.com/vernesong/OpenClash/releases/download/TUN-Premium/clash-linux-${CPU_MODEL}-${OPENCLASH_TUN_VERSION}.gz
gzip -d clash-linux-${CPU_MODEL}-${OPENCLASH_TUN_VERSION}.gz
mv clash-linux-${CPU_MODEL}-${OPENCLASH_TUN_VERSION} base-files/files/etc/openclash/core/clash_tun
chmod +x base-files/files/etc/openclash/core/clash_tun
rm -rf OpenClash
# luci-app-smartdns
git clone --depth 1 https://github.com/pymumu/smartdns.git smartdns
echo '
config smartdns
  option server_name 'smartdns'
  option port '6053'
  option ipv6_server '0'
  option dualstack_ip_selection '0'
  option prefetch_domain '1'
  option serve_expired '1'
  option redirect 'none'
  option cache_size '20000'
  option rr_ttl '3600'
  option rr_ttl_min '5'
  option seconddns_port '7053'
  option seconddns_no_rule_addr '0'
  option seconddns_no_rule_nameserver '0'
  option seconddns_no_rule_ipset '0'
  option seconddns_no_rule_soa '0'
  option coredump '0'
  option enabled '1'
  option seconddns_enabled '1'
  option seconddns_no_dualstack_selection '1'
  option force_aaaa_soa '1'
  option seconddns_server_group 'foreign'
  option tcp_server '1'
  option seconddns_tcp_server '1'
  option seconddns_no_cache '1'
  option seconddns_no_speed_check '1'

config server
  option type 'udp'
  option ip '8.8.8.8'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option type 'udp'
  option ip '8.8.4.4'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option type 'udp'
  option ip '1.1.1.1'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option ip '1.0.0.1'
  option type 'udp'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option type 'udp'
  option ip '4.2.2.1'
  option enabled '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'

config server
  option type 'udp'
  option ip '4.2.2.2'
  option enabled '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'

config server
  option type 'udp'
  option ip '119.29.29.29'
  option enabled '0'

config server
  option type 'udp'
  option ip '119.28.28.28'
  option enabled '0'

config server
  option type 'udp'
  option ip '223.5.5.5'
  option enabled '0'

config server
  option type 'udp'
  option enabled '0'
  option ip '223.6.6.6'

config server
  option ip '8.8.8.8'
  option type 'tcp'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option ip '8.8.4.4'
  option type 'tcp'
  option blacklist_ip '0'
  option server_group 'foreign'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option ip '1.1.1.1'
  option type 'tcp'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option ip '1.0.0.1'
  option type 'tcp'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'
  option enabled '0'

config server
  option ip '4.2.2.1'
  option type 'tcp'
  option enabled '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'

config server
  option ip '4.2.2.2'
  option enabled '0'
  option type 'tcp'
  option server_group 'foreign'
  option blacklist_ip '0'
  option addition_arg '-exclude-default-group'

config server
  option enabled '0'
  option ip '119.29.29.29'
  option type 'tcp'

config server
  option enabled '0'
  option ip '119.28.28.28'
  option type 'tcp'

config server
  option enabled '0'
  option ip '223.5.5.5'
  option type 'tcp'

config server
  option enabled '0'
  option ip '223.6.6.6'
  option type 'tcp'

config server
  option ip '8.8.8.8'
  option type 'tls'
  option no_check_certificate '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option host_name 'dns.google'
  option addition_arg '-exclude-default-group'
  option enabled '1'

config server
  option ip '8.8.4.4'
  option type 'tls'
  option enabled '0'
  option no_check_certificate '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option host_name 'dns.google'
  option addition_arg '-exclude-default-group'

config server
  option ip '1.1.1.1'
  option type 'tls'
  option no_check_certificate '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option host_name '1dot1dot1dot1.cloudflare-dns.com'
  option addition_arg '-exclude-default-group'
  option enabled '1'

config server
  option ip '1.0.0.1'
  option type 'tls'
  option enabled '0'
  option no_check_certificate '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option host_name '1dot1dot1dot1.cloudflare-dns.com'
  option addition_arg '-exclude-default-group'

config server
  option ip 'dns.pub'
  option type 'tls'
  option no_check_certificate '0'
  option enabled '1'

config server
  option enabled '0'
  option ip 'doh.pub'
  option type 'tls'
  option no_check_certificate '0'

config server
  option ip '223.5.5.5'
  option type 'tls'
  option no_check_certificate '0'
  option enabled '1'
  option host_name 'dns.alidns.com'

config server
  option enabled '0'
  option ip '223.6.6.6'
  option type 'tls'
  option no_check_certificate '0'
  option host_name 'dns.alidns.com'

config server
  option ip 'https://1.1.1.1/dns-query'
  option type 'https'
  option no_check_certificate '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option host_name '1dot1dot1dot1.cloudflare-dns.com'
  option http_host '1dot1dot1dot1.cloudflare-dns.com'
  option addition_arg '-exclude-default-group'
  option enabled '1'

config server
  option ip 'https://8.8.8.8/dns-query'
  option type 'https'
  option no_check_certificate '0'
  option server_group 'foreign'
  option blacklist_ip '0'
  option host_name 'dns.google'
  option http_host 'dns.google'
  option addition_arg '-exclude-default-group'
  option enabled '1'

config server
  option ip 'https://doh.pub/dns-query'
  option type 'https'
  option no_check_certificate '0'
  option enabled '1'

config server
  option ip 'https://223.5.5.5/dns-query'
  option type 'https'
  option no_check_certificate '0'
  option enabled '1'
  option host_name 'dns.alidns.com'
  option http_host 'dns.alidns.com'
' >smartdns/package/openwrt/files/etc/config/smartdns
echo '

speed-check-mode tcp:80,ping
' >>smartdns/package/openwrt/custom.conf
svn co https://github.com/immortalwrt/openwrt/trunk/package/ntlf9t/luci-app-smartdns lean/luci-app-smartdns
svn co https://github.com/immortalwrt/packages/branches/openwrt-18.06/net/smartdns lean/smartdns
cat smartdns/package/openwrt/files/etc/config/smartdns >lean/smartdns/conf/smartdns.conf
cat smartdns/package/openwrt/custom.conf >lean/smartdns/conf/custom.conf
rm -rf smartdns
#luci-app-freq
rm -rf lean/luci-app-cpufreq
svn co https://github.com/immortalwrt/openwrt/trunk/package/lean/luci-app-cpufreq lean/luci-app-cpufreq
sed -i "s/option governor ''/option governor 'schedutil'/g" lean/luci-app-cpufreq/root/etc/config/cpufreq
sed -i "s/option minfreq ''/option minfreq '816000'/g" lean/luci-app-cpufreq/root/etc/config/cpufreq
sed -i "s/option maxfreq ''/option maxfreq '1608000000'/g" lean/luci-app-cpufreq/root/etc/config/cpufreq
# zerotier
svn co https://github.com/immortalwrt/packages/branches/openwrt-18.06/net/zerotier lean/zerotier
popd

# initialize feeds
p_list=$(ls -l patches | grep ^d | awk '{print $NF}')
pushd openwrt
# clone feeds
./scripts/feeds update -a
# patching
pushd feeds
for p in $p_list ; do
  [ -d $p ] && {
    pushd $p
    git am -3 ../../../patches/$p/*.patch
    popd
  }
done
popd
popd

#install packages
pushd openwrt
./scripts/feeds install -a
popd

# customize configs
pushd openwrt
cat ../config.seed > .config
make defconfig
popd

# build openwrt
pushd openwrt
make download -j8
make -j$(($(nproc) + 1)) || make -j1 V=s
popd

# package output files
archive_tag=OpenWrt_$(date +%Y%m%d)_NanoPi-R2S
pushd openwrt/bin/targets/*/*
# repack openwrt*.img.gz
set +e
gunzip openwrt*.img.gz
set -e
gzip openwrt*.img
sha256sum -b $(ls -l | grep ^- | awk '{print $NF}' | grep -v sha256sums) >sha256sums
tar zcf $archive_tag.tar.gz $(ls -l | grep ^- | awk '{print $NF}')
popd
mv openwrt/bin/targets/*/*/$archive_tag.tar.gz .
