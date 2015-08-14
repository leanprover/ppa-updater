This script creates Ubuntu packages for
[the Lean theorem prover][lean] and uploads them to
[launchpad.net](https://launchpad.net/~leanprover/+archive/ubuntu/lean/+packages).

Uploaded packages are available at

https://launchpad.net/~leanprover/+archive/ubuntu/lean/+packages

[lean]: https://leanprover.github.io


Required packages
-----------------

We assume that you have Ubuntu 14.04 LTS system. You need the
following packages:

```bash
sudo apt-get install git pbuilder build-essential ubuntu-dev-tools devscripts
```

Also we assume that you have created your GPG/PGP key and published to
launchpad.


How to use script
-----------------

```bash
./update.sh
```


How to install Lean using PPA
-----------------------------

```bash
sudo apt-get install python-software-properties # for add-apt-repository 
sudo add-apt-repository ppa:leanprover/lean
sudo apt-get update
sudo apt-get install lean
```

Once install Lean via PPA, you can use the standard `apt-get upgrade`
to get the latest version of Lean.

Status
------

 - [Soonho Kong](https://www.cs.cmu.edu/~soonhok) is running the `update.sh` script on a CMU Linux machine daily.
