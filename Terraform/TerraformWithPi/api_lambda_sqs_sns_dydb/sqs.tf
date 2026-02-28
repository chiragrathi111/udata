resource "aws_sqs_queue" "order_queue" {
    name = "order_queue"
    delay_seconds = 0
    # max_message_size = 262144
    # receive_wait_time_seconds = 10
    
    tags = {
        Environment = "production"
    }
}