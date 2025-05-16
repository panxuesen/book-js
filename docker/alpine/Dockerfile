FROM book-js:base

WORKDIR /book_js

COPY ./package.json /book_js

RUN pwd && ls /book_js

# 使用Alpine兼容的命令清理和安装依赖
RUN npm cache clean --force \
    && npm config set registry https://registry.npmjs.org -g \
    && rm -rf public \
    && mkdir -p public/fonts public/pdf public/img \
    && yarn install \
    && yarn cache clean --force \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

# 复制所有文件
COPY . /book_js

# 设置脚本权限
RUN chmod 777 *.sh

# 运行时会执行install-font.sh，因此确保目录权限正确
RUN chmod -R 755 /usr/share/fonts

EXPOSE 80

VOLUME /book_js/public

# RUN sed -i 's/\r$//' /book_js/docker/alpine/run.sh

CMD ["sh", "/book_js/docker/alpine/run.sh"]