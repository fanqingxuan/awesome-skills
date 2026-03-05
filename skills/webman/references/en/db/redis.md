# Redis

[webman/redis](https://github.com/webman-php/redis) extends [illuminate/redis](https://github.com/illuminate/redis) with connection pooling, supporting both coroutine and non-coroutine environments. Its usage is the same as Laravel.

You must install the redis extension for `php-cli` before using `illuminate/redis`.

## Installation

```php
composer require -W webman/redis illuminate/events
```

A restart is required after installation (reload is ineffective).

## Configuration

The Redis configuration file is located at `config/redis.php`
```php
return [
    'default' => [
        'host'     => '127.0.0.1',
        'username' => null,
        'password' => null,
        'port'     => 6379,
        'database' => 0,
        'pool' => [ // Connection pool settings
            'max_connections' => 10,     // Maximum connections in the pool
            'min_connections' => 1,      // Minimum connections in the pool
            'wait_timeout' => 3,         // Max wait time when acquiring a connection (seconds)
            'idle_timeout' => 50,        // Idle timeout; connections are closed after this until count reaches min_connections
            'heartbeat_interval' => 50,  // Heartbeat interval (do not exceed 60 seconds)
        ],
    ]
];
```

## Connection pool

* Each process has its own connection pool; pools are not shared across processes.
* When coroutine is disabled, work runs sequentially within a process, so at most one connection is used.
* With coroutine enabled, work runs concurrently, and the pool scales dynamically between `min_connections` and `max_connections`.
* When the number of coroutines using Redis exceeds `max_connections`, coroutines wait in a queue, up to `wait_timeout` seconds; beyond that, an exception is raised.
* When idle (with or without coroutine), connections are released after `idle_timeout` until the count reaches `min_connections` (which may be 0).

## Example

```php
<?php
namespace app\controller;

use support\Request;
use support\Redis;

class UserController
{
    public function db(Request $request)
    {
        $key = 'test_key';
        Redis::set($key, rand());
        return response(Redis::get($key));
    }
}
```

## Redis API

```php
Redis::append($key, $value)
Redis::bitCount($key)
Redis::decr($key, $value)
Redis::decrBy($key, $value)
Redis::get($key)
Redis::getBit($key, $offset)
Redis::getRange($key, $start, $end)
Redis::getSet($key, $value)
Redis::incr($key, $value)
Redis::incrBy($key, $value)
Redis::incrByFloat($key, $value)
Redis::mGet(array $keys)
Redis::getMultiple(array $keys)
Redis::mSet($pairs)
Redis::mSetNx($pairs)
Redis::set($key, $value, $expireResolution = null, $expireTTL = null, $flag = null)
Redis::setBit($key, $offset, $value)
Redis::setEx($key, $ttl, $value)
Redis::pSetEx($key, $ttl, $value)
Redis::setNx($key, $value)
Redis::setRange($key, $offset, $value)
Redis::strLen($key)
Redis::del(...$keys)
Redis::exists(...$keys)
Redis::expire($key, $ttl)
Redis::expireAt($key, $timestamp)
Redis::select($dbIndex)
```

Equivalent to

```php
$redis = Redis::connection('default');
$redis->append($key, $value)
$redis->bitCount($key)
$redis->decr($key, $value)
$redis->decrBy($key, $value)
$redis->get($key)
$redis->getBit($key, $offset)
...
```

> **Note**
> Use the `Redis::select($db)` API with caution. Because webman keeps state in memory, switching databases in one request affects later requests. For multiple databases, configure separate Redis connections for each `$db`.

## Using multiple Redis connections

Example configuration in `config/redis.php`:

```php
return [
    'default' => [
        'host'     => '127.0.0.1',
        'username' => null,
        'password' => null,
        'port'     => 6379,
        'database' => 0,
    ],

    'cache' => [
        'host'     => '127.0.0.1',
        'password' => null,
        'port'     => 6379,
        'database' => 1,
    ],

]
```

By default, the connection under `default` is used. Use `Redis::connection()` to choose which Redis connection to use:

```php
$redis = Redis::connection('cache');
$redis->get('test_key');
```

## Cluster configuration

If your application uses Redis clusters, define them in the Redis configuration with the `clusters` key:

```php
return [
    'clusters' => [
        'default' => [
            [
                'host'     => 'localhost',
                'username' => null,
                'password' => null,
                'port'     => 6379,
                'database' => 0,
            ],
        ],
    ],

];
```

By default, the cluster uses client-side sharding on nodes, allowing node pools and large amounts of memory. Note that client-side sharding does not handle failures, so this is best for cache data fetched from another primary database. For native Redis clustering, specify it under `options` in the configuration:

```php
return[
    'options' => [
        'cluster' => 'redis',
    ],

    'clusters' => [
        // ...
    ],
];
```

## Pipeline commands

When you need to send many commands in one operation, use pipelines. The `pipeline` method accepts a closure. Send all commands to the Redis instance and they will run in a single operation:

```php
Redis::pipeline(function ($pipe) {
    for ($i = 0; $i < 1000; $i++) {
        $pipe->set("key:$i", $i);
    }
});
```
