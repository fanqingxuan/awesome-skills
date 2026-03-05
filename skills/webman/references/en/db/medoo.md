# Medoo Database

[webman/medoo](https://github.com/webman-php/medoo) extends [Medoo](https://medoo.in/) with connection pool support and works in both coroutine and non-coroutine environments. Usage is the same as Medoo.

## Installation
`composer require webman/medoo`

## Medoo Database Configuration
Configuration file location: `config/plugin/webman/medoo/database.php`

## Medoo Database Usage
```php
<?php
namespace app\controller;

use support\Request;
use support\Medoo;

class Index
{
    public function index(Request $request)
    {
        $user = Medoo::get('user', '*', ['uid' => 1]);
        return json($user);
    }
}
```

> **Tip**
> `Medoo::get('user', '*', ['uid' => 1]);`
> is equivalent to
> `Medoo::instance('default')->get('user', '*', ['uid' => 1]);`

## Medoo Multiple Database Configuration

**Configuration**
Add a new configuration in `config/plugin/webman/medoo/database.php` with any key; here we use `other`.

```php
<?php
return [
    'default' => [
        'type' => 'mysql',
        'host' => 'localhost',
        'database' => 'database',
        'username' => 'username',
        'password' => 'password',
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_general_ci',
        'port' => 3306,
        'prefix' => '',
        'logging' => false,
        'error' => PDO::ERRMODE_EXCEPTION,
        'option' => [
            PDO::ATTR_CASE => PDO::CASE_NATURAL
        ],
        'command' => [
            'SET SQL_MODE=ANSI_QUOTES'
        ],
        'pool' => [ // Connection pool configuration
            'max_connections' => 5, // Maximum number of connections
            'min_connections' => 1, // Minimum number of connections
            'wait_timeout' => 60,   // Maximum time to wait when acquiring a connection from the pool; throws exception on timeout
            'idle_timeout' => 3,    // Maximum idle time for connections in the pool; idle connections beyond this are closed and reclaimed until count reaches min_connections
            'heartbeat_interval' => 50, // Connection pool heartbeat interval in seconds; recommended to be less than 60 seconds
        ]
    ],
    // Add new configuration 'other' here
    'other' => [
        'type' => 'mysql',
        'host' => 'localhost',
        'database' => 'database',
        'username' => 'username',
        'password' => 'password',
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_general_ci',
        'port' => 3306,
        'prefix' => '',
        'logging' => false,
        'error' => PDO::ERRMODE_EXCEPTION,
        'option' => [
            PDO::ATTR_CASE => PDO::CASE_NATURAL
        ],
        'command' => [
            'SET SQL_MODE=ANSI_QUOTES'
        ],
        'pool' => [
            'max_connections' => 5,
            'min_connections' => 1,
            'wait_timeout' => 60,
            'idle_timeout' => 3,
            'heartbeat_interval' => 50,
        ],
    ],
];
```

## Medoo Database Usage
```php
$user = Medoo::instance('other')->get('user', '*', ['uid' => 1]);
```

See [Medoo official documentation](https://medoo.in/api/select)
