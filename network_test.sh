#!/bin/bash

# Test 1: No limits (reset any existing rules)
sudo tc qdisc del dev eth0 root 2>/dev/null || true  # Ignore if no qdisc exists
iperf3 -c 192.168.29.97 -t 10 -P 2 > ~/iperf_no_limit.log

# Test 2: 100Mbps bandwidth limit
sudo tc qdisc add dev eth0 root handle 1: htb default 12 r2q 10
sudo tc class add dev eth0 parent 1: classid 1:1 htb rate 100mbit ceil 100mbit
iperf3 -c 192.168.29.97 -t 10 -P 2 > ~/iperf_100mbit.log

# Test 3: 50ms latency + 2% packet loss
sudo tc qdisc del dev eth0 root 2>/dev/null || true
sudo tc qdisc add dev eth0 root netem delay 50ms loss 2%
iperf3 -c 192.168.29.97 -t 10 -P 2 > ~/iperf_latency.log

# Reset
sudo tc qdisc del dev eth0 root 2>/dev/null || true
echo "Tests complete. Results saved to ~/iperf_*.log"
