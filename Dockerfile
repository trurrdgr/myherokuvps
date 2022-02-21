FROM kalilinux/kali-last-release as system
LABEL AboutImage "Ubuntu20.04_Fluxbox_NoVNC"
LABEL Maintainer "HackGodX"
ARG localbuild
ENV DEBIAN_FRONTEND=noninteractive \
#VNC Server Password
	VNC_PASS="samplepass" \
#VNC Server Title(w/o spaces)
	VNC_TITLE="Kali" \
#VNC Resolution(720p is preferable)
	VNC_RESOLUTION="1920x1080" \
#Local Display Server Port
	DISPLAY=:0 \
#NoVNC Port
	NOVNC_PORT=$PORT \
#Ngrok Token (It's advisable to use your personal token, else it may clash with other users & your tunnel may get terminated)
	NGROK_TOKEN="1tNm3GUFYV1A4lQFXF1bjFvnCvM_4DjiFRiXKGHDaTGBJH8VM" \
#Locale
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	TZ="Asia/Kolkata"
RUN apt install -y novnc x11vnc
COPY . /app
RUN apt-get update && \
	apt-get install -y \
#Packages Installation
	tzdata \
	software-properties-common \
	apt-transport-https \
	wget \
	git \
	curl \
	vim \
	zip \
	net-tools \
	iputils-ping \
	build-essential \
	python3 \
	python3-pip \
	python-is-python3 \
	perl \
	ruby \
	golang \
	lua5.3 \
	scala \
	mono-complete \
	r-base \
	default-jre \
	default-jdk \
	clojure \
	php \
	firefox \
	gnome-terminal \
	gnome-calculator \
	gnome-system-monitor \
	gedit \
	vim-gtk3 \
	mousepad \
	libreoffice \
	pcmanfm \
	snapd \
	terminator \
	websockify \
	supervisor \
	x11vnc \
	xvfb \
	gnupg \
	dirmngr \
	gdebi-core \
	nginx \
	novnc \
	openvpn \
	ffmpeg \
	openssh-server pwgen \
	screen \
#Fluxbox
	/app/fluxbox-heroku-mod.deb && \
#MATE Desktop
	apt install -y \ 
	ubuntu-mate-core \
	ubuntu-mate-desktop && \
#XFCE Desktop
	#apt install -y \
	#xubuntu-desktop && \
#TimeZone
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
#NoVNC
	cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
	openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=IN/ST=Maharastra/L=Private/O=Dis/CN=www.google.com" -keyout /etc/ssl/novnc.key  -out /etc/ssl/novnc.cert && \
#VS Code
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
	install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
	sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
	rm -f packages.microsoft.gpg && \
	apt install apt-transport-https && \
	apt update && \
	apt install code -y && \
	cd /usr/bin && \
#Brave
	curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|tee /etc/apt/sources.list.d/brave-browser-release.list && \
	apt update && \
	apt install brave-browser -y && \
#PeaZip
	wget https://github.com/peazip/PeaZip/releases/download/7.9.0/peazip_7.9.0.LINUX.x86_64.GTK2.deb && \
	dpkg -i peazip_7.9.0.LINUX.x86_64.GTK2.deb && \
	rm -rf peazip_7.9.0.LINUX.x86_64.GTK2.deb && \
#Sublime
	curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - && \
	add-apt-repository "deb https://download.sublimetext.com/ apt/stable/" && \
	apt install -y sublime-text && \
#Ngrok
	chmod +x /app/ngrok_install.sh && \
	/app/ngrok_install.sh && \
#Telegram
	wget https://updates.tdesktop.com/tlinux/tsetup.2.7.4.tar.xz -P /tmp && \
	tar -xvf /tmp/tsetup.2.7.4.tar.xz -C /tmp && \
	mv /tmp/Telegram/Telegram /usr/bin/telegram && \
#PowerShell
	wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -P /tmp && \
	apt install -y /tmp/packages-microsoft-prod.deb && \
	apt update && \
	apt-get install -y powershell
# tini for subreap                                   
ARG TINI_VERSION=v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

#ADD files /root

# ffmpeg
RUN mkdir -p /usr/local/ffmpeg && \
    curl -sSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz | tar xJvf - -C /usr/local/ffmpeg/ --strip 1

ENTRYPOINT ["supervisord", "-c"]

CMD ["/app/supervisord.conf"]
