FROM debian:10.2

RUN     apt-get update && \
        # INSTALL FROM MAIN
        apt-get install --no-install-recommends -y \
        software-properties-common \
        # Build tools
        cmake \
        cppcheck \
        g++ \
        make \
        pkg-config \
        # Misc
        git \
        # python
        python3 \
        python3-setuptools \
        python3-pip \
        && \
        # INSTALL NEWER REQUIRED PACKAGES FROM UPSTREAM (repo: sid)
        add-apt-repository "deb http://httpredir.debian.org/debian sid main" && \
        apt-get update && \
        apt-get -t sid install --no-install-recommends -y \
        lcov \
        && \
        pip3 install wheel && \
        pip3 install conan==1.21.0

# - Default to python3
# - Default to pip3
RUN     update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1 && \
        update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

WORKDIR /source