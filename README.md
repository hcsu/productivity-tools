# My productivity tools

## oidc-roles-selector

**Easy select role for `oidc2aws`.**

Requires：
* oidc2aws
* fzf

Copy following script in your `~/.zshrc` file.

```shell
o() {
  ROLE=$(ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | fzf --exact --height "50%")

  if [ ! $ROLE ]; then
    echo "No role selected, exit!"
    return
  fi
  
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
```

## terraform-targets

**Deal with multiple terraform targets.**

https://github.com/hcsu/terraform-targets
