# nvim JAVA IDE in Docker

```
#build with 
#--format docker is important due to comppability issues with k8s
podman build --format docker -t senexi/java-vim:latest .

#run with
podman run -it -w /data -v $(pwd):/data --userns=keep-id --rm --net=host senexi/java-vim:latest /bin/zsh

#set alias
alias vimja='podman run -it -w /data -v $(pwd):/data --userns=keep-id --rm --net=host senexi/java-vim:latest /bin/zsh'
```
