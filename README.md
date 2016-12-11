# Load test

<!-- [記事](http://sambaiz.net/article/42) -->

[tsenart/vegeta](https://github.com/tsenart/vegeta)

## Usage

### Install tools (macOS)

```
$ brew install awscli pdsh jq vegeta packer
$ aws configure
```

### Build AMI

```
$ packer build \
    -var 'aws_access_key=YOUR ACCESS KEY' \
    -var 'aws_secret_key=YOUR SECRET KEY' \
    packer.json
...
ap-northeast-1: ami-xxxxxxxx
```

### Run (sample/sample.sh)

```
#!/bin/bash

export INSTANCE_NUM=3

export AMI_ID=ami-xxxxxxxx
export SECURITY_GROUP_IDS=sg-xxxxxxxx
export SUBNET_ID=subnet-xxxxxxxx

# https://github.com/tsenart/vegeta#attack
export VEGETA_CMD='echo "GET http://target/" | vegeta attack -rate=100 -duration=30s'

sh ../run.sh 
```

