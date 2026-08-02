FROM alpine@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce

WORKDIR  /App_redis

RUN apk update && \
		apk add --no-cache redis
		

COPY --chmod=744 /conf/init.sh /App_redis/init.sh

ENTRYPOINT ["/App_redis/init.sh"]

#EXPOSE ${REDIS_PORT}

CMD ["redis-server"]

