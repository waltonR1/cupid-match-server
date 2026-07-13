FROM maven:3.9.11-eclipse-temurin-17 AS build

WORKDIR /workspace
COPY . .
RUN mvn -pl ruoyi-admin -am clean package -DskipTests

FROM eclipse-temurin:17-jre

WORKDIR /app
COPY --from=build /workspace/ruoyi-admin/target/ruoyi-admin.jar app.jar

ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0"
EXPOSE 10000

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
