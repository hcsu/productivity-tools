# My productivity tools

## oidc-roles-selector

**Easy select role for `oidc2aws`.**

Features:
* Interaction with all roles in oidc2aws config file (excluded roles with suffix `iam` since I don't use them often)
* Auto sort all roles base on frequency, using `~/.oidc2aws/rank` as command history file

Requires：
* [oidc2aws](https://github.com/theplant/oidc2aws)
* [fzf](https://github.com/junegunn/fzf)
* [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)

Copy following script in your `~/.zshrc` file.

```shell
e() {
  RANK_FILE="$HOME/.oidc2aws/rank"

  if [ -e $RANK_FILE ]
  then
    sed -i '' '/^_/d' $RANK_FILE
  fi
  
  ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | sed 's/^/_ /' >> $RANK_FILE

  ROLE=$(sed 's/^_ //' $RANK_FILE | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --no-sort --exact --height "50%")

  if [ ! $ROLE ]; then
    echo "No role selected, exit!"
    return
  fi

  echo $ROLE >> $RANK_FILE
  
  print -z '$(oidc2aws -env -alias' $ROLE')'
}

o() {
  RANK_FILE="$HOME/.oidc2aws/rank"
  
  if [ -e $RANK_FILE ]
  then
    sed -i '' '/^_/d' $RANK_FILE
  fi

  ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | sed 's/^/_ /' >> $RANK_FILE
  
  ROLE=$(sed 's/^_ //' $RANK_FILE | sort | uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --no-sort --exact --height "50%")

  if [ ! $ROLE ]; then
    echo "No role selected, exit!"
    return
  fi

  echo $ROLE >> $RANK_FILE
  
  if [ -z "$1" ]; then
    print -z "oidc2aws -login -alias $ROLE"
    return
  fi

  if echo "$1" | grep -qwi "login"; then
    print -z "oidc2aws -login -alias $ROLE"
    return
  elif echo "$1" | grep -qwi "env"; then
    print -z '$(oidc2aws -env -alias' $ROLE')'
    return
  else 
    echo "Invalid argument, usage: 'o env' or 'o login'"
    return
  fi
}
```

## ssh-hosts-selector

**Easy select hosts in `.ssh/config`.**

Features:
* Interaction with all hosts in ssh config file
* Auto sort all roles base on frequency, using `~/.ssh/rank` as command history file

Requires：
* Saving hosts in `~/.ssh/config`
* [fzf](https://github.com/junegunn/fzf)
* [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)

```bash
s() {
  RANK_FILE="$HOME/.ssh/rank"

  if [ -e $RANK_FILE ]
  then
    # remove legacy hosts
    sed -i '' '/^_/d' $RANK_FILE 
  fi

  # reload the latest hosts into rank file
  ag -o '(?<=^Host )(?!\*).+' ~/.ssh/config | sed 's/^/_ /' >> $RANK_FILE

  # get host need connect to, hosts are sorted by the most counted
  SERVER=$(sed 's/^_ //' $RANK_FILE | sort| uniq -c | sort -nr | awk  -F' ' '{print $NF}' | fzf --no-sort --exact --height "50%")
  
  # exit if host not selected
  if [ ! $SERVER ]; then
    echo "No server selected, exit!"
    return
  fi

  # save host to rank file
  echo $SERVER >> $RANK_FILE
  
  print -z "ssh $SERVER"
}
```

## terraform-targets

**Deal with multiple terraform targets.**

https://github.com/hcsu/terraform-targets

## List all images for AES ECS running task

**Review umages at once for all regions all running tasks**

Requires：
* [AWS Cli](https://aws.amazon.com/cli/)
* [jq](https://github.com/stedolan/jq)

