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
by protectli, in which the VP2410 is used. The service has been tested on
VP2430 platform, on which it worked.

It's worth to note that despite those platforms having different
Super I/O chips:

* VP2410: `IT8613E`
* VP2430: `IT8659E`

The differences appear to not alter the functionality of the script. If it is
found to not work on certain protectli platforms, the script can be improved
by adding platform detection, where it will check what platform it is running
on, then adjust the `PORT` and `MASK` values for that specific platform.
