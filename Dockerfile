FROM ubuntu:latest
MAINTAINER John-William Trenholm jw@xomar.com

RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y curl lsb-release supervisor openssh-server puppetmaster puppetmaster-passenger vim git

#remove seed certs
RUN (rm -rf /var/lib/puppet/ssl/certs/4f4aada0a781.pem)
RUN (rm -rf /var/lib/puppet/ssl/private_keys/4f4aada0a781.pem)

#put a new one in apache' config
RUN (HOSTNAME=`hostname` sed -i "s/4f4aada0a781/$HOSTNAME/g" /etc/apache2/sites-enabled/puppetmaster)

#make a new cert
RUN (puppetmasterd start)
RUN (puppetmasterd stop)

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN locale-gen en_US en_US.UTF-8

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo 'root:jw' | chpasswd

EXPOSE 22
EXPOSE 8140

CMD ["/usr/bin/supervisord"]
