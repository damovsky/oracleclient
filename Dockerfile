# Pull base image.
FROM wscherphof/oracle-linux-7

RUN yum -y install binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33.i686 gcc gcc-c++ glibc.i686 glibc glibc-devel glibc-devel.i686 ksh libgcc.i686 libgcc libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 libaio libaio.i686 libaio-devel libaio-devel.i686 libXext libXext.i686 libXtst libXtst.i686 libX11 libX11.i686 libXau libXau.i686 libxcb libxcb.i686 libXi libXi.i686 make sysstat vte3 smartmontools unzip sudo wget tar && \
yum clean all



ADD sysctl.conf /etc/sysctl.conf && \
	echo "oracle soft stack 10240" >> /etc/security/limits.conf && \
	echo "session     required    pam_limits.so" >> /etc/pam.d/login

# create user and group for oracle
RUN groupadd -g 54321 oinstall && \
	groupadd -g 54322 dba && \
	userdel oracle && \
	rm -rf /home/oracle && \
	rm /var/spool/mail/oracle && \
	useradd -m -u 54321 -g oinstall -G dba oracle && \
	echo "oracle:oracle" | chpasswd && \
	mkdir -p /opt/oracle /oracle && \
	chown oracle.oinstall /opt/oracle /oracle


ADD linux.x64_11gR2_client.zip /tmp/install/linux.x64_11gR2_client.zip
ADD client_install.rsp /tmp/install/client_install.rsp
ADD install.sh /tmp/install/install.sh

RUN chmod +x /tmp/install/install.sh && \
	cd /tmp/install && \
	unzip /tmp/install/linux.x64_11gR2_client.zip && \
	chown -R oracle:oinstall /tmp/install/ && \
	su -s /bin/bash oracle -c "/tmp/install/install.sh" && \
	/oracle/oinventory/orainstRoot.sh && \
	/oracle/app/ohome/root.sh && \
	rm -Rf /tmp/install

# RUN mkdir -p /usr/local/apache-maven && \
#	cd /usr/local/ && \
#	wget http://mirror.olnevhost.net/pub/apache/maven/binaries/apache-maven-3.2.1-bin.tar.gz && \
#	tar xvf apache-maven-3.2.1-bin.tar.gz && \
#	mv ./apache-maven-3.2.1 /usr/local/apache-maven/ && \
#	rm -f /usr/local/apache-maven-3.2.1-bin.tar.gz

#ENV M2_HOME /usr/local/apache-maven/
#ENV M2 $M2_HOME/bin
#ENV PATH $M2:$PATH

ENV ORACLE_HOME /oracle/app/ohome/
ENV PATH $PATH:$ORACLE_HOME/bin
ENV LD_LIBRARY_PATH $ORACLE_HOME/lib

RUN rm -rf /var/lib/yum/history/* /tmp/* /var/tmp/* /var/log/* /oracle/oinventory/logs/* /oracle/app/ohome/install/*

# Define working directory.
WORKDIR /tmp

# Define default command.
CMD ["/bin/bash"]