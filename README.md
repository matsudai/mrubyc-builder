# mruby/c for ESP32

## Requirements

* Windows 10 Home (21H2)
  * Drivers for ESP32
    * refs: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/establish-serial-connection.html
  * Docker Desktop (4.10.1)

## Installation

Use command prompt. (`Win + r` > `cmd`)

1. Download this repository

```cmd
git clone https://github.com/matsudai/mrubyc-builder.git
cd mrubyc-builder
```

2. Build Docker image.

```cmd
docker build -t localhost/mrubyc .
```

3. Run container.

```cmd
docker run -d --rm -it localhost/mrubyc bash
```

4. Export Docker filesystem.

* `<CONTAINER_ID>` is CONTAINER_ID in result of `docker ps` . (e.g. `a581beb190b2`)

```cmd
docker ps
docker export <CONTAINER_ID> > .\mrubyc-2.1.0.tar
```

After exported, stop container.

```cmd
docker stop <CONTAINER_ID>
```

5. Import Docker filesystem as WSL1

```cmd
mkdir C:\wsl-distro\mrubyc-2.1.0
wsl --import mrubyc-2.1.0 C:\wsl-distro\mrubyc-2.1.0 .\mrubyc-2.1.0.tar --version 1
```

After imported, you can delete image.

```cmd
del .\mrubyc-2.1.0.tar
docker rmi <CONTAINER_ID>
```

## Check

1. Run the WSL distro.

* `[Win + r]`

```cmd
wsl -d mrubyc-2.1.0
```

2. Clone mrubyc project in WSL terminal. (Thanks for https://github.com/gfd-dennou-club)

* refs: https://github.com/gfd-dennou-club/mrubyc-esp32.git

```sh
git clone --depth 1 https://github.com/gfd-dennou-club/mrubyc-esp32.git
cd mrubyc-esp32
```

3. Init mrubyc project in WSL terminal.

```sh
make menuconfig        # -> ESC
export PORT=/dev/ttyS3 # Specify your device
```

4. Build and flash mrubyc programs.

```sh
make spiffs         # Build
make flash-vm       # Build & Flash
make spiffs-monitor # Monitor

# Results (exit : `ctrl + ]`)

    ...
  hello world from ESP32 (master)
  hello world from ESP32 (master)
  hello world from ESP32 (master)
    ...
```

## Uninstallation

1. Specify the WSL distro.

```cmd
wsl -l -v
```

2. Remove distro.

```cmd
wsl --unregister mrubyc-2.1.0
```

3. Check the WSL distro is deleted.

```cmd
wsl -l -v
```

4. Delete the installed folder (`C:\wsl-distro\mrubyc-2.1.0`) .

If `C:\wsl-distro` is empty, you can delete `C:\wsl-distro` .
