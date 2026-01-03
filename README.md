What you do is simply put these two files in your home directory! also put sanity in Users/tensor/.local/bin



--------------this is how I did it and i keep it uptodate-----------

for the file .zshrc:

>gh repo create zshell-setup --public --source=~ --remote=origin --push
>
>mkdir -p ~/zshell-setup
>
>mv ~/.zshrc ~/zshell-setup/.zshrc
>
>cd ~/zshell-setup
>
>git init
>
>git add .zshrc
>
>git commit -m "Track .zshrc"
>
>ln -s ~/zshell-setup/.zshrc ~/.zshrc
>
>git push


for the file sanity: 

same shit 



