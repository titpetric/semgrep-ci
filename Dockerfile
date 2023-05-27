FROM debian:bullseye-slim

ADD ./bin/hugo /usr/local/bin

WORKDIR /hugo

COPY ./* /hugo/

CMD hugo server -D --bind="0.0.0.0"
