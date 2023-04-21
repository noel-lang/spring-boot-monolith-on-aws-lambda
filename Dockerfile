FROM public.ecr.aws/lambda/java:17-x86_64

RUN yum groupinstall -y development && \
  yum install -d1 -y \
  yum \
  tar \
  gzip \
  unzip \
  python3 \
  jq \
  grep \
  curl \
  make \
  rsync \
  binutils \
  gcc-c++ \
  procps \
  libgmp3-dev \
  zlib1g-dev \
  libmpc-devel \
  python3-devel \
  && yum clean all

# Install AWS CLI
ARG AWS_CLI_ARCH
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$AWS_CLI_ARCH.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf ./aws

# Install SAM CLI in a dedicated Python virtualenv
ARG SAM_CLI_VERSION
RUN curl -L "https://github.com/awslabs/aws-sam-cli/archive/v$SAM_CLI_VERSION.zip" -o "samcli.zip" && \
  unzip samcli.zip && python3 -m venv /usr/local/opt/sam-cli && \
  /usr/local/opt/sam-cli/bin/pip3 --no-cache-dir install -r ./aws-sam-cli-$SAM_CLI_VERSION/requirements/base.txt && \
  /usr/local/opt/sam-cli/bin/pip3 --no-cache-dir install ./aws-sam-cli-$SAM_CLI_VERSION && \
  rm samcli.zip && rm -rf aws-sam-cli-$SAM_CLI_VERSION

ENV PATH=$PATH:/usr/local/opt/sam-cli/bin

ENV LANG=en_US.UTF-8

# Wheel is required by SAM CLI to build libraries like cryptography. It needs to be installed in the system
# Python for it to be picked up during `sam build`
RUN pip3 install wheel

# Setup Java Home
ENV JAVA_HOME="/var/lang"

# Install Java build tools
RUN mkdir /usr/local/gradle && curl -L -o gradle.zip https://downloads.gradle-dn.com/distributions/gradle-7.3.1-bin.zip && \
  unzip -d /usr/local/gradle gradle.zip && rm gradle.zip && mkdir /usr/local/maven && \
  curl -L https://downloads.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz | \
  tar -zx -C /usr/local/maven

ENV PATH="/usr/local/gradle/gradle-7.3.1/bin:/usr/local/maven/apache-maven-3.8.8/bin:${PATH}"

ENTRYPOINT []

CMD ["/bin/bash"]

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.7.0 /lambda-adapter /opt/extensions/lambda-adapter

EXPOSE 8080

WORKDIR /opt

COPY build/libs/spring-boot-aws-lambda-0.0.1-SNAPSHOT.jar app.jar

CMD ["java", "-jar", "app.jar"]
