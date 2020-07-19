# Build the app
FROM ocaml/opam2:alpine

WORKDIR /finch

# TODO - work out why this is necessary
RUN cd /home/opam/opam-repository && git pull && cd /finch

COPY finch.opam .
RUN opam switch 4.09 &&\
    eval $(opam env)
RUN opam pin -yn finch .
RUN opam update
ENV OPAMSOLVERTIMEOUT=3600
# RUN sudo apt-get update
RUN opam depext finch
RUN opam install --deps-only finch
# TODO - figure out exactly why chown necessary
# (taken from here https://medium.com/@bobbypriambodo/lightweight-ocaml-docker-images-with-multi-stage-builds-f7a060c7fce4)
# TODO - work out why the `eval` and `dune build` have to be in the same RUN step
# TODO - see if there is a better solution to copying depexts to production than this one
# (taken from same blog post)
# TODO - determine whether removing the egrep and sed from that post in the depext command was correct
RUN sudo chown -R opam:nogroup . && opam depext -ln finch > depexts
COPY . .
RUN eval $(opam env) && sudo chown -R opam:nogroup . && patch bin/dune static-dune.patch && dune build @install
RUN mkdir finch
# minimize
RUN sudo apk add upx
RUN ls -l /finch/_build/install/default/bin/finch
RUN ls -l /finch/_build/default/bin
RUN du -k /finch/_build/default/bin/finch.exe
RUN sudo chmod 777 /finch/_build/default/bin/finch.exe
RUN sudo strip --strip-all /finch/_build/default/bin/finch.exe
RUN sudo upx /finch/_build/default/bin/finch.exe
RUN du -k /finch/_build/default/bin/finch.exe

# RUN eval $(opam env) && sudo chown -R opam:nogroup . && dune build @install && opam depext -ln app > depexts

FROM scratch
COPY --from=0 /finch/_build/default/bin/finch.exe /bin/finch.exe
COPY --from=0 /finch/finch /finch
WORKDIR finch
ENTRYPOINT ["/bin/finch.exe"]
