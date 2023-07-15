# For Java 11, try this
FROM eclipse-temurin:11

# Refer to Maven build -> finalName
ARG JAR_FILE=target/spring-boot-web.jar

# cd /opt/app
WORKDIR /opt/app

# cp target/spring-boot-web.jar /opt/app/app.jar
COPY ${JAR_FILE} spring-boot-web.jar

# java -jar /opt/app/app.jar
CMD [ "java","-jar","spring-boot-web.jar" ]
