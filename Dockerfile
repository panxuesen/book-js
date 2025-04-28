FROM registry.cn-hangzhou.aliyuncs.com/consume/book-js:base 

WORKDIR /book_js

COPY ./package.json /book_js

RUN pwd && ls /book_js

RUN npm cache clean --force \
    && npm config set registry https://registry.npmjs.org -g\
    && rm -rf public  \
    && mkdir -p public \
    && yarn install \
    && yarn cache clean --force \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get clean all


COPY . /book_js
RUN chmod 777 *.sh


EXPOSE 3000

VOLUME /book_js/public

ENTRYPOINT /book_js/run.sh