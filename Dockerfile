# Stage 1: Build
FROM maven:3.8.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B  # Batch mode for CI/CD
COPY src ./src
RUN mvn package -DskipTests -Dmaven.test.skip=true

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
RUN addgroup --system spring && \
    adduser --system --ingroup spring spring  # Non-root user
USER spring:spring
COPY --from=build --chown=spring:spring /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]