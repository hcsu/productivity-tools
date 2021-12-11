# My productivity tools

## Interact with multiple roles for `oidc2aws`

Requirement：
* oidc2aws
* fzf

Copy following script in your `~/.zshrc` file.

```shell
o() {
  ROLE=$(ag -o '(?<=\[alias.)(.*(?<!iam))(?=\])' ~/.oidc2aws/oidcconfig | fzf --exact --height "50%")
  
  if [ -z "$1" ]; then
    echo "Please input login or env!!!"
    return
  fi

  if [ $1 = login ]; then
    oidc2aws -login -alias $ROLE
    echo 'oidc2aws -login -alias' $ROLE
  elif [ $1 = env ]; then
    $(oidc2aws -env -alias $ROLE)
    echo '$(oidc2aws -env -alias' $ROLE')'
  fi
}
```

## Deal with multiple terraform targets
https://github.com/hcsu/terraform-targets
