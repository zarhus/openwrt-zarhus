# Quick step-by-step building guide

This is a quick step-by-step guide for building an OpenWrt image for Protectli
platforms. It is assumed that Fedora 41 is being used, but
[this repository](https://github.com/mwarning/docker-openwrt-build-env)
can also be used (the directions in the
[README.md](https://github.com/mwarning/docker-openwrt-build-env/blob/master/README.md)
need to be followed).

# Dependencies

Install dependencies for build-system:

```bash
sudo dnf install \
  gawk git subversion rsync wget which time tar unzip patch diffutils findutils \
  bzip2 gzip xz flex bison gettext gettext-devel texinfo help2man sharutils \
  perl perl-Thread-Queue perl-FindBin perl-IPC-Cmd perl-Data-Dumper \
  python3 python3-pip \
  ncurses-devel ncurses-compat-libs zlib-devel openssl-devel elfutils-libelf-devel \
  glibc-static libstdc++-static ccache
```

Install OpenWrt feeds (packages):

```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

_Note: During running the above steps, the dependency warnings might occur.
Warnings are normal and can safely be ignored unless one explicitly requires one
of the affected packages._

Finally, to test if all necessary tools are installed run:

```bash
make prereq
```

_Note: after running this command the `menuconfig` configuration menu will
open. Continue according to the [configuration](#configuration) section._

[This repository](https://github.com/mwarning/docker-openwrt-build-env) can
also be used (the directions in the
[README.md](https://github.com/mwarning/docker-openwrt-build-env/blob/master/README.md)
need to be followed).

# Configuration

This section showcases how to set up a working configuration manually, or use
a predefined one.

If you want to use predefined configuration, close the opened `menuconfig`
configuration menu and proceed to step
"[Using predefined config](#using-predefined-config)".

If you want to set up the configuration manually continue with the next section.

## Manual configuration

If `menuconfig` isn't opened up already, run `make menuconfig` to open
`menuconfig`, then:

* select `Target System` to be `x86`
* select `Subtarget` to be `x86_64`

This seems like a reasonable starting point for building for `VP2430` platform.
Then, enable drivers:

* `Kernel modules` -> `Network Devices` -> `kmod-igc`
* `Kernel modules` -> `Block Devices` -> `kmod-nvme`

`kmod-igc` is the Intel I225/I226 driver, which is needed for the four NICs,
while `kmod-nvme` enables us to use/boot from the NVME memory.

Ensure that dmidecode is available, because platform-specific logic will be
present:

* `Utilities` -> `dmidecode`

Finally, embed `LuCi` interface into the image:

* `LuCi` -> `Collections` -> `luci-ssl-openssl`

It's also a good idea to add `opkg` package manager by going to `Base System`
and selecting `opkg`.

## Enabling serial output

Run `make menuconfig`, then go to `Target Images`. Make sure `Build GRUB images`
and `Build GRUB EFI images` are checked, and change the baud rate from the
default `38400` to `115200`.

> TBD:
>
> tpm support - seems to be `kmod-tpm-tis` in `Kernel modules` -> `TPM Devices`
> WiFi card support - seems to be `kmod-iwlwifi`

## Using predefined config

A working `defconfig` with all of these changed applied can be found in
`docs/files/minimal-defconfig`. It can be reused like this:

```bash
cat docs/files/minimal-defconfig > .config
make defconfig
```

If any changes to the configuration have been made, the `defconfig` can be
re-generated like follows:

```bash
./scripts/diffconfig.sh > docs/files/minimal-defconfig
```

# Building

In order to build, make sure that the configuration is exactly as explained
above, and that the dependencies are installed. Then, just run
`make -j$(nproc) V=s`.

# Flashing

The image files produced by building are available in `bin/targets/x86/64/`.
The one that interest us is
`openwrt-x86-64-generic-squashfs-combined-efi.img.gz`. It can be flashed
from the root directory with these commands:

```bash
sudo umount /dev/sdX*
gunzip -c bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
sudo sync
```

> Note: remember to replace `/dev/sdX` with the actual device that needs to be
> flashed.

# Booting

To boot, connect the power to the `Power Supply Connector` on the rear panel
(number `#6` in the
[datasheet](https://kb.protectli.com/wp-content/uploads/sites/9/2025/04/VP2430-Datasheet-20250404.pdf)).

Also connect to serial using the `USB-C COM Port` on the front panel (again
info available in the
[datasheet](https://kb.protectli.com/wp-content/uploads/sites/9/2025/04/VP2430-Datasheet-20250404.pdf)).
Make sure to use a USB cable that supports data transfer.

Insert the USB stick with OpenWrt, connect with `minicom`:

```bash
minicom -D /dev/ttyUSBX -c on
```

> Note: the `/dev/ttyUSBX` needs to match the actual serial port.

All that remains is to boot the platform.

> Note: right now with this configuration OpenWrt does not appear as a one-time
> bootable option in the Dasharo menu. It needs to be booted from file.

# Running image in a VM

In order to run the image in a VM, we can use a script from
[open-source-firmware-validation](https://github.com/Dasharo/open-source-firmware-validation/).

Just make sure to flash the image:

```
cd open-source-firmware-validation
gunzip -c /path/to/openwrt-zarhus/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz > image
export HDD_PATH=./image
./scripts/ci/qemu-run.sh graphic os
```

The virtual machine should boot up and into OpenWrt.
