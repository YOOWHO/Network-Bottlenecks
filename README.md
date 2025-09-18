# Network-Bottlenecks
A project focused on analyzing and resolving network bottlenecks in virtualized cloud environments, by utilizing tools such as ZeroTier, iperf3, ping, tc, and iptables to simulate and test real-world traffic. Set up using 5 different VMs. Applied optimization techniques to improve latency, throughput, and reliability.

The setup and Commands.

1. Zero Tier Network Setup

a. Install ZeroTier
bash		curl -s https://install.zerotier.com | sudo bash

What it does: Downloads and runs the official ZeroTier installer script with root privileges.
Why use it: Sets up ZeroTier's VPN service on your machine to create secure peer-to-peer connections.

b. Join Network
bash 		sudo zerotier-cli join <NETWORK_ID>

What it does: Connects your device to a ZeroTier virtual network using its unique 16-character ID.
Why use it: Establishes the encrypted tunnel between your device and other peers in the network.

c. Verify Peers
bash  		sudo zerotier-cli peers

What it does: Lists all devices (peers) in your ZeroTier network and their connection status.
Why use it: Confirms whether your device can see others and checks if connections are direct (optimal) or relayed (slower).

2. Traffic Shaping (tc)
a. Bandwidth Limiting
bash  		sudo tc qdisc add dev eth0 root handle 1: htb default 12
 		sudo tc class add dev eth0 parent 1: classid 1:1 htb rate 100mbit ceil 100mbit

What it does:
The first command creates a Hierarchical Token Bucket (HTB) queue discipline to manage bandwidth.
Second command caps bandwidth at 100Mbps for all traffic on eth0.

Why use it: Simulates network congestion or enforces bandwidth limits for testing.


b. Add Latency/Packet Loss
bash 		sudo tc qdisc add dev eth0 root netem delay 50ms loss 5%

What it does: Introduces artificial latency (50ms) and packet loss (5%) to outbound traffic.
Why use it: Mimics poor network conditions (e.g., high-latency WAN links or unreliable connections).

c. Reset Rules
bash		sudo tc qdisc del dev eth0 root

What it does: Removes all traffic control rules from eth0.
Why use it: Cleans up after testing to restore normal network behavior.


3. Firewall Optimization (iptables)
a. Allow iperf3 Port
bash		sudo iptables -A INPUT -p tcp --dport 5201 -j ACCEPT

What it does: Opens TCP port 5201 (iperf3's default port) in the firewall.
Why use it: Ensures iperf3 traffic isn't blocked during tests.

b. Prioritize ZeroTier Traffic
bash 		sudo iptables -t mangle -A POSTROUTING -o zt+ -j DSCP --set-dscp-class EF

What it does: Marks ZeroTier traffic (zt+ interfaces) with Expedited Forwarding (EF) DSCP class.
Why use it: Gives ZeroTier packets higher priority in the network stack.

c. Save Rules
bash 		sudo netfilter-persistent save

What it does: Makes iptables rules persistent across reboots (if netfilter-persistent is installed).
Why use it: Prevents manual reconfiguration after system restarts.


4. Performance Testing
a. Start iperf3 Server
bash		iperf3 -s

What it does: Runs iperf3 in server mode, listening on port 5201.
Why use it: Allows other devices to connect and measure network performance.

b. Basic Client Test
bash		iperf3 -c <PEER_IP> -t 30

What it does: Connects to an iperf3 server at <PEER_IP> and runs a 30-second throughput test.
Why use it: Measures baseline bandwidth between two devices.

c. Parallel Streams Test
bash		iperf3 -c <PEER_IP> -t 30 -P 4

What it does: Runs the same test but with 4 parallel streams.
Why use it: Simulates multiple users/devices transferring data simultaneously.

d. Latency Test
bash 		ping <PEER_IP> -c 20

What it does: Sends 20 ICMP packets to <PEER_IP> and calculates round-trip time (RTT).
Why use it: Measures network latency and packet loss.


5. Diagnostics
a. Check tc Rules
bash 		tc -s qdisc show dev eth0

What it does: Displays active traffic control rules and statistics for eth0.
Why use it: Verifies that bandwidth/latency rules are applied correctly.

b. Monitor Traffic
bash		iftop -i eth0

What it does: Shows real-time bandwidth usage per connection on eth0.
Why use it: Identifies which hosts/apps are consuming the most bandwidth.

c. ZeroTier Debug Logs
bash 		journalctl -u zerotier-one -f

What it does: Streams ZeroTier service logs in real-time.
Why use it: Diagnoses connectivity issues (e.g., authentication failures, NAT traversal problems).


6. Cleanup
a. Stop iperf3
bash 		pkill iperf3

What it does: Terminates all running iperf3 processes.
Why use it: Frees up port 5201 and stops background tests.

b. Leave ZeroTier Network
bash		sudo zerotier-cli leave <NETWORK_ID>

What it does: Disconnects your device from the ZeroTier network.
Why use it: Removes the VPN tunnel when testing is complete.


Key Takeaways
ZeroTier commands establish/manage the VPN overlay network.

tc commands simulate real-world network conditions.

Iptables rules optimize traffic flow and prioritize critical data.

iperf3/ping quantify performance metrics (throughput, latency).

Diagnostic tools verify configurations and troubleshoot issues.
