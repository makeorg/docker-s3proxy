FROM maven:3-jdk-8 as builder
MAINTAINER Samuel Bernard "samuel.bernard@gmail.com"

WORKDIR /root
RUN \
# Build S3proxy
  git clone https://github.com/s-bernard/s3proxy.git && \
  cd s3proxy && \
  git checkout swift_single_segment && \
  mvn clean package -Dmaven.test.skip=true
Run \
  cd s3proxy && \
  printf 'VERSION=${project.version}\n0\n' | \
  mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | \
  grep '^VERSION' > version && \
  echo GIT_SHA=$(git rev-parse --verify HEAD) >> version

# Restart from clean image
FROM azul/zulu-openjdk-alpine:8
# Create user
RUN adduser -D s3proxy
COPY --from=builder /root/s3proxy/target/s3proxy /home/s3proxy/.
COPY --from=builder /root/s3proxy/version /home/s3proxy/.

WORKDIR /home/s3proxy

COPY run.sh /home/s3proxy/.
USER s3proxy
CMD ["/home/s3proxy/run.sh"]
