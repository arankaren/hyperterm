#!/bin/bash
function __network() {
    unset MY_IP
    : "${MY_IP:=$(ip route show table local | awk -F "local" '{print $2}' | uniq)}"

    unset MY_ISP
    : "${MY_ISP:=$(host whoami.akamai.net. ns1-1.akamaitech.net. | grep "whoami.akamai.net has" | awk '{print $4}')}"
}
