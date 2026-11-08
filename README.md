# Scripts

My personal script collection

## helper

Utilitary commands to speed up daily activies.

### aproxy

This command manages the Android proxy via ADB shell. 

It can be sourced:
```shell
$ source ./helper.sh
$ aproxy --transparent --enable -address 192.168.1.2:8080
```

Or used as a normal bash script

```shell
$ ./helper.sh aproxy --transparent --enable -address 192.168.1.2:8080
```

aproxy allows you to setup transparent proxy via android iptables and explicit proxy via android settings.

The order does not matter, you can simple do:

```shell
$ aproxy -eta 192.168.1.2:8080
```

if you have more than one device connected, you can specify which one you want to use via the --serial flag:

```shell
$ aproxy -eta 192.168.1.2:8080 -s 192.168.1.10:5555
```

```shell
$ aproxy -h
aproxy -- Android Proxy Manager
-a, --address                proxy's address ipv4:port
-e|-d, --enable|--disable    enable or disable the proxy
-s, --serial|--disable       adb serial
```