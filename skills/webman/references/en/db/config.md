# Database Configuration (Laravel Style)
webman/database supports the following databases and versions:

- MySQL 5.6+
- PostgreSQL 9.4+
- SQLite 3.8.8+
- SQL Server 2017+

The database configuration file is located at `config/database.php`.

```php
return [
    // Default database
    'default' => 'mysql',
    // Various database configurations
    'connections' => [

        'mysql' => [
            'driver'      => 'mysql',
            'host'        => '127.0.0.1',
            'port'        => 3306,
            'database'    => 'webman',
            'username'    => 'webman',
            'password'    => '',
            'unix_socket' => '',
            'charset'     => 'utf8',
            'collation'   => 'utf8_unicode_ci',
            'prefix'      => '',
            'strict'      => true,
            'engine'      => null,
            'pool' => [ // Connection pool config, only supported with swoole/swow drivers
                'max_connections' => 5, // Max connections
                'min_connections' => 1, // Min connections
                'wait_timeout' => 3,    // Max wait time to get a connection from pool, throws exception on timeout
                'idle_timeout' => 60,   // Max idle time for connections in pool, reclaims on timeout until count reaches min_connections
                'heartbeat_interval' => 50, // Heartbeat interval in seconds, recommended less than 60
            ],
         ],
         
         'sqlite' => [
             'driver'   => 'sqlite',
             'database' => '',
             'prefix'   => '',
             'pool' => [ // Connection pool config, only supported with swoole/swow drivers
                'max_connections' => 5, // Max connections
                'min_connections' => 1, // Min connections
                'wait_timeout' => 3,    // Max wait time to get a connection from pool, throws exception on timeout
                'idle_timeout' => 60,   // Max idle time for connections in pool, reclaims on timeout until count reaches min_connections
                'heartbeat_interval' => 50, // Heartbeat interval in seconds, recommended less than 60
            ],
         ],

         'pgsql' => [
             'driver'   => 'pgsql',
             'host'     => '127.0.0.1',
             'port'     => 5432,
             'database' => 'webman',
             'username' => 'webman',
             'password' => '',
             'charset'  => 'utf8',
             'prefix'   => '',
             'schema'   => 'public',
             'sslmode'  => 'prefer',
             'pool' => [ // Connection pool config, only supported with swoole/swow drivers
                'max_connections' => 5, // Max connections
                'min_connections' => 1, // Min connections
                'wait_timeout' => 3,    // Max wait time to get a connection from pool, throws exception on timeout
                'idle_timeout' => 60,   // Max idle time for connections in pool, reclaims on timeout until count reaches min_connections
                'heartbeat_interval' => 50, // Heartbeat interval in seconds, recommended less than 60
            ],
         ],

         'sqlsrv' => [
             'driver'   => 'sqlsrv',
             'host'     => 'localhost',
             'port'     => 1433,
             'database' => 'webman',
             'username' => 'webman',
             'password' => '',
             'charset'  => 'utf8',
             'prefix'   => '',
             'pool' => [ // Connection pool config, only supported with swoole/swow drivers
                'max_connections' => 5, // Max connections
                'min_connections' => 1, // Min connections
                'wait_timeout' => 3,    // Max wait time to get a connection from pool, throws exception on timeout
                'idle_timeout' => 60,   // Max idle time for connections in pool, reclaims on timeout until count reaches min_connections
                'heartbeat_interval' => 50, // Heartbeat interval in seconds, recommended less than 60
            ],
         ],
     ],
 ];
```

## Using Multiple Databases
Use `Db::connection('config_name')` to select which database to use, where `config_name` is the corresponding `key` in the configuration file `config/database.php`.

For example, with the following database configuration:

```php
 return [
     // Default database
     'default' => 'mysql',
     // Various database configurations
     'connections' => [

         'mysql' => [
             'driver'      => 'mysql',
             'host'        =>   '127.0.0.1',
             'port'        => 3306,
             'database'    => 'webman',
             'username'    => 'webman',
             'password'    => '',
             'unix_socket' =>  '',
             'charset'     => 'utf8',
             'collation'   => 'utf8_unicode_ci',
             'prefix'      => '',
             'strict'      => true,
             'engine'      => null,
         ],
         
         'mysql2' => [
              'driver'      => 'mysql',
              'host'        => '127.0.0.1',
              'port'        => 3306,
              'database'    => 'webman2',
              'username'    => 'webman2',
              'password'    => '',
              'unix_socket' => '',
              'charset'     => 'utf8',
              'collation'   => 'utf8_unicode_ci',
              'prefix'      => '',
              'strict'      => true,
              'engine'      => null,
         ],
         'pgsql' => [
              'driver'   => 'pgsql',
              'host'     => '127.0.0.1',
              'port'     =>  5432,
              'database' => 'webman',
              'username' =>  'webman',
              'password' => '',
              'charset'  => 'utf8',
              'prefix'   => '',
              'schema'   => 'public',
              'sslmode'  => 'prefer',
          ],
 ];
```

Switch databases like this:
```php
// Use default database, equivalent to Db::connection('mysql')->table('users')->where('name', 'John')->first();
$users = Db::table('users')->where('name', 'John')->first(); 
// Use mysql2
$users = Db::connection('mysql2')->table('users')->where('name', 'John')->first();
// Use pgsql
$users = Db::connection('pgsql')->table('users')->where('name', 'John')->first();
```
