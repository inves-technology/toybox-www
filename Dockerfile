FROM node:alpine
# PROJECT arg to be passed in from docker-compose and/or .env file
ARG PROJECT=unnamedProject 

ENV TERRAFORM_VERSION=0.11.7
ENV TERRAFORM_SHA256SUM=6b8ce67647a59b2a3f70199c304abca0ddec0e49fd060944c26f666298e23418

RUN apk add --update git curl openssh && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN apk update
RUN apk upgrade
RUN apk add ca-certificates wget && update-ca-certificates
RUN apk add --no-cache --update \
    curl \
    bash \
    python \
    py-pip \
    groff \ 
    less \
    make \
    ncurses \
    vim 

RUN pip install --upgrade pip
RUN pip install awscli

RUN rm /var/cache/apk/*

RUN mkdir -p /${PROJECT}
RUN mkdir -p /${PROJECT}/src

#TODO: Bring Yarn and other crap back for a package manager later. Temporarily giving up on parceljs

#COPY ./src/package.json ./src/yarn.lock /${PROJECT}/src/

WORKDIR /${PROJECT}/src

# Yarn Installs
#RUN yarn global add parcel-bundler
#RUN yarn

# Copy Project and kick off build
COPY . /${PROJECT}/

# Docker Whale prompt (which needs ncurses package for tput to work)
RUN printf 'export PS1="\[$(tput setaf 4)\] __v_\\n\[$(tput setaf 4)\]($(tput smul)₀   $(tput rmul)\/{\[$(tput sgr0)\] \\t \[$(tput setaf 5)\][\w]\[$(tput sgr0)\]\$ "' >> ~/.bashrc

# start app
# CMD ["npm", "start"]