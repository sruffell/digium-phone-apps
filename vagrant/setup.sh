#!/bin/bash
set -e
cd /vagrant/vagrant

DPMA_ARCHIVE_FILE=res_digium_phone-12.0_2.0.0-x86_32.tar.gz
PHONE_FIRMWARE_ARCHIVE_FILE=firmware_1_4_2_0_package.tar.gz
REGISTER_UTILITY=http://downloads.digium.com/pub/register/x86-32/register
ASTHOSTID_UTILITY=http://downloads.digium.com/pub/register/x86-32/asthostid

#############################################################################
# Install Asterisk from the repositories
#############################################################################
yum install -y dnsmasq avahi avahi-devel
yum localinstall -y http://packages.asterisk.org/centos/6/current/i386/RPMS/asterisknow-version-3.0.1-2_centos6.noarch.rpm
sudo yum install -y asterisk asterisk-configs --enablerepo=asterisk-12
yum update -y

#############################################################################
# Now install DPMA for this version of Asterisk
#############################################################################
if [ ! -e ${DPMA_ARCHIVE_FILE} ]; then
	wget "http://downloads.digium.com/pub/telephony/res_digium_phone/asterisk-12.0/x86-32/${DPMA_ARCHIVE_FILE}"
fi
tar xfz ${DPMA_ARCHIVE_FILE}
DPMA_ARCHIVE_DIR=$(echo ${DPMA_ARCHIVE_FILE} | sed -n -e "s/\(.*\)\.tar\.gz/\1/p")
cp -f ${DPMA_ARCHIVE_DIR}/*.so /usr/lib/asterisk/modules/
cp -f ${DPMA_ARCHIVE_DIR}/res_digium_phone.conf.sample /etc/asterisk/res_digium_phone.conf

#############################################################################
# Install and register DPMA
#############################################################################
if [ ! -e register ]; then
	wget "http://downloads.digium.com/pub/register/x86-32/register"
	chmod +x register
fi

if [ ! -e asthostid ]; then
	wget "http://downloads.digium.com/pub/register/x86-32/asthostid"
	chmod +x asthostid
fi

#############################################################################
# Now grab the phone firmware
#############################################################################
if [ ! -e ${PHONE_FIRMWARE_ARCHIVE_FILE} ]; then
	wget "http://downloads.digium.com/pub/telephony/res_digium_phone/firmware/${PHONE_FIRMWARE_ARCHIVE_FILE}" || exit 1
fi
tar xfz ${PHONE_FIRMWARE_ARCHIVE_FILE}
PHONE_ACHIVE_DIR=$(echo ${PHONE_FIRMWARE_ARCHIVE_FILE} | sed -n -e "s/\(.*\)\.tar\.gz/\1/p")

set +e

ls /var/lib/asterisk/licenses/ | grep -e "^DPMA.*\.lic" -q 
if [ $? -ne 0 ]; then
	echo "You do not have any license files installed in this machine. As the root user on the virtual machine, please run /vagrant/vagrant/register"
fi
