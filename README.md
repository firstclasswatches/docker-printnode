
# Installation

Make sure to create a named volume to store your CUPS configuration. Pre-defining an empty named volume with for e.g `docker volume create printnode` will allow /etc/cups directory to be copied over into the new volume. Failure to provide a working CUPS configuration directory will result in a broken container.

# Build Multi-Platform Image

```bash
cd printnode
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 -t scottie1010/printnode:0.0.2 -t scottie1010/printnode:latest .
```

# Run Image

```bash
docker run -d \
-e PRINT_CLIENT_EMAIL='test@example.com' \
-e PRINT_CLIENT_PASSWORD='printnode' \
-e CUPS_USER='admin' \
-e CUPS_PASSWORD='printnode' \
--network='bridge' \
-p 631:631 \
-p 8888:8888 \
--restart unless-stopped \
printnode
```

# Environment Variables

- CUPS_USER - The username to secure CUPS
- CUPS_PASSWORD - The password to secure CUPS
- PRINT_CLIENT_EMAIL - Email you use to login to PrintNode
- PRINT_CLIENT_PASSWORD - Password you use to login to PrintNode

# Adding Printers (IPP)

To add printers, you can use IPP (which negates the need for drivers) by attaching to the running container and running something like the following:

```bash
docker container exec CONTAINER lpadmin -p LabelPrinter -E -v ipp://192.168.86.44/ipp -m everywhere
docker container exec CONTAINER lpadmin -p LaserPrinter -E -v ipp://192.168.86.54/ipp -m everywhere
```
