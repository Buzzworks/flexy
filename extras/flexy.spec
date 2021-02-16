#################################################################################
#
# Flexy spec file
# -----------------
#################################################################################
%define _includedir     /usr/share/flexy/include
%define _pluginsdir     /usr/share/flexy/plugins
%define _dbdir          /usr/share/flexy/db
%define _bindir         /usr/bin

Summary:                Security tool to audit systems running Linux, macOS, and Unix.
Name:                   flexy
Version:                3.0.3
Release:                100<RELEASE>%{?dist}
License:                GPL
Group:                  Applications/System
Source:                 flexy-%{version}.tar.gz
URL:                    https://buzzworks.com/
Vendor:                 Buzzworks Business Services Pvt Ltd
Packager:               Buzzworks Business Services Pvt Ltd <help@flexydial.com>
BuildArch:              noarch

%description
Flexy is an security auditing and hardening tool for UNIX derivatives like Linux, BSD
and Solaris. It performs an in-depth security scan on the system to detect software
and security issues. Besides information related to security, it will also scan for
general system information, installed packages, and possible
configuration issues.

This software is aimed at assisting with automated auditing, configuration management,
software patch management, penetration testing, vulnerability management, and malware
scanning of UNIX-based systems.

Flexy is released as a GPLv3 licensed project and free for everyone to use.
Commercial support and plugins are available via Buzzworks Business Services Pvt Ltd.

See https://buzzworks.com for a full description and documentation.

%prep
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf "$RPM_BUILD_ROOT"
mkdir -p $RPM_BUILD_ROOT

# Make directory with our name, instead of with version
%setup -n flexy
#%setup

#%patch

%build

%install
# Install profile
install -d ${RPM_BUILD_ROOT}/etc/flexy
install default.prf ${RPM_BUILD_ROOT}/etc/flexy
# Install binary
install -d ${RPM_BUILD_ROOT}/%{_bindir}
install flexy ${RPM_BUILD_ROOT}/%{_bindir}
# Install man page
install -d ${RPM_BUILD_ROOT}/%{_mandir}/man8
install flexy.8 ${RPM_BUILD_ROOT}/%{_mandir}/man8
# Install functions/includes
install -d ${RPM_BUILD_ROOT}%{_includedir}
install include/* ${RPM_BUILD_ROOT}%{_includedir}
# Install plugins
install -d ${RPM_BUILD_ROOT}%{_pluginsdir}
install plugins/README ${RPM_BUILD_ROOT}%{_pluginsdir}
# Install database files
install -d ${RPM_BUILD_ROOT}%{_dbdir}
install -d ${RPM_BUILD_ROOT}%{_dbdir}/languages
install db/*.db ${RPM_BUILD_ROOT}%{_dbdir}
install db/languages/* ${RPM_BUILD_ROOT}%{_dbdir}/languages

# Bash completion
mkdir -p ${RPM_BUILD_ROOT}/etc/bash_completion.d/
install -pm644 extras/bash_completion.d/flexy ${RPM_BUILD_ROOT}/etc/bash_completion.d/

install -D -p -m 0644 extras/systemd/flexy-clear.service ${RPM_BUILD_ROOT}%{_unitdir}/flexy-clear.service

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf "$RPM_BUILD_ROOT"

%files
%defattr(644,root,root,755)
# Binaries
%attr(755, root, root) %{_bindir}/flexy
# Documentation and flexy(8) man page
%doc %{_mandir}/man8/flexy.8.gz
# Default profile
/etc/flexy/default.prf
/etc/bash_completion.d/flexy
# Databases, functions, plugins
%{_dbdir}/*
%{_includedir}/*
%{_pluginsdir}/*
#%attr(644, root, root) %{_dbdir}/*
#%attr(644, root, root) %{_includedir}/*
#%attr(644, root, root) %{_plugindir}
#%attr(644, root, root) %{_plugindir}/*
%{_unitdir}/flexy-clear.service


%changelog
* Fri Feb 12 2021 Ganapathi Chidambaram - 3.0.3
- New release 3.0.3

# The End