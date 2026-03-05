# Cache

[webman/cache](https://github.com/webman-php/cache) is a cache component based on [symfony/cache](https://github.com/symfony/cache), compatible with both coroutine and non-coroutine environments, with connection pool support.

## Installation

```php
composer require -W webman/cache
```

## Example
```php
<?php
namespace app\controller;

use support\Request;
use support\Cache;

class UserController
{
    public function db(Request $request)
    {
        $key = 'test_key';
        Cache::set($key, rand());
        return response(Cache::get($key));
    }
}
```

## Configuration File Location
The configuration file is at `config/cache.php`. Create it manually if it does not exist.

## Configuration File Content
```php
<?php
return [
    'default' => 'file',
    'stores' => [
        'file' => [
            'driver' => 'file',
            'path' => runtime_path('cache')
        ],
        'redis' => [
            'driver' => 'redis',
            'connection' => 'default'
        ],
        'array' => [
            'driver' => 'array'
        ],
        'apcu' => [
            'driver' => 'apcu'
        ]
    ]
];
```
`stores.driver` supports four drivers: **file**, **redis**, **array**, and **apcu**.

#### file driver
The default driver. No external dependencies. Supports cache sharing across processes. Does not support sharing across multiple servers.

#### array driver
In-memory storage with the best performance, but consumes memory. Does not support sharing across processes or servers. Data is lost on process restart. Typically used for projects with small cache volumes.

#### apcu driver
In-memory storage. Performance is second only to array. Supports cache sharing across processes. Does not support sharing across multiple servers. Data is lost on process restart. Typically used for projects with small cache volumes.

> Requires the [APCu extension](https://pecl.php.net/package/APCu) to be installed and enabled. Not recommended for scenarios with frequent cache writes/deletes, as it may cause significant performance degradation.

#### redis driver
Depends on the [webman/redis](./redis.md) component. Supports cache sharing across processes and servers.

**stores.redis.connection**

`stores.redis.connection` corresponds to the key defined in `config/redis.php`. When using Redis, it reuses the `webman/redis` configuration, including connection pool settings.

**It is recommended to add a dedicated Redis configuration in `config/redis.php` for cache, for example:**

```php
<?php
return [
    'default' => [
        'password' => 'abc123',
        'host' => '127.0.0.1',
        'port' => 6379,
        'database' => 0,
    ],
    'cache' => [ // <==== Add new
        'password' => 'abc123',
        'host' => '127.0.0.1',
        'port' => 6379,
        'database' => 1,
        'prefix' => 'webman_cache-',
    ]
];
```

Then set `stores.redis.connection` to `cache`. The final `config/cache.php` should look like:

```php
<?php
return [
    'default' => 'redis', // <====
    'stores' => [
        'file' => [
            'driver' => 'file',
            'path' => runtime_path('cache')
        ],
        'redis' => [
            'driver' => 'redis',
            'connection' => 'cache' // <====
        ],
        'array' => [
            'driver' => 'array'
        ]
    ]
];
```

## Switching Stores
You can manually switch stores to use different drivers, for example:

```php
Cache::store('redis')->set('key', 'value');
Cache::store('array')->set('key', 'value');
```

> **Tip**
> Cache key names are restricted by [PSR-6](https://www.php-fig.org/psr/psr-6/#definitions) and must not contain any of `{}()/\@:`. As of `symfony/cache` 7.2.4, this check can be bypassed by setting PHP ini option `zend.assertions=-1`.

## Using Other Cache Components

See [Other Databases](others.md#ThinkCache) for the [ThinkCache](https://github.com/webman-php/think-cache) component.
