********************************************************************************************
La siguiente práctica tiene como objetivo configurar FlexVPN Hub to Spoke Routers CSRV1k con IKEv2
by Fer Gutierrez
SageITraining - Certificarse hace la diferencia
********************************************************************************************



======================
Routers configuration:
======================
-----------------
Hub:
-----------------
config t
hostname HUB
!
interface GigabitEthernet1
ip address 10.10.30.1 255.255.255.0
no shut
!
interface loopback0
ip address 3.3.3.3 255.255.255.0
no shut
!
interface loopback33
ip address 33.33.33.33 255.255.255.0
no shut
!
router eigrp 2
network 10.10.30.0 0.0.0.255
network 3.3.3.3 0.0.0.0
network 33.33.33.33 0.0.0.0
no auto-summary
!no ip split-horizon eigrp 2
!

=======
FlexVPN
========
int virtual-template 3 type tunnel
!mode gre ip
crypto ikev2 keyring IKEV2-KEYRING 
peer R1
address 10.10.10.1
pre-shared-key local SageIT
pre-shared-key remote SageIT
peer R2
address 10.10.20.1
pre-shared-key local SageIT
pre-shared-key remote SageIT
exit
exit
crypto ikev2 profile PRO
match identity remote address 10.10.10.1
match identity remote address 10.10.20.1
identity local address 10.10.30.1
authentication local pre-share
authentication remote pre-share
keyring local IKEV2-KEYRING
virtual-template 3
exit
crypto ipsec transform-set TSET esp-aes 256 esp-sha-hmac
exit
crypto ipsec profile IPSECPRO
set transform-set TSET
set ikev2-profile PRO
exit
!
int virtual-template 3 type tunnel
tunnel protection ipsec profile IPSECPRO
ip unnumbered loopback 0
tunnel source 10.10.30.1
!


show running-config | section crypto




-----------------
ISP:
-----------------
config t
hostname ISP
!
interface GigabitEthernet1
ip address 10.10.30.2 255.255.255.0
no shut
!
interface GigabitEthernet2
ip address 10.10.10.2 255.255.255.0
no shut
!
interface GigabitEthernet3
ip address 10.10.20.2 255.255.255.0
no shut
!
router eigrp 2
network 10.10.10.0 0.0.0.255
network 10.10.20.0 0.0.0.255
network 10.10.30.0 0.0.0.255
no auto-summary
!

 -----------------
R1
-----------------
config t
hostname R1
!
interface GigabitEthernet2
ip address 10.10.10.1 255.255.255.0
no shut
!
int loopback0
ip address 1.1.1.1 255.255.255.0
no shut
int loopback2
ip address 22.22.22.22 255.255.255.0
no shut
!
router eigrp 2
network 10.10.10.0 0.0.0.255
network 1.1.1.1 0.0.0.0
network 22.22.22.22 0.0.0.0
no auto-summary
!
crypto ikev2 keyring IKEV2-KEYRING
peer HUB
address 10.10.30.1
pre-shared-key local SageIT
pre-shared-key remote SageIT
!
crypto ikev2 profile PRO
match identity remote address 10.10.30.1 255.255.255.255 
identity local address 10.10.10.1
authentication remote pre-share
authentication local pre-share
keyring local IKEV2-KEYRING
!
crypto ipsec transform-set TSET esp-aes 256 esp-sha-hmac 
mode tunnel
crypto ipsec profile IPSECPRO
set transform-set TSET 
set ikev2-profile PRO
!
int tunnel 2
tunnel source 10.10.10.1
tunnel destination 10.10.30.1
ip unnumbered loopback0
tunnel protection ipsec profile IPSECPRO





 -----------------
R2
-----------------
config t
hostname R2
!
interface GigabitEthernet3
ip address 10.10.20.1 255.255.255.0
no shut
!
interface loopback0
ip address 4.4.4.4 255.255.255.0
no shut
!
interface loopback3
ip address 33.33.33.33 255.255.255.0
no shut
!
router eigrp 2
network 10.10.20.0 0.0.0.255
network 4.4.4.4 0.0.0.0
network 33.33.33.33 0.0.0.0
no auto-summary
!
crypto ikev2 keyring IKEV2-KEYRING
peer HUB
address 10.10.30.1
pre-shared-key local SageIT
pre-shared-key remote SageIT
!
crypto ikev2 profile PRO
match identity remote address 10.10.30.1 255.255.255.255 
identity local address 10.10.20.1
authentication remote pre-share
authentication local pre-share
keyring local IKEV2-KEYRING
!
crypto ipsec transform-set TSET esp-aes 256 esp-sha-hmac 
mode tunnel
crypto ipsec profile IPSECPRO
set transform-set TSET 
set ikev2-profile PRO
!
int tunnel 2
tunnel source 10.10.20.1
tunnel destination 10.10.30.1
ip unnumbered loopback0
tunnel protection ipsec profile IPSECPRO


show commands:

show crypto ikev2 sa
show crypto ipsec sa

verification 
Ping from R2 to 22.22.22.22
traceroute from R2 to 22.22.22.2