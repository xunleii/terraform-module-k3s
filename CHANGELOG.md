<a name="unreleased"></a>
## [Unreleased]


<a name="v1.7.1"></a>
## [v1.7.1] - 2020-02-02
### Documentation
- fix README example


<a name="v1.7.0"></a>
## [v1.7.0] - 2020-02-01
### Features
- add taints & labels


<a name="v1.6.3"></a>
## [v1.6.3] - 2019-12-28
### Bug Fixes
- use node_name field in node deletion


<a name="v1.6.2"></a>
## [v1.6.2] - 2019-12-21
### Features
- use name in agent nodes


<a name="v1.6.1"></a>
## [v1.6.1] - 2019-12-04
### Features
- upload k3s installer on node
- upload k3s version only if latest is chosen


<a name="v1.6.0"></a>
## [v1.6.0] - 2019-12-04
### Code Refactoring
- rename node roles in server and agent


<a name="v1.5.0"></a>
## [v1.5.0] - 2019-12-01
### Code Refactoring
- update examples with module refactoring
- use new module variables

### Documentation
- update module usage


<a name="v1.4.0"></a>
## [v1.4.0] - 2019-11-28
### Code Refactoring
- clean custom flags feature


<a name="v1.3.2"></a>
## [v1.3.2] - 2019-11-27
### Bug Fixes
- join custom arguments


<a name="v1.3.1"></a>
## [v1.3.1] - 2019-11-27
### Features
- add custom arguments


<a name="v1.2.3"></a>
## [v1.2.3] - 2019-11-24
### Bug Fixes
- remove warning 'quoted keywords are now deprecated'


<a name="v1.2.2"></a>
## [v1.2.2] - 2019-11-16
### Features
- add Terraform actions


<a name="v1.2.1"></a>
## [v1.2.1] - 2019-11-16
### Bug Fixes
- use random_password to make k3s key sensitive


<a name="v1.2.0"></a>
## [v1.2.0] - 2019-11-16
### Bug Fixes
- fix Terraform crash

### Code Refactoring
- run terraform fmt

### Features
- use K3S_CLUSTER_SECRET and remove scp


<a name="v1.1.0"></a>
## [v1.1.0] - 2019-11-03
### Bug Fixes
- drain & delete node from the master node
- use map instead of list to fix removable node


<a name="v1.0.0"></a>
## v1.0.0 - 2019-11-03
### Bug Fixes
- specify dependencies and fix pre-calc values

### Code Refactoring
- clean minions and master file

### Documentation
- add litle documentation

### Features
- add minions.tf
- install and update k3s master node automatically
- check automatically new release of k3s
- add master.tf
- add module variables


[Unreleased]: https://github.com/xunleii/terraform-module-k3s/compare/v1.7.1...HEAD
[v1.7.1]: https://github.com/xunleii/terraform-module-k3s/compare/v1.7.0...v1.7.1
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
