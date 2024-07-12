FROM registry.cn-hangzhou.aliyuncs.com/bay1/maven:3.8.6-amazoncorretto-17 as builder

COPY . /builds

COPY ./settings.xml /usr/share/maven/conf/settings.xml

WORKDIR /builds

RUN mvn clean package -Dmaven.test.skip=true

FROM registry.cn-hangzhou.aliyuncs.com/bay1/amazoncorretto:17

ARG APPLICATION
ARG CLUSTER
ARG ENVIRONMENT

COPY --from=builder /builds/target/*.jar /lib/app.jar

RUN yum install -y tar && yum install -y gzip && mkdir -p /artifacts && tar -zcf /artifacts/artifacts.tar.gz /lib/app.jar

# RUN chown -R $USER:$GROUP /artifacts

CMD exec java $JAVA_OPTS -jar /lib/app.jar -Dserver.port=8888 -DAPPLICATION=$APPLICATION -DCLUSTER=$CLUSTER -DENVIRONMENT=$ENVIRONMENT
