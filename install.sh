#!/bin/bash
set -ex
export parent_dir=$(dirname $0)
mkdir $parent_dir/share
scp $HOME/.ssh/id_rsa $parent_dir/share/ssh_key.pem
scp deploy.sh $parent_dir/share/
export RC_HOST=192.168.22.24
export NODE=192.168.22.18
export BASE_URL=http://192.168.22.24:8000
source $parent_dir/setup-env.sh
pushd $parent_dir/share
python3 -m http.server &
popd
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
