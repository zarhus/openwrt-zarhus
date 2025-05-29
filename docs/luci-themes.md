# Luci GUI configuration

This document describes the process of configuring the `LuCi` web interface.

## Setup note

This has been tested on the `VP2430`, with the `eth0` port (furthest away from
the power source) being used for internet connection (for easy installation of
packages), and `eth1` (next to `eth0`) being directly connected to the PC on
which the GUI is being tested. After running these commands on the `VP2430`:

```bash
ip link set eth0 up
ip link set br-lan up
/etc/init.d/network restart
```

The web interface could be accessed from the PC at
[http://192.168.1.1/](http://192.168.1.1/).

Keep in mind, this is just an example simple setup, that allows for the `LuCi`
interface to be accessed. It can be done in other ways.

## Basics of configuration

By default, the image comes with `LuCi` already embedded into it. `LuCi` can
use different themes, to change how the web browser interface looks. These are
the available themes:

```console
root@OpenWrt:~# opkg list | grep -i luci-theme
luci-theme-bootstrap - 25.137.37373~691440a - Bootstrap Theme (default)
luci-theme-material - 25.137.37373~691440a - Material Theme
luci-theme-openwrt - 25.137.37373~691440a - LuCI OpenWrt.org theme
luci-theme-openwrt-2020 - 25.137.37373~691440a - LuCI modern OpenWrt theme
root@OpenWrt:~#
```

By default, the image comes with `luci-theme-bootstrap` installed, which
provides three design layouts:

* `Bootstrap`
* `BootstrapDark`
* `BootstrapLight`

In order to change the current design layout, go to `System -> System`:

![](./img/system-system.png)

Then change the design layout in the `Design` dropdown:

![](./img/change-design-layout.png)

Then click `Save & Apply`.

If there is a need to use other design layouts, they can all be easily
installed like this:

```bash
echo 'src/gz openwrt_luci https://downloads.openwrt.org/releases/24.10.1/packages/x86_64/luci' >> /etc/opkg/distfeeds.conf
opkg update
opkg install luci-theme-material luci-theme-openwrt luci-theme-openwrt-2020
```

Then they are available in the same spot as all the `Bootstrap` variations,
so in `System -> System -> Design`:

![](./img/all-design-layouts-in-gui.png)

## Theme showcase

Here is a quick showcase of all the different, default (available in `opkg`)
themes.

### Bootstrap && BootstrapDark

These seem to be the same exact theme:

<table>
  <tr>
    <td><img src="./img/Bootstrap-system-system.png" width="800"/></td>
    <td><img src="./img/Bootstrap-realtime.png" width="800"/></td>
  </tr>
  <tr>
    <td><img src="./img/Bootstrap-wireless.png" width="800"/></td>
    <td><img src="./img/Bootstrap-routing.png" width="800"/></td>
  </tr>
</table>

### BootstrapLight

<table>
  <tr>
    <td><img src="./img/BootstrapLight-system-system.png" width="800"/></td>
    <td><img src="./img/BootstrapLight-realtime.png" width="800"/></td>
  </tr>
  <tr>
    <td><img src="./img/BootstrapLight-wireless.png" width="800"/></td>
    <td><img src="./img/BootstrapLight-routing.png" width="800"/></td>
  </tr>
</table>

### Material

<table>
  <tr>
    <td><img src="./img/Material-system-system.png" width="800"/></td>
    <td><img src="./img/Material-realtime.png" width="800"/></td>
  </tr>
  <tr>
    <td><img src="./img/Material-wireless.png" width="800"/></td>
    <td><img src="./img/Material-routing.png" width="800"/></td>
  </tr>
</table>

### OpenWRT

<table>
  <tr>
    <td><img src="./img/OpenWRT-system-system.png" width="800"/></td>
    <td><img src="./img/OpenWRT-realtime.png" width="800"/></td>
  </tr>
  <tr>
    <td><img src="./img/OpenWRT-wireless.png" width="800"/></td>
    <td><img src="./img/OpenWRT-routing.png" width="800"/></td>
  </tr>
</table>

### OpenWRT-2020

<table>
  <tr>
    <td><img src="./img/OpenWRT-2020-system-system.png" width="800"/></td>
    <td><img src="./img/OpenWRT-2020-realtime.png" width="800"/></td>
  </tr>
  <tr>
    <td><img src="./img/OpenWRT-2020-wireless.png" width="800"/></td>
    <td><img src="./img/OpenWRT-2020-routing.png" width="800"/></td>
  </tr>
</table>

## Making custom changes

For example, let's say the top banner needs to say something else other than
`OpenWRT`, so this needs to be changed:

![](./img/what-needs-to-be-changed.png)

Those files are in `feeds/luci/` in the build system. They can be
modified/inspected in order to find the neccessary information on how to
make this change.

From this file
`themes/luci-theme-bootstrap/ucode/template/themes/bootstrap/header.ut` it can
be deduced, that the `OpenWRT` text is actually dynamically populated from
the router's hostname:

```console
user@e1b48df628f8:~/openwrt-zarhus/feeds/luci/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap$ cat header.ut -n | grep -i hostname
    21			<title>{{ striptags(`${boardinfo.hostname ?? '?'}${node ? ` - ${node.title}` : ''}`) }} - LuCI</title>
    50				<a class="brand" href="/">{{ striptags(boardinfo.hostname ?? '?') }}</a>
user@e1b48df628f8:~/openwrt-zarhus/feeds/luci/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap$
```

This means that all that needs to be done in order to change the top banner
from `OpenWRT` to `OpenWRT-Protectli` is to do this on the router:

```bash
uci set system.@system[0].hostname='OpenWrt-Protectli'
uci commit system
/etc/init.d/system reload
```

And here is the result:

![](./img/OpenWRT-Protectli.png)

As it has been shown, the particular changes to the appearance of the web UI
depend on the exact outcome that needs to be achieved.

But the important thing is these custom changes can be made, and they can be
baked into the image by modifying the source of the `LuCi` package. This above
example didn't require that, but it could have just hard-coded
`OpenWRT-Protectli` into the tag.
