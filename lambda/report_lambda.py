import json
import boto3
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
BUCKET_NAME = "event-driven-pipeline-bucket"

def lambda_handler(event, context):
    try:
        today = datetime.utcnow().date().isoformat()
        prefix = f"raw-data/{today}/"

        response = s3.list_objects_v2(
            Bucket=BUCKET_NAME,
            Prefix=prefix
        )

        count = response.get("KeyCount", 0)

        report = {
            "date": today,
            "total_events": count,
            "generated_at": datetime.utcnow().isoformat()
        }

        report_key = f"reports/daily-report-{today}.json"

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=report_key,
            Body=json.dumps(report)
        )

        logger.info("Daily report generated")

        return {
            "statusCode": 200,
            "body": json.dumps(report)
        }

    except Exception as e:
        logger.error("Report error: %s", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Report generation failed"})
        }
