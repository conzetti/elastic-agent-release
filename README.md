Elastic Agent BOSH Release
===========================
💡 _A deployment mechanism for Elastic Agent on BOSH managed virtual machines_

## 🎬 Getting Started

Fork this repo or download one of the [prebuilt releases](https://github.com/conzetti/elastic-agent-release/releases).

**NOTE**: This is intended to be used as a BOSH [addon](https://bosh.io/docs/runtime-config/#update)

## ⚙️ Create a BOSH runtime configuration
_Example runtime configuration YAML to run on a variety of Ubuntu Linux stemcells_

```yml
releases:
- name: elastic-agent-release
  version: 0.0.22-alpha

addons:
- name: elastic-agent-release
  jobs:
  - name: elastic-agent
    release: elastic-agent-release
    properties:
      fleet:
        enrollment-token: Zm9vOmJhego=
        url: https://foobaz.fleet.us-east4.gcp.elastic-cloud.com
  include:
    stemcell:
    - os: ubuntu-trusty
    - os: ubuntu-bionic
    - os: ubuntu-xenial
    - os: ubuntu-jammy
```

📣 See the [Platform Automation Documentation](https://docs.pivotal.io/platform-automation/v5.0/tasks.html#update-runtime-config) for help including this with Ops Manager deployed BOSH

## 🔨 Building an updated release
* Clone this repo and navigate to `elastic-agent-release/`
  ```console
  git clone git@github.com:conzetti/elastic-agent-release.git
  pushd elastic-agent-release/
  ```

* Print out the current ["blobs" ](https://bosh.io/docs/release-blobs/)
  ```console
  ➜  bosh blobs
  Path                                      Size     Blobstore ID                          Digest
  elastic-agent-8.10.2-linux-x86_64.tar.gz  535 MiB  665008fd-0590-4036-4cc2-81d445882c14  sha256:67f50acbff3a3e03dc0354d443fdb154c4d3f722826218a4d7d7250b8735361c

  1 blobs

  Succeeded
  ```

* Purge the current blob for the Elastic Agent
  ```console
  bosh remove-blob elastic-agent-8.10.2-linux-x86_64.tar.gz
  ```

* Gather the _latest_ Elastic Agent via one of the following methods 
  * Manually download from https://www.elastic.co/downloads/elastic-agent
  * Using `wget` && `jq`
    > ```wget https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$(wget -qO - https://api.github.com/repos/elastic/elastic-agent/tags\?per_page\=1 | jq -r '.[].name | capture("(?<v>[[:digit:].]+)").v')-linux-x86_64.tar.gz```
  * Using `curl` && `jq`
    > ```curl https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$(curl -s GET https://api.github.com/repos/elastic/elastic-agent/tags\?per_page\=1 | jq -r '.[].name| capture("(?<v>[[:digit:].]+)").v')-linux-x86_64.tar.gz --output elastic-agent-$(curl -s GET https://api.github.com/repos/elastic/elastic-agent/tags\?per_page\=1 | jq -r '.[].name | capture("(?<v>[[:digit:].]+)").v')-linux-x86_64.tar.gz```

* Add the updated agent to the BOSH blob store
  ```console
  bosh add-blob ~/Downloads/elastic-agent-8.10.4-linux-x86_64.tar.gz elastic-agent-8.10.4-linux-x86_64.tar.gz
  ```

* Optionally upload the blobs to S3 (not required for offline or local development)
```console
bosh upload-blobs
```

* Amend the following files with the updated agent filename
  ```
  packages/elastic-agent/spec
  ```

* Generate a release tarball
  ```bash
  bosh create-release \
    --name elastic-agent-release \
    --version 0.0.22-alpha \ 
    --tarball /tmp/release.tgz \
    --[force | final]
  ```
  
* **NOTE**: When crafting your `runtime.yml`, be sure to reference the updated release version (_and_ make sure that you've uploaded the new release to BOSH)