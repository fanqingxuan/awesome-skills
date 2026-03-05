# Redis Queue

A message queue based on Redis, supports delayed message processing.

## Installation
`composer require webman/redis-queue`

## Configuration File
The Redis configuration file is automatically generated at `{main-project}/config/plugin/webman/redis-queue/redis.php`, with content similar to the following:
```php
<?php
return [
    'default' => [
        'host' => 'redis://127.0.0.1:6379',
        'options' => [
            'auth' => '',         // Password, optional
            'db' => 0,            // Database
            'max_attempts'  => 5, // Retry count after consumption failure
            'retry_seconds' => 5, // Retry interval in seconds
        ]
    ],
];
```

### Consumption Failure Retry
If consumption fails (an exception occurs), the message will be placed in the delayed queue and wait for the next retry. The retry count is controlled by `max_attempts`, and the retry interval is jointly controlled by `retry_seconds` and `max_attempts`. For example, if `max_attempts` is 5 and `retry_seconds` is 10, the first retry interval is `1*10` seconds, the second retry interval is `2*10` seconds, the third retry interval is `3*10` seconds, and so on up to 5 retries. If the retry count exceeds the `max_attempts` setting, the message will be placed in the failed queue with key `{redis-queue}-failed`.

## Message Delivery (Synchronous)

```php
<?php
namespace app\controller;

use support\Request;
use Webman\RedisQueue\Redis;

class Index
{
    public function queue(Request $request)
    {
        // Queue name
        $queue = 'send-mail';
        // Data, can be passed as array directly without serialization
        $data = ['to' => 'tom@gmail.com', 'content' => 'hello'];
        // Deliver message
        Redis::send($queue, $data);
        // Deliver delayed message, to be processed after 60 seconds
        Redis::send($queue, $data, 60);

        return response('redis queue test');
    }

}
```
On successful delivery, `Redis::send()` returns true; otherwise it returns false or throws an exception.

> **Tip**
> There may be deviation in delayed queue consumption time. For example, when consumption speed is slower than production speed, it can cause queue backlog and consumption delay. The mitigation is to run more consumer processes.

## Message Delivery (Asynchronous)
```php
<?php
namespace app\controller;

use support\Request;
use Webman\RedisQueue\Client;

class Index
{
    public function queue(Request $request)
    {
        // Queue name
        $queue = 'send-mail';
        // Data, can be passed as array directly without serialization
        $data = ['to' => 'tom@gmail.com', 'content' => 'hello'];
        // Deliver message
        Client::send($queue, $data);
        // Deliver delayed message, to be processed after 60 seconds
        Client::send($queue, $data, 60);

        return response('redis queue test');
    }

}
```
`Client::send()` has no return value. It is an asynchronous push and does not guarantee 100% message delivery to Redis.

> **Tip**
> The principle of `Client::send()` is to create an in-memory queue locally and asynchronously synchronize messages to Redis (synchronization is fast, about 10,000 messages per second). If the process restarts while data in the local memory queue has not been fully synchronized, message loss may occur. `Client::send()` async delivery is suitable for non-critical messages.

> **Tip**
> `Client::send()` is asynchronous and can only be used in the Workerman runtime. For command-line scripts, use the synchronous interface `Redis::send()`.

## Delivering Messages from Other Projects
Sometimes you need to deliver messages from other projects and cannot use `webman\redis-queue`. In such cases, you can refer to the following function to deliver messages to the queue.

```php
function redis_queue_send($redis, $queue, $data, $delay = 0) {
    $queue_waiting = '{redis-queue}-waiting';
    $queue_delay = '{redis-queue}-delayed';
    $now = time();
    $package_str = json_encode([
        'id'       => rand(),
        'time'     => $now,
        'delay'    => $delay,
        'attempts' => 0,
        'queue'    => $queue,
        'data'     => $data
    ]);
    if ($delay) {
        return $redis->zAdd($queue_delay, $now + $delay, $package_str);
    }
    return $redis->lPush($queue_waiting.$queue, $package_str);
}
```

Here, the `$redis` parameter is the Redis instance. For example, usage with the Redis extension is similar to:

```php
$redis = new Redis;
$redis->connect('127.0.0.1', 6379);
$queue = 'user-1';
$data= ['some', 'data'];
redis_queue_send($redis, $queue, $data);
```

## Consumption
The consumer process configuration file is at `{main-project}/config/plugin/webman/redis-queue/process.php`. The consumer directory is under `{main-project}/app/queue/redis/`.

Executing the command `php webman redis-queue:consumer my-send-mail` will generate the file `{main-project}/app/queue/redis/MyMailSend.php`.

> **Tip**
> This command requires installing the [Console](../plugin/console.md) plugin. If you prefer not to install it, you can manually create a file similar to the following:

```php
<?php

namespace app\queue\redis;

use Webman\RedisQueue\Consumer;

class MyMailSend implements Consumer
{
    // Queue name to consume
    public $queue = 'send-mail';

    // Connection name, corresponding to connection in plugin/webman/redis-queue/redis.php
    public $connection = 'default';

    // Consumption
    public function consume($data)
    {
        // No need for deserialization
        var_export($data); // Outputs ['to' => 'tom@gmail.com', 'content' => 'hello']
    }
    // Consumption failure callback
    /* 
    $package = [
        'id' => 1357277951, // Message ID
        'time' => 1709170510, // Message time
        'delay' => 0, // Delay time
        'attempts' => 2, // Consumption count
        'queue' => 'send-mail', // Queue name
        'data' => ['to' => 'tom@gmail.com', 'content' => 'hello'], // Message content
        'max_attempts' => 5, // Max retry count
        'error' => 'Error message' // Error message
    ]
    */
    public function onConsumeFailure(\Throwable $e, $package)
    {
        echo "consume failure\n";
        echo $e->getMessage() . "\n";
        // No need for deserialization
        var_export($package); 
    }
}
```

> **Note**
> Consumption is considered successful when no exception or Error is thrown during consumption; otherwise it is a failure and the message enters the retry queue. Redis-queue has no ack mechanism; you can treat it as automatic ack (when no exception or Error occurs). If you want to mark the current message as not successfully consumed, you can manually throw an exception to send the message to the retry queue. In practice this is no different from an ack mechanism.

> **Tip**
> Consumers support multiple servers and processes, and the same message will **not** be consumed twice. Consumed messages are automatically removed from the queue; no manual deletion is needed.

> **Tip**
> Consumer processes can consume multiple different queues at the same time. Adding a new queue does not require changing the configuration in `process.php`. When adding a new queue consumer, simply add the corresponding `Consumer` class under `app/queue/redis`, and use the class property `$queue` to specify the queue name to consume.

> **Tip**
> Windows users need to run `php windows.php` to start webman, otherwise the consumer process will not start.

> **Tip**
> The onConsumeFailure callback is triggered each time consumption fails. You can handle post-failure logic here. (This feature requires `webman/redis-queue>=1.3.2` and `workerman/redis-queue>=1.2.1`)

## Setting Different Consumer Processes for Different Queues
By default, all consumers share the same consumer process. However, sometimes we need to separate consumption for some queues—for example, put slow-consuming business in one group of processes and fast-consuming business in another. To do this, we can split consumers into two directories, e.g. `app_path() . '/queue/redis/fast'` and `app_path() . '/queue/redis/slow'` (note that the consumer class namespace must be updated accordingly). The configuration is as follows:
```php
return [
    ...other configurations omitted...
    
    'redis_consumer_fast'  => [ // Key is custom, no format restriction, named redis_consumer_fast here
        'handler'     => Webman\RedisQueue\Process\Consumer::class,
        'count'       => 8,
        'constructor' => [
            // Consumer class directory
            'consumer_dir' => app_path() . '/queue/redis/fast'
        ]
    ],
    'redis_consumer_slow'  => [  // Key is custom, no format restriction, named redis_consumer_slow here
        'handler'     => Webman\RedisQueue\Process\Consumer::class,
        'count'       => 8,
        'constructor' => [
            // Consumer class directory
            'consumer_dir' => app_path() . '/queue/redis/slow'
        ]
    ]
];
```

This way, fast-business consumers go in the `queue/redis/fast` directory and slow-business consumers in `queue/redis/slow`, achieving the goal of assigning consumer processes to queues.

## Multiple Redis Configuration
#### Configuration
`config/plugin/webman/redis-queue/redis.php`
```php
<?php
return [
    'default' => [
        'host' => 'redis://192.168.0.1:6379',
        'options' => [
            'auth' => null,       // Password, string type, optional
            'db' => 0,            // Database
            'max_attempts'  => 5, // Retry count after consumption failure
            'retry_seconds' => 5, // Retry interval in seconds
        ]
    ],
    'other' => [
        'host' => 'redis://192.168.0.2:6379',
        'options' => [
            'auth' => null,       // Password, string type, optional
            'db' => 0,            // Database
            'max_attempts'  => 5, // Retry count after consumption failure
            'retry_seconds' => 5, // Retry interval in seconds
        ]
    ],
];
```

Note that an additional Redis configuration with key `other` has been added.

#### Delivering Messages to Multiple Redis

```php
// Deliver message to queue with key `default`
Client::connection('default')->send($queue, $data);
Redis::connection('default')->send($queue, $data);
// Same as
Client::send($queue, $data);
Redis::send($queue, $data);

// Deliver message to queue with key `other`
Client::connection('other')->send($queue, $data);
Redis::connection('other')->send($queue, $data);
```

#### Consuming from Multiple Redis
Consuming messages from the queue with key `other` in the configuration:
```php
namespace app\queue\redis;

use Webman\RedisQueue\Consumer;

class SendMail implements Consumer
{
    // Queue name to consume
    public $queue = 'send-mail';

    // === Set to 'other' here to consume from queue with key 'other' in config ===
    public $connection = 'other';

    // Consumption
    public function consume($data)
    {
        // No need for deserialization
        var_export($data);
    }
}
```

## FAQ

**Why does the error `Workerman\Redis\Exception: Workerman Redis Wait Timeout (600 seconds)` occur?**

This error only occurs with the asynchronous delivery interface `Client::send()`. Asynchronous delivery first saves messages in local memory, then sends them to Redis when the process is idle. If Redis receives messages more slowly than they are produced, or if the process is busy with other tasks and does not have enough time to synchronize messages from memory to Redis, message backlog can occur. If messages are backlogged for more than 600 seconds, this error is triggered.

Solution: Use the synchronous delivery interface `Redis::send()` for message delivery.
