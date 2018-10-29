# terraform-aws-guardduty-s3
[![CircleCI](https://circleci.com/gh/Mattias-/terraform-aws-guardduty-s3.svg?style=svg)](https://circleci.com/gh/Mattias-/terraform-aws-guardduty-s3)

This module writes [AWS GuardDuty](https://aws.amazon.com/guardduty/) findings to an AWS S3 bucket of your choice.
There will be one file per finding.

Usage:

```hcl
provider "aws" {
  region = "eu-west-1"
}

resource "aws_guardduty_detector" "detector" {
  enable = true
}

resource "aws_s3_bucket" "bucket" {
  bucket = "example"
}

module "guardduty_s3" {
  source  = "github.com/Mattias-/terraform-aws-guardduty-s3"
  bucket  = "${aws_s3_bucket.bucket.id}"
  prefix  = ""
  enabled = true
}
```

Result:

```
$ aws s3 ls s3://example --recursive
2018-10-25 22:26:10       3029 2018/10/25/10b3562e61fab7a3a1135aa3c68b3644-guardduty.txt
2018-10-25 22:26:10       2016 2018/10/25/10b3562e61fc1e71f40483413db08369-guardduty.txt
2018-10-25 22:26:05       3001 2018/10/25/12b3562e61fb4e07174f4bb10463ec06-guardduty.txt
2018-10-25 22:26:10       1845 2018/10/25/12b3562e61fe51a0d28381230935c468-guardduty.txt
2018-10-25 22:26:09       2255 2018/10/25/1ab3562e62007073f745271c446d4976-guardduty.txt
2018-10-25 22:26:44       2984 2018/10/25/24b3562e62013e20efb720cf2d6fe836-guardduty.txt
2018-10-25 22:26:05       1868 2018/10/25/32b3562e61fa519f42316b01acba678d-guardduty.txt
2018-10-25 22:26:45       1683 2018/10/25/32b3562e61fb553edf497f0585a3c57a-guardduty.txt
2018-10-25 22:26:07       3486 2018/10/25/3cb3562e61f8cbfd9b9a0df251369a35-guardduty.txt
2018-10-25 22:26:44       3039 2018/10/25/48b3562e61fabfe8c976b3e67d36e4af-guardduty.txt

$ aws s3 cp s3://example/2018/10/25/10b3562e61fab7a3a1135aa3c68b3644-guardduty.txt -
{"schemaVersion": "2.0", "accountId": "000000000000", "region": "eu-west-1", "partition": "aws", "id": "10b3562e61fab7a3a1135aa3c68b3644", "arn": "arn:aws:guardduty:eu-west-1:000000000000:detector/3cb3562d0dd992501515c484383ee494/finding/10b3562e61fab7a3a1135aa3c68b3644", "type": "Trojan:EC2/DGADomainRequest.B", "resource": {"resourceType": "Instance", "instanceDetails": {"instanceId": "i-99999999", "instanceType": "m3.xlarge", "launchTime": "2016-03-11T21:23:34Z", "platform": null, "productCodes": [{"productCodeId": "GeneratedFindingProductCodeId", "productCodeType": "GeneratedFindingProductCodeType"}], "iamInstanceProfile": {"arn": "GeneratedFindingInstanceProfileArn", "id": "GeneratedFindingInstanceProfileId"}, "networkInterfaces": [{"networkInterfaceId": "eni-bfcffe88", "privateIpAddresses": [{"privateDnsName": "GeneratedFindingPrivateName", "privateIpAddress": "10.0.0.1"}], "subnetId": "GeneratedFindingSubnetId", "vpcId": "GeneratedFindingVPCId", "privateDnsName": "GeneratedFindingPrivateDnsName", "securityGroups": [{"groupName": "GeneratedFindingSecurityGroupName", "groupId": "GeneratedFindingSecurityId"}], "publicIp": "198.51.100.0", "ipv6Addresses": [], "publicDnsName": "GeneratedFindingPublicDNSName", "privateIpAddress": "10.0.0.1"}], "tags": [{"value": "GeneratedFindingInstaceValue1", "key": "GeneratedFindingInstaceTag1"}, {"value": "GeneratedFindingInstaceTagValue2", "key": "GeneratedFindingInstaceTag2"}, {"value": "GeneratedFindingInstaceTagValue3", "key": "GeneratedFindingInstaceTag3"}, {"value": "GeneratedFindingInstaceTagValue4", "key": "GeneratedFindingInstaceTag4"}, {"value": "GeneratedFindingInstaceTagValue5", "key": "GeneratedFindingInstaceTag5"}, {"value": "GeneratedFindingInstaceTagValue6", "key": "GeneratedFindingInstaceTag6"}, {"value": "GeneratedFindingInstaceTagValue7", "key": "GeneratedFindingInstaceTag7"}, {"value": "GeneratedFindingInstaceTagValue8", "key": "GeneratedFindingInstaceTag8"}, {"value": "GeneratedFindingInstaceTagValue9", "key": "GeneratedFindingInstaceTag9"}], "instanceState": "running", "availabilityZone": "GeneratedFindingInstaceAvailabilityZone", "imageId": "ami-99999999", "imageDescription": "GeneratedFindingInstaceImageDescription"}}, "service": {"serviceName": "guardduty", "detectorId": "3cb3562d0dd992501515c484383ee494", "action": {"actionType": "DNS_REQUEST", "dnsRequestAction": {"domain": "GeneratedFindingDomainName", "protocol": "0", "blocked": true}}, "resourceRole": "ACTOR", "additionalInfo": {"domain": "GeneratedFindingAdditionalDomainName", "sample": true}, "eventFirstSeen": "2018-10-25T17:54:12.597Z", "eventLastSeen": "2018-10-25T20:22:25.471Z", "archived": false, "count": 5}, "severity": 8, "createdAt": "2018-10-25T17:54:12.597Z", "updatedAt": "2018-10-25T20:22:25.471Z", "title": "DGA domain name queried by EC2 instance i-99999999.", "description": "EC2 instance i-99999999 is querying algorithmically generated domains. Such domains are commonly used by malware and could be an indication of a compromised EC2 instance."}
```

In the bucket you will now find that one object is created per finding. The finding format can be found [here](https://docs.aws.amazon.com/guardduty/latest/ug/get-findings.html#get-findings-response-syntax).
