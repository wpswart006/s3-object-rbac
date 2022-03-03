import json
import logging
from ntpath import join
import boto3
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)
s3 = boto3.client('s3')
iam = boto3.client('iam')

def lambda_handler(event, context):
    logger.info(json.dumps(event, indent=2))
    result = "NOPE"
    
    get_context = event["getObjectContext"]
    # user_request_headers = event["userRequest"]["headers"]
    route = get_context["outputRoute"]
    token = get_context["outputToken"]
    s3_url = get_context["inputS3Url"]
    role_name = event["userIdentity"]["sessionContext"]["sessionIssuer"]["arn"].split("role/")[-1].split("/")[-1]
    logger.warn(role_name)
    key = s3_url.split("?")[0].split(".com/")[-1]
    # logger.warn(key)
    bucket = os.environ.get("BUCKET_NAME")

    tags = s3.get_object_tagging(
        Bucket=bucket,
        Key=key,
    )["TagSet"]

    access_tags = list(filter(lambda x: x.get("Key")=="access", tags))
    if access_tags:
        access = access_tags[0]["Value"].split("+")
        role_tags = iam.list_role_tags(
            RoleName=role_name,
        )["Tags"]
        logger.warn(json.dumps(role_tags))
        role_access = list(filter(lambda x: x.get("Key") == "access", role_tags))
        logger.warn(role_access)
        role_access = role_access[0] if role_access else None
        for a in access:
            if a == role_access["Value"]:
                result = "YUP"
                break
    else:
        result = "YUP!"
        # s3.write_get_object_response(RequestRoute=route, RequestToken=token, StatusCode=200,)

    if result == "YUP":
        s3.write_get_object_response(RequestRoute=route, RequestToken=token, StatusCode=200,)
    else:
        s3.write_get_object_response(RequestRoute=route, RequestToken=token, StatusCode=401,ErrorCode="AccessDenied", ErrorMessage="You don't have access to this object")

    
    return {
        'statusCode': 200,
        # 'body': json.dumps('Hello from Lambda!')
    }
