What you do is simply put these two files in your home directory! also put sanity in Users/tensor/.local/bin

--------------this is how I did it and i keep it uptodate-----------

for the file .zshrc:

> cd ~/Documents/GitHub/
>
> git clone https://github.com/h0t5tuff/zshell-setup.git>
>
> cd
>
> mv ~/.zshrc ~/.zshrc.backup && rm -i ~/.zshrc
>
> ln -s ~/Documents/GitHub/zshell-setup/.zshrc ~/.zshrc
>
> z

for the file sanity:

same shit, then,

> chmod +x ~/sanity
>
> ln -s ~/sanity ~/.local/bin/sanity
