from ubuntu:19.10

RUN apt-get update && apt-get upgrade --yes

# install zsh
RUN apt-get install zsh --yes
RUN chsh -s $(which zsh)
# install some essential packages
RUN apt-get install git curl wget vim tmux --yes
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

# Add a rob user ------------------------------------------------------------
RUN useradd -ms /bin/zsh rob
USER rob
WORKDIR /home/rob

RUN mkdir .ssh/
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw1iIgdz85lvNGeAQ2uwA/Ej2tZR2lR6aFO/B0SbEMaDN0E+A+XVbr81MAQPjqaHfanRf8UifIcTpjf1e7MgywryXDiC86N0dxm9NQiO7ASmUOvuMdTuEeo/jp6hP+sPYKxxRtjjNOpFKT5WLwcLlrR4pmHAAPH1hrax8SPbca0SWCJ0Pj1fCDMpUJY811ZB6utmd9ze5Ar1d8Khceqyl2zD+ER00B06Heu7QLBbEsN1mewp6II6aK+ANs1tkgC7JuYSr2T2XOd0V6fKVWXTT2xX3LwLhFfST4RqpO7hj4qVNSS+2dHR2H/A5hWs8Om4RLHL0wEdpK73CaueQwkkvt rob@polk" >> /home/rob/.ssh/authorized_keys
RUN chmod 700 .ssh && chmod 600 .ssh/authorized_keys

# Make a temp working dir
RUN mkdir /home/rob/.local/src -p
WORKDIR /home/rob/.local/src

# install oh my zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# Lets get conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN sh Miniconda3-latest-Linux-x86_64.sh -b -p /home/rob/.conda
RUN /home/rob/.conda/bin/conda init zsh

# add in my doot files
COPY --chown=rob:rob include/tmux.conf /home/rob/.tmux.conf
COPY --chown=rob:rob include/vimrc     /home/rob/.vimrc

# Install snakemake 
RUN /home/rob/.conda/bin/conda install -c bioconda -c conda-forge snakemake --yes
# add the syntax file
RUN mkdir /home/rob/.vim/syntax -p
COPY --chown=rob:rob include/snakemake.vim /home/rob/.vim/syntax/snakemake.vim
RUN echo "au BufNewFile,BufRead Snakefile set syntax=snakemake\nau BufNewFile,BufRead *.smk set syntax=snakemake" >> .vimrc

WORKDIR /home/rob


#USER root
#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]
