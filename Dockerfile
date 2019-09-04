# docker build . -t [tag]
# docker run -it -v ${PWD}:/source_code [tag]
FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install curl git nano wget sshpass -y
# nodejs 11
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install nodejs -y
# angular cli
RUN echo -ne '\n'|npm install -g @angular/cli@8.1.0
RUN apt-get clean
# chrome
RUN wget http://www.slimjetbrowser.com/chrome/files/75.0.3770.80/google-chrome-stable_current_amd64.deb &&\
    apt-get install -f -y ./google-chrome-stable_current_amd64.deb &&\
    rm -f google-chrome-stable_current_amd64.deb
# clean up
RUN apt clean && rm -rf /var/lib/apt/lists/*
# working dir
RUN mkdir app
WORKDIR /app
VOLUME ["/app"]

