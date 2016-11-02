#!/bin/bash

# Copy this to your Repository

# The following vars should be set in the Jenkins job
#  - $BUILD_TAG
#  - $TOWER_IP
#  - $TOWER_USER
#  - $TOWER_PASS
#  - $ENV (Can be passed as an arg to this script)
#  - $TOWER_TEMPLATE (id of the Ansible Tower template, can be found in the URL of the template)

set -ex

cd $WORKSPACE

GIT_HASH=`git rev-parse HEAD`
BUILD_TAG="${PIPELINE_VERSION}_${GIT_HASH}" # Replace this with your own tag

ENV=${1-testb} # argument passed to script or testb

git clone https://github.com/madedotcom/ansiballer.git
cp ansiballer/deploy_ansible_playbook.yml deploy_ansible_playbook.yml
rm -rf ansiballer

echo "GIT_HASH ==  ${GIT_HASH}"
echo "PIPELINE_VERSION ==  ${PIPELINE_VERSION}"
echo "BUILD_NUMBER ==  ${BUILD_NUMBER}"
echo "BUILD_TAG ==  ${BUILD_TAG}"
echo "ENV ==  ${ENV}"

echo "------------------- DEPLOYING ver $PIPELINE_VERSION WITH ANSIBLE ON TEST -------------------"


ansible-playbook -v \
    -e build_version=$BUILD_TAG \
    -e env=$ENV \
    -e ansible_tower_address=$TOWER_IP \
    -e tower_user=$TOWER_USER \
    -e tower_pass=$TOWER_PASS \
    -e job_template_id=$TOWER_TEMPLATE \
    -e library_path=./ansible-playbooks/playbooks/ \
    -i localhost -c local \
    ./deploy_ansible_playbook.yml

