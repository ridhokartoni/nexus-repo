# Use the official Sonatype Nexus 3 image as the base
FROM sonatype/nexus3:3.68.1

# Switch to the root user to have permissions to install things
USER root

# Set arguments for plugin URL and version for easy updates
ARG PLUGIN_VERSION=0.61.0
#ARG GCS_PLUGIN_URL="https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-blobstore-gcs-plugin/${PLUGIN_VERSION}/nexus-blobstore-gcs-plugin-${PLUGIN_VERSION}-bundle.kar"
ARG GCS_PLUGIN_URL="https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-blobstore-google-cloud/${PLUGIN_VERSION}/nexus-blobstore-google-cloud-${PLUGIN_VERSION}-bundle.kar"
# Create the deployment directory for plugins
RUN mkdir -p /opt/sonatype/nexus/deploy

# Download the Google Cloud Storage plugin and place it in the deploy directory
RUN curl -fsSL --output /opt/sonatype/nexus/deploy/nexus-blobstore-gcs-plugin.kar "${GCS_PLUGIN_URL}"

# Switch back to the nexus user to follow best practices
USER nexus