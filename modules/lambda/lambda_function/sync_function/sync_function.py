import os
import boto3
import shlex
import logging
import time
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    airflow_instances_id = json.loads(os.environ.get('AIRFLOW_INSTANCES_ID', '[]'))  
    
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        event_name = event['Records'][0]['eventName']
    except KeyError as e:
        logger.error(f"Missing key in event data: {str(e)}")
        return {'statusCode': 400, 'body': f'Missing key in event data: {str(e)}'}
    
    safe_key = shlex.quote(key)
    airflow_home = "/home/ubuntu/airflow"
    
    if event_name.startswith('ObjectCreated'):
        commands = [
            f"sudo -u ubuntu aws s3 cp s3://{bucket}/{safe_key} {airflow_home}/{safe_key}",
            f"if [ '{safe_key}' = 'dags/requirements.txt' ]; then",
            f"    sudo -u ubuntu {airflow_home}/bin/pip install -r {airflow_home}/dags/requirements.txt",
            "fi"
        ]
    elif event_name.startswith('ObjectRemoved'):
        commands = [f"rm {airflow_home}/{safe_key}"]
    else:
        logger.warning(f"Unsupported event type: {event_name}")
        return {'statusCode': 400, 'body': f'Unsupported event type: {event_name}'}
    
    logger.info(f"Executing commands: {commands}")
    
    ssm = boto3.client('ssm')
    
    try:
        logger.info(f"Sending SSM command to Airflow instances: {airflow_instances_id}")
        response = ssm.send_command(
            InstanceIds=['i-0e77f31bdb9039c0d'],
            DocumentName="AWS-RunShellScript",
            Parameters={'commands': commands}
        )
        
        command_id = response['Command']['CommandId']
        logger.info(f"SSM Command ID: {command_id}")
        
        
    except Exception as e:
        logger.error(f"Error executing command: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': f'Error executing command: {str(e)}'
        }

