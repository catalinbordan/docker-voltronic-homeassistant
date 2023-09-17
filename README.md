This is a fork from ned-kelly version with improved changes from  kchiem, dilyanpalauzov, nrm21 and many more:
- no more needed fixes responses for QMOD, QPIRI... program it will find them.
- changes regarding mqtt broker compatibility, topics, auto-discovery...
- polling/transmit rate speed improved. now it transmit to HA almost every 10 seconds.
- now you can transmit commands to inverter bigger then 5 characters by sending them in batch of 5 characters .
- Battery redicharge voltage - now show good values.
- many changes witch I don't remember :)
- Add support for 2 MPPT
- Fix the bulk command write to work since the inverter requires full 8 byte blocks at a time

**The instructions to use this fork are at the end of readme and I have taking in consideration that you allready have installed and followed the intructions of original repository of ned-kelly. If you start from zero, then install docker and docker-compose and then skip to no 5.**

This is a fork for my personal use, like other 85 forks, witch I combine all the changes I found to be useful and I could understand(no programming skills). 
Manny thanks for this people, and I am glad if is it is useful for others because I have spent a lot of time to study the changes. If it is not working for you, be sure you inverter it is working with protocol PI30 and have a good connection with inverter. If you find something bad/need to be improved and you know why/how to do, I will haply change it when I will find free time. 

==========================
# A Docker based Home Assistant interface for MPP/Voltronic Solar Inverters 

**Docker Hub:** [`bushrangers/ha-voltronic-mqtt:latest`](https://hub.docker.com/r/bushrangers/ha-voltronic-mqtt/)

![License](https://img.shields.io/github/license/ned-kelly/docker-voltronic-homeassistant.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/bushrangers/ha-voltronic-mqtt.png) ![buildx](https://github.com/ned-kelly/docker-voltronic-homeassistant/workflows/buildx/badge.svg)

----

The following other projects may also run on the same SBC _(using the same style docker setup as this)_, to give you a fully featured solution with other sensors and devices:

 - [EPEver MPPT Stats (MQTT, Docker Image)](https://github.com/ned-kelly/docker-epever-homeassistant)
 - [LeChacal.com's CT Clamp Current/Energy Monitors for your Breaker Box](https://github.com/ned-kelly/docker-lechacal-homeassistant)

---

This project [was derived](https://github.com/manio/skymax-demo) from the 'skymax' [C based monitoring application](https://skyboo.net/2017/03/monitoring-voltronic-power-axpert-mex-inverter-under-linux/) designed to take the monitoring data from Voltronic, Axpert, Mppsolar PIP, Voltacon, Effekta, and other branded OEM Inverters and send it to a [Home Assistant](https://www.home-assistant.io/) MQTT server for ingestion...

The program can also receive commands from Home Assistant (via MQTT) to change the state of the inverter remotely.

By remotely setting values via MQTT you can implement many more complex forms of automation _(triggered from Home Assistant)_ such as:

 - Changing the power mode to '_solar only_' during the day, but then change back to '_grid mode charging_' for your AGM or VLRA batteries in the evenings, but if it's raining (based on data from your weather station), set the charge mode to `PCP02` _(Charge based on 'Solar and Utility')_ so that the following day there's plenty of juice in your batteries...

 - Programatically set the charge & float voltages based on additional sensors _(such as a Zigbee [Temperature Sensor](https://www.zigbee2mqtt.io/devices/WSDCGQ11LM.html), or a [DHT-22 + ESP8266](https://github.com/bastianraschke/dht-sensor-esp8266-homeassistant))_ - This way if your battery box is too hot/cold you can dynamically adjust the voltage so that the batteries are not damaged...

 - Dynamically adjust the inverter's "solar power balance" and other configuration options to ensure that you get the most "bang for your buck" out of your setup... 

--------------------------------------------------

The program is designed to be run in a Docker Container, and can be deployed on a lightweight SBC next to your Inverter (i.e. an Orange Pi Zero running Arabian), and read data via the RS232 or USB ports on the back of the Inverter.

![Example Lovelace Dashboard](images/lovelace-dashboard.jpg "Example Lovelace Dashboard")
_Example #1: My "Lovelace" dashboard using data collected from the Inverter & the ability to change modes/configuration via MQTT._

![Example Lovelace Dashboard](images/grafana-example.jpg "Example Grafana Dashboard")
_Example #2: Grafana summary allowing more detailed analysis of data collected, and the ability to 'deep-dive' historical data._


## Prerequisites

- Docker
- Docker-compose
- [Voltronic/Axpert/MPPSolar](https://www.ebay.com.au/sch/i.html?_from=R40&_trksid=p2334524.m570.l1313.TR11.TRC1.A0.H0.Xaxpert+inverter.TRS0&_nkw=axpert+inverter&_sacat=0&LH_TitleDesc=0&LH_PrefLoc=2&_osacat=0&_odkw=solar+inverter&LH_TitleDesc=0) based inverter that you want to monitor
- Home Assistant [running with a MQTT Server](https://www.home-assistant.io/components/mqtt/)


## Configuration & Standing Up

It's pretty straightforward, just clone down the sources and set the configuration files in the `config/` directory:

```bash
# Clone down sources on the host you want to monitor...
git clone https://github.com/ned-kelly/docker-voltronic-homeassistant.git /opt/ha-inverter-mqtt-agent
cd /opt/ha-inverter-mqtt-agent

# Configure the 'device=' directive (in inverter.conf) to suit for RS232 or USB.. 
vi config/inverter.conf

# Configure your MQTT server's IP/Host Name, Port, Credentials, HA topic, and name of the Inverter that you want displayed in Home Assistant...
# If your MQTT server does not need a username/password just leave these values empty.

vi config/mqtt.json
```

Then, plug in your Serial or USB cable to the Inverter & stand up the container:

```bash
docker-compose up -d

```

_**Note:**_

  - builds on docker hub are currently for `linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/386` -- If you have issues standing up the image on your Linux distribution (i.e. An old Pi/ARM device) you may need to manually build the image to support your local device architecture - This can be done by uncommenting the build flag in your docker-compose.yml file.
  
  - The default `docker-compose.yml` file includes Watchtower, which can be  configured to auto-update this image when we push new changes to github - Please **uncomment if you wish to auto-update to the latest builds of this project**.

## Integrating into Home Assistant.

Providing you have setup [MQTT](https://www.home-assistant.io/components/mqtt/) with Home Assistant, the device will automatically register in your Home Assistant when the container starts for the first time -- You do not need to manually define any sensors.

From here you can setup [Graphs](https://www.home-assistant.io/lovelace/history-graph/) to display sensor data, and optionally change state of the inverter by "[publishing](https://www.home-assistant.io/docs/mqtt/service/)" a string to the inverter's primary topic like so:

![Example, Changing the Charge Priority](images/mqtt-publish-packet.png "Example, Changing the Charge Priority")
_Example: Changing the Charge Priority of the Inverter_

**COMMON COMMANDS THAT CAN BE SENT TO THE INVERTER**

_(see [protocol manual](http://forums.aeva.asn.au/uploads/293/HS_MS_MSX_RS232_Protocol_20140822_after_current_upgrade.pdf) for complete list of supported commands)_



```
DESCRIPTION:                PAYLOAD:  OPTIONS:
----------------------------------------------------------------
Set output source priority  POP00     (Utility first)
                            POP01     (Solar first)
                            POP02     (SBU)

Set charger priority        PCP00     (Utility first)
                            PCP01     (Solar first)
                            PCP02     (Solar and utility)
                            PCP03     (Solar only)

Set the Charge/Discharge Levels & Cutoff
                            PBDV26.9  (Don't discharge the battery unless it is at 26.9v or more)
                            PBCV24.8  (Switch back to 'grid' when battery below 24.8v)
                            PBFT27.1  (Set the 'float voltage' to 27.1v)
                            PCVV28.1  (Set the 'charge voltage' to 28.1v)

Set other commands          PEa / PDa (Enable/disable buzzer)
                            PEb / PDb (Enable/disable overload bypass)
                            PEj / PDj (Enable/disable power saving)
                            PEu / PDu (Enable/disable overload restart);
                            PEx / PDx (Enable/disable backlight)
```

*NOTE:* When setting/configuring your charge, discharge, float & cutoff voltages for the first time, it's worth  understanding how to optimize charging conditions to extend service life of your battery: https://batteryuniversity.com/learn/article/charging_the_lead_acid_battery


### Using `inverter_poller` binary directly

This project uses heavily modified sources, from [manio's](https://github.com/manio/skymax-demo) original demo, and be compiled to run standalone on Linux, Mac, and Windows (via Cygwin).

Just head to the `sources/inverter-cli` directory and build it directly using: `cmake . && make`.

Basic arguments supported are:

```
USAGE:  ./inverter_poller <args> [-r <command>], [-h | --help], [-1 | --run-once]

SUPPORTED ARGUMENTS:
          -r <raw-command>      TX 'raw' command to the inverter
          -h | --help           This Help Message
          -1 | --run-once       Runs one iteration on the inverter, and then exits
          -d                    Additional debugging

```

### Bonus: Lovelace Dashboard Files

_**Please refer to the screenshot above for an example of the dashboard.**_

I've included some Lovelace dashboard files in the `homeassistant/` directory, however you will need to need to adapt to your own Home Assistant configuration and/or name of the inverter if you have changed it in the `mqtt.json` config file.

Note that in addition to merging the sample Yaml files with your Home Assistant, you will need the following custom Lovelace cards installed if you wish to use my templates:

 - [vertical-stack-in-card](https://github.com/custom-cards/vertical-stack-in-card)
 - [circle-sensor-card](https://github.com/custom-cards/circle-sensor-card)


===========================

Credit and many thanks for kchiem, dilyanpalauzov, nrm21,

When you will use this fork you need to do the following commands on your device:
1) cd /opt/ha-inverter-mqtt-agent
2) sudo docker-compose down
3) cd ..
4) sudo rm -rf ha-inverter-mqtt-agent
5) sudo git clone https://github.com/catalinbordan/docker-voltronic-homeassistant.git /opt/ha-inverter-mqtt-agent
6) cd /opt/ha-inverter-mqtt-agent
7) sudo nano config/inverter.conf (only edit this file if you don't have usb cable to inverter)
8) sudo nano config/mqtt.json (change it with your variables)
9) sudo docker-compose build
10) sudo docker-compose up -d
11) sudo docker exec -it voltronic-mqtt bash -c '/opt/inverter-cli/bin/inverter_poller -d -1' (this is to test to see is everything ok regarding connection between inverter and docker)

this is the output result of my inverter:
````
Wed Jun 15 19:14:55 2022 INVERTER: Debug set
Wed Jun 15 19:14:55 2022 DEBUG:  Current CRC: 49 C1
Wed Jun 15 19:14:55 2022 DEBUG:  Send buffer hex bytes:  ( 51 4d 4f 44 49 c1 0d )
Wed Jun 15 19:14:55 2022 DEBUG:  7 bytes written, 7 bytes sent, 0 bytes remaining
Wed Jun 15 19:14:55 2022 DEBUG:  8 bytes read, 8 total bytes:  28 42 e7 c9 0d 00 00 00
Wed Jun 15 19:14:55 2022 DEBUG:  Found reply <cr> at byte: 5
Wed Jun 15 19:14:55 2022 DEBUG:  QMOD: 8 bytes read: (B
Wed Jun 15 19:14:55 2022 DEBUG:  QMOD query finished
Wed Jun 15 19:14:56 2022 DEBUG:  Current CRC: B7 A9
Wed Jun 15 19:14:56 2022 DEBUG:  Send buffer hex bytes:  ( 51 50 49 47 53 b7 a9 0d )
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes written, 8 bytes sent, 0 bytes remaining
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 8 total bytes:  28 32 33 31 2e 37 20 34
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 16 total bytes:  39 2e 39 20 32 33 30 2e
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 24 total bytes:  32 20 35 30 2e 30 20 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 32 total bytes:  33 39 31 20 30 31 34 37
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 40 total bytes:  20 30 31 33 20 33 35 38
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 48 total bytes:  20 32 35 2e 39 38 20 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 56 total bytes:  30 30 20 31 30 30 20 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 64 total bytes:  30 33 36 20 30 30 30 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 72 total bytes:  20 30 30 30 2e 30 20 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 80 total bytes:  30 2e 30 30 20 30 30 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 88 total bytes:  30 36 20 30 30 30 31 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 96 total bytes:  30 30 30 20 30 30 20 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 104 total bytes:  30 20 30 30 30 30 30 20
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 112 total bytes:  30 31 31 5c c6 0d 00 00
Wed Jun 15 19:14:56 2022 DEBUG:  Found reply <cr> at byte: 110
Wed Jun 15 19:14:56 2022 DEBUG:  QPIGS: 112 bytes read: (231.7 49.9 230.2 50.0 0391 0147 013 358 25.98 000 100 0036 0000 000.0 00.00 00006 00010000 00 00 00000 011
Wed Jun 15 19:14:56 2022 DEBUG:  QPIGS query finished
Wed Jun 15 19:14:56 2022 DEBUG:  Current CRC: F8 54
Wed Jun 15 19:14:56 2022 DEBUG:  Send buffer hex bytes:  ( 51 50 49 52 49 f8 54 0d )
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes written, 8 bytes sent, 0 bytes remaining
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 8 total bytes:  28 32 33 30 2e 30 20 31
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 16 total bytes:  33 2e 30 20 32 33 30 2e
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 24 total bytes:  30 20 35 30 2e 30 20 31
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 32 total bytes:  33 2e 30 20 33 30 30 30
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 40 total bytes:  20 33 30 30 30 20 32 34
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 48 total bytes:  2e 30 20 32 32 2e 30 20
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 56 total bytes:  32 31 2e 30 20 32 38 2e
Wed Jun 15 19:14:56 2022 DEBUG:  8 bytes read, 64 total bytes:  32 20 32 37 2e 34 20 32
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 72 total bytes:  20 30 32 20 30 37 30 20
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 80 total bytes:  31 20 32 20 32 20 31 20
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 88 total bytes:  30 31 20 30 20 30 20 32
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 96 total bytes:  36 2e 30 20 30 20 31 d7
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 104 total bytes:  e2 0d 00 00 00 00 00 00
Wed Jun 15 19:14:57 2022 DEBUG:  Found reply <cr> at byte: 98
Wed Jun 15 19:14:57 2022 DEBUG:  QPIRI: 104 bytes read: (230.0 13.0 230.0 50.0 13.0 3000 3000 24.0 22.0 21.0 28.2 27.4 2 02 070 1 2 2 1 01 0 0 26.0 0 1
Wed Jun 15 19:14:57 2022 DEBUG:  QPIRI query finished
Wed Jun 15 19:14:57 2022 DEBUG:  Current CRC: B4 DA
Wed Jun 15 19:14:57 2022 DEBUG:  Send buffer hex bytes:  ( 51 50 49 57 53 b4 da 0d )
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes written, 8 bytes sent, 0 bytes remaining
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 8 total bytes:  28 30 30 30 30 30 30 30
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 16 total bytes:  30 30 30 30 30 30 30 30
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 24 total bytes:  30 30 30 30 30 30 30 30
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 32 total bytes:  30 30 30 30 30 30 30 30
Wed Jun 15 19:14:57 2022 DEBUG:  8 bytes read, 40 total bytes:  30 eb e4 0d 00 00 00 00
Wed Jun 15 19:14:57 2022 DEBUG:  Found reply <cr> at byte: 36
Wed Jun 15 19:14:57 2022 DEBUG:  QPIWS: 40 bytes read: (00000000000000000000000000000000
Wed Jun 15 19:14:57 2022 DEBUG:  QPIWS query finished
Wed Jun 15 19:14:57 2022 DEBUG:  Start loop
INVERTER: ampfactor from config is 1.00
INVERTER: wattfactor from config is 1.00
{
  "Inverter_mode":4,
  "AC_grid_voltage":231.7,
  "AC_grid_frequency":49.9,
  "AC_out_voltage":230.2,
  "AC_out_frequency":50.0,
  "PV_in_voltage":0.0,
  "PV_in_current":0.0,
  "PV_in_watts":0.0,
  "SCC_voltage":0.0000,
  "Load_pct":13,
  "Load_watt":147,
  "Load_va":391,
  "Bus_voltage":358,
  "Heatsink_temperature":36,
  "Battery_capacity":100,
  "Battery_voltage":25.98,
  "Battery_charge_current":0,
  "Battery_discharge_current":6,
  "Load_status_on":1,
  "SCC_charge_on":0,
  "AC_charge_on":0,
  "Battery_voltage_offset_for_fans_on":0,
  "Eeprom_version":0,
  "PV_charging_power":0,
  "Charging_to_floating_mode":0,
  "Switch_On":1,
  "Dustproof_installed":1,
  "Battery_recharge_voltage":22.0,
  "Battery_under_voltage":21.0,
  "Battery_bulk_voltage":28.2,
  "Battery_float_voltage":27.4,
  "Max_grid_charge_current":2,
  "Max_charge_current":70,
  "Out_source_priority":2,
  "Charger_source_priority":2,
  "Battery_redischarge_voltage":26.0,
  "Warnings":"00000000000000000000000000000000"
}
Wed Jun 15 19:14:57 2022 INVERTER: All queries complete, exiting loop.

```

Example of command for Set battery re-discharge voltage to 26.1V
```
sudo docker exec -it voltronic-mqtt bash -c '/opt/inverter-cli/bin/inverter_poller -d -r PBDV26.1'
```

 I have put in home assistant folder the examples of what I have for sending commands to inverter, template sensor for warnings, etc. 
For the input buttons you will use the helpers in HA to create them. 
The names and the option of them look in automations examples.

