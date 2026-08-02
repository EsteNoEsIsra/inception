FROM alpine@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce


RUN 	apk update && \
	apk add --no-cache vsftpd \
	gettext \
	shadow 

COPY --chmod=644 conf/sftpd.cnf.template /
COPY --chmod=744 conf/init.sh /init.sh

ENTRYPOINT ["/init.sh"]
#EXPOSE ${VSFTPD_PORT}
CMD ["vsftpd"]
