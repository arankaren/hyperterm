#!/bin/bash
# Network
function my_ip() {
    unset MY_IP
    : "${MY_IP:=$(ip route show table local | awk -F "local" '{print $2}' | uniq)}"
}

function my_isp() {
    unset MY_ISP
    : "${MY_ISP:=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')}"
}
