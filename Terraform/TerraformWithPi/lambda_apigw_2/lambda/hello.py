import json

def lambda_handler(event, context):
    """
    Lambda function to handle both GET /hello and POST /users requests
    
    GET /hello - Returns greeting with optional name query parameter
    POST /users - Processes user data (name and age) from request body
    """
    
    # Get HTTP method and path from the event
    http_method = event.get('httpMethod', 'GET')
    path = event.get('path', '/hello')
    
    try:
        # Handle GET request to /hello endpoint
        if http_method == 'GET' and path == '/hello':
            return handle_hello_get(event)
        
        # Handle POST request to /users endpoint
        elif http_method == 'POST' and path == '/users':
            return handle_users_post(event)
        
        # Handle unsupported method/path combinations
        else:
            return {
                "statusCode": 404,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                },
                "body": json.dumps({
                    "error": "Not Found",
                    "message": f"Endpoint {http_method} {path} not found"
                })
            }
    
    except Exception as e:
        # Handle any unexpected errors
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": "Internal Server Error",
                "message": str(e)
            })
        }

def handle_hello_get(event):
    """
    Handle GET /hello requests with optional name query parameter
    Example: GET /hello?name=John
    """
    name = "Chirag Rathi"  # Default name
    
    # Check for query parameters
    if event.get('queryStringParameters'):
        name = event.get('queryStringParameters').get('name', name)

    response_data = {
        "message": f"Hello, {name}! Your request was successful.",
        "status": "success",
        "endpoint": "GET /hello"
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(response_data)
    }

def handle_users_post(event):
    """
    Handle POST /users requests with user data in request body
    Expected JSON body: {"name": "John Doe", "age": 25}
    """
    try:
        # Parse the request body
        if not event.get('body'):
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                },
                "body": json.dumps({
                    "error": "Bad Request",
                    "message": "Request body is required"
                })
            }
        
        # Parse JSON body
        user_data = json.loads(event['body'])
        
        # Validate required fields
        if 'name' not in user_data or 'age' not in user_data:
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                },
                "body": json.dumps({
                    "error": "Bad Request",
                    "message": "Both 'name' and 'age' fields are required"
                })
            }
        
        name = user_data['name']
        age = user_data['age']
        
        # Basic validation
        if not isinstance(name, str) or len(name.strip()) == 0:
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                },
                "body": json.dumps({
                    "error": "Bad Request",
                    "message": "Name must be a non-empty string"
                })
            }
        
        if not isinstance(age, int) or age < 1 or age > 150:
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                },
                "body": json.dumps({
                    "error": "Bad Request",
                    "message": "Age must be an integer between 1 and 150"
                })
            }
        
        # Process user data (in real app, you might save to database)
        response_data = {
            "message": f"User {name} (age {age}) has been processed successfully!",
            "status": "success",
            "endpoint": "POST /users",
            "user_data": {
                "name": name,
                "age": age,
                "processed_at": "2024-01-01T00:00:00Z"  # In real app, use actual timestamp
            }
        }
        
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps(response_data)
        }
    
    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": "Bad Request",
                "message": "Invalid JSON in request body"
            })
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": "Internal Server Error",
                "message": f"Error processing user data: {str(e)}"
            })
        }