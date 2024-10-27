FROM mulesoft/flex-gateway:1.7.1

ADD start.sh /start.sh
CMD ["/start.sh"]