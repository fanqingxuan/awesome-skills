# Configuration Files

## Location
webman configuration files are located in the `config/` directory. You can use the `config()` function to access the corresponding configurations in your project.

## Accessing Configurations

Get all configurations:
```php
config();
```

Get all configurations in `config/app.php`:
```php
config('app');
```

Get the `debug` configuration in `config/app.php`:
```php
config('app.debug');
```

If the configuration is an array, you can use `.` to access nested values. For example:
```php
config('file.key1.key2');
```

## Default Value
```php
config($key, $default);
```
Pass the default value as the second parameter. If the configuration does not exist, the default value will be returned. If the configuration does not exist and no default is set, `null` is returned.

## Custom Configuration
Developers can add their own configuration files in the `config/` directory. For example:

**config/payment.php**

```php
<?php
return [
    'key' => '...',
    'secret' => '...'
];
```

**Usage when accessing configurations**
```php
config('payment');
config('payment.key');
config('payment.secret');
```

## Modifying Configurations
Webman does not support dynamic configuration changes. All configurations must be modified manually in the corresponding configuration files, then reload or restart the application.

> **Note**
> Server configuration `config/server.php` and process configuration `config/process.php` do not support reload. You must restart for changes to take effect.

## Important Reminder
If you create configuration files in a subdirectory under `config/`, for example `config/order/status.php`, you need an `app.php` file in the `config/order/` directory with the following content:
```php
<?php
return [
    'enable' => true,
];
```
`enable` set to `true` tells the framework to load configurations from this directory.
The configuration directory structure should look like this:
```
├── config
│   ├── order
│   │   ├── app.php
│   │   └── status.php
```
You can then access the array or specific keys from `status.php` via `config.order.status`.


## Configuration File Reference

#### server.php
```php
return [
    'listen' => 'http://0.0.0.0:8787', // Listen port (removed since 1.6.0, configured in config/process.php)
    'transport' => 'tcp', // Transport protocol (removed since 1.6.0, configured in config/process.php)
    'context' => [], // SSL etc. (removed since 1.6.0, configured in config/process.php)
    'name' => 'webman', // Process name (removed since 1.6.0, configured in config/process.php)
    'count' => cpu_count() * 4, // Process count (removed since 1.6.0, configured in config/process.php)
    'user' => '', // User (removed since 1.6.0, configured in config/process.php)
    'group' => '', // Group (removed since 1.6.0, configured in config/process.php)
    'reusePort' => false, // Enable port reuse (removed since 1.6.0, configured in config/process.php)
    'event_loop' => '',  // Event loop class, auto-selected by default
    'stop_timeout' => 2, // Max wait time when receiving stop/restart/reload signal, force exit if process does not exit in time
    'pid_file' => runtime_path() . '/webman.pid', // PID file location
    'status_file' => runtime_path() . '/webman.status', // Status file location
    'stdout_file' => runtime_path() . '/logs/stdout.log', // stdout file location, all output after webman starts is written here
    'log_file' => runtime_path() . '/logs/workerman.log', // Workerman log file location
    'max_package_size' => 10 * 1024 * 1024 // Max packet size, 10M. Upload file size is limited by this
];
```

#### app.php
```php
return [
    'debug' => true,  // Debug mode, enables stack trace etc. on errors. Should be disabled in production
    'error_reporting' => E_ALL, // Error reporting level
    'default_timezone' => 'Asia/Shanghai', // Default timezone
    'public_path' => base_path() . DIRECTORY_SEPARATOR . 'public', // Public directory path
    'runtime_path' => base_path(false) . DIRECTORY_SEPARATOR . 'runtime', // Runtime directory path
    'controller_suffix' => 'Controller', // Controller suffix
    'controller_reuse' => false, // Whether to reuse controllers
];
```

#### process.php
```php
use support\Log;
use support\Request;
use app\process\Http;
global $argv;

return [
     // webman process configuration
    'webman' => [ 
        'handler' => Http::class, // Process handler class
        'listen' => 'http://0.0.0.0:8787', // Listen address
        'count' => cpu_count() * 4, // Process count, 4x CPU by default
        'user' => '', // Process user, should use low-privilege user
        'group' => '', // Process group, should use low-privilege group
        'reusePort' => false, // Enable reusePort, distributes connections across worker processes
        'eventLoop' => '', // Event loop class, uses server.event_loop when empty
        'context' => [], // Listen context, e.g. SSL
        'constructor' => [ // Constructor parameters for process handler, here Http class
            'requestClass' => Request::class, // Custom request class
            'logger' => Log::channel('default'), // Logger instance
            'appPath' => app_path(), // App directory path
            'publicPath' => public_path() // Public directory path
        ]
    ],
    // Monitor process for file change auto-reload and memory leak detection
    'monitor' => [
        'handler' => app\process\Monitor::class, // Handler class
        'reloadable' => false, // This process does not execute reload
        'constructor' => [ // Constructor parameters for process handler
            // Directories to watch, avoid too many as it slows detection
            'monitorDir' => array_merge([
                app_path(),
                config_path(),
                base_path() . '/process',
                base_path() . '/support',
                base_path() . '/resource',
                base_path() . '/.env',
            ], glob(base_path() . '/plugin/*/app'), glob(base_path() . '/plugin/*/config'), glob(base_path() . '/plugin/*/api')),
            // File extensions to watch for changes
            'monitorExtensions' => [
                'php', 'html', 'htm', 'env'
            ],
            // Other options
            'options' => [
                // Enable file monitoring, Linux only, file monitoring is disabled by default in daemon mode
                'enable_file_monitor' => !in_array('-d', $argv) && DIRECTORY_SEPARATOR === '/',
                // Enable memory monitoring, Linux only
                'enable_memory_monitor' => DIRECTORY_SEPARATOR === '/',
            ]
        ]
    ]
];
```

#### container.php
```php
// Return a PSR-11 dependency injection container instance
return new Webman\Container;
```

#### dependence.php
```php
// Configure services and dependencies in the dependency injection container
return [];
```

#### route.php
```php

use support\Route;
// Define route for /test path
Route::any('/test', function (Request $request) {
    return response('test');
});
```

#### view.php
```php
use support\view\Raw;
use support\view\Twig;
use support\view\Blade;
use support\view\ThinkPHP;

return [
    'handler' => Raw::class // Default view handler class
];
```

### autoload.php
```php
// Configure framework autoload files
return [
    'files' => [
        base_path() . '/app/functions.php',
        base_path() . '/support/Request.php',
        base_path() . '/support/Response.php',
    ]
];
```

#### cache.php
```php
// Cache configuration
return [
    'default' => 'file', // Default driver
    'stores' => [
        'file' => [
            'driver' => 'file',
            'path' => runtime_path('cache') // Cache file storage path
        ],
        'redis' => [
            'driver' => 'redis',
            'connection' => 'default' // Redis connection name, refers to config in redis.php
        ],
        'array' => [
            'driver' => 'array' // In-memory cache, cleared on restart
        ]
    ]
];
```

#### redis.php
```php
return [
    'default' => [
        'host' => '127.0.0.1',
        'password' => null,
        'port' => 6379,
        'database' => 0,
    ],
];
```

#### database.php
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
         'database'    => 'webman',
         'username'    => 'webman',
         'password'    => '',
         'unix_socket' => '',
         'charset'     => 'utf8',
         'collation'   => 'utf8_unicode_ci',
         'prefix'      => '',
         'strict'      => true,
         'engine'      => null,
     ],

     'sqlite' => [
         'driver'   => 'sqlite',
         'database' => '',
         'prefix'   => '',
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
     ],
 ],
];
```

#### exception.php
```php
return [
    // Set exception handler class
    '' => support\exception\Handler::class,
];
```

#### log.php
```php
return [
    'default' => [
        'handlers' => [
            [
                'class' => Monolog\Handler\RotatingFileHandler::class, // Handler
                'constructor' => [
                    runtime_path() . '/logs/webman.log', // Log file name
                    7, //$maxFiles // Keep logs for 7 days
                    Monolog\Logger::DEBUG, // Log level
                ],
                'formatter' => [
                    'class' => Monolog\Formatter\LineFormatter::class, // Formatter
                    'constructor' => [null, 'Y-m-d H:i:s', true], // Formatter parameters
                ],
            ]
        ],
    ],
];
```

#### session.php
```php
return [
     // Type
    'type' => 'file', // or redis or redis_cluster
     // Handler
    'handler' => FileSessionHandler::class,
     // Configuration
    'config' => [
        'file' => [
            'save_path' => runtime_path() . '/sessions', // Storage directory
        ],
        'redis' => [
            'host' => '127.0.0.1',
            'port' => 6379,
            'auth' => '',
            'timeout' => 2,
            'database' => '',
            'prefix' => 'redis_session_',
        ],
        'redis_cluster' => [
            'host' => ['127.0.0.1:7000', '127.0.0.1:7001', '127.0.0.1:7001'],
            'timeout' => 2,
            'auth' => '',
            'prefix' => 'redis_session_',
        ]
    ],
    'session_name' => 'PHPSID', // Session name
    'auto_update_timestamp' => false, // Auto-update timestamp to prevent session expiry
    'lifetime' => 7*24*60*60, // Lifetime
    'cookie_lifetime' => 365*24*60*60, // Cookie lifetime
    'cookie_path' => '/', // Cookie path
    'domain' => '', // Cookie domain
    'http_only' => true, // HTTP only
    'secure' => false, // HTTPS only
    'same_site' => '', // SameSite attribute
    'gc_probability' => [1, 1000], // Session garbage collection probability
];
```

#### middleware.php
```php
// Configure middleware
return [];
```

#### static.php
```php
return [
    'enable' => true, // Enable webman static file serving
    'middleware' => [ // Static file middleware, for cache policy, CORS etc.
        //app\middleware\StaticFile::class,
    ],
];
```

#### translation.php
```php
return [
    // Default language
    'locale' => 'zh_CN',
    // Fallback languages
    'fallback_locale' => ['zh_CN', 'en'],
    // Translation file location
    'path' => base_path() . '/resource/translations',
];
```
