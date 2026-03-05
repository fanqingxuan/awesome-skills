# Coroutine

webman is built on Workerman, so webman can use Workerman's coroutine features.
Coroutines support three drivers: `Swoole`, `Swow`, and `Fiber`.

## Prerequisites

- PHP >= 8.1
- Workerman >= 5.1.0 (`composer require workerman/workerman ~v5.1`)
- webman-framework >= 2.1 (`composer require workerman/webman-framework ~v2.1`)
- Swoole or Swow extension installed, or `composer require revolt/event-loop` (for Fiber)
- Coroutines are disabled by default and must be enabled via the `eventLoop` setting

## How to Enable

webman supports different coroutine drivers per process. You can configure the coroutine driver in `config/process.php` (including plugin process.php configuration) via the `eventLoop` option:

```php
return [
    'webman' => [
        'handler' => Http::class,
        'listen' => 'http://0.0.0.0:8787',
        'count' => 1,
        'user' => '',
        'group' => '',
        'reusePort' => false,
        'eventLoop' => '', // Empty by default, auto-selects Select or Event, coroutines disabled
        'context' => [],
        'constructor' => [
            'requestClass' => Request::class,
            'logger' => Log::channel('default'),
            'appPath' => app_path(),
            'publicPath' => public_path()
        ]
    ],
    'my-coroutine' => [
        'handler' => Http::class,
        'listen' => 'http://0.0.0.0:8686',
        'count' => 1,
        'user' => '',
        'group' => '',
        'reusePort' => false,
        // To enable coroutines, set to Workerman\Events\Swoole::class, Workerman\Events\Swow::class, or Workerman\Events\Fiber::class
        'eventLoop' => Workerman\Events\Swoole::class,
        'context' => [],
        'constructor' => [
            'requestClass' => Request::class,
            'logger' => Log::channel('default'),
            'appPath' => app_path(),
            'publicPath' => public_path()
        ]
    ]
    
    // ... other config omitted ...
];
```

> **Tip**
> webman allows different `eventLoop` settings per process, so you can enable coroutines only for specific processes.
> For example, in the config above, the service on port 8787 has coroutines disabled, while the service on port 8686 has them enabled. Together with nginx routing, you can deploy a mix of coroutine and non-coroutine services.

## Coroutine Example

```php
<?php
namespace app\controller;

use support\Response;
use Workerman\Coroutine;
use Workerman\Timer;

class IndexController
{
    public function index(): Response
    {
        Coroutine::create(function(){
            Timer::sleep(1.5);
            echo "hello coroutine\n";
        });
        return response('hello webman');
    }

}
```

When `eventLoop` is `Swoole`, `Swow`, or `Fiber`, webman creates a coroutine for each request. You can spawn additional coroutines within request handlers to run business logic.

## Coroutine Limitations

* With Swoole or Swow as the driver, when a coroutine hits blocking I/O, it will switch automatically, so synchronous code runs asynchronously.
* With the Fiber driver, blocking I/O does not trigger coroutine switching; the process blocks instead.
* When using coroutines, avoid multiple coroutines operating on the same resource (e.g., DB connection, file handle) without protection, which can cause resource contention. Use connection pools or locks to protect shared resources.
* When using coroutines, do not store request-related state in global or static variables, as this can pollute global state. Use coroutine context (`context`) to store and retrieve such data instead.

## Other Notes

Swow hooks PHP blocking functions at a low level. This changes some default PHP behavior, so if Swow is installed but not used, it may cause bugs.

**Recommendations:**
* If your project does not use Swow, do not install the Swow extension.
* If your project uses Swow, set `eventLoop` to `Workerman\Events\Swow::class`.

## Coroutine Context

In a coroutine environment, do not store **request-related** state in global or static variables, as this can lead to global pollution. For example:

```php
<?php

namespace app\controller;

use support\Request;
use Workerman\Timer;

class TestController
{
    protected static $name = '';

    public function index(Request $request)
    {
        static::$name = $request->get('name');
        Timer::sleep(5);
        return static::$name;
    }
}
```

> **Note**
> Coroutines do not forbid global or static variables entirely—only using them for **request-related state**. Global config, database connections, singletons, and similar shared objects are fine to store in globals or statics.

With the process count set to 1, if we issue two requests in succession:
http://127.0.0.1:8787/test?name=lilei
http://127.0.0.1:8787/test?name=hanmeimei

We expect the responses to be `lilei` and `hanmeimei`, but both return `hanmeimei`. The second request overwrites the static `$name`, and when the first request wakes up, it returns the updated value.

**The correct approach is to store request state in context:**

```php
<?php

namespace app\controller;

use support\Request;
use support\Context;
use Workerman\Timer;

class TestController
{
    public function index(Request $request)
    {
        Context::set('name', $request->get('name'));
        Timer::sleep(5);
        return Context::get('name');
    }
}
```

The `support\Context` class stores coroutine context data. When a coroutine finishes, its context data is removed automatically.
With coroutines enabled, each request runs in its own coroutine, so context is cleared when the request completes.
Without coroutines, context is cleared when the request ends.

**Local variables are safe from data pollution**

```php
<?php

namespace app\controller;

use support\Request;
use support\Context;
use Workerman\Timer;

class TestController
{
    public function index(Request $request)
    {
        $name = $request->get('name');
        Timer::sleep(5);
        return $name;
    }
}
```

Because `$name` is a local variable, coroutines cannot access each other’s local variables, so local variables are coroutine-safe.

## Locker

When some component or business logic was not designed with coroutines in mind, resource contention or atomicity issues may arise. In such cases, use `Workerman\Locker` to serialize access and avoid concurrency problems:

```php
<?php

namespace app\controller;

use Redis;
use support\Response;
use Workerman\Coroutine\Locker;

class IndexController
{
    public function index(): Response
    {
        static $redis;
        if (!$redis) {
            $redis = new Redis();
            $redis->connect('127.0.0.1', 6379);
        }
        // Without locking, Swoole may throw errors like "Socket#10 has already been bound to another coroutine#10"
        // Swow may trigger a coredump
        // Fiber works fine since the Redis extension uses blocking I/O
        Locker::lock('redis');
        $time = $redis->time();
        Locker::unlock('redis');
        return json($time);
    }

}
```

## Parallel Execution

When you need to run multiple tasks concurrently and collect their results, use `Workerman\Parallel`:

```php
<?php

namespace app\controller;

use support\Response;
use Workerman\Coroutine\Parallel;

class IndexController
{
    public function index(): Response
    {
        $parallel = new Parallel();
        for ($i=1; $i<5; $i++) {
            $parallel->add(function () use ($i) {
                // Do something
                return $i;
            });
        }
        $results = $parallel->wait();
        return json($results); // Response: [1,2,3,4]
    }

}
```

## Pool (Connection Pool)

Multiple coroutines sharing the same connection can corrupt data, so use a connection pool for database, Redis, and similar connections.

webman already provides [webman/database](../db/tutorial.md), [webman/redis](../db/redis.md), [webman/cache](../db/cache.md), [webman/think-orm](../db/thinkorm.md), and [webman/think-cache](../db/thinkcache.md). They all include connection pools and work in both coroutine and non-coroutine environments.

To adapt a component without a pool, use `Workerman\Pool`. Example:

**Database component**

```php
<?php
namespace app;

use Workerman\Coroutine\Context;
use Workerman\Coroutine;
use Workerman\Coroutine\Pool;

class Db
{
    private static ?Pool $pool = null;

    public static function __callStatic($name, $arguments)
    {
        if (self::$pool === null) {
            self::initializePool();
        }
        // Get connection from coroutine context so the same coroutine reuses the same connection
        $pdo = Context::get('pdo');
        if (!$pdo) {
            $pdo = self::$pool->get();
            Context::set('pdo', $pdo);
            Coroutine::defer(function () use ($pdo) {
                self::$pool->put($pdo);
            });
        }
        return call_user_func_array([$pdo, $name], $arguments);
    }

    private static function initializePool(): void
    {
        self::$pool = new Pool(10);
        self::$pool->setConnectionCreator(function () {
            return new \PDO('mysql:host=127.0.0.1;dbname=your_database', 'your_username', 'your_password');
        });
        self::$pool->setConnectionCloser(function ($pdo) {
            $pdo = null;
        });
        self::$pool->setHeartbeatChecker(function ($pdo) {
            $pdo->query('SELECT 1');
        });
    }

}
```

**Usage**

```php
<?php
namespace app\controller;

use support\Response;
use app\Db;

class IndexController
{
    public function index(): Response
    {
        $value = Db::query('SELECT NOW() as now')->fetchAll();
        return json($value); // [{"now":"2025-02-06 23:41:03","0":"2025-02-06 23:41:03"}]
    }

}
```

## More on Coroutines and Related Components

See the [Workerman coroutine documentation](https://www.workerman.net/doc/workerman/coroutine/coroutine.html).

## Mixed Coroutine and Non-Coroutine Deployment

webman supports running coroutine and non-coroutine services together. For example, use non-coroutine for general traffic and coroutines for slow I/O. Route traffic with nginx to different upstreams.

Example `config/process.php`:

```php
return [
    'webman' => [
        'handler' => Http::class,
        'listen' => 'http://0.0.0.0:8787',
        'count' => 1,
        'user' => '',
        'group' => '',
        'reusePort' => false,
        'eventLoop' => '', // Empty by default, coroutines disabled
        'context' => [],
        'constructor' => [
            'requestClass' => Request::class,
            'logger' => Log::channel('default'),
            'appPath' => app_path(),
            'publicPath' => public_path()
        ]
    ],
    'my-coroutine' => [
        'handler' => Http::class,
        'listen' => 'http://0.0.0.0:8686',
        'count' => 1,
        'user' => '',
        'group' => '',
        'reusePort' => false,
        'eventLoop' => Workerman\Events\Swoole::class,
        'context' => [],
        'constructor' => [
            'requestClass' => Request::class,
            'logger' => Log::channel('default'),
            'appPath' => app_path(),
            'publicPath' => public_path()
        ]
    ],
    
    // ... other config omitted ...
];
```

Then route nginx traffic to the appropriate backend:

```nginx
upstream webman {
    server 127.0.0.1:8787;
    keepalive 10240;
}

upstream task {
   server 127.0.0.1:8686;
   keepalive 10240;
}

server {
  server_name webman.com;
  listen 80;
  access_log off;
  root /path/webman/public;

  # Requests starting with /tast go to port 8686; change /tast to your desired prefix
  location /tast {
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header Host $host;
      proxy_http_version 1.1;
      proxy_set_header Connection "";
      proxy_pass http://task;
  }

  # Other requests go to port 8787
  location / {
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header Host $host;
      proxy_http_version 1.1;
      proxy_set_header Connection "";
      if (!-f $request_filename){
          proxy_pass http://webman;
      }
  }
}
```
