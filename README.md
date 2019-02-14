<h1 align="center">
Swiftbot
<br>
</h1>

Swiftbot on slack.
Inspired by [kishikawakatsumi/swift-compiler-discord-bot](https://github.com/kishikawakatsumi/swift-compiler-discord-bot)

# Setup

## Ubuntu 18.04

### install dependences

```shell
sudo apt update

sudo apt upgrade

sudo apt install clang libicu-dev libpython-all-dev libssl1.0-dev

// Docker install

curl -fsSL get.docker.com -o get-docker.sh

sudo sh get-docker.sh

// Swift install

wget https://swift.org/builds/swift-4.2.1-release/ubuntu1804/swift-4.2.1-RELEASE/swift-4.2.1-RELEASE-ubuntu18.04.tar.gz

tar xvfz swift-4.2.1-RELEASE-ubuntu18.04.tar.gz

sudo mv swift-4.2.1-RELEASE-ubuntu18.04 /usr/local/swift

```

// export PATH

- Ex: /usr/local/swift/usr/bin/


### Swiftbot build

```shell
git clone git@github.com:noppefoxwolf/Swiftbot.git

// Make Docket image

cd Docker

sudo docker build -t kishikawakatsumi/swift:4.2.1 .

// Build and install Swiftbot

swift build -c release

mv ./.build/x86_64-unknown-linux/release/Swiftbot /usr/local/bin/swiftbot

```

### Add Service

```shell
sudo vim /etc/systemd/system/swiftbot.service
```

```service
[Unit]
Description = Swift bot

[Service]
ExecStart = /usr/local/bin/swiftbot --token "<<TOEKN>>"
Restart = always
Type = simple

[Install]
WantedBy = multi-user.target
```

```shell
sudo systemctl enable swiftbot

sudo reboot
```

## License

Swiftbot is released under the MIT license. See LICENSE for details.

Dockerfile, run.sh and script.sh by https://github.com/kishikawakatsumi/swift-playground
