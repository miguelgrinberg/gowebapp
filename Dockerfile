FROM alpine:latest
RUN mkdir /app
COPY gowebapp /app
RUN mkdir /app/static
COPY static/ /app/static
RUN mkdir /app/vendor
COPY vendor/ /app/vendor
RUN mkdir /app/template
COPY template/ /app/template
RUN mkdir /app/config
COPY docker-boot.sh /app
WORKDIR /app
EXPOSE 80
CMD ["./docker-boot.sh"]
