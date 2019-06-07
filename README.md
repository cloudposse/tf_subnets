<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![README Header][readme_header_img]][readme_header_link]

[![Cloud Posse][logo]](https://cpco.io/homepage)

# terraform-aws-dynamic-subnets [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-dynamic-subnets.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-dynamic-subnets) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-aws-dynamic-subnets.svg)](https://github.com/cloudposse/terraform-aws-dynamic-subnets/releases/latest) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


Terraform module to provision public and private [`subnets`](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) in an existing [`VPC`](https://aws.amazon.com/vpc)

__Note:__ this module is intended for use with an existing VPC and existing Internet Gateway.
To create a new VPC, use [terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc) module.


---

This project is part of our comprehensive ["SweetOps"](https://cpco.io/sweetops) approach towards DevOps. 
[<img align="right" title="Share via Email" src="https://docs.cloudposse.com/images/ionicons/ios-email-outline-2.0.1-16x16-999999.svg"/>][share_email]
[<img align="right" title="Share on Google+" src="https://docs.cloudposse.com/images/ionicons/social-googleplus-outline-2.0.1-16x16-999999.svg" />][share_googleplus]
[<img align="right" title="Share on Facebook" src="https://docs.cloudposse.com/images/ionicons/social-facebook-outline-2.0.1-16x16-999999.svg" />][share_facebook]
[<img align="right" title="Share on Reddit" src="https://docs.cloudposse.com/images/ionicons/social-reddit-outline-2.0.1-16x16-999999.svg" />][share_reddit]
[<img align="right" title="Share on LinkedIn" src="https://docs.cloudposse.com/images/ionicons/social-linkedin-outline-2.0.1-16x16-999999.svg" />][share_linkedin]
[<img align="right" title="Share on Twitter" src="https://docs.cloudposse.com/images/ionicons/social-twitter-outline-2.0.1-16x16-999999.svg" />][share_twitter]


[![Terraform Open Source Modules](https://docs.cloudposse.com/images/terraform-open-source-modules.svg)][terraform_modules]



It's 100% Open Source and licensed under the [APACHE2](LICENSE).







We literally have [*hundreds of terraform modules*][terraform_modules] that are Open Source and well-maintained. Check them out! 







## Usage


**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/cloudposse/terraform-aws-dynamic-subnets/releases).


```hcl
module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  namespace           = "cp"
  stage               = "prod"
  name                = "app"
  region              = "us-east-1"
  vpc_id              = "vpc-XXXXXXXX"
  igw_id              = "igw-XXXXXXXX"
  cidr_block          = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
}
```






## Subnet calculation logic

`terraform-aws-dynamic-subnets` creates a set of subnets based on `${var.cidr_block}` input and number of Availability Zones in the region.

For subnet set calculation, the module uses Terraform interpolation

[cidrsubnet](https://www.terraform.io/docs/configuration/interpolation.html#cidrsubnet-iprange-newbits-netnum-).


```hcl
${
  cidrsubnet(
  signum(length(var.cidr_block)) == 1 ?
  var.cidr_block : data.aws_vpc.default.cidr_block,
  ceil(log(length(data.aws_availability_zones.available.names) * 2, 2)),
  count.index)
}
```


1. Use `${var.cidr_block}` input (if specified) or
   use a VPC CIDR block `data.aws_vpc.default.cidr_block` (e.g. `10.0.0.0/16`)
2. Get number of available AZ in the region (e.g. `length(data.aws_availability_zones.available.names)`)
3. Calculate `newbits`. `newbits` number specifies how many subnets
   be the CIDR block (input or VPC) will be divided into. `newbits` is the number of `binary digits`.

    Example:

    `newbits = 1` - 2 subnets are available (`1 binary digit` allows to count up to `2`)

    `newbits = 2` - 4 subnets are available (`2 binary digits` allows to count up to `4`)

    `newbits = 3` - 8 subnets are available (`3 binary digits` allows to count up to `8`)

    etc.

    1. We know, that we have `6` AZs in a `us-east-1` region (see step 2).
    2. We need to create `1 public` subnet and `1 private` subnet in each AZ,
       thus we need to create `12 subnets` in total (`6` AZs * (`1 public` + `1 private`)).
    3. We need `4 binary digits` for that ( 2<sup>4</sup> = 16 ).
       In order to calculate the number of `binary digits` we should use `logarithm`
       function. We should use `base 2` logarithm because decimal numbers
       can be calculated as `powers` of binary number.
       See [Wiki](https://en.wikipedia.org/wiki/Binary_number#Decimal)
       for more details

       Example:

       For `12 subnets` we need `3.58` `binary digits` (log<sub>2</sub>12)

       For `16 subnets` we need `4` `binary digits` (log<sub>2</sub>16)

       For `7 subnets` we need `2.81` `binary digits` (log<sub>2</sub>7)

       etc.
    4. We can't use fractional values to calculate the number of `binary digits`.
       We can't round it down because smaller number of `binary digits` is
       insufficient to represent the required subnets.
       We round it up. See [ceil](https://www.terraform.io/docs/configuration/interpolation.html#ceil-float-).

       Example:

       For `12 subnets` we need `4` `binary digits` (ceil(log<sub>2</sub>12))

       For `16 subnets` we need `4` `binary digits` (ceil(log<sub>2</sub>16))

       For `7 subnets` we need `3` `binary digits` (ceil(log<sub>2</sub>7))

       etc.

    5. Assign private subnets according to AZ number (we're using `count.index` for that).
    6. Assign public subnets according to AZ number but with a shift according to the number of AZs in the region (see step 2)
## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tag_map | Additional tags for appending to each tag map | map | `<map>` | no |
| attributes | [Label Module] Any extra attributes for naming these resources | list | `<list>` | no |
| availability_zones | List of Availability Zones where subnets will be created | list | - | yes |
| cidr_block | Base CIDR block which will be divided into subnet CIDR blocks (e.g. `10.0.0.0/16`) | string | - | yes |
| context | [Label Module] The context output from an external label module to pass to the label modules within this module | map | `<map>` | no |
| delimiter | [Label Module] Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| environment | [Label Module] The environment name if not using stage | string | `` | no |
| igw_id | Internet Gateway ID the public route table will point to (e.g. `igw-9c26a123`) | string | - | yes |
| label_order | [Label Module] The naming order of the id output and Name tag | list | `<list>` | no |
| map_public_ip_on_launch | Instances launched into a public subnet should be assigned a public IP address | string | `true` | no |
| max_subnet_count | Sets the maximum amount of subnets to deploy.  0 will deploy a subnet for every provided availablility zone (in `availability_zones` variable) within the region | string | `0` | no |
| name | [Label Module] Solution name, e.g. 'app' or 'jenkins' | string | `` | no |
| namespace | [Label Module] Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | string | `` | no |
| nat_gateway_enabled | Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet | string | `true` | no |
| nat_instance_enabled | Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet | string | `false` | no |
| nat_instance_type | NAT Instance type | string | `t3.micro` | no |
| private_network_acl_id | Network ACL ID that will be added to private subnets. If empty, a new ACL will be created | string | `` | no |
| public_network_acl_id | Network ACL ID that will be added to public subnets. If empty, a new ACL will be created | string | `` | no |
| regex_replace_chars | [Label Module] Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. By default only hyphens, letters and digits are allowed, all other chars are removed | string | `/[^a-zA-Z0-9-]/` | no |
| region | AWS Region (e.g. `us-east-1`) | string | - | yes |
| stage | [Label Module] Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | `` | no |
| subnet_type_tag_key | Key for subnet type tag to provide information about the type of subnets, e.g. `cpco.io/subnet/type=private` or `cpco.io/subnet/type=public` | string | `cpco.io/subnet/type` | no |
| subnet_type_tag_value_format | This is using the format interpolation symbols to allow the value of the subnet_type_tag_key to be modified. | string | `%s` | no |
| tags | [Label Module] Additional tags to apply to all resources that use this label module | map | `<map>` | no |
| vpc_default_route_table_id | Default route table for public subnets. If not set, will be created. (e.g. `rtb-f4f0ce12`) | string | `` | no |
| vpc_id | VPC ID where subnets will be created (e.g. `vpc-aceb2723`) | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| availability_zones | List of Availability Zones where subnets were created |
| nat_gateway_ids | IDs of the NAT Gateways created |
| nat_instance_ids | IDs of the NAT Instances created |
| private_route_table_ids | IDs of the created private route tables |
| private_subnet_cidrs | CIDR blocks of the created private subnets |
| private_subnet_ids | IDs of the created private subnets |
| public_route_table_ids | IDs of the created public route tables |
| public_subnet_cidrs | CIDR blocks of the created public subnets |
| public_subnet_ids | IDs of the created public subnets |




## Share the Love 

Like this project? Please give it a ★ on [our GitHub](https://github.com/cloudposse/terraform-aws-dynamic-subnets)! (it helps us **a lot**) 

Are you using this project or any of our other projects? Consider [leaving a testimonial][testimonial]. =)


## Related Projects

Check out these related projects.

- [terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc) - Terraform Module that defines a VPC with public/private subnets across multiple AZs with Internet Gateways
- [terraform-aws-vpc-peering](https://github.com/cloudposse/terraform-aws-vpc-peering) - Terraform module to create a peering connection between two VPCs
- [terraform-aws-kops-vpc-peering](https://github.com/cloudposse/terraform-aws-kops-vpc-peering) - Terraform module to create a peering connection between a backing services VPC and a VPC created by Kops
- [terraform-aws-named-subnets](https://github.com/cloudposse/terraform-aws-named-subnets) - Terraform module for named subnets provisioning.



## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-dynamic-subnets/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## Commercial Support

Work directly with our team of DevOps experts via email, slack, and video conferencing. 

We provide [*commercial support*][commercial_support] for all of our [Open Source][github] projects. As a *Dedicated Support* customer, you have access to our team of subject matter experts at a fraction of the cost of a full-time engineer. 

[![E-Mail](https://img.shields.io/badge/email-hello@cloudposse.com-blue.svg)][email]

- **Questions.** We'll use a Shared Slack channel between your team and ours.
- **Troubleshooting.** We'll help you triage why things aren't working.
- **Code Reviews.** We'll review your Pull Requests and provide constructive feedback.
- **Bug Fixes.** We'll rapidly work to fix any bugs in our projects.
- **Build New Terraform Modules.** We'll [develop original modules][module_development] to provision infrastructure.
- **Cloud Architecture.** We'll assist with your cloud strategy and design.
- **Implementation.** We'll provide hands-on support to implement our reference architectures. 



## Terraform Module Development

Are you interested in custom Terraform module development? Submit your inquiry using [our form][module_development] today and we'll get back to you ASAP.


## Slack Community

Join our [Open Source Community][slack] on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

## Newsletter

Signup for [our newsletter][newsletter] that covers everything on our technology radar.  Receive updates on what we're up to on GitHub as well as awesome new projects we discover. 

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-dynamic-subnets/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://cpco.io/help-out) with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2019 [Cloud Posse, LLC](https://cpco.io/copyright)



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know by [leaving a testimonial][testimonial]!

[![Cloud Posse][logo]][website]

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We ❤️  [Open Source Software][we_love_open_source].

We offer [paid support][commercial_support] on all of our projects.  

Check out [our other projects][github], [follow us on twitter][twitter], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.



### Contributors

|  [![Erik Osterman][osterman_avatar]][osterman_homepage]<br/>[Erik Osterman][osterman_homepage] | [![Andriy Knysh][aknysh_avatar]][aknysh_homepage]<br/>[Andriy Knysh][aknysh_homepage] | [![Sergey Vasilyev][s2504s_avatar]][s2504s_homepage]<br/>[Sergey Vasilyev][s2504s_homepage] | [![Vladimir][SweetOps_avatar]][SweetOps_homepage]<br/>[Vladimir][SweetOps_homepage] | [![Konstantin B][comeanother_avatar]][comeanother_homepage]<br/>[Konstantin B][comeanother_homepage] | [![dcowan-vestmark][dcowan-vestmark_avatar]][dcowan-vestmark_homepage]<br/>[dcowan-vestmark][dcowan-vestmark_homepage] | [![Ivan Pinatti][ivan-pinatti_avatar]][ivan-pinatti_homepage]<br/>[Ivan Pinatti][ivan-pinatti_homepage] | [![Oscar Sullivan][osulli_avatar]][osulli_homepage]<br/>[Oscar Sullivan][osulli_homepage] |
|---|---|---|---|---|---|---|---|

  [osterman_homepage]: https://github.com/osterman
  [osterman_avatar]: https://github.com/osterman.png?size=150
  [aknysh_homepage]: https://github.com/aknysh
  [aknysh_avatar]: https://github.com/aknysh.png?size=150
  [s2504s_homepage]: https://github.com/s2504s
  [s2504s_avatar]: https://github.com/s2504s.png?size=150
  [SweetOps_homepage]: https://github.com/SweetOps
  [SweetOps_avatar]: https://github.com/SweetOps.png?size=150
  [comeanother_homepage]: https://github.com/comeanother
  [comeanother_avatar]: https://github.com/comeanother.png?size=150
  [dcowan-vestmark_homepage]: https://github.com/dcowan-vestmark
  [dcowan-vestmark_avatar]: https://github.com/dcowan-vestmark.png?size=150
  [ivan-pinatti_homepage]: https://github.com/ivan-pinatti
  [ivan-pinatti_avatar]: https://github.com/ivan-pinatti.png?size=150
  [osulli_homepage]: https://github.com/osulli
  [osulli_avatar]: https://github.com/osulli.png?size=150



[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs
  [website]: https://cpco.io/homepage
  [github]: https://cpco.io/github
  [jobs]: https://cpco.io/jobs
  [hire]: https://cpco.io/hire
  [slack]: https://cpco.io/slack
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://cpco.io/twitter
  [testimonial]: https://cpco.io/leave-testimonial
  [newsletter]: https://cpco.io/newsletter
  [email]: https://cpco.io/email
  [commercial_support]: https://cpco.io/commercial-support
  [we_love_open_source]: https://cpco.io/we-love-open-source
  [module_development]: https://cpco.io/module-development
  [terraform_modules]: https://cpco.io/terraform-modules
  [readme_header_img]: https://cloudposse.com/readme/header/img?repo=cloudposse/terraform-aws-dynamic-subnets
  [readme_header_link]: https://cloudposse.com/readme/header/link?repo=cloudposse/terraform-aws-dynamic-subnets
  [readme_footer_img]: https://cloudposse.com/readme/footer/img?repo=cloudposse/terraform-aws-dynamic-subnets
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?repo=cloudposse/terraform-aws-dynamic-subnets
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img?repo=cloudposse/terraform-aws-dynamic-subnets
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?repo=cloudposse/terraform-aws-dynamic-subnets
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-dynamic-subnets&url=https://github.com/cloudposse/terraform-aws-dynamic-subnets
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-dynamic-subnets&url=https://github.com/cloudposse/terraform-aws-dynamic-subnets
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudposse/terraform-aws-dynamic-subnets
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudposse/terraform-aws-dynamic-subnets
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudposse/terraform-aws-dynamic-subnets
  [share_email]: mailto:?subject=terraform-aws-dynamic-subnets&body=https://github.com/cloudposse/terraform-aws-dynamic-subnets
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-dynamic-subnets?pixel&cs=github&cm=readme&an=terraform-aws-dynamic-subnets
