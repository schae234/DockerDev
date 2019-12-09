from ubuntu:19.10

RUN apt-get update && apt-get upgrade --yes

# install zsh
RUN apt-get install zsh --yes
RUN chsh -s $(which zsh)
# install some essential packages
RUN apt-get install git curl wget vim tmux tree --yes
# Instal GCC
RUN apt-get install gcc zlib1g-dev libbz2-dev liblzma-dev --yes
RUN apt-get install build-essential --yes
# Install sudo
RUN apt-get install sudo
RUN echo "rob ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Install ssh server
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install htop, parallel
RUN apt-get install htop parallel --yes

# Add a rob user ------------------------------------------------------------
RUN useradd -ms /bin/zsh rob
USER rob
WORKDIR /home/rob

RUN mkdir /home/rob/.local
RUN mkdir /home/rob/.local/bin

# Instal, tree, parallel 

RUN mkdir .ssh/
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw1iIgdz85lvNGeAQ2uwA/Ej2tZR2lR6aFO/B0SbEMaDN0E+A+XVbr81MAQPjqaHfanRf8UifIcTpjf1e7MgywryXDiC86N0dxm9NQiO7ASmUOvuMdTuEeo/jp6hP+sPYKxxRtjjNOpFKT5WLwcLlrR4pmHAAPH1hrax8SPbca0SWCJ0Pj1fCDMpUJY811ZB6utmd9ze5Ar1d8Khceqyl2zD+ER00B06Heu7QLBbEsN1mewp6II6aK+ANs1tkgC7JuYSr2T2XOd0V6fKVWXTT2xX3LwLhFfST4RqpO7hj4qVNSS+2dHR2H/A5hWs8Om4RLHL0wEdpK73CaueQwkkvt rob@polk" >> /home/rob/.ssh/authorized_keys
RUN chmod 700 .ssh && chmod 600 .ssh/authorized_keys

# Add user data to git config
RUN git config --global user.email "rob@linkage.io"
RUN git config --global user.name "rob"

# Make a temp working dir
RUN mkdir /home/rob/.local/src -p
WORKDIR /home/rob/.local/src

# install oh my zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Lets get conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN sh Miniconda3-latest-Linux-x86_64.sh -b -p /home/rob/.conda
RUN /home/rob/.conda/bin/conda init zsh

WORKDIR /home/rob/.local/bin
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod u+x mc

WORKDIR /home/rob/

# add in my doot files
COPY include/tmux.conf /home/rob/.tmux.conf
COPY include/vimrc     /home/rob/.vimrc
RUN sudo chown rob:rob /home/rob/.tmux.conf
RUN sudo chown rob:rob /home/rob/.vimrc

# Install snakemake 
RUN /home/rob/.conda/bin/conda install -c bioconda -c conda-forge snakemake --yes

# Install pathogen
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# add the syntax file
RUN mkdir /home/rob/.vim/syntax -p
COPY include/snakemake.vim /home/rob/.vim/syntax/snakemake.vim
RUN echo "au BufNewFile,BufRead Snakefile set syntax=snakemake\nau BufNewFile,BufRead *.smk set syntax=snakemake" >> /home/rob/.vimrc

WORKDIR /home/rob
ENV PATH /home/rob/.local/bin:$PATH


USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
