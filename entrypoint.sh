#!/bin/bash

set -e -o pipefail

PACKAGE_LOCATION="${1}"
BINTRAY_REPO="${2}"
BINTRAY_LICENSE="${3}"
BINTRAY_USERNAME="${4}"
BINTRAY_API_KEY="${5}"
BINTRAY_VCS_URL="https://github.com/${GITHUB_REPOSITORY}"

function jfrog_upload {
    linux_version=$1
    pkg_filename=$2
    rev_filename=`echo ${pkg_filename} | rev`

    if [[ ${linux_version} =~ centos_* ]]; then
	# centos
	pkg_dist="centos"

    else
	# fedora
	pkg_dist="fedora"
    fi

    pkg_name=`echo ${rev_filename} | cut -d '-' -f3- | rev`
    pkg_version=`echo ${rev_filename} | cut -d '-' -f1-2 | rev | cut -d '.' -f1-3`
    pkg_arch=`echo ${rev_filename} | cut -d '.' -f2 | rev`
    pkg_rel=`echo ${rev_filename} | cut -d '.' -f3 | rev`
    releasever="${pkg_rel:2}"


    jfrog bt package-create --licenses "${BINTRAY_LICENSE}" --vcs-url "${BINTRAY_VCS_URL}" "${BINTRAY_REPO}/${pkg_name}" || true
    jfrog bt upload --publish=true "${pkg_filename}" "${BINTRAY_REPO}/${pkg_name}/${pkg_version}" "${pkg_dist}/${releasever}/${pkg_arch}/"

fi
}

curl --silent -fL -XGET \
    "https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-amd64/jfrog?bt_package=jfrog-cli-linux-amd64" \
    > /usr/local/bin/jfrog
chmod +x /usr/local/bin/jfrog
mkdir -p ~/.jfrog/
cat << EOF > ~/.jfrog/jfrog-cli.conf
{
  "artifactory": null,
  "bintray": {
    "user": "${BINTRAY_USERNAME}",
    "key": "${BINTRAY_API_KEY}"
  },
  "Version": "1"
}
EOF
while IFS= read -r -d '' path
do
    IFS=_ read -r distro release <<< "$(basename "${path}")"
    while IFS= read -r -d '' rpm
    do
        jfrog_upload "${release}" "${rpm}"
    done <    <(find "${path}" -maxdepth 1 -type f -print0)
done <   <(find "${PACKAGE_LOCATION}" -mindepth 1 -maxdepth 1 -type d -print0)

