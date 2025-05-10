Kinesis Data:-

aws --version

Producer:-

* CLi version v2
aws kinesis put-record --stream-name <name> --partition-key <name> --data "user signup" --cli-binary-format raw-in-base64-out

* Cli v1
aws kinesis put-record --stream-name <name> --partition-key <name> --data "user signup"


Consumer:-

* Describe the stream
aws kinesis describe-stream --stream-name <name>


* Consume some data
aws kinesis get-shard-iterator --stream-name <name> --shard-id shardId-000000000000
--shard-iterator-type TRIM_HORIZON

aws kinesis get-records --shard-iterator <paste previouse string output>
