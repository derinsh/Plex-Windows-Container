# Plex in a Windows container

Build tools for a Windows container running Plex Media Server. The script `Build.ps1` will auto-detect the host Windows 10/11 release version, processor architecture and build the image properly.

## Build Instructions

You need docker installed and have to make sure it is in Windows containers mode. If you use Docker Desktop you can select the option in the tray icon context menu. Otherwise enter `$Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon` in a PowerShell prompt.

Running `Build.ps1` will create and install the docker image.

## Docker Instructions

The next step is creating the container.

There are different options for networking. I recommend using a transparent network device. It will get its own IP-address and communicate with your LAN directly. You can see the existing virtual network devices with `docker network ls`. If there are no transparent network devices already you can create one with:

```docker network create -d transparent --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o com.docker.network.windowsshim.dnsservers=1.1.1.1,1.0.0.1 tlan```

Replace with proper addresses and DNS-server. This will create a transparent network device 'tlan'.

My recommendation for creating the container is with:

```
docker run -t -d --name=plex -v C:\Path_to_Plex:C:\Plex -v D:\MediaDir1:C:\MediaDir1:ro -v E:\MediaDir2:C:\MediaDir2:ro --network "tlan" --mac-address d0:c8:32:12:23:56 --ip 192.168.1.101 --isolation process --cpus CPU_NUMBER --restart always plex-win
```

Replace with proper paths for the volumes you want to mount on the container, the static ip you want it to have and the number of CPU cores you want to share. `C:\Path_to_Plex` should be an empty or previously created directory on the host where Plex Media Server can save its configuration. It must be bound to `C:\Plex` on the container side. Media volumes can and should be bound read-only.

The setting `--isolation process` will make all the container's processes and resources visible to the host. This will be easier to manage and yields higher performance. The alternative is `--isolation hyperv` where all the processes will be combined into a virtual machine and not transparent to the host.

You can passthrough your host GPU by adding `--device`. But this is not useful at the moment since Plex doesn't use DirectX and DXVA transcoding.

When the container is up and running you can browse to `http://IP_YOU_SET:32400` and configure Plex. If you re-created the container and kept your old Plex volume all the settings will be restored.

## Extras

For some more helpful info, see https://github.com/dr1rrb/docker-plex-win/blob/master/README.md.

In the future I will release my script for a fully-featured image with tools such as Apache web server with vhosts, automatic SSL certificates from LetsEncrypt with Posh-ACME and Dynamic DNS support with Amazon Route53.
