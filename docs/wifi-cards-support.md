# Building

Use the defconfig provided at `docs/files/jww6051-working` in order to build an
image that has support for that card.

```bash
cat docs/files/jww6051-working > .config
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
