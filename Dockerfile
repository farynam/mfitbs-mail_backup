FROM debian:stretch
WORKDIR /app
RUN mkdir /backup
RUN apt-get update && apt-get install offlineimap -y && apt-get install ca-certificates -y && update-ca-certificates && apt-get install rsync -y
COPY ./src/ /app/

CMD /app/backup.sh /backup/conf/conf.env
