sqs-bunny
=========

Utility for spreading messages from one sqs queue to multiple children

This utility will poll a single Amazon AWS SQS queue and make copies of the message and add them to other queues.

For example, you could have an "outbox" queue that you polled and then had all messages delivered to "email" and "sms".  It would be up to the email and sms queues to decided what to do with the message and process them if the message content was interesting.

# Setup

```ruby
gem install sqs-bunny
```

Setup a JSON configuration file like the example below which will monitor `my-parent-q` and copy the body of all messags to both `test-child` and `test-child-2`

```json
{
    "parent_q": {
        "queue_url": "https://sqs.us-east-1.amazonaws.com/12345/my-parent-q"
    },
     "children": [
        {
            "queue_url": "https://sqs.us-east-1.amazonaws.com/12345/test-child"
        },
        {
            "queue_url": "https://sqs.us-east-1.amazonaws.com/12345/test-child-2"
        }
    ]
}
```


# Running

The simplest way to run is by passing your credentials and configuration file on the command line:

```
AWS_REGION=us-east-1 AWS_ACCESS_KEY_ID=MYACCESSKEY AWS_SECRET_ACCESS_KEY=MYSECRETKEY sqs_bunny /path/to/setup.json 
```

## AWS Credentials
This gem relies on the [AWS SDK for Ruby Version 2.0.0](http://docs.aws.amazon.com/sdkforruby/api/frames.html).  See the link for details on how to configure your AWS Credentials.