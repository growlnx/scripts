# Scripts

My personal script collection

## helper

Utility commands to speed up daily activies.

It can be sourced:
```
$ source ./helper.sh
$ aproxy --transparent --enable --address 192.168.1.2:8080
```

Or used as a regular bash script

```
$ ./helper.sh aproxy --transparent --enable -address 192.168.1.2:8080
```

### AProxy

AProxy allows you to setup transparent proxy via android iptables and explicit proxy via android settings.

The order does not matter, you can just do:

```
$ aproxy -eta 192.168.1.2:8080
```

If you have more than one device connected, you can specify which one you want to use via the --serial flag:

```
$ aproxy -eta 192.168.1.2:8080 -s 192.168.1.10:5555
```

It supports long/short parameters, the order does not matter:

```
$ aproxy -h
aproxy -- Android Proxy Manager
-a, --address                Proxy's address ipv4:port
-s, --serial                 ADB serial
-t, --transparent            Transparent proxy via Android's iptables
-e|-d, --enable|--disable    Enable or disable the proxy
-h, --help                   Displays this message
```

### AScr

This command allows you to take a screenshot or download it from the device.

Taking a screenshot:

```
$ ascr -c
```

Downloading the 2 most recent screenshots:

```
$ ascr -d 2
```

See --help for more details.