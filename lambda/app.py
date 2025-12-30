import json
import logging
from datetime import datetime


logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        logger.info("Event received: %s", json.dumps(event))

        
        response = {
            "message": "Serverless CI/CD application deployed successfully",
            "timestamp": datetime.utcnow().isoformat(),
            "requestId": context.aws_request_id
        }

        logger.info("Response generated successfully")

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(response)
        }

    except Exception as e:
        logger.error("Error occurred: %s", str(e))

        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal Server Error"})
        }
