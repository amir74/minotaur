FROM swift

ADD .  /src/swift-exercises
RUN cd /src/swift-exercises \
 && swift build \
 && swift test
