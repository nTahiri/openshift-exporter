FROM openshift/base-centos7


# Export the environment variable that provides information about the application.
# Replace this with the according version for your application.


ENV JAVA_VERSON 1.8.0
ENV MAVEN_VERSION 3.3.9

# Set the labels that are used for OpenShift to describe the builder image.
LABEL io.k8s.description="Platform for Export Project from OpenShift cluster to another" \
      io.k8s.display-name="OpenShift Export" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="Export" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

RUN yum update -y && \
  yum install -y vi && \
  yum install -y java-$JAVA_VERSON-openjdk java-$JAVA_VERSON-openjdk-devel && \
  yum clean all

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV JAVA_HOME /usr/lib/jvm/java
ENV MAVEN_HOME /usr/share/maven

RUN mkdir /nt
ENV HOME /nt

# Copy the S2I scripts to /usr/libexec/s2i since we set the label that way
COPY  ["run", "assemble", "/usr/libexec/s2i/"]
COPY ["oc", "/bin/"]
COPY ["export.sh", "/nt/"]

ENV OPENSHIFT_OC_HOME /bin
RUN chmod +x /bin/oc && \
	chown -R 1001:0 /bin

RUN chmod +x /nt/export.sh && \
	chown -R 1001:0 /nt
	

RUN chmod +x /usr/libexec/s2i/run /usr/libexec/s2i/assemble /usr/libexec/s2i/usage
RUN chown -R 1001:0 /opt/app-root
USER 1001

#EXPOSE 1000-10000
#EXPOSE 8080
WORKDIR $HOME

CMD ["/usr/libexec/s2i/run"]
