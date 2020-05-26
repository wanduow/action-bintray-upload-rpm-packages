# action-bintray-upload-rpm-packages

Github action for uploading rpm packages to bintray, borrowing heavily from
Brad Cowie's action-bintray-upload-debian-packages
(https://github.com/wanduow/action-bintray-upload-debian-packages)

## Inputs

### `path`

**Required** Path to a directory full of packages with the following structure:

```
distro_version1/*.rpm
distro_version2/*.rpm
distro_versionN/*.rpm
```

Packages in the `distro_version/` directory (e.g. `centos_8`, `fedora_32`) will
just be uploaded to that particular version of the distribution.

### `repo`

**Required** The Bintray repository to upload to

### `license`

**Required** Open-source license the package is licensed as

### `username`

**Required** The Bintray username to use for authentication

### `api_key`

**Required** The Bintray API key to use for authentication

## Example usage

```
uses: wanduow/action-bintray-upload-rpm-packages@v1
with:
  path: packages/
  repo: LibtraceTeam/libtrace
  license: LGPL-3.0
  username: libtrace-maintainer
  api_key: ${{ secrets.BINTRAY_API_KEY }}
```

