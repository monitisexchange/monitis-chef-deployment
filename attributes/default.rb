#
# Cookbook Name:: monitis
# Attributes:: default
#
# Author:: 
#
# Copyright 2012, Monitis, Inc.


# default attributes for all platforms
default['MONITIS']['INSTALLDIR'] = "/usr/local"
default['MONITIS']['USEREMAIL'] = "youremail@address.com"
default['MONITIS']['AGENTNAME'] = node[:hostname]

default['MONITIS']['TARBALL_32'] = "MonitisLinuxAgent-32bit.tar.gz"
default['MONITIS']['TARBALL_64'] = "MonitisLinuxAgent-64bit.tar.gz"
default['MONITIS']['TARBALL_URL_32'] = "http://dashboard.monitis.com/downloader?type=internalAgent&platform=linux32"
default['MONITIS']['TARBALL_URL_64'] = "http://dashboard.monitis.com/downloader?type=internalAgent&platform=linux64"

# overrides on a platform-by-platform basis
case platform
when "debian","ubuntu"

default['MONITIS']['LIBSSL'] = "openssl"

when "redhat","centos","fedora"
default['MONITIS']['LIBSSL'] = "openssl-devel"

when "suse"

default['MONITIS']['LIBSSL'] = "libopenssl1_0_0"

when "windows"

default['MONITIS']['TARBALL'] = "MonitisWindowsAgent-32-64bit.zip"
default['MONITIS']['TARBALL_URL'] = "http://dashboard.monitis.com/downloader?type=internalAgent&platform=win64"

end
