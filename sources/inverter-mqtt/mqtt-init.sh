#!/bin/bash
#
# Simple script to register the MQTT topics when the container starts for the first time...

MQTT_SERVER=`cat /etc/inverter/mqtt.json | jq '.server' -r`
MQTT_PORT=`cat /etc/inverter/mqtt.json | jq '.port' -r`
MQTT_TOPIC=`cat /etc/inverter/mqtt.json | jq '.topic' -r`
MQTT_DEVICENAME=`cat /etc/inverter/mqtt.json | jq '.devicename' -r`
MQTT_MANUFACTURER=`cat /etc/inverter/mqtt.json | jq '.manufacturer' -r`
MQTT_MODEL=`cat /etc/inverter/mqtt.json | jq '.model' -r`
MQTT_SERIAL=`cat /etc/inverter/mqtt.json | jq '.serial' -r`
MQTT_VER=`cat /etc/inverter/mqtt.json | jq '.ver' -r`
MQTT_USERNAME=`cat /etc/inverter/mqtt.json | jq '.username' -r`
MQTT_PASSWORD=`cat /etc/inverter/mqtt.json | jq '.password' -r`

registerTopic () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i ""$MQTT_DEVICENAME"_"$MQTT_SERIAL"" \
        -t ""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1/config" \
        -r \
        -m "{
            \"name\": \"$5\",
            \"uniq_id\": \""$MQTT_SERIAL"_$1\",
            \"device\": { \"ids\": \""$MQTT_SERIAL"\", \"mf\": \""$MQTT_MANUFACTURER"\", \"mdl\": \""$MQTT_MODEL"\", \"name\": \""$MQTT_DEVICENAME"\", \"sw\": \""$MQTT_VER"\"},
            \"state_topic\": \""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1\",
            \"state_class\": \"measurement\",
            \"device_class\": \"$4\",
            \"unit_of_measurement\": \"$2\",
            \"icon\": \"mdi:$3\"
        }"
}
# Remove the energy topic because they are not good for HA. Device class:total increasing or total it will add in statistics the differences between states, and we need to make sum of states. Best cases it is useful for influxdb.
# registerEnergyTopic () {
#     mosquitto_pub \
#         -h $MQTT_SERVER \
#         -p $MQTT_PORT \
#         -u "$MQTT_USERNAME" \
#         -P "$MQTT_PASSWORD" \
#         -i ""$MQTT_DEVICENAME"_"$MQTT_SERIAL"" \
#         -t "$MQTT_TOPIC/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1/LastReset" \
#         -r \
#         -m "1970-01-01T00:00:00+00:00"

#     mosquitto_pub \
#         -h $MQTT_SERVER \
#         -p $MQTT_PORT \
#         -u "$MQTT_USERNAME" \
#         -P "$MQTT_PASSWORD" \
#         -i ""$MQTT_DEVICENAME"_"$MQTT_SERIAL"" \
#         -t ""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1/config" \
#         -r \
#         -m "{
#             \"name\": \"$5\",
#             \"uniq_id\": \""$MQTT_SERIAL"_$1\",
#             \"device\": { \"ids\": \""$MQTT_SERIAL"\", \"mf\": \""$MQTT_MANUFACTURER"\", \"mdl\": \""$MQTT_MODEL"\", \"name\": \""$MQTT_DEVICENAME"\", \"sw\": \""$MQTT_VER"\"},
#             \"state_topic\": \""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1\",
#             \"state_class\": \"total_increasing\",
#             \"device_class\": \"$4\",
#             \"unit_of_measurement\": \"$2\",
#             \"icon\": \"mdi:$3\"
#         }"
# }
registerModeTopic () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i ""$MQTT_DEVICENAME"_"$MQTT_SERIAL"" \
        -t ""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1/config" \
        -r \
        -m "{
            \"name\": \"$5\",
            \"uniq_id\": \""$MQTT_SERIAL"_$1\",
            \"device\": { \"ids\": \""$MQTT_SERIAL"\", \"mf\": \""$MQTT_MANUFACTURER"\", \"mdl\": \""$MQTT_MODEL"\", \"name\": \""$MQTT_DEVICENAME"\", \"sw\": \""$MQTT_VER"\"},
            \"state_topic\": \""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/$1\",
            \"unit_of_measurement\": \"$2\",
            \"icon\": \"mdi:$3\"
        }"
}
registerInverterRawCMD () {
    mosquitto_pub \
        -h $MQTT_SERVER \
        -p $MQTT_PORT \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i ""$MQTT_DEVICENAME"_"$MQTT_SERIAL"" \
        -t ""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/COMMANDS/config" \
        -r \
        -m "{
            \"name\": \""$MQTT_DEVICENAME"_COMMANDS\",
            \"uniq_id\": \""$MQTT_DEVICENAME"_"$MQTT_SERIAL"\",
            \"device\": { \"ids\": \""$MQTT_SERIAL"\", \"mf\": \""$MQTT_MANUFACTURER"\", \"mdl\": \""$MQTT_MODEL"\", \"name\": \""$MQTT_DEVICENAME"\", \"sw\": \""$MQTT_VER"\"},
            \"state_topic\": \""$MQTT_TOPIC"/sensor/"$MQTT_DEVICENAME"_"$MQTT_SERIAL"/COMMANDS\"
            }"
}

#              $1code    $2unit of measure  $3mdi $4class   $5name
registerModeTopic "AC_charge_on" "" "power" "None" "AC charge on"
registerTopic "AC_grid_frequency" "Hz" "current-ac" "frequency" "AC grid frequency"
registerTopic "AC_grid_voltage" "V" "power-plug" "voltage" "AC grid voltage"
registerTopic "AC_out_frequency" "Hz" "current-ac" "frequency" "AC out frequency"
registerTopic "AC_out_voltage" "V" "power-plug" "voltage" "AC out voltage"
registerTopic "Battery_bulk_voltage" "V" "current-dc" "voltage" "Battery bulk voltage"
registerTopic "Battery_capacity" "%" "battery-outline" "battery" "Battery capacity"
registerTopic "Battery_charge_current" "A" "current-dc" "current" "Battery charge current"
registerTopic "Battery_discharge_current" "A" "current-dc" "current" "Battery discharge current"
registerTopic "Battery_float_voltage" "V" "current-dc" "voltage" "Battery float voltage"
registerTopic "Battery_recharge_voltage" "V" "current-dc" "voltage" "Battery recharge voltage"
registerTopic "Battery_redischarge_voltage" "V" "battery-negative" "voltage" "Battery redischarge voltage"
registerTopic "Battery_under_voltage" "V" "current-dc" "voltage" "Battery under voltage"
registerTopic "Battery_voltage" "V" "battery-outline" "voltage" "Battery voltage"
registerTopic "Battery_voltage_offset_for_fans_on" "10mV" "battery-outline" "voltage" "Battery voltage offset for fans on"
registerTopic "Bus_voltage" "V" "details" "voltage" "Bus voltage"
registerModeTopic "Charger_source_priority" "" "solar-power" "None" "Charger source priority"
registerModeTopic "Charging_to_floating_mode" "" "solar-power" "None" "Charging to floating mode"
registerModeTopic "Dustproof_installed" "" "solar-power" "None" "Dustproof installed" # 1-dustproof installed,0-no dustproof
registerModeTopic "Eeprom_version" "" "power" "None" "Eeprom version"
registerTopic "Heatsink_temperature" "°C" "details" "temperature" "Heatsink temperature"
registerModeTopic "Load_pct" "%" "brightness-percent" "None" "Load pct"
registerModeTopic "Load_status_on" "" "power" "None" "Load status on"
registerTopic "Load_va" "VA" "chart-bell-curve" "apparent_power" "Load va"
registerTopic "Load_watt" "W" "chart-bell-curve" "power" "Load watt"
# registerEnergyTopic "Load_watthour" "kWh" "chart-bell-curve" "energy" "Load kWatthour"
registerTopic "Max_charge_current" "A" "current-ac" "current" "Max charge current"
registerTopic "Max_grid_charge_current" "A" "current-ac" "current" "Max grid charge current"
registerModeTopic "Inverter_mode" "" "solar-power" "None" "Inverter mode" # 1 = Power_On, 2 = Standby, 3 = Line, 4 = Battery, 5 = Fault, 6 = Power_Saving, 7 = Unknown
registerModeTopic "Out_source_priority" "" "grid" "None" "Out source priority"
registerTopic "PV_in_current" "A" "solar-panel-large" "current" "PV in current"
registerTopic "PV_in_voltage" "V" "solar-panel-large" "voltage" "PV in voltage"
# registerEnergyTopic "PV_in_watthour" "kWh" "solar-panel-large" "energy" "PV in kWatthour"
registerTopic "PV_in_watts" "W" "solar-panel-large" "power" "PV in watts"
registerTopic "PV_charging_power" "W" "solar-panel-large" "power" "PV charging power"
registerModeTopic "SCC_charge_on" "" "power" "None" "SCC charge on"
registerTopic "SCC_voltage" "V" "current-dc" "voltage" "SCC voltage"
registerModeTopic "Switch_On" "" "power" "None" "Switch On"
registerModeTopic "Warnings" "" "power" "None" "Warnings"
registerTopic "PV2_in_current" "A" "solar-panel-large" "current" "PV2 in current"
registerTopic "PV2_in_voltage" "V" "solar-panel-large" "voltage" "PV2 in voltage"
registerTopic "PV2_in_watts" "W" "solar-panel-large" "power" "PV2 in watts"
registerTopic "PV2_charging_power" "W" "solar-panel-large" "power" "PV2 charging power"
registerTopic "PV_total_charging_power" "W" "solar-panel-large" "power" "PV Total charging power"
# Add in a separate topic so we can send raw commands from assistant back to the inverter via MQTT (such as changing power modes etc)...
registerInverterRawCMD
