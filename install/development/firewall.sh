#!/bin/bash

# ufw: nothing in, everything out, plus the interfaces this desktop always has.
#
# Rules only, no LAN subnet. "Allow 192.168.1.0/24" is one home network; on a
# laptop it opens every port to any cafe Wi-Fi that hands out the same range.
# Trusted networks are added by hand on the machine that has them.
#
# Docker is NOT protected here: a port published with -p 8080:80 goes through
# FORWARD, past every rule below, and is open to the whole network ufw or not.
# Publish to 127.0.0.1:8080:80 instead. ufw-docker / DOCKER-USER was left out on
# purpose -- almost nothing runs in Docker on these machines.

sudo xbps-install -y ufw

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed

# lo needs no rule: ufw's before.rules already accept it.

# mihomo's TUN. Added unconditionally: a rule for an interface that does not
# exist yet is accepted and simply matches nothing.
sudo ufw allow in on Meta comment 'mihomo tun'

# Containers talking to the host (DNS, a service on the host). Only the default
# bridge: compose networks get their own br-* interfaces and are not covered.
sudo ufw allow in on docker0 comment 'docker bridge'

# Yggdrasil is a public mesh -- anyone on it can reach this machine. Default
# deny already drops it; the rule is here so the intent is visible in
# "ufw status". IPv6 only, because Yggdrasil carries nothing else: a plain
# "deny in on ygg0" also adds a useless IPv4 copy, and "proto ipv6" is not
# IPv6 at all but protocol 41 (6in4 tunnels) inside IPv4.
sudo ufw deny in on ygg0 from ::/0 comment 'yggdrasil is public'

# Without this an install over SSH would cut itself off the moment ufw comes up.
if [[ -e /etc/runit/runsvdir/default/sshd ]]; then
  sudo ufw allow 22/tcp comment 'sshd'
fi

# "ufw enable" loads the rules into the kernel, and in a chroot that kernel is
# the live system's -- it would firewall the machine running the install, not
# the one being installed. There only the flag is set; ufw-init reads it at
# boot. On a running system enable for real, so it takes effect now.
if [[ -n ${OMVOID_IN_CHROOT:-} ]]; then
  sudo sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
else
  sudo ufw --force enable
fi

omvoid-service-enable ufw
