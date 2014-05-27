if [-f = "parallax"]
then
    git clone "https://github.com/jroesch/parallax"
else
    cd parallax; git pull; cd ..
fi

if [-f = "IdrisNet2"]
then
    git clone "https://github.com/SimonJF/IdrisNet2.git"
else
    cd IdrisNet2; git pull; cd ..
fi
