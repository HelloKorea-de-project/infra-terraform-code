import json
import os
import boto3
import time
import logging

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    rds = boto3.client('rds')
    redshift = boto3.client('redshift')

    
    try:
      ec2_instances = json.loads(os.environ.get('EC2_INSTANCES', '[]'))
    
    except json.JSONDecodeError as e:
        logging.error(f"Failed to decode JSON: {str(e)}")
        return {'statusCode': 400, 'body': f'Failed to decode JSON: {str(e)}'}
    

    try:
      # EC2 인스턴스 시작
        for ec2_instance in ec2_instances:
            if ec2.describe_instances(InstanceIds=[ec2_instance])['Reservations'][0]['Instances'][0]['State']['Name'] == 'stopped':
                ec2.start_instances(InstanceIds=[ec2_instance])
                print(f"Started EC2 instances: {ec2_instance}")
            else:
                continue
    except Exception as e:
        logging.error(f"Failed to start EC2 instances: {str(e)}")
        return {'statusCode': 500, 'body': f'Failed to start EC2 instances: {str(e)}'}


    return {
        'statusCode': 200,
        'body': 'Instances started successfully'
    }