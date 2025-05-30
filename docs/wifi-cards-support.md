# Building

Use the defconfig provided at `docs/files/all-wifi-and-nic-defconfig` in order
to build an image that has support for:

* JWW6051
* Intel I225-V / I226-V NICs
* Intel I210-V / I211-V NICs
* Intel X710 (SFP+) NICs
* Mediatek MT7612E (Wi-Fi 5)
* Mediatek AW7915-NPD / MT7915E (Wi-Fi 6)
* Mediatek MT7916AN (Wi-Fi 6E)

```bash
cat docs/files/all-wifi-and-nic-defconfig > .config
make defconfig
make -j(nproc) V=s
```

Follow build instructions from [here](./building.md).

Also, the overlay containing two drivers from
[Protectli](https://kb.protectli.com/kb/wifi-modules-for-protectli-vaults/)
will be applied automatically. The relevant files located in the
`wifi-fix-standalone-0.3.1.tar.gz` file provided by `Protectli` have been
copied over to the repo:

```bash
user in ~/openwrt-zarhus:# tree files
files
└── lib
    └── firmware
        └── ath10k
            └── QCA6174
                └── hw3.0
                    ├── board-2.bin
                    └── firmware-6.bin

6 directories, 2 files
user in ~/openwrt-zarhus:#
```

and they will replace the default driver files, which are not working.

# Running

This setup has been tested on two platforms so far, with the following results:

## VP2430 with JWW6051

Once this setup is built and booted, all that remains to be done is change and
commit the wireless config, so that the network is enabled:

```bash
uci set wireless.radio0.disabled='0'
uci commit wireless
wifi reload
```

And then the network should be visible:

```bash
root@OpenWrt:~# iw dev
phy#0
        Interface phy0-ap0
                ifindex 7
                wdev 0x1
                addr 00:15:61:21:eb:62
                ssid OpenWrt
                type AP
                channel 36 (5180 MHz), width: 80 MHz, center1: 5210 MHz
                txpower 23.00 dBm
                multicast TXQ:
                        qsz-byt qsz-pkt flows   drops   marks   overlmt hashcol tx-bytes        tx-packets
                        0       0       0       0       0       0       0       0               0
```

and connections can be made:

```bash
root@OpenWrt:~# iwinfo phy0-ap0 assoclist
No station connected
root@OpenWrt:~# iwinfo phy0-ap0 assoclist
No station connected
root@OpenWrt:~# iwinfo phy0-ap0 assoclist
AE:D0:E6:3C:90:EC  -35 dBm / -100 dBm (SNR 65)  90 ms ago
        RX: 390.0 MBit/s, VHT-MCS 9, 80MHz, VHT-NSS 1       175 Pkts.
        TX: unknown                                      134 Pkts.
        expected throughput: unknown

root@OpenWrt:~#
```

## VP2440 with AW7916-AED

We can see that the `kmod-igc` driver is working:

```bash
...
[    8.234173] igc 0000:02:00.0 eth0: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
...
[   13.697518] igc 0000:02:00.0 eth0: entered allmulticast mode
[   13.703612] igc 0000:02:00.0 eth0: entered promiscuous mode
[   16.734132] igc 0000:02:00.0 eth0: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RXroot@OpenWrt:~# ip a
...
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br-lan state UP qlen 1000
    link/ether 00:e0:97:1b:95:25 brd ff:ff:ff:ff:ff:ff
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN qlen 1000
    link/ether 00:e0:97:1b:95:26 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:e0:97:1b:95:23 brd ff:ff:ff:ff:ff:ff
5: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:e0:97:1b:95:24 brd ff:ff:ff:ff:ff:ff
6: br-lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP qlen 1000
    link/ether 00:e0:97:1b:95:25 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.1/24 brd 192.168.1.255 scope global br-lan
       valid_lft forever preferred_lft forever
    inet6 fdbd:bd47:5814::1/60 scope global noprefixroute
       valid_lft forever preferred_lft forever
    inet6 fe80::2e0:97ff:fe1b:9525/64 scope link
       valid_lft forever preferred_lft forever
```

Also the wifi card is working as well:

```bash
# before connection
root@OpenWrt:~# iw dev phy1-ap0 station dump
# after connection
root@OpenWrt:~# iw dev phy1-ap0 station dump
Station ae:d0:e6:3c:90:ec (on phy1-ap0)
        inactive time:  140 ms
        rx bytes:       9158
        rx packets:     119
        tx bytes:       8317
        tx packets:     80
        tx retries:     0
        tx failed:      0
        rx drop misc:   1
        signal:         -53 [-63, -53] dBm
        signal avg:     -52 [-63, -52] dBm
        tx bitrate:     390.0 MBit/s VHT-MCS 9 80MHz VHT-NSS 1
        tx duration:    11807 us
        rx bitrate:     6.0 MBit/s 80MHz
        rx duration:    18860 us
        last ack signal:-52 dBm
        avg ack signal: -53 dBm
        airtime weight: 256
        authorized:     yes
        authenticated:  yes
        associated:     yes
        preamble:       long
        WMM/WME:        yes
        MFP:            no
        TDLS peer:      no
        DTIM period:    2
        beacon interval:100
        short slot time:yes
        connected time: 6 seconds
        associated at [boottime]:       1591.957s
        associated at:  1748445586298 ms
```

# Included packages

Explicitly enabled packages in the config include:

## Wired NIC drivers

* `CONFIG_PACKAGE_kmod-igc`
* `CONFIG_PACKAGE_kmod-igb`
* `CONFIG_PACKAGE_kmod-i40e`
* `CONFIG_PACKAGE_kmod-iavf`

## Wireless drivers and firmware

* `CONFIG_PACKAGE_kmod-mt76-core`
* `CONFIG_PACKAGE_kmod-mt76x2-common`
* `CONFIG_PACKAGE_kmod-mt76x2`
* `CONFIG_PACKAGE_kmod-mt7915e`
* `CONFIG_PACKAGE_kmod-mt7915-firmware`
* `CONFIG_PACKAGE_kmod-mt7916-firmware`
* `CONFIG_PACKAGE_mt7915-firmware`
* `CONFIG_PACKAGE_mt7916-firmware`
* `CONFIG_PACKAGE_kmod-ath10k`

And also `LuCi` interface embedded into the image.
