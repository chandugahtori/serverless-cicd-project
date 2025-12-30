import json
import logging
import boto3
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
BUCKET_NAME = "event-driven-pipeline-bucket"

def lambda_handler(event, context):
    try:
        logger.info("Event received: %s", json.dumps(event))

        record = {
            "event": event,
            "requestId": context.aws_request_id,
            "timestamp": datetime.utcnow().isoformat()
        }

        file_name = f"raw-data/{datetime.utcnow().date()}/{context.aws_request_id}.json"

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=file_name,
            Body=json.dumps(record)
        )

        logger.info("Data stored successfully in S3")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Data captured and stored"})
        }

    except Exception as e:
        logger.error("Error: %s", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to store data"})
        }
