import boto3

session = boto3.Session(profile_name='developer-sso')

s3_client = session.client('s3')

buckets = s3_client.list_buckets()

for bucket in buckets['Buckets']:
    print(bucket['Name'])