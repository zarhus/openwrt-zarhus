# Reset button support

These two files in the `files` OpenWRT overlay provide support for the desired
reset button functionality:

* [`files/etc/init.d/reset-button`](./../files/etc/init.d/reset-button)
* [`files/usr/lib/reset-button-watch.sh`](./../files/usr/lib/reset-button-watch.sh)

Together they make a service that listens for change on `/dev/port` that
corresponds to the reset button. It checks if the button is pressed every
second, and when that is the case, it will trigger a
[soft factory reset](https://openwrt.org/docs/guide-user/troubleshooting/failsafe_and_factory_reset#soft_factory_reset)
sequence (although the script can be very easily modified to do anything).

All the user has to do is to build according to [this guide](./building.md),
and the `files` overlay will get applied automatically, meaning the service
will be there already. Then just press the reset button (next to the power
button) for at least ten seconds in a row, in order to do a soft factory reset.

This service should work with any of the defconfigs provided in `docs/files`,
as it doesn't require a GPIO driver to operate.

# Note about different platforms

This so far has been based off of
[this guide](https://kb.protectli.com/kb/mapping-the-reset-button-on-vp2410-in-linux/)
by protectli, in which the VP2410 is used. The service has been tested on the
following platforms:

- VP2410 with Dasharo (coreboot+UEFI) v1.1.1
- VP2420 with Dasharo (coreboot+UEFI) v1.2.2-rc1
- VP2430 with Dasharo (coreboot+UEFI) v0.9.0
- VP2440
- VP4630 with Dasharo (coreboot+UEFI) v1.2.1-rc5
- VP6650
- VP6670

by physically holding the reset button for 10 seconds on each one.

The OpenWRT image has been built from the commit
`553e7f90f4154ca024d0a1e25117215abc896d5a`. The
*protectli-openwrt-factory-reset-service* feed's revision is provided in
[feeds.conf.default](../feeds.conf.default).

It's worth to note that despite those platforms having different
Super I/O chips:

* VP2410: `IT8613E`
* VP2430: `IT8659E`

The differences appear to not alter the functionality of the script. If it is
found to not work on certain protectli platforms, the script can be improved
by adding platform detection, where it will check what platform it is running
on, then adjust the `PORT` and `MASK` values for that specific platform.

# Testing the factory reset

To test if the factory reset functionality works as intended, ensure that the
Protectli platform has the most recent Dasharo firmware deployed. Otherwise
machines like the VP4630 with no eMMC support might present themselves
incorrectly with `dmidecode` - this has been fixed as of Dasharo v1.2.1-rc5.
Deploy the OpenWRT image to the Protectli platform, boot to OpenWRT and create
an example empty file:

```shell
cd ~
touch somefile
```

Enable printing the system logs:

```shell
logread -f
```

Hold the reset button for 10 seconds and see if the messages appear in the
logs:

(At minimum it's expected that the `reset-button-watch: button held 10 s -
factory reset initiated` message is printed)

```console
Fri May 22 03:58:11 2026 daemon.warn odhcpd[2142]: No default route present, overriding ra_lifetime to 0!
Fri May 22 03:58:17 2026 user.notice reset-button-watch: button held 10 s - factory reset initiated
Fri May 22 03:58:17 2026 daemon.info jffs2reset: /dev/loop0 is mounted as /overlay, only erasing files
Fri May 22 03:58:17 2026 daemon.info procd: - shutdown -
Fri May 22 03:58:17 2026 authpriv.info dropbear[1916]: Early exit: Terminated by signal
Failed to find log object: Not found
[10680.785967] br-lan: port 1(eth0) entered disabled state
[10680.791525] igc 0000:01:00.0 eth0: left allmulticast mode
[10680.796953] igc 0000:01:00.0 eth0: left promiscuous mode
[10680.802411] br-lan: port 1(eth0) entered disabled state
Failed to find log object: Not found
[10685.318988] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[10685.651376] ACPI: PM: Preparing to enter system sleep state S5
[10685.658608] reboot: Restarting system
[10685.662292] reboot: machine restart
3hDEL   to enter Setup
```

Observe the platform rebooting - once finished, see if the example `somefile`
is still present. It must **not** exist to confirm that the factory reset works
properly.
