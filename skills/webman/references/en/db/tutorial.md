# Database Quick Start (Based on Laravel Database Component)

[webman/database](https://github.com/webman-php/database) is built on [illuminate/database](https://github.com/illuminate/database) and adds connection pooling support for both coroutine and non-coroutine environments. The API is the same as Laravel.

You can also refer to the [Using Other Database Components](others.md) section to use ThinkPHP or other databases.

## Database Installation

`composer require -W webman/database illuminate/pagination illuminate/events symfony/var-dumper`

A restart is required after installation (reload will not work).

> **Tip**
> webman/database depends on Laravel's `illuminate/database`, so it will automatically install the dependencies of `illuminate/database`.

> **Note**
> If you do not need pagination, database events, or SQL logging, you only need to run:
> `composer require -W webman/database`

## Database Configuration
`config/database.php`
```php

return [
    // Default database
    'default' => 'mysql',

    // Database connection configurations
    'connections' => [
        'mysql' => [
            'driver'      => 'mysql',
            'host'        => '127.0.0.1',
            'port'        => 3306,
            'database'    => 'test',
            'username'    => 'root',
            'password'    => '',
            'unix_socket' => '',
            'charset'     => 'utf8',
            'collation'   => 'utf8_unicode_ci',
            'prefix'      => '',
            'strict'      => true,
            'engine'      => null,
            'options' => [
                PDO::ATTR_EMULATE_PREPARES => false, // Required when using swoole or swow as runtime
            ],
            'pool' => [ // Connection pool configuration
                'max_connections' => 5, // Maximum number of connections
                'min_connections' => 1, // Minimum number of connections
                'wait_timeout' => 3,    // Maximum time to wait for a connection from the pool; throws an exception on timeout. Only effective in coroutine environment
                'idle_timeout' => 60,   // Maximum idle time for connections in the pool; connections are closed and reclaimed after timeout until count reaches min_connections
                'heartbeat_interval' => 50, // Connection pool heartbeat interval in seconds; recommended to be less than 60
            ],
        ],
    ],
];
```

Except for the `pool` configuration, all other options are the same as Laravel.

## About Connection Pool
* Each process has its own connection pool; pools are not shared between processes.
* When coroutines are disabled, requests are executed sequentially within the process, so there is no concurrency and the pool has at most 1 connection.
* When coroutines are enabled, requests run concurrently within the process. The pool adjusts the number of connections dynamically, never exceeding `max_connections` and never below `min_connections`.
* Because the pool is capped at `max_connections`, when the number of coroutines using the database exceeds this limit, some will wait in queue for up to `wait_timeout` seconds; exceeding that triggers an exception.
* When idle (in both coroutine and non-coroutine environments), connections are reclaimed after `idle_timeout` until the count reaches `min_connections` (`min_connections` can be 0).


## Database Usage Example
```php
<?php
namespace app\controller;

use support\Request;
use support\Db;

class UserController
{
    public function db(Request $request)
    {
        $default_uid = 29;
        $uid = $request->get('uid', $default_uid);
        $name = Db::table('users')->where('uid', $uid)->value('username');
        return response("hello $name");
    }
}
```

As you can see, the usage is the same as Laravel: use the `Db::table()` method to work with the database.
