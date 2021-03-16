# Add Certbot and the Gandi authentication plugin to base alpine image.
FROM alpine:3.13 AS golden-certbot

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Certbot Golden Image"
LABEL maintainer="John Chase <ratteal@gmail.com>"

RUN apk add certbot py3-pip
RUN pip3 install --no-cache-dir -U certbot-plugin-gandi

# Overwrite the default schedules with the certificate renewal job.
RUN echo "14 3 * * 4   certbot renew --authenticator dns-gandi --dns-gandi-credentials /etc/letsencrypt/gandi/gandi.ini" > /etc/crontabs/root

# Start cron running in the foreground.
#
#BusyBox v1.32.1 () multi-call binary.
#
#Usage: crond -fbS -l N -d N -L LOGFILE -c DIR
#
#	-f	Foreground
#	-b	Background (default)
#	-S	Log to syslog (default)
#	-l N	Set log level. Most verbose 0, default 8
#	-d N	Set log level, log to stderr
#	-L FILE	Log to FILE
#	-c DIR	Cron dir. Default:/var/spool/cron/crontabs
#
CMD ["crond", "-f"]
