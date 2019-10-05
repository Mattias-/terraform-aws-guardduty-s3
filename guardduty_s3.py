#!/usr/bin/env python3

import datetime
import json
import os

import boto3


def main(finding, dry_run=False):
    bucket = os.environ.get("bucket")
    assert bucket
    prefix = os.environ.get("prefix", "")

    finding_id = finding["id"]
    key = _gen_key(finding_id, prefix=prefix)

    if dry_run:
        print(f"Dry run to s3://{bucket}/{key}")
        print(json.dumps(finding))
    else:
        s3 = boto3.resource("s3")
        s3_object = s3.Object(bucket, key)
        s3_object.put(Body=json.dumps(finding))


def lambda_handler(event, context):
    """Handler to be called by AWS Lambda"""
    assert event.get("detail")
    main(event["detail"])


def _gen_key(finding_id, prefix=""):
    now = datetime.datetime.now()
    key = "{p}/{d.year}/{d.month}/{d.day}/{f_id}-guardduty.json".format(
        d=now, p=prefix, f_id=finding_id
    )
    # Keys should not start with /
    return key.lstrip("/")


if __name__ == "__main__":
    fake_event = {"id": "deadbeef", "a": "b"}
    main(fake_event, dry_run=True)
