from ubuntu:19.10

RUN apt-get update && apt-get upgrade --yes

# install zsh
RUN apt-get install zsh --yes
RUN chsh -s $(which zsh)
# install some packages
RUN apt-get install git curl wget vim --yes

# Add a rob user
RUN useradd -ms /bin/zsh rob
USER rob

# Make a temp working dir
RUN mkdir /home/rob/.local/src -p
WORKDIR /home/rob/.local/src
# install oh my zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Lets get conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN sh Miniconda3-latest-Linux-x86_64.sh -b -p /home/rob/.conda
RUN /home/rob/.conda/bin/conda init zsh

WORKDIR /home/rob
