FROM jenkins/jenkins:lts
ARG USER
ARG PASS
USER root
RUN apt-get update && \
apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    sudo \
    jq \
    gnupg2 \
    software-properties-common
RUN apt-get install zip -y
#RUN apt install python3 -y
#RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
#RUN unzip awscli-bundle.zip
#RUN apt-get -y install python3
#RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN apt-get update && apt-get install awscli -y
# install jenkins plugins
COPY ./plugins.txt /usr/share/jenkins/plugins
RUN while read i ; \
		do /usr/local/bin/install-plugins.sh $i ; \
	done < /usr/share/jenkins/plugins

ENV JENKINS_USER $USER
ENV JENKINS_PASS $PASS

# allows to skip Jenkins setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Jenkins runs all grovy files from init.groovy.d dir
# use this for creating default admin user
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
VOLUME /var/jenkins_home
RUN echo "jenkins     ALL=(ALL) NOPASSWD:ALL" | cat >> /etc/sudoers
#switch to root to run
#RUN chown -R jenkins:jenkins ../data
RUN chown -R jenkins:jenkins "$JENKINS_HOME"
USER jenkins