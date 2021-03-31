FROM adoptopenjdk:15-jdk-hotspot

RUN apt-get update -y && apt-get -y install vim \
	nodejs \
	silversearcher-ag \
	protobuf-compiler \
	postgresql-client \
	less \
    maven \
	zsh \
    git \
    gnupg \
    make \
    wget \
    gcc \
    exuberant-ctags \
    zip

RUN curl --fail -L https://github.com/neovim/neovim/releases/download/v0.4.4/nvim-linux64.tar.gz|tar xzfv - && mv nvim-linux64/bin/nvim /usr/bin && mv nvim-linux64/share /

# add dev user
RUN adduser dev --disabled-password --gecos ""                          && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers     && \
    chown -R dev:dev /home/dev && \
    chgrp -R 0 /home/dev && \
    chmod -R g+rwX /home/dev 
#    chsh -s /usr/bin/zsh dev \
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update && \
	apt-get install yarn


RUN mkdir -p /opt/google-java-format && wget https://github.com/google/google-java-format/releases/download/google-java-format-1.9/google-java-format-1.9-all-deps.jar -O /opt/google-java-format/google-java-format.jar && chmod -R 555 /opt/google-java-format

RUN wget https://services.gradle.org/distributions/gradle-6.8.3-bin.zip -P /tmp && unzip -d /opt/gradle /tmp/gradle-*.zip && chmod -R 555 /opt/gradle

USER dev
ENV HOME /home/dev
WORKDIR ${HOME} 

COPY init.vim ${HOME}/.config/nvim/
RUN nvim --headless +PlugInstall  +qall && timeout 35 nvim --headless +"CocInstall coc-java coc-java-debug coc-json" test.java || : && echo "huhu"
COPY coc-settings.json ${HOME}/.config/nvim

#configure git to use ssh instead of https
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k && \
    git config --global user.email "dev@go.com" && \
    git config --global user.name "dev" && \
    git config --global url."git@github.com:".insteadOf "https://github.com/"

COPY .p10k.zsh ${HOME}/.p10k.zsh
COPY .zshrc ${HOME}/.zshrc

CMD "exec zsh"
