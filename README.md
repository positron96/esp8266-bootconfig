# esp8266-bootconfig

A project that allows Wi-Fi configuration via HTTP on devices based on ESP8266 nodeMCU.

Load this code into ESP8266 (flashed with NodeMCU) and you will get:

1. If device is rebooted >= 3 times in a row with <5 sec intervals between reboots, it goes into *bootconf mode*. That means that device:
    * creates an open Wi-Fi Access point "ESP8266-Config"
    * starts HTTP server at 192.168.4.1:80 (default NodeMCU DHCP IP)
    * provides an index.html that shows 2 fields: AP name and AP password. Data is sent from browser to another page on server 
      that saves parameters into ````wificonfig.txt```` on ESP module.
    * To access the configuration page, connect any device (smartphone, tablet, notebook) to Wi-Fi AccessPoint ESP8266-Config and go to  http://192.168.4.1 from browser. 
2. If boot is normal (less than 3 reboots within 5 secs intervals), program reads ````wificonfig.txt```` and connects to 
specified network. Then it executes ````main.lua````. At this moment ````main.lua```` starts ````led.lua```` that does PWM-blink a led on pin 3. Feel free to remove ````led.lua```` and modify ````main.lua````
