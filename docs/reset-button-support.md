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

# Testing the factory reset

To test if the factory reset functionality works as intended, ensure that the
Protectli platform has the most recent Dasharo firmware deployed.

1. Deploy the OpenWRT image to the Protectli platform, boot to OpenWRT and create
an example empty file:

    ```bash
    cd ~
    touch somefile
    ```

2. Enable printing the system logs:

    ```shell
    logread -f
    ```

3. Hold the reset button for 10 seconds and see if the message
   `reset-button-watch: button held 10 s - factory reset initiated` appear in
    the logs:

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
    ```

4. Observe the platform rebooting - once finished, see if the example `somefile`
    is still present. If it is not present after the reboot - that means the
    factory reset works as expected.

# Test results

This so far has been based on [this
guide](https://kb.protectli.com/kb/mapping-the-reset-button-on-vp2410-in-linux/)
by protectli, in which the VP2410 is used.

The test results per platform and firmware, the OpenWRT image is the same for
every test and was built according to [the build instructions](./building.md)
from tag `protectli-v24.10.2-rc1` from this repository:

<!--

The images hash'es from the table below:
* Dasharo (coreboot+UEFI) v0.9.2:
  9020ceb1334c7315256df96018d16301117e6df46a4c869265a563253969142a
* Dasharo (coreboot+UEFI) v1.2.1-rc5:
  e8aaf0c5724e6d6cd38e344175ceaff2172d7314785ad3dfeb0b50d360f605c6
* Dasharo (coreboot+UEFI) v1.2.2-rc1:
  09f8d4b07a97c6ed99cf55c681685b651fd078d01b85587a8d008bd7635938a6
* Dasharo (coreboot+UEFI) v0.9.0:
  50b1df04ff73cc6a5f51b8bfb5845f316c827a5d71d8b581e55f45ca377e0c26
* Dasharo (coreboot+UEFI) v1.1.1: not known.
  

Some notes:
* The VP6650 was not available for testing, so the tests for the family VP66XX
  was done only on VP6670.
* The VP46XX was tested only on VP4630.
* The VP2440 was not available for testing.
* The V1XXX is not supported because the reset button is not connected to the
  IO that can be read from OpenWRT.

-->

|      | V1XXX                | VP2410 | VP2420 | VP2430 | VP2440 | VP46XX | VP66XX |
|------|----------------------|--------|--------|--------|--------|--------|--------|
| -    | Is not supported (h) | -      | -      | -      | -      | -      | -      |
| Dasharo (coreboot+UEFI) v1.1.1  | -                | Works | -      | -      | -      | -      | -      |
| Dasharo (coreboot+UEFI) v1.2.2-rc1 | - | - | Works | - | - | - | - |
| Dasharo (coreboot+UEFI) v0.9.0 | - | - | - | Works | - | - | - |
| - | - | - | - | - | Not tested | - | - |
| Dasharo (coreboot+UEFI) v1.2.1-rc5 | - | - | - | - | - | Works | - |
| Dasharo (coreboot+UEFI) v0.9.2 | - | - | - | - | - | - | Works |

> The "Is not supported (h)" means there is no way to activate this feature on
> this hardware.

The testing was done according to the [previous
chapter](#testing-the-factory-reset).

If it is found to not work on certain protectli platforms, the script can be
improved by adding platform detection, where it will check what platform it is
running on, then adjust the `PORT` and `MASK` values for that specific platform.
