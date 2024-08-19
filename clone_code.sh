if [ -d "ecr" ]; then
    cd ecr
    git pull
else
    git clone https://github.com/dungdt-dev/ecr.git
fi
