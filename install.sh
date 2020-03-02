#!/bin/bash
set -ex
mkdir $(dirname $0)/share
scp $HOME/.ssh/id_rsa $(dirname $0)/share/ssh_key.pem
scp deploy.sh $(dirname $0)/share/
source $(dirname $0)/setup-env.sh
export RC_HOST=192.168.22.24
export NODE=192.168.22.18
export BASE_URL=http://192.168.22.24:8000
pushd $(dirname $0)/share
python3 -m http.server &
popd
export REPO_URL=https://github.com/soujanyamahendra/treasuremap.git
export REPO_BRANCH=master
cat objects.yaml.env | envsubst > objects.yaml
cat TF_blueprint.yaml.env | envsubst > TF_blueprint.yaml
export PATH=$PATH:$HOME/api-server/scripts
rc_loaddata -H $RC_HOST -u $RC_USER -p $RC_PW -A objects.yaml
rc_cli -H $RC_HOST -u $RC_USER -p $RC_PW blueprint create TF_blueprint.yaml
export ESID=$(rc_cli -H $RC_HOST -u $RC_USER -p $RC_PW edgesite list | awk 'NR==3 {print $1}')
export BPID=$(rc_cli -H $RC_HOST -u $RC_USER -p $RC_PW blueprint list | awk 'NR==3 {print $1}')
echo "ESID = $ESID"
echo "BPID = $BPID"
cat POD.yaml.env | envsubst > POD.yaml
sleep 30
rc_cli -H $RC_HOST -u $RC_USER -p $RC_PW pod create POD.yaml
