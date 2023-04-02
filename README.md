# Arch Linux post-installation steps

This repository contains the config files to automate the post-installation
steps in Arch Linux or derivatives. 

Do not just run this. Examine and judge. Run at your own risk.

## Examples

Show available options:

```
./arch_post.sh -h
```

To install paru:

```
./arch_post.sh -p
```

To install applications listed in `2_apps.txt` file:

```
./arch_post.sh -a
```

To install vscodium extensions listed in `30_vscodium.txt`:

```
./arch_post.sh -vs
```



