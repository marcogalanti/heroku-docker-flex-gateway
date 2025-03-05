FROM mulesoft/flex-gateway:1.8.3

ADD start.sh /start.sh
CMD ["/start.sh"]
