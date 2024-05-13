FROM fedora

RUN dnf install -y bison 
RUN dnf install -y cmake coin-or-Clp-devel
RUN dnf install -y flex gcc-c++ gsl-devel
RUN dnf install -y git
RUN git clone https://github.com/aldukeman/popf2.git
RUN cd popf2; curl https://raw.githubusercontent.com/morxa/fedora-popf/main/popf.vector-init.patch > popf.vector-init.patch; git apply popf.vector-init.patch
RUN cd popf2; curl https://raw.githubusercontent.com/morxa/fedora-popf/main/popf.iterator-type-traits.patch > popf.iterator.patch; git apply popf.iterator.patch
RUN cd popf2; ./build.bash

ADD domain.pddl .
ADD problems .

#CMD ["./popf2/compile/popf2/popf3-clp", "--help"]
ENTRYPOINT ["./popf2/compile/popf2/popf3-clp"]