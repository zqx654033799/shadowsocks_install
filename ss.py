#!/usr/bin/python
import json
import sys

if sys.argv[1] == 'add':
    if len(sys.argv) < 4:
        print('missing required arguments')
        exit(1)
    else:
        if sys.argv[2].isdigit() and int(sys.argv[2]) >= 1 and int(sys.argv[2]) < 65535:
            with open("/etc/shadowsocks.json",'r') as load_f:
                load_dict = json.load(load_f)
            port_password = load_dict['port_password']
            port_password[sys.argv[2]] = sys.argv[3]
            print('add port:%s password:%s' %(sys.argv[2], sys.argv[3]))
            with open("/etc/shadowsocks.json",'w') as dump_f:
                json.dump(load_dict, dump_f, indent=4, sort_keys=True)
            exit(0)
        else:
            print('port in [1-65535]')
            exit(1)
elif sys.argv[1] == 'remove':
    if len(sys.argv) < 3:
        print('missing required arguments')
        exit(1)
    else:
        if sys.argv[2].isdigit() and int(sys.argv[2]) >= 1 and int(sys.argv[2]) < 65535:
            with open("/etc/shadowsocks.json",'r') as load_f:
                load_dict = json.load(load_f)
            port_password = load_dict['port_password']
            del port_password[sys.argv[2]]
            print('remove port:%s' %(sys.argv[2]))
            with open("/etc/shadowsocks.json",'w') as dump_f:
                json.dump(load_dict, dump_f, indent=4, sort_keys=True)
            exit(0)
        else:
            print('port in [1-65535]')
            exit(1)
elif sys.argv[1] == 'list':
    if len(sys.argv) < 2:
        print('missing required arguments')
        exit(1)
    else:
        with open("/etc/shadowsocks.json",'r') as load_f:
            load_dict = json.load(load_f)
        port_password = load_dict['port_password']
        ports = port_password.keys()
        for port in ports:
            print('port:%s password:%s' %(port, port_password[port]))
        exit(0)
elif sys.argv[1] == 'port':
    if len(sys.argv) < 2:
        print('missing required arguments')
        exit(1)
    else:
        with open("/etc/shadowsocks.json",'r') as load_f:
            load_dict = json.load(load_f)
        port_password = load_dict['port_password']
        ports = port_password.keys()
        for port in ports:
            print(port)
        exit(0)
else:
    print('missing required arguments')
    exit(1)
