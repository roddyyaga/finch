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
RUN patch static-dune.patch bin/dune
RUN eval $(opam env) && sudo chown -R opam:nogroup . && dune external-lib-deps --missing @install && dune build @install
RUN mkdir finch && chmod 777 finch
# RUN eval $(opam env) && sudo chown -R opam:nogroup . && dune build @install && opam depext -ln app > depexts

# Create the production image
# FROM python:3.8-alpine
# WORKDIR /app
# RUN mkdir app
# RUN pip install pywebpush
# TODO - work out how to set the timezone properly
# RUN apk add tzdata && ln -s /usr/share/zoneinfo/Etc/GMT /etc/localtime
# For processing images
# RUN apk --update add imagemagick
# COPY ./app/send_notification.py /app/app/send_notification.py
# COPY --from=0 /app/depexts depexts
# RUN cat depexts | xargs apk --update add && rm -rf /var/cache/apk/*
# COPY --from=0 /app/_build/install/default/bin/main main.exe

# EXPOSE 3000
# CMD ./main.exe

FROM scratch
COPY --from=0 /finch/_build/install/default/bin/finch /bin/finch.exe
COPY --from=0 /finch/finch /finch
WORKDIR finch
ENTRYPOINT ["/bin/finch.exe"]

# FROM debian:buster-slim
# RUN mkdir finch
# COPY --from=0 /finch/depexts depexts
# RUN apt-get update
# RUN cat depexts | xargs apt-get install --no-install-recommends -y && rm -rf /var/lib/apt/lists/*
# RUN apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib{apit,dpkg,cache,log}/
# COPY --from=0 /finch/_build/install/default/bin/finch /bin/finch.exe
# WORKDIR finch
# ENTRYPOINT ["/bin/finch.exe"]
