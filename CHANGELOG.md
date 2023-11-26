# Changelog

## [v3.4.0](https://github.com/xunleii/terraform-module-k3s/tree/v3.4.0) (2023-11-26)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v3.3.0...v3.4.0)

**Dependencies upgrades:**

- chore\(deps\): update dependency terraform to v1.6.4 [\#154](https://github.com/xunleii/terraform-module-k3s/pull/154) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update zgosalvez/github-actions-ensure-sha-pinned-actions action to v3 [\#152](https://github.com/xunleii/terraform-module-k3s/pull/152) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update hashicorp/setup-terraform action to v3 [\#151](https://github.com/xunleii/terraform-module-k3s/pull/151) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update zgosalvez/github-actions-ensure-sha-pinned-actions action to v1.4.1 [\#150](https://github.com/xunleii/terraform-module-k3s/pull/150) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update marocchino/sticky-pull-request-comment action to v2.8.0 [\#149](https://github.com/xunleii/terraform-module-k3s/pull/149) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update dependency trivy to v0.47.0 [\#148](https://github.com/xunleii/terraform-module-k3s/pull/148) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update aquasecurity/trivy-action action to v0.14.0 [\#147](https://github.com/xunleii/terraform-module-k3s/pull/147) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update hashicorp/setup-terraform action to v2.0.3 [\#146](https://github.com/xunleii/terraform-module-k3s/pull/146) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update dependency terraform to v1.6.3 [\#145](https://github.com/xunleii/terraform-module-k3s/pull/145) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update actions/checkout action to v4 [\#137](https://github.com/xunleii/terraform-module-k3s/pull/137) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update terraform http to v3.4.0 [\#130](https://github.com/xunleii/terraform-module-k3s/pull/130) ([renovate[bot]](https://github.com/apps/renovate))

**Closed issues:**

- When generate\_ca\_certificates = false, module does not export any kubeconfig [\#143](https://github.com/xunleii/terraform-module-k3s/issues/143)
- Refresh kubeconfig when terraform state is lost [\#142](https://github.com/xunleii/terraform-module-k3s/issues/142)
- terraform destroy gets stuck while draining the last node [\#138](https://github.com/xunleii/terraform-module-k3s/issues/138)
- cdktf compatibility  [\#135](https://github.com/xunleii/terraform-module-k3s/issues/135)
- hcloud-k3s doesnt work with v3.3.0 [\#127](https://github.com/xunleii/terraform-module-k3s/issues/127)
- Generated kubeconfig cannot be used \(certificate signed by unknown authority\) [\#107](https://github.com/xunleii/terraform-module-k3s/issues/107)
- Cluster CA certificate is not trusted [\#85](https://github.com/xunleii/terraform-module-k3s/issues/85)
- Windows Terraform - SSH authentication failed [\#43](https://github.com/xunleii/terraform-module-k3s/issues/43)
- Custom k3s cluster name inside of the admin kubeconfig  [\#144](https://github.com/xunleii/terraform-module-k3s/issues/144)
- 🚧 Refresh this repository [\#140](https://github.com/xunleii/terraform-module-k3s/issues/140)
- Error "Variable `name` is deprecated" [\#136](https://github.com/xunleii/terraform-module-k3s/issues/136)

**Merged pull requests:**

- :recycle: Cleanup this repository [\#141](https://github.com/xunleii/terraform-module-k3s/pull/141) ([xunleii](https://github.com/xunleii))
- fix--multi\_server-install [\#131](https://github.com/xunleii/terraform-module-k3s/pull/131) ([N7KnightOne](https://github.com/N7KnightOne))
- Fix k3s\_install\_env\_vars and hcloud-k3s example issues [\#128](https://github.com/xunleii/terraform-module-k3s/pull/128) ([xunleii](https://github.com/xunleii))

## [v3.3.0](https://github.com/xunleii/terraform-module-k3s/tree/v3.3.0) (2023-05-14)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v3.2.0...v3.3.0)

**Dependencies upgrades:**

- chore\(deps\): update endbug/add-and-commit action to v9.1.3 [\#123](https://github.com/xunleii/terraform-module-k3s/pull/123) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update terraform http to v3.3.0 [\#122](https://github.com/xunleii/terraform-module-k3s/pull/122) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update actions/checkout action to v3.5.2 [\#121](https://github.com/xunleii/terraform-module-k3s/pull/121) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update terraform random to v3.5.1 [\#120](https://github.com/xunleii/terraform-module-k3s/pull/120) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update actions/checkout action to v3.5.0 [\#119](https://github.com/xunleii/terraform-module-k3s/pull/119) ([renovate[bot]](https://github.com/apps/renovate))
- Update actions/checkout action to v3.4.0 [\#118](https://github.com/xunleii/terraform-module-k3s/pull/118) ([renovate[bot]](https://github.com/apps/renovate))
- Update actions/checkout action to v3.3.0 [\#108](https://github.com/xunleii/terraform-module-k3s/pull/108) ([renovate[bot]](https://github.com/apps/renovate))
- Update xunleii/github-actions-grimoire digest to 0ab2cd9 [\#106](https://github.com/xunleii/terraform-module-k3s/pull/106) ([renovate[bot]](https://github.com/apps/renovate))
- Update actions/checkout action to v3.1.0 [\#105](https://github.com/xunleii/terraform-module-k3s/pull/105) ([renovate[bot]](https://github.com/apps/renovate))
- Update EndBug/add-and-commit action to v9.1.1 [\#102](https://github.com/xunleii/terraform-module-k3s/pull/102) ([renovate[bot]](https://github.com/apps/renovate))
- Update Terraform http to v3 [\#101](https://github.com/xunleii/terraform-module-k3s/pull/101) ([renovate[bot]](https://github.com/apps/renovate))
- Update Terraform tls to v4 [\#100](https://github.com/xunleii/terraform-module-k3s/pull/100) ([renovate[bot]](https://github.com/apps/renovate))

**Closed issues:**

- API URL broken in build script when using dual stack configs [\#111](https://github.com/xunleii/terraform-module-k3s/issues/111)
- Deprecated attribute with Terraform 1.3.7 [\#110](https://github.com/xunleii/terraform-module-k3s/issues/110)
- Error: Invalid Attribute Value Match  [\#104](https://github.com/xunleii/terraform-module-k3s/issues/104)

**Merged pull requests:**

- Update workflows generating documentation assets [\#125](https://github.com/xunleii/terraform-module-k3s/pull/125) ([xunleii](https://github.com/xunleii))
- feat\(k3s\_env\_vars\): introduce k3s\_install\_env\_vars [\#124](https://github.com/xunleii/terraform-module-k3s/pull/124) ([FalcoSuessgott](https://github.com/FalcoSuessgott))
- Dual-stack & IPv6 fixes [\#113](https://github.com/xunleii/terraform-module-k3s/pull/113) ([djh00t](https://github.com/djh00t))
- Update providers and fix \#110 [\#112](https://github.com/xunleii/terraform-module-k3s/pull/112) ([xunleii](https://github.com/xunleii))
- Add support for INSTALL\_K3S\_SELINUX\_WARN [\#109](https://github.com/xunleii/terraform-module-k3s/pull/109) ([hobbypunk90](https://github.com/hobbypunk90))

## [v3.2.0](https://github.com/xunleii/terraform-module-k3s/tree/v3.2.0) (2022-10-18)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v3.1.0...v3.2.0)

**Dependencies upgrades:**

- Update actions-ecosystem/action-remove-labels digest to d051625 [\#103](https://github.com/xunleii/terraform-module-k3s/pull/103) ([renovate[bot]](https://github.com/apps/renovate))
- Update EndBug/add-and-commit action to v9.0.1 [\#99](https://github.com/xunleii/terraform-module-k3s/pull/99) ([renovate[bot]](https://github.com/apps/renovate))
- Update xunleii/github-actions-grimoire digest to 42f3d38 [\#98](https://github.com/xunleii/terraform-module-k3s/pull/98) ([renovate[bot]](https://github.com/apps/renovate))
- Update actions/checkout action to v3 [\#97](https://github.com/xunleii/terraform-module-k3s/pull/97) ([renovate[bot]](https://github.com/apps/renovate))
- Update EndBug/add-and-commit action to v9 [\#94](https://github.com/xunleii/terraform-module-k3s/pull/94) ([renovate[bot]](https://github.com/apps/renovate))
- Update Hetzner Cloud example [\#93](https://github.com/xunleii/terraform-module-k3s/pull/93) ([xunleii](https://github.com/xunleii))
- Update actions/checkout action to v2.4.2 [\#89](https://github.com/xunleii/terraform-module-k3s/pull/89) ([renovate[bot]](https://github.com/apps/renovate))
- Update xunleii/github-actions-grimoire digest to 7b2b767 [\#87](https://github.com/xunleii/terraform-module-k3s/pull/87) ([renovate[bot]](https://github.com/apps/renovate))
- Update actions/checkout action to v3 [\#86](https://github.com/xunleii/terraform-module-k3s/pull/86) ([renovate[bot]](https://github.com/apps/renovate))

**Closed issues:**

- Error sensitive var.servers [\#84](https://github.com/xunleii/terraform-module-k3s/issues/84)
- Publish a new version on the Terraform registry  [\#79](https://github.com/xunleii/terraform-module-k3s/issues/79)

**Merged pull requests:**

- fix: typo in variables.tf [\#96](https://github.com/xunleii/terraform-module-k3s/pull/96) ([Tchoupinax](https://github.com/Tchoupinax))
- Fix some Github Action issues [\#92](https://github.com/xunleii/terraform-module-k3s/pull/92) ([xunleii](https://github.com/xunleii))
- Reenable auto changelog generation [\#91](https://github.com/xunleii/terraform-module-k3s/pull/91) ([xunleii](https://github.com/xunleii))
- Add missing permission on github actions workflow [\#90](https://github.com/xunleii/terraform-module-k3s/pull/90) ([xunleii](https://github.com/xunleii))
- addressing changes in recent hashicorp tls provider [\#88](https://github.com/xunleii/terraform-module-k3s/pull/88) ([ptu](https://github.com/ptu))
- Generate Changelog automatically [\#82](https://github.com/xunleii/terraform-module-k3s/pull/82) ([xunleii](https://github.com/xunleii))

## [v3.1.0](https://github.com/xunleii/terraform-module-k3s/tree/v3.1.0) (2022-01-04)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v3.0.0...v3.1.0)

**Dependencies upgrades:**

- chore\(deps\): update commitlint monorepo \(major\) [\#78](https://github.com/xunleii/terraform-module-k3s/pull/78) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update actions/checkout action to v2.4.0 [\#77](https://github.com/xunleii/terraform-module-k3s/pull/77) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update commitlint monorepo to v15 \(major\) [\#76](https://github.com/xunleii/terraform-module-k3s/pull/76) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update zgosalvez/github-actions-ensure-sha-pinned-actions action to v1.1.1 [\#75](https://github.com/xunleii/terraform-module-k3s/pull/75) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update dependency husky to v7.0.4 [\#74](https://github.com/xunleii/terraform-module-k3s/pull/74) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update marocchino/sticky-pull-request-comment action to v2.2.0 [\#73](https://github.com/xunleii/terraform-module-k3s/pull/73) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update actions/checkout action to v2.3.5 [\#72](https://github.com/xunleii/terraform-module-k3s/pull/72) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update wagoid/commitlint-github-action action to v4.1.9 [\#71](https://github.com/xunleii/terraform-module-k3s/pull/71) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update dependency @commitlint/cli to v13.2.1 [\#70](https://github.com/xunleii/terraform-module-k3s/pull/70) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update marocchino/sticky-pull-request-comment action to v2.1.1 [\#68](https://github.com/xunleii/terraform-module-k3s/pull/68) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update terraform random to v3 [\#65](https://github.com/xunleii/terraform-module-k3s/pull/65) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update terraform null to v3 [\#64](https://github.com/xunleii/terraform-module-k3s/pull/64) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update terraform http to v2 [\#63](https://github.com/xunleii/terraform-module-k3s/pull/63) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update dependency husky to v7 [\#62](https://github.com/xunleii/terraform-module-k3s/pull/62) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): update commitlint monorepo to v13 \(major\) [\#61](https://github.com/xunleii/terraform-module-k3s/pull/61) ([renovate[bot]](https://github.com/apps/renovate))
- chore\(deps\): pin dependencies [\#58](https://github.com/xunleii/terraform-module-k3s/pull/58) ([renovate[bot]](https://github.com/apps/renovate))

**Merged pull requests:**

- Remove commit lint dependencies [\#81](https://github.com/xunleii/terraform-module-k3s/pull/81) ([xunleii](https://github.com/xunleii))
- Output the Kubernetes cluster secret [\#80](https://github.com/xunleii/terraform-module-k3s/pull/80) ([orf](https://github.com/orf))
- Add Hacktoberfest labels [\#69](https://github.com/xunleii/terraform-module-k3s/pull/69) ([xunleii](https://github.com/xunleii))
- Rewrite CI/CD workflows [\#67](https://github.com/xunleii/terraform-module-k3s/pull/67) ([xunleii](https://github.com/xunleii))
- Add new use\_sudo input to the documentation [\#66](https://github.com/xunleii/terraform-module-k3s/pull/66) ([Corwind](https://github.com/Corwind))
- add option to use kubectl with sudo [\#57](https://github.com/xunleii/terraform-module-k3s/pull/57) ([Corwind](https://github.com/Corwind))
- Configure Renovate [\#56](https://github.com/xunleii/terraform-module-k3s/pull/56) ([renovate[bot]](https://github.com/apps/renovate))
- Fix civo example [\#55](https://github.com/xunleii/terraform-module-k3s/pull/55) ([debovema](https://github.com/debovema))

## [v3.0.0](https://github.com/xunleii/terraform-module-k3s/tree/v3.0.0) (2021-06-27)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.2.4...v3.0.0)

**Closed issues:**

- rename variable name to cluster\_domain [\#53](https://github.com/xunleii/terraform-module-k3s/issues/53)
- Pod and Service cidrs must be passed on all masters \(not just the 1st one\) [\#52](https://github.com/xunleii/terraform-module-k3s/issues/52)
- Hetzner example doesn't work [\#50](https://github.com/xunleii/terraform-module-k3s/issues/50)
- mkdir: cannot create directory ‘/var/lib/rancher’: Permission denied [\#42](https://github.com/xunleii/terraform-module-k3s/issues/42)

**Merged pull requests:**

- Resolve issues \#52 & \#53 [\#54](https://github.com/xunleii/terraform-module-k3s/pull/54) ([xunleii](https://github.com/xunleii))

## [v2.2.4](https://github.com/xunleii/terraform-module-k3s/tree/v2.2.4) (2021-04-30)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.2.3...v2.2.4)

**Closed issues:**

- Failed to join the cluster with the same name [\#26](https://github.com/xunleii/terraform-module-k3s/issues/26)

**Merged pull requests:**

- Enhancing 'Hetzner example' docs [\#51](https://github.com/xunleii/terraform-module-k3s/pull/51) ([NicoWde](https://github.com/NicoWde))
- Add support for provisioning without logging in as root [\#49](https://github.com/xunleii/terraform-module-k3s/pull/49) ([caleb-devops](https://github.com/caleb-devops))

## [v2.2.3](https://github.com/xunleii/terraform-module-k3s/tree/v2.2.3) (2021-02-17)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.2.2...v2.2.3)

**Merged pull requests:**

- fix: add \*\_drain to kubernetes\_ready [\#48](https://github.com/xunleii/terraform-module-k3s/pull/48) ([xunleii](https://github.com/xunleii))

## [v2.2.2](https://github.com/xunleii/terraform-module-k3s/tree/v2.2.2) (2021-02-13)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.2.1...v2.2.2)

**Merged pull requests:**

- feat: add dependency endpoint to allow sychronizing k3s install & provisionning [\#47](https://github.com/xunleii/terraform-module-k3s/pull/47) ([xunleii](https://github.com/xunleii))

## [v2.2.1](https://github.com/xunleii/terraform-module-k3s/tree/v2.2.1) (2021-02-10)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.2.0...v2.2.1)

**Closed issues:**

- failed to start k3s node with label `node-role.kubernetes.io/***` [\#45](https://github.com/xunleii/terraform-module-k3s/issues/45)
- register: metadata.name: Invalid value [\#44](https://github.com/xunleii/terraform-module-k3s/issues/44)
- Fix this stupid CI [\#38](https://github.com/xunleii/terraform-module-k3s/issues/38)

**Merged pull requests:**

- fix: correct some installation issues \(\#44 & \#45\) [\#46](https://github.com/xunleii/terraform-module-k3s/pull/46) ([xunleii](https://github.com/xunleii))
- Generate Kubeconfig file [\#37](https://github.com/xunleii/terraform-module-k3s/pull/37) ([guitcastro](https://github.com/guitcastro))
- removed missing additional\_flags from readme [\#36](https://github.com/xunleii/terraform-module-k3s/pull/36) ([guitcastro](https://github.com/guitcastro))
- doc: update README [\#35](https://github.com/xunleii/terraform-module-k3s/pull/35) ([xunleii](https://github.com/xunleii))

## [v2.2.0](https://github.com/xunleii/terraform-module-k3s/tree/v2.2.0) (2021-01-03)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.1.0...v2.2.0)

**Closed issues:**

- kube\_config output missing  [\#41](https://github.com/xunleii/terraform-module-k3s/issues/41)
- NodeNotFound when trying to update nodes [\#31](https://github.com/xunleii/terraform-module-k3s/issues/31)

**Merged pull requests:**

- Try to fix this CI.... another time [\#40](https://github.com/xunleii/terraform-module-k3s/pull/40) ([xunleii](https://github.com/xunleii))
- Fix doc typo in readme [\#39](https://github.com/xunleii/terraform-module-k3s/pull/39) ([DblK](https://github.com/DblK))

## [v2.1.0](https://github.com/xunleii/terraform-module-k3s/tree/v2.1.0) (2020-08-26)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.0.1...v2.1.0)

**Closed issues:**

- Deprecation of network\_id in `hcloud_server_network` [\#29](https://github.com/xunleii/terraform-module-k3s/issues/29)
- Remove or fix the 'latest' feature [\#27](https://github.com/xunleii/terraform-module-k3s/issues/27)
- Agent not update when k3s version changes [\#24](https://github.com/xunleii/terraform-module-k3s/issues/24)
- Need actions to test automatically PR [\#5](https://github.com/xunleii/terraform-module-k3s/issues/5)

**Merged pull requests:**

- fix: repair Terraform workflow \(CI\) [\#33](https://github.com/xunleii/terraform-module-k3s/pull/33) ([xunleii](https://github.com/xunleii))
- Make sure the node is up before trying to use it. [\#32](https://github.com/xunleii/terraform-module-k3s/pull/32) ([tedsteen](https://github.com/tedsteen))
- fix: replace network\_id with subnet\_id [\#30](https://github.com/xunleii/terraform-module-k3s/pull/30) ([solidnerd](https://github.com/solidnerd))
- fix: use k3s update channels for latest releases instead of github [\#28](https://github.com/xunleii/terraform-module-k3s/pull/28) ([solidnerd](https://github.com/solidnerd))

## [v2.0.1](https://github.com/xunleii/terraform-module-k3s/tree/v2.0.1) (2020-05-31)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v2.0.0...v2.0.1)

**Closed issues:**

- CI needs to be fixed before v2 release [\#22](https://github.com/xunleii/terraform-module-k3s/issues/22)

**Merged pull requests:**

- fix: do not uninstall k3s during upgrade [\#25](https://github.com/xunleii/terraform-module-k3s/pull/25) ([xunleii](https://github.com/xunleii))

## [v2.0.0](https://github.com/xunleii/terraform-module-k3s/tree/v2.0.0) (2020-05-31)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.7.0...v2.0.0)

**Closed issues:**

- Server taints flags are not used [\#20](https://github.com/xunleii/terraform-module-k3s/issues/20)
- Make it possible to have additional flags per agent [\#18](https://github.com/xunleii/terraform-module-k3s/issues/18)

**Merged pull requests:**

- fix: update Github Actions worflow [\#23](https://github.com/xunleii/terraform-module-k3s/pull/23) ([xunleii](https://github.com/xunleii))
- feat: rewrote module [\#21](https://github.com/xunleii/terraform-module-k3s/pull/21) ([xunleii](https://github.com/xunleii))
- Additional flags per instance [\#19](https://github.com/xunleii/terraform-module-k3s/pull/19) ([tedsteen](https://github.com/tedsteen))

## [v1.7.0](https://github.com/xunleii/terraform-module-k3s/tree/v1.7.0) (2020-01-31)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.6.3...v1.7.0)

**Merged pull requests:**

- feat: add node taints & labels [\#17](https://github.com/xunleii/terraform-module-k3s/pull/17) ([xunleii](https://github.com/xunleii))

## [v1.6.3](https://github.com/xunleii/terraform-module-k3s/tree/v1.6.3) (2019-12-28)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.6.2...v1.6.3)

**Merged pull requests:**

- fix: use node\_name field in node deletion [\#16](https://github.com/xunleii/terraform-module-k3s/pull/16) ([xunleii](https://github.com/xunleii))

## [v1.6.2](https://github.com/xunleii/terraform-module-k3s/tree/v1.6.2) (2019-12-21)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.6.1...v1.6.2)

**Merged pull requests:**

- feat: use name in agent nodes [\#15](https://github.com/xunleii/terraform-module-k3s/pull/15) ([xunleii](https://github.com/xunleii))

## [v1.6.1](https://github.com/xunleii/terraform-module-k3s/tree/v1.6.1) (2019-12-04)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.6.0...v1.6.1)

**Merged pull requests:**

- feat: upload installer [\#14](https://github.com/xunleii/terraform-module-k3s/pull/14) ([xunleii](https://github.com/xunleii))

## [v1.6.0](https://github.com/xunleii/terraform-module-k3s/tree/v1.6.0) (2019-12-04)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.5.0...v1.6.0)

**Merged pull requests:**

- refact: rename node roles in server and agent [\#13](https://github.com/xunleii/terraform-module-k3s/pull/13) ([xunleii](https://github.com/xunleii))
- Refact clean module [\#12](https://github.com/xunleii/terraform-module-k3s/pull/12) ([xunleii](https://github.com/xunleii))

## [v1.5.0](https://github.com/xunleii/terraform-module-k3s/tree/v1.5.0) (2019-12-01)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.4.0...v1.5.0)

## [v1.4.0](https://github.com/xunleii/terraform-module-k3s/tree/v1.4.0) (2019-11-27)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.3.2...v1.4.0)

**Merged pull requests:**

- refact: clean custom flags feature [\#11](https://github.com/xunleii/terraform-module-k3s/pull/11) ([xunleii](https://github.com/xunleii))

## [v1.3.2](https://github.com/xunleii/terraform-module-k3s/tree/v1.3.2) (2019-11-27)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.3.1...v1.3.2)

**Merged pull requests:**

- fix: join custom arguments [\#10](https://github.com/xunleii/terraform-module-k3s/pull/10) ([xunleii](https://github.com/xunleii))

## [v1.3.1](https://github.com/xunleii/terraform-module-k3s/tree/v1.3.1) (2019-11-27)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.2.3...v1.3.1)

**Merged pull requests:**

- feat: add custom arguments [\#9](https://github.com/xunleii/terraform-module-k3s/pull/9) ([xunleii](https://github.com/xunleii))

## [v1.2.3](https://github.com/xunleii/terraform-module-k3s/tree/v1.2.3) (2019-11-24)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.2.2...v1.2.3)

**Merged pull requests:**

- fix: remove warning 'quoted keywords are now deprecated' [\#8](https://github.com/xunleii/terraform-module-k3s/pull/8) ([xunleii](https://github.com/xunleii))

## [v1.2.2](https://github.com/xunleii/terraform-module-k3s/tree/v1.2.2) (2019-11-16)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.2.1...v1.2.2)

**Merged pull requests:**

- feat: add Terraform actions [\#6](https://github.com/xunleii/terraform-module-k3s/pull/6) ([xunleii](https://github.com/xunleii))

## [v1.2.1](https://github.com/xunleii/terraform-module-k3s/tree/v1.2.1) (2019-11-16)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/xunleii/terraform-module-k3s/tree/v1.2.0) (2019-11-16)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.1.0...v1.2.0)

**Closed issues:**

- Remove 'scp' dependency [\#3](https://github.com/xunleii/terraform-module-k3s/issues/3)

**Merged pull requests:**

- Remove 'scp' dependency [\#4](https://github.com/xunleii/terraform-module-k3s/pull/4) ([xunleii](https://github.com/xunleii))

## [v1.1.0](https://github.com/xunleii/terraform-module-k3s/tree/v1.1.0) (2019-11-03)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/v1.0.0...v1.1.0)

**Closed issues:**

- Impossible to remove one \(several\) minion node\(s\) [\#1](https://github.com/xunleii/terraform-module-k3s/issues/1)

**Merged pull requests:**

- \#1 - fix removable node [\#2](https://github.com/xunleii/terraform-module-k3s/pull/2) ([xunleii](https://github.com/xunleii))

## [v1.0.0](https://github.com/xunleii/terraform-module-k3s/tree/v1.0.0) (2019-11-02)

[Full Changelog](https://github.com/xunleii/terraform-module-k3s/compare/ccc49fe3f98ef7a9885dcf5ae3efb087048497f9...v1.0.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
