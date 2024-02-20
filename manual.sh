# Must check we are running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
apt-get update

apt-get install -y curl cups cups-pdf cups-client cups-bsd cups-ipp-utils libcups2-dev && \
apt-get clean && \
find /var/lib/apt/lists -type f -delete

# Setup PrintNode
mkdir /usr/local/PrintNode && \
curl -s -o /root/PrintNode.tar.gz https://dl.printnode.com/client/printnode/4.27.8/PrintNode-4.27.8-pi-bullseye-armv7l.tar.gz && \
tar -xz -C /usr/local/PrintNode --strip-components 1 -f /root/PrintNode.tar.gz && \
rm /root/PrintNode.tar.gz

# Remove backends that aren't needed
rm /usr/lib/cups/backend/parallel && \
rm /usr/lib/cups/backend/serial && \
rm /usr/lib/cups/backend/cups-brf

# Allow remote connections, turn on browsing and allow unsecure HTTP
sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# Add admin user to lpadmin group
usermod -a -G lpadmin admin

# Setup services
systemd enable cups
systemd restart cups
systemd status cups

# Setup printnode service
## Don't run as admin as unreliable
## sed -i 's/user=""/user="admin"/' /usr/local/PrintNode/init.sh && \
cp /usr/local/PrintNode/init.sh /etc/init.d/PrintNode && \
update-rc.d PrintNode defaults && \
systemctl daemon-reload && \
systemctl enable PrintNode
systemctl restart PrintNode
systemd status PrintNode

echo "Once PrintNode is loaded, login to the web interface with the 'admin' user and add your printers."
