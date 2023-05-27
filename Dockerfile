FROM debian:bullseye-slim

# RUN apt update && apt install git -y

ADD ./bin/hugo /usr/local/bin

WORKDIR /hugo

COPY ./* /hugo/

ENV HUGO_ENABLEGITINFO=false

CMD hugo server -D --bind="0.0.0.0"
