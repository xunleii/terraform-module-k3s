
<a name="v3.0.0"></a>
## [v3.0.0] - 2021-06-24
### Bug Fixes
- **server:** configure CIDR on all server nodes

### Code Refactoring
- **inputs:** use `cluster_domain` instead of `name`

### Docs
- **readme:** use tf-docs to generate README automatically from TF config

### Others Changes
- **repo:** add git hooks for commit message lint
- **tf:** upgrade TF required version to 1.x release

### Pull Requests
- Merge pull request [#54](https://github.com/xunleii/terraform-module-k3s/issues/54) from xunleii/fix/resolve-[#53](https://github.com/xunleii/terraform-module-k3s/issues/53)-[#52](https://github.com/xunleii/terraform-module-k3s/issues/52)

### BREAKING CHANGE

Deprecation of `name` variable


<a name="v2.2.4"></a>
## [v2.2.4] - 2021-04-30
### Pull Requests
- Merge pull request [#51](https://github.com/xunleii/terraform-module-k3s/issues/51) from NicoWde/master
- Merge pull request [#49](https://github.com/xunleii/terraform-module-k3s/issues/49) from caleb-devops/master


<a name="v2.2.3"></a>
## [v2.2.3] - 2021-02-17
### Bug Fixes
- add *_drain to kubernetes_ready

### Pull Requests
- Merge pull request [#48](https://github.com/xunleii/terraform-module-k3s/issues/48) from xunleii/fix/add-drain-to-dependencies


<a name="v2.2.2"></a>
## [v2.2.2] - 2021-02-13
### Features
- add dependency endpoint to allow sychronizing k3s install & provisionning

### Pull Requests
- Merge pull request [#47](https://github.com/xunleii/terraform-module-k3s/issues/47) from xunleii/features/done-trigger


<a name="v2.2.1"></a>
## [v2.2.1] - 2021-02-10
### Bug Fixes
- change README node name
- post-pone node labeling after installation

### Pull Requests
- Merge pull request [#46](https://github.com/xunleii/terraform-module-k3s/issues/46) from xunleii/fix/node-install


<a name="v2.2.0"></a>
## [v2.2.0] - 2021-01-03
### Bug Fixes
- remove useless interpolation syntax
- lint module with TF 0.14.x
- avoid JS interpretation on TF vars

### Documentation Improvements
- use : instead of = in README

### Pull Requests
- Merge pull request [#40](https://github.com/xunleii/terraform-module-k3s/issues/40) from xunleii/fix/what-ci
- Merge pull request [#39](https://github.com/xunleii/terraform-module-k3s/issues/39) from DblK/master
- Merge pull request [#37](https://github.com/xunleii/terraform-module-k3s/issues/37) from noct-cloud/master
- Merge pull request [#36](https://github.com/xunleii/terraform-module-k3s/issues/36) from guitcastro/patch-1


<a name="v2.1.0"></a>
## [v2.1.0] - 2020-08-26
### Bug Fixes
- use k3s update channels for latest releases instead of github
- replace network_id with subnet_id
- use k3s update channels for latest releases instead of github

### Documentation Improvements
- update README

### Others Changes
- bump terraform requirement to 0.13
- update actions/github-script to v3

### Pull Requests
- Merge pull request [#32](https://github.com/xunleii/terraform-module-k3s/issues/32) from tedsteen/fix-node-not-found
- Merge pull request [#35](https://github.com/xunleii/terraform-module-k3s/issues/35) from xunleii/chore-update-readme
- Merge pull request [#33](https://github.com/xunleii/terraform-module-k3s/issues/33) from xunleii/fix-ci
- Merge pull request [#30](https://github.com/xunleii/terraform-module-k3s/issues/30) from solidnerd/fix-examples-for-hcloud-provider
- Merge pull request [#28](https://github.com/xunleii/terraform-module-k3s/issues/28) from solidnerd/fix-latest-feature


<a name="v2.0.1"></a>
## [v2.0.1] - 2020-05-31
### Bug Fixes
- do not uninstall k3s during upgrade

### Pull Requests
- Merge pull request [#25](https://github.com/xunleii/terraform-module-k3s/issues/25) from xunleii/24-fix-version-upgrade


<a name="v2.0.0"></a>
## [v2.0.0] - 2020-05-31
### Bug Fixes
- format main.tf file
- use new TF Action for Terraform Format
- remove useless validation
- force agent or server mode during install
- store connection value directly into objects

### Documentation Improvements
- update README
- add dependency variable
- document all TF files
- fix README example

### Draft
- prepare example for the v2 DSL

### Features
- add validation for agent nodes
- add summary output
- ignore 'connection_json' changes
- add node drain mechanism
- use root server to manage annotation/label/taint
- add agent node management
- add multi servers feature
- add server annotation management
- add server node management
- update module variables

### Others Changes
- add plan step in Github Action workflow
- update CI workflow

### Refact
- add missing linereturn
- update/remove useless requirement
- clean example
- remove k3s_ prefix
- rename 'enabled_managed_field' in 'managed_fields'

### Pull Requests
- Merge pull request [#23](https://github.com/xunleii/terraform-module-k3s/issues/23) from xunleii/22-fix-CI
- Merge pull request [#21](https://github.com/xunleii/terraform-module-k3s/issues/21) from xunleii/feat-rewrote-module
- Merge pull request [#19](https://github.com/xunleii/terraform-module-k3s/issues/19) from tedsteen/flags-per-agent


<a name="v1.7.0"></a>
## [v1.7.0] - 2020-02-01
### Features
- add taints & labels

### Test
- update tests for taints & labels

### Pull Requests
- Merge pull request [#17](https://github.com/xunleii/terraform-module-k3s/issues/17) from xunleii/feat-add-node-taint-label


<a name="v1.6.3"></a>
## [v1.6.3] - 2019-12-28
### Bug Fixes
- use node_name field in node deletion

### Pull Requests
- Merge pull request [#16](https://github.com/xunleii/terraform-module-k3s/issues/16) from xunleii/fix-use-node-cache


<a name="v1.6.2"></a>
## [v1.6.2] - 2019-12-21
### Features
- use name in agent nodes

### Pull Requests
- Merge pull request [#15](https://github.com/xunleii/terraform-module-k3s/issues/15) from xunleii/feat-use-name-in-agent


<a name="v1.6.1"></a>
## [v1.6.1] - 2019-12-04
### Features
- upload k3s installer on node
- upload k3s version only if latest is chosen

### Pull Requests
- Merge pull request [#14](https://github.com/xunleii/terraform-module-k3s/issues/14) from xunleii/feat-upload-installer


<a name="v1.6.0"></a>
## [v1.6.0] - 2019-12-04
### Refact
- rename node roles in server and agent

### Pull Requests
- Merge pull request [#13](https://github.com/xunleii/terraform-module-k3s/issues/13) from xunleii/fix-rename-node-role


<a name="v1.5.0"></a>
## [v1.5.0] - 2019-12-01
### Documentation Improvements
- update module usage

### Refact
- update examples with module refactoring
- use new module variables

### Pull Requests
- Merge pull request [#12](https://github.com/xunleii/terraform-module-k3s/issues/12) from xunleii/refact-clean-module


<a name="v1.4.0"></a>
## [v1.4.0] - 2019-11-28
### Refact
- clean custom flags feature

### Pull Requests
- Merge pull request [#11](https://github.com/xunleii/terraform-module-k3s/issues/11) from xunleii/refact-clean-flags


<a name="v1.3.2"></a>
## [v1.3.2] - 2019-11-27
### Bug Fixes
- join custom arguments

### Pull Requests
- Merge pull request [#10](https://github.com/xunleii/terraform-module-k3s/issues/10) from xunleii/fix-join-custom-args


<a name="v1.3.1"></a>
## [v1.3.1] - 2019-11-27
### Features
- add custom arguments

### Pull Requests
- Merge pull request [#9](https://github.com/xunleii/terraform-module-k3s/issues/9) from xunleii/feat-add-custom-args


<a name="v1.2.3"></a>
## [v1.2.3] - 2019-11-24
### Bug Fixes
- remove warning 'quoted keywords are now deprecated'

### Pull Requests
- Merge pull request [#8](https://github.com/xunleii/terraform-module-k3s/issues/8) from xunleii/fix-warn


<a name="v1.2.2"></a>
## [v1.2.2] - 2019-11-16
### Features
- add Terraform actions

### Pull Requests
- Merge pull request [#6](https://github.com/xunleii/terraform-module-k3s/issues/6) from xunleii/feat-add-actions


<a name="v1.2.1"></a>
## [v1.2.1] - 2019-11-16
### Bug Fixes
- use random_password to make k3s key sensitive


<a name="v1.2.0"></a>
## [v1.2.0] - 2019-11-16
### Bug Fixes
- fix Terraform crash

### Features
- use K3S_CLUSTER_SECRET and remove scp

### Refact
- run terraform fmt

### Repo
- add example for hcloud

### Pull Requests
- Merge pull request [#4](https://github.com/xunleii/terraform-module-k3s/issues/4) from xunleii/feat-remove-scp


<a name="v1.1.0"></a>
## [v1.1.0] - 2019-11-03
### Bug Fixes
- drain & delete node from the master node
- use map instead of list to fix removable node

### Pull Requests
- Merge pull request [#2](https://github.com/xunleii/terraform-module-k3s/issues/2) from xunleii/fix-removable-node


<a name="v1.0.0"></a>
## v1.0.0 - 2019-11-03
### Bug Fixes
- specify dependencies and fix pre-calc values

### Documentation Improvements
- add litle documentation

### Features
- add minions.tf
- install and update k3s master node automatically
- check automatically new release of k3s
- add master.tf
- add module variables

### Refact
- clean minions and master file

### Repo
- add more details to README
- prepare repository


[v3.0.0]: https://github.com/xunleii/terraform-module-k3s/compare/v2.2.4...v3.0.0
[v2.2.4]: https://github.com/xunleii/terraform-module-k3s/compare/v2.2.3...v2.2.4
[v2.2.3]: https://github.com/xunleii/terraform-module-k3s/compare/v2.2.2...v2.2.3
[v2.2.2]: https://github.com/xunleii/terraform-module-k3s/compare/v2.2.1...v2.2.2
[v2.2.1]: https://github.com/xunleii/terraform-module-k3s/compare/v2.2.0...v2.2.1
[v2.2.0]: https://github.com/xunleii/terraform-module-k3s/compare/v2.1.0...v2.2.0
[v2.1.0]: https://github.com/xunleii/terraform-module-k3s/compare/v2.0.1...v2.1.0
[v2.0.1]: https://github.com/xunleii/terraform-module-k3s/compare/v2.0.0...v2.0.1
[v2.0.0]: https://github.com/xunleii/terraform-module-k3s/compare/v1.7.0...v2.0.0
[v1.7.0]: https://github.com/xunleii/terraform-module-k3s/compare/v1.6.3...v1.7.0
[v1.6.3]: https://github.com/xunleii/terraform-module-k3s/compare/v1.6.2...v1.6.3
[v1.6.2]: https://github.com/xunleii/terraform-module-k3s/compare/v1.6.1...v1.6.2
[v1.6.1]: https://github.com/xunleii/terraform-module-k3s/compare/v1.6.0...v1.6.1
[v1.6.0]: https://github.com/xunleii/terraform-module-k3s/compare/v1.5.0...v1.6.0
[v1.5.0]: https://github.com/xunleii/terraform-module-k3s/compare/v1.4.0...v1.5.0
[v1.4.0]: https://github.com/xunleii/terraform-module-k3s/compare/v1.3.2...v1.4.0
[v1.3.2]: https://github.com/xunleii/terraform-module-k3s/compare/v1.3.1...v1.3.2
[v1.3.1]: https://github.com/xunleii/terraform-module-k3s/compare/v1.2.3...v1.3.1
[v1.2.3]: https://github.com/xunleii/terraform-module-k3s/compare/v1.2.2...v1.2.3
[v1.2.2]: https://github.com/xunleii/terraform-module-k3s/compare/v1.2.1...v1.2.2
[v1.2.1]: https://github.com/xunleii/terraform-module-k3s/compare/v1.2.0...v1.2.1
[v1.2.0]: https://github.com/xunleii/terraform-module-k3s/compare/v1.1.0...v1.2.0
[v1.1.0]: https://github.com/xunleii/terraform-module-k3s/compare/v1.0.0...v1.1.0
