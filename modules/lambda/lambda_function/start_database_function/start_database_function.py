import json
import os
import boto3
import time
import logging

def lambda_handler(event, context):
    rds = boto3.client('rds')
    redshift = boto3.client('redshift')

    
    try:
      rds_instances = json.loads(os.environ.get('RDS_INSTANCES', '[]'))
      redshift_clusters = json.loads(os.environ.get('REDSHIFT_CLUSTERS', '[]'))
    
    except json.JSONDecodeError as e:
        logging.error(f"Failed to decode JSON: {str(e)}")
        return {'statusCode': 400, 'body': f'Failed to decode JSON: {str(e)}'}


    try:
        # RDS 인스턴스 시작
        for rds_instance in rds_instances:
            if rds.describe_db_instances(DBInstanceIdentifier=rds_instance)['DBInstances'][0]['DBInstanceStatus'] == 'stopped':
                rds.start_db_instance(DBInstanceIdentifier=rds_instance)
                print(f"Started RDS instance: {rds_instance}")
            else:
                continue
        
    except Exception as e:
        logging.error(f"Failed to start RDS instances: {str(e)}")
        return {'statusCode': 500, 'body': f'Failed to start RDS instances: {str(e)}'}
    
    try:
      # Redshift 클러스터 시작
        for redshift_cluster in redshift_clusters:
            if redshift.describe_clusters(ClusterIdentifier=redshift_cluster)['Clusters'][0]['ClusterStatus'] == 'paused':
                redshift.resume_cluster(ClusterIdentifier=redshift_cluster)
                print(f"Resumed Redshift cluster: {redshift_cluster}")
            else:
                continue

    except Exception as e:
        logging.error(f"Failed to resume Redshift clusters: {str(e)}")
        return {'statusCode': 500, 'body': f'Failed to resume Redshift clusters: {str(e)}'}
    

    return {
        'statusCode': 200,
        'body': 'Instances started successfully'
    }