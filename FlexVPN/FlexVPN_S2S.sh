**************************************************************************************************
La siguiente práctica tiene como objetivo configurar FlexVPN Site to Site VPN en CSRV1k con IKEv2
by Fer Gutierrez
SageITraining - Certificarse hace la diferencia
***************************************************************************************************


=====================
Router 1
=====================
a. Define IKEv2 Proposal and Policy.
b. Configure a keyring and enter a Pre-Shared Key that is used to authenticate the peer.
c. Create an IKEv2 profile and assign the keyring.
Config t
!
Hostname R1
!
Int gi1
Ip address 192.168.0.10 255.255.255.0
No shut
!
crypto ikev2 proposal FLEXVPN_PROPOSAL
 encryption aes-cbc-256
 integrity sha256
 group 14
!
crypto ikev2 policy FLEXVPN_POLICY
 proposal FLEXVPN_PROPOSAL
!
crypto ikev2 keyring FLEXVPN_KEYRING
peer FLEVPNPeers
address 192.168.0.20
pre-shared-key local cisco123
pre-shared-key remote cisco123
!
crypto ikev2 profile FLEXVPN_PROFILE
match identity remote address 192.168.0.20
authentication remote pre-share
authentication local pre-share
keyring local FLEXVPN_KEYRING
lifetime 86400
dpd 10 2 on-demand
!
!d. Create a Transport Set and define the encryption and hash algorithms used to protect data.
!e. Create an IPsec profile.
!
crypto ipsec transform-set FLEXVPN_TRANSFORM esp-aes 256 esp-sha-hmac
 mode tunnel
!
crypto ipsec profile FLEXVPN_PROFILE
 set transform-set FLEXVPN_TRANSFORM
 set ikev2-profile FLEXVPN_PROFILE
!
!f. Configure the tunnel interface.
!
interface Tunnel0
ip address 10.1.120.10 255.255.255.0
tunnel source GigabitEthernet1
tunnel destination 192.168.0.20
tunnel protection ipsec profile FLEXVPN_PROFILE
!
!Configure dynamic routing to advertise the tunnel interface. After that, it can advertise other networks that must pass through the tunnel.
!
router eigrp 100
no auto-summary
network 10.1.120.0 0.0.0.255
!

=====================
Router 2
=====================
Config t
Hostname R2
Int gi1
Ip address 192.168.0.20 255.255.255.0
No shut
!
crypto ikev2 proposal FLEXVPN_PROPOSAL
 encryption aes-cbc-256
 integrity sha256
 group 14
!
crypto ikev2 policy FLEXVPN_POLICY
 proposal FLEXVPN_PROPOSAL
!
crypto ikev2 keyring FLEXVPN_KEYRING
peer FLEVPNPeers
address 192.168.0.10
pre-shared-key local cisco123
pre-shared-key remote cisco123
!
crypto ikev2 profile FLEXVPN_PROFILE
match identity remote address 192.168.0.10
authentication remote pre-share
authentication local pre-share
keyring local FLEXVPN_KEYRING
lifetime 86400
dpd 10 2 on-demand
!
!
crypto ipsec transform-set FLEXVPN_TRANSFORM esp-aes 256 esp-sha-hmac
 mode tunnel
!
crypto ipsec profile FLEXVPN_PROFILE
 set transform-set FLEXVPN_TRANSFORM
 set ikev2-profile FLEXVPN_PROFILE
!
!
interface Tunnel0
 ip address 10.1.120.20 255.255.255.0
 tunnel source GigabitEthernet1
 tunnel destination 192.168.0.10
 tunnel protection ipsec profile FLEXVPN_PROFILE
!
router eigrp 100
 no auto-summary
 network 10.1.120.0 0.0.0.255
!

*Apr 21 16:02:43.319: IKEv2-ERROR:Address type 2147516380 not supported