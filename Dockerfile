FROM ubuntu:22.04
LABEL maintainer="scott@firstclasswatches.co.uk"

ADD run.sh /root/

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

RUN apt-get update

RUN apt-get install -y curl cups cups-pdf cups-client cups-bsd cups-ipp-utils libcups2-dev && \
    apt-get clean && \
    find /var/lib/apt/lists -type f -delete

# Setup PrintNode
RUN mkdir /usr/local/PrintNode && \
    curl -s https://dl.printnode.com/client/printnode/4.27.8/PrintNode-4.27.8-ubuntu-22.04-x86_64.tar.gz | \
    tar -xz -C /usr/local/PrintNode --strip-components 1

# Remove backends that aren't needed
RUN rm /usr/lib/cups/backend/parallel \
    && rm /usr/lib/cups/backend/serial \
    && rm /usr/lib/cups/backend/cups-brf

# Allow remote connections, turn on browsing and allow unsecure HTTP
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

CMD /root/run.sh
