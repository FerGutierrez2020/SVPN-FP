********************************************************************************************
La siguiente práctica tiene como objetivo configurar DMVPN con IPSEC Phase 2 usando routers CSRv1k 
by Fer Gutierrez
SageITraining - Certificarse hace la diferencia
********************************************************************************************

=============
Configuration
=============

-------------
Hub
------------

!The ISAKMP policy
Config t
Hostname Hub
crypto isakmp policy 10
hash md5
authentication pre-share
! A dynamic ISAKMP key and IPsec profile
crypto isakmp key cisco123 address 0.0.0.0 0.0.0.0
crypto ipsec transform-set strong esp-3des esp-md5-hmac 
crypto ipsec profile cisco
set security-association lifetime seconds 900
set transform-set strong 
!
! The tunnel interface with NHRP
interface Tunnel0
ip address 192.168.1.1 255.255.255.0
no ip redirects
ip mtu 1440
ip nhrp authentication cisco123
ip nhrp map multicast dynamic
ip nhrp network-id 1
no ip split-horizon eigrp 90
no ip next-hop-self eigrp 90
tunnel source GigabitEthernet1
tunnel mode gre multipoint
! This line must match on all nodes that want to use this mGRE tunnel.
tunnel key 0
tunnel protection ipsec profile cisco
!
interface GigabitEthernet1
ip address 209.168.202.225 255.255.255.0
no shut
!
interface GigabitEthernet2
ip address 1.1.1.1 255.255.255.0
no shut
!
router eigrp 90
network 1.1.1.0 0.0.0.255
network 192.168.1.0
no auto-summary
!
!ip route 0.0.0.0 0.0.0.0 209.168.202.226
!


-------------
Londres
------------

Spoke 1:
Config t
!
Hostname Londres
crypto isakmp policy 10
hash md5
authentication pre-share
crypto isakmp key cisco123 address 0.0.0.0 0.0.0.0
crypto ipsec transform-set strong esp-3des esp-md5-hmac 
crypto ipsec profile cisco
set security-association lifetime seconds 900
set transform-set strong 
!
interface Tunnel0
ip address 192.168.1.2 255.255.255.0
no ip redirects
ip mtu 1440
ip nhrp authentication cisco123
ip nhrp map multicast dynamic
ip nhrp map 192.168.1.1 209.168.202.225
ip nhrp map multicast 209.168.202.225
ip nhrp network-id 1
! Configures the hub router as the NHRP next-hop server.
ip nhrp nhs 192.168.1.1
tunnel source GigabitEthernet1
tunnel mode gre multipoint
tunnel key 0
tunnel protection ipsec profile cisco
!
interface GigabitEthernet1
ip address 209.168.202.131 255.255.255.0
no shut
!
interface GigabitEthernet2
ip address 2.2.2.2 255.255.255.0
no shut
!
router eigrp 90
network 2.2.2.0 0.0.0.255
network 192.168.1.0
no auto-summary
!
ip route 3.3.3.0 255.255.255.0 Tunnel0
!
!ip http server
!ip route 0.0.0.0 0.0.0.0 209.168.202.225



-------------
Tokio
------------
Spoke 2:
Config t
!
Hostname Tokio
crypto isakmp policy 10
hash md5
authentication pre-share
crypto isakmp key cisco123 address 0.0.0.0 0.0.0.0
crypto ipsec transform-set strong esp-3des esp-md5-hmac 
crypto ipsec profile cisco
set security-association lifetime seconds 900
set transform-set strong 
!
interface Tunnel0
ip address 192.168.1.3 255.255.255.0
no ip redirects
ip mtu 1440
ip nhrp authentication cisco123
ip nhrp map multicast dynamic
ip nhrp map 192.168.1.1 209.168.202.225
ip nhrp map multicast 209.168.202.225
ip nhrp network-id 1
! Configures the hub router as the NHRP next-hop server.
ip nhrp nhs 192.168.1.1
tunnel source GigabitEthernet1
tunnel mode gre multipoint
tunnel key 0
tunnel protection ipsec profile cisco
!
interface GigabitEthernet1
ip address 209.168.202.130 255.255.255.0
no shut
!
interface GigabitEthernet2
ip address 3.3.3.3 255.255.255.0
no shut
!
router eigrp 90
network 3.3.3.0 0.0.0.255
network 192.168.1.0
no auto-summary
!
ip route 2.2.2.0 255.255.255.0 Tunnel0
!
!ip http server
!ip route 0.0.0.0 0.0.0.0 209.168.202.225
!



=============
Show Commands
=============

show crypto ipsec sa—Displays the stats on the active tunnels.
show crypto isakmp sa—Displays the state for the ISAKMP SA.
Show ip eigrp ne
show dmvpn 
show nhrp stats
show ip nhrp 
show crypto session detail
show ip nhrp nhs detail


=============
Verification
=============

NHRP Debugs

1.	debug nhrp 
2.  Logging Console
3.	Ping to 2.2.2.2 (Londres) from Tokio





Hub#show ip nhrp nhs detail 
Hub#
Hub#
Hub#
Hub#
*Jun 22 19:09:23.207: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:09:23.208: NHRP: Tunnels gave us pak src addr: 209.168.202.131
*Jun 22 19:09:23.208: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:09:23.208: NHRP: NHRP subblock already exists for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:09:23.208: NHRP: Peer capability:0
*Jun 22 19:09:23.208: NHRP: Cache already has a subblock node attached for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:09:23.208: NHRP: nhrp_subblock_check_for_map() - Map Already Exists
*Jun 22 19:09:23.208: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.2 nbma 209.168.202.131 code: no error(0)
*Jun 22 19:09:23.208: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.2
*Jun 22 19:09:23.208: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:09:23.208:       src: 192.168.1.1, dst: 192.168.1.2
*Jun 22 19:09:23.208: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.131
*Jun 22 19:09:23.209: NHRP: 156 bytes out Tunnel0 
*Jun 22 19:09:27.669: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:09:27.669: NHRP: Tunnels gave us pak src addr: 209.168.202.130
*Jun 22 19:09:27.669: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:09:27.672: NHRP: Successfully attached NHRP subblock for Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:09:27.673: NHRP: Peer capability:0
*Jun 22 19:09:27.673: NHRP-EVE: NHC-UP: 192.168.1.3, NBMA: 209.168.202.130
*Jun 22 19:09:27.673: NHRP: Enqueued dynamic mapping to end of list
*Jun 22 19:09:27.673: NHRP: Tu0: Creating dynamic multicast mapping  NBMA: 209.168.202.130
*Jun 22 19:09:27.673: NHRP: Added dynamic multicast mapping for NBMA: 209.168.202.130
*Jun 22 19:09:27.673: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.3 nbma 209.168.202.130 code: no error(0)
*Jun 22 19:09:27.673: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.3
*Jun 22 19:09:27.673: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:09:27.673:       src: 192.168.1.1, dst: 192.168.1.3
*Jun 22 19:09:27.673: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.130
*Jun 22 19:09:27.673: NHRP: 156 bytes out Tunnel0 
*Jun 22 19:09:29.762: %DUAL-5-NBRCHANGE: EIGRP-IPv4 90: Neighbor 192.168.1.3 (Tunnel0) is up: new adjacency
Hub#
Hub#
Hub#
Hub#show dmvpn              
Legend: Attrb --> S - Static, D - Dynamic, I - Incomplete
        N - NATed, L - Local, X - No Socket
        T1 - Route Installed, T2 - Nexthop-override, B - BGP
        C - CTS Capable, I2 - Temporary
        # Ent --> Number of NHRP entries with same NBMA peer
        NHS Status: E --> Expecting Replies, R --> Responding, W --> Waiting
        UpDn Time --> Up or Down Time for a Tunnel
==========================================================================

Interface: Tunnel0, IPv4 NHRP Details 
Type:Hub, NHRP Peers:2, 

 # Ent  Peer NBMA Addr Peer Tunnel Add State  UpDn Tm Attrb
 ----- --------------- --------------- ----- -------- -----
     1 209.168.202.131     192.168.1.2    UP 00:07:52     D
     1 209.168.202.130     192.168.1.3    UP 00:01:15     D

Hub#
*Jun 22 19:11:56.219: NHRP: Receive Resolution Request via Tunnel0 vrf: global(0x0), packet size: 88
*Jun 22 19:11:56.219: NHRP: Route lookup for destination 2.2.2.2 in vrf: global(0x0) yielded interface Tunnel0, prefixlen 24
*Jun 22 19:11:56.219: NHRP: Route lookup for 2.2.2.2 in vrf: global(0x0) yielded nexthop 192.168.1.2 interface Tunnel0
*Jun 22 19:11:56.219: NHRP: Cache lookup for nexthop 192.168.1.2 on Tunnel0 returned nbma 209.168.202.131
*Jun 22 19:11:56.219: NHRP: Forwarding request due to authoritative request.
*Jun 22 19:11:56.219: NHRP: Attempting to forward to destination: 2.2.2.2 vrf: global(0x0)
*Jun 22 19:11:56.219: NHRP: Forwarding: NHRP SAS picked source: 192.168.1.1 for destination: 2.2.2.2
*Jun 22 19:11:56.219: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 2.2.2.2
*Jun 22 19:11:56.219: NHRP: Forwarding Resolution Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:11:56.219:       src: 192.168.1.1, dst: 2.2.2.2
*Jun 22 19:11:56.220: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.131
*Jun 22 19:11:56.220: NHRP: 136 bytes out Tunnel0 
*Jun 22 19:11:58.057: NHRP: Receive Resolution Request via Tunnel0 vrf: global(0x0), packet size: 88
*Jun 22 19:11:58.057: NHRP: Route lookup for destination 2.2.2.2 in vrf: global(0x0) yielded interface Tunnel0, prefixlen 24
*Jun 22 19:11:58.057: NHRP: Route lookup for 2.2.2.2 in vrf: global(0x0) yielded nexthop 192.168.1.2 interface Tunnel0
*Jun 22 19:11:58.057: NHRP: Cache lookup for nexthop 192.168.1.2 on Tunnel0 returned nbma 209.168.202.131
*Jun 22 19:11:58.057: NHRP: Forwarding request due to authoritative request.
*Jun 22 19:11:58.058: NHRP: Attempting to forward to destination: 2.2.2.2 vrf: global(0x0)
*Jun 22 19:11:58.058: NHRP: Forwarding: NHRP SAS picked source: 192.168.1.1 for destination: 2.2.2.2
*Jun 22 19:11:58.058: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 2.2.2.2
*Jun 22 19:11:58.058: NHRP: Forwarding Resolution Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:11:58.058:       src: 192.168.1.1, dst: 2.2.2.2
*Jun 22 19:11:58.058: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.131
*Jun 22 19:11:58.058: NHRP: 136 bytes out Tunnel0 
*Jun 22 19:12:01.590: NHRP: Receive Resolution Request via Tunnel0 vrf: global(0x0), packet size: 88
*Jun 22 19:12:01.590: NHRP: Route lookup for destination 2.2.2.2 in vrf: global(0x0) yielded interface Tunnel0, prefixlen 24
*Jun 22 19:12:01.590: NHRP: Route lookup for 2.2.2.2 in vrf: global(0x0) yielded nexthop 192.168.1.2 interface Tunnel0
*Jun 22 19:12:01.590: NHRP: Cache lookup for nexthop 192.168.1.2 on Tunnel0 returned nbma 209.168.202.131
*Jun 22 19:12:01.590: NHRP: Forwarding request due to authoritative request.
*Jun 22 19:12:01.591: NHRP: Attempting to forward to destination: 2.2.2.2 vrf: global(0x0)
*Jun 22 19:12:01.591: NHRP: Forwarding: NHRP SAS picked source: 192.168.1.1 for destination: 2.2.2.2
*Jun 22 19:12:01.591: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 2.2.2.2
*Jun 22 19:12:01.591: NHRP: Forwarding Resolution Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:12:01.591:       src: 192.168.1.1, dst: 2.2.2.2
*Jun 22 19:12:01.591: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.131
*Jun 22 19:12:01.591: NHRP: 136 bytes out Tunnel0 
*Jun 22 19:12:15.681: NHRP: Receive Resolution Request via Tunnel0 vrf: global(0x0), packet size: 88
*Jun 22 19:12:15.681: NHRP: Route lookup for destination 3.3.3.3 in vrf: global(0x0) yielded interface Tunnel0, prefixlen 24
*Jun 22 19:12:15.681: NHRP: Route lookup for 3.3.3.3 in vrf: global(0x0) yielded nexthop 192.168.1.3 interface Tunnel0
*Jun 22 19:12:15.681: NHRP: Cache lookup for nexthop 192.168.1.3 on Tunnel0 returned nbma 209.168.202.130
*Jun 22 19:12:15.681: NHRP: Forwarding request due to authoritative request.
*Jun 22 19:12:15.681: NHRP: Attempting to forward to destination: 3.3.3.3 vrf: global(0x0)
*Jun 22 19:12:15.681: NHRP: Forwarding: NHRP SAS picked source: 192.168.1.1 for destination: 3.3.3.3
*Jun 22 19:12:15.681: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 3.3.3.3
*Jun 22 19:12:15.681: NHRP: Forwarding Resolution Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:12:15.681:       src: 192.168.1.1, dst: 3.3.3.3
*Jun 22 19:12:15.681: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.130
*Jun 22 19:12:15.682: NHRP: 136 bytes out Tunnel0 
*Jun 22 19:12:36.462: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:12:36.462: NHRP: Tunnels gave us pak src addr: 209.168.202.130
*Jun 22 19:12:36.463: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:12:36.463: NHRP: NHRP subblock already exists for Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:12:36.463: NHRP: Peer capability:0
*Jun 22 19:12:36.463: NHRP: Cache already has a subblock node attached for Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:12:36.463: NHRP: nhrp_subblock_check_for_map() - Map Already Exists
*Jun 22 19:12:36.463: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.3 nbma 209.168.202.130 code: no error(0)
*Jun 22 19:12:36.463: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.3
*Jun 22 19:12:36.463: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:12:36.463:       src: 192.168.1.1, dst: 192.168.1.3
*Jun 22 19:12:36.463: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.130
*Jun 22 19:12:36.463: NHRP: 156 bytes out Tunnel0 
*Jun 22 19:12:43.208: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:12:43.208: NHRP: Tunnels gave us pak src addr: 209.168.202.131
*Jun 22 19:12:43.209: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:12:43.209: NHRP: NHRP subblock already exists for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:12:43.209: NHRP: Peer capability:0
*Jun 22 19:12:43.209: NHRP: Cache already has a subblock node attached for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:12:43.209: NHRP: nhrp_subblock_check_for_map() - Map Already Exists
*Jun 22 19:12:43.209: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.2 nbma 209.168.202.131 code: no error(0)
*Jun 22 19:12:43.209: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.2
*Jun 22 19:12:43.209: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:12:43.210:       src: 192.168.1.1, dst: 192.168.1.2
*Jun 22 19:12:43.210: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.131
*Jun 22 19:12:43.210: NHRP: 156 bytes out Tunnel0 
*Jun 22 19:15:56.463: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:15:56.464: NHRP: Tunnels gave us pak src addr: 209.168.202.130
*Jun 22 19:15:56.464: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:15:56.464: NHRP: NHRP subblock already exists for Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:15:56.464: NHRP: Peer capability:0
*Jun 22 19:15:56.464: NHRP: Cache already has a subblock node attached for Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:15:56.464: NHRP: nhrp_subblock_check_for_map() - Map Already Exists
*Jun 22 19:15:56.464: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.3 nbma 209.168.202.130 code: no error(0)
*Jun 22 19:15:56.464: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.3
*Jun 22 19:15:56.464: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:15:56.464:       src: 192.168.1.1, dst: 192.168.1.3
*Jun 22 19:15:56.464: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.130
*Jun 22 19:15:56.464: NHRP: 156 bytes out Tunnel0 
*Jun 22 19:16:03.208: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:16:03.208: NHRP: Tunnels gave us pak src addr: 209.168.202.131
*Jun 22 19:16:03.208: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:16:03.209: NHRP: NHRP subblock already exists for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:16:03.209: NHRP: Peer capability:0
*Jun 22 19:16:03.209: NHRP: Cache already has a subblock node attached for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:16:03.209: NHRP: nhrp_subblock_check_for_map() - Map Already Exists
*Jun 22 19:16:03.209: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.2 nbma 209.168.202.131 code: no error(0)
*Jun 22 19:16:03.209: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.2
*Jun 22 19:16:03.209: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:16:03.209:       src: 192.168.1.1, dst: 192.168.1.2
*Jun 22 19:16:03.209: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.131
*Jun 22 19:16:03.209: NHRP: 156 bytes out Tunnel0 
*Jun 22 19:19:16.464: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:19:16.464: NHRP: Tunnels gave us pak src addr: 209.168.202.130
*Jun 22 19:19:16.464: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:19:16.464: NHRP: NHRP subblock already exists for Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:19:16.464: NHRP: Peer capability:0
*Jun 22 19:19:16.464: NHRP: Cache already has a subblock node attached for Tunnel Endpoints (VPN: 192.168.1.3, NBMA: 209.168.202.130)
*Jun 22 19:19:16.464: NHRP: nhrp_subblock_check_for_map() - Map Already Exists
*Jun 22 19:19:16.464: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.3 nbma 209.168.202.130 code: no error(0)
*Jun 22 19:19:16.465: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.3
*Jun 22 19:19:16.465: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:19:16.465:       src: 192.168.1.1, dst: 192.168.1.3
*Jun 22 19:19:16.465: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.130
*Jun 22 19:19:16.465: NHRP: 156 bytes out Tunnel0 
*Jun 22 19:19:23.209: NHRP: Receive Registration Request via Tunnel0 vrf: global(0x0), packet size: 108
*Jun 22 19:19:23.209: NHRP: Tunnels gave us pak src addr: 209.168.202.131
*Jun 22 19:19:23.209: NHRP: Adding Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:19:23.209: NHRP: NHRP subblock already exists for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:19:23.209: NHRP: Peer capability:0
*Jun 22 19:19:23.209: NHRP: Cache already has a subblock node attached for Tunnel Endpoints (VPN: 192.168.1.2, NBMA: 209.168.202.131)
*Jun 22 19:19:23.209: NHRP: nhrp_subblock_check_for_map() - Map Already Exists
*Jun 22 19:19:23.209: NHRP: Sending Registration Reply if_in Tunnel0 vrf: global(0x0) dst 192.168.1.2 nbma 209.168.202.131 code: no error(0)
*Jun 22 19:19:23.209: NHRP: Attempting to send packet through interface Tunnel0 via DEST  dst 192.168.1.2
*Jun 22 19:19:23.209: NHRP: Send Registration Reply via Tunnel0 vrf: global(0x0), packet size: 128
*Jun 22 19:19:23.210:       src: 192.168.1.1, dst: 192.168.1.2
*Jun 22 19:19:23.210: NHRP: Encapsulation succeeded.  Sending NHRP Control Packet  NBMA Address: 209.168.202.131
*Jun 22 19:19:23.210: NHRP: 156 bytes out Tunnel0 