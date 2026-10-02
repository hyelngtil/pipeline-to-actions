# =============================================================================
# Dockerfile — Multi-Stage Build for Java Web Application
# =============================================================================
# This Dockerfile uses a "multi-stage build" pattern:
#   Stage 1 (build):   Compiles the Java source code into a WAR file using Maven
#   Stage 2 (runtime): Deploys the WAR into a Tomcat container
#
# WHY MULTI-STAGE?
# - The build stage needs Maven + JDK (large, ~800MB)
# - The runtime stage only needs Tomcat + JRE (small, ~200MB)
# - Multi-stage builds produce smaller, more secure production images
# - Build tools and source code are NOT included in the final image
#
# COMPARISON WITH ORIGINAL PROJECT:
# The original project used buildspec.yml to compile the WAR via CodeBuild,
# stored it in S3, then CodeDeploy's appspec.yml copied it to EC2's Tomcat.
# Here, the Dockerfile replaces BOTH buildspec.yml AND appspec.yml:
#   - Stage 1 = buildspec.yml (compile the code)
#   - Stage 2 = appspec.yml (deploy to Tomcat)
# =============================================================================

# ── STAGE 1: BUILD ──────────────────────────────────────────────────────────
# Use the official Maven image with JDK 8 as the build environment.
# This is equivalent to the CodeBuild environment configuration where we
# selected "amazonlinux2-x86_64-standard:corretto8" as the build image.
FROM maven:3.5.2-jdk-8 AS build

# Set the working directory inside the build container.
# All subsequent commands (COPY, RUN) execute relative to /app.
WORKDIR /app

# OPTIMIZATION: Copy pom.xml FIRST, then download dependencies.
# Docker caches each layer. If pom.xml hasn't changed, Docker reuses the
# cached dependency layer — dramatically speeding up rebuilds.
# (Only re-downloads when pom.xml changes)
COPY pom.xml .
RUN mvn dependency:resolve

# NOW copy the source code and build the WAR file.
# This step re-runs on every code change, but dependencies are cached above.
COPY src ./src
RUN mvn clean package -DskipTests

# After this stage, the compiled WAR exists at:
#   /app/target/pipeline-actions-webapp.war

# ── STAGE 2: RUNTIME ────────────────────────────────────────────────────────
# Use the official Tomcat image with JRE 8 as the production runtime.
# This is equivalent to the EC2 instance with Tomcat installed via
# the CloudFormation template in the original project.
FROM tomcat:8.5-jre8

# Remove the default Tomcat sample applications.
# In the original project, the stop_server.sh script did this cleanup
# during the BeforeInstall lifecycle hook.
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the compiled WAR from the build stage into Tomcat's webapps directory.
# Naming it ROOT.war tells Tomcat to serve it at the root URL path (/).
# In the original project, appspec.yml's 'files' section did this:
#   source: /target/hye-web-app.war
#   destination: /usr/share/tomcat/webapps/
COPY --from=build /app/target/pipeline-actions-webapp.war /usr/local/tomcat/webapps/ROOT.war

# Document that this container listens on port 8080.
# This is informational — it doesn't actually open the port.
# The ECS task definition and ALB target group handle actual port mapping.
EXPOSE 8080

# Health check — ECS uses this to determine if the container is healthy.
# If this check fails, ECS will stop the container and start a new one.
# In the original project, CodeDeploy's ApplicationStart hook served
# a similar purpose (though less automated).
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start Tomcat in the foreground (not as a daemon).
# In the original project, start_server.sh did:
#   systemctl start tomcat
# Here, we use catalina.sh run (foreground mode required for containers).
CMD ["catalina.sh", "run"]

