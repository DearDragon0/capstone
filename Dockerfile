# Use OpenJDK base image
FROM openjdk:11-jre-slim

# Set environment variables
ENV APP_HOME=/usr/app
WORKDIR $APP_HOME

# Copy the JAR file (the build system should name the JAR consistently)
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
