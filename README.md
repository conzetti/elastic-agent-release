Elastic Agent BOSH Release
===========================
💡 _A deployment mechanism for Elastic Agent on BOSH managed virtual machines_

## 🎬 Getting Started

Fork this repo as a starting point _or_ initialize your release and git repository with the expected release directory structure
```
bosh init-release --git
```

**NOTE**: This is intended to be used as a BOSH [addon](https://bosh.io/docs/runtime-config/#update)

## ⚙️ Create a BOSH runtime configuration
_Example runtime configuration YAML to run on a variety of Ubuntu Linux stemcells_

```yml
releases:
- name: elastic-agent-release
  version: 0.0.1-alpha

addons:
- name: elastic-agent-release
  jobs:
  - name: elastic-agent
    release: elastic-agent-release
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
  FIXME

  1 blobs

  Succeeded
  ```

* Purge the current blob for the Elastic Agent
  ```console
  bosh remove-blob FIXME
  ```

* Gather the _latest_ Elastic Agent from https://www.tenable.com/downloads/nessus-agents

* Add the updated agent to the BOSH blob store
  ```console
  bosh add-blob ~/Downloads/FIXME
  ```

* Amend the following files with the updated agent version
  ```
  jobs/elastic-agent/templates/pre-start.sh
  packages/elastic-agent/packaging
  packages/elastic-agent/spec
  ```

* Generate a release tarball
  ```bash
  bosh create-release \
    --name elastic-agent-release \
    --version <CURRENT_RELEASE> \
    --tarball /tmp/release.tgz \
    --[force | final]
  ```
* **NOTE**: When crafting your `runtime.yml`, be sure to reference the updated release version (_and_ make sure that you've uploaded the new release to BOSH)