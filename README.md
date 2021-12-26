# My productivity tools

## oidc-roles-selector

**Easy select role for `oidc2aws`.**

Requires：
* [oidc2aws](https://github.com/theplant/oidc2aws)
* [fzf](https://github.com/junegunn/fzf)
* [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)

Copy following script in your `~/.zshrc` file.

```shell
o() {
  sed -i '' '/^_/d' ~/.oidc2aws/rank 

  ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | sed 's/^/_ /' >> ~/.oidc2aws/rank
  
  ROLE=$(sed 's/^_ //' ~/.oidc2aws/rank | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --exact --height "50%")

  if [ ! $ROLE ]; then
    echo "No role selected, exit!"
    return
  fi

  echo $ROLE >> ~/.oidc2aws/rank
  
  if [ -z "$1" ]; then
    print -z "oidc2aws -login -alias $ROLE"
    return
  fi

  if [ $1 = login ]; then
    print -z "oidc2aws -login -alias $ROLE"
    return
  elif [ $1 = env ]; then
    print -z '$(oidc2aws -env -alias' $ROLE')'
    return
  else 
    echo "Invalid argument, usage: 'o env' or 'o login'"
    return
  fi
}

e() {
  sed -i '' '/^_/d' ~/.oidc2aws/rank
  
  ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | sed 's/^/_ /' >> ~/.oidc2aws/rank

  ROLE=$(sed 's/^_ //' ~/.oidc2aws/rank | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --exact --height "50%")

  if [ ! $ROLE ]; then
    echo "No role selected, exit!"
    return
  fi

  echo $ROLE >> ~/.oidc2aws/rank
  
  print -z '$(oidc2aws -env -alias' $ROLE')'
}
```

## ssh-hosts-selector

**Easy select hosts in `.ssh/config`.**

Requires：
* Saving hosts in `~/.ssh/config`
* [fzf](https://github.com/junegunn/fzf)
* [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)

```bash
s() {
  # remove legacy hosts
  sed -i '' '/^_/d' ~/.ssh/rank 

  # reload the latest hosts into rank file
  ag -o '(?<=^Host )(?!\*).+' ~/.ssh/config | sed 's/^/_ /' >> ~/.ssh/rank

  # get host need connect to, hosts are sorted by the most counted
  SERVER=$(sed 's/^_ //' ~/.ssh/rank | sort| uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --exact --height "50%")
  
  # exit if host not selected
  if [ ! $SERVER ]; then
    echo "No server selected, exit!"
    return
  fi

  # save host to rank file
  echo $SERVER >> ~/.ssh/rank
  
  print -z "ssh $SERVER"
}
```

## terraform-targets

**Deal with multiple terraform targets.**

https://github.com/hcsu/terraform-targets
