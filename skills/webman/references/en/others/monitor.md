# Process Monitoring
webman comes with a built-in monitor process that supports two functions:
1. Monitors file updates and automatically reloads new business code (generally used during development)
2. Monitors memory usage of all processes; if a process is about to exceed the `memory_limit` set in `php.ini`, it automatically and safely restarts that process (without affecting the business)

## Monitoring Configuration
Configuration for `monitor` in `config/process.php`:
```php

global $argv;

return [
    // File update detection and automatic reload
    'monitor' => [
        'handler' => process\Monitor::class,
        'reloadable' => false,
        'constructor' => [
            // Monitor these directories
            'monitorDir' => array_merge([    // Which directories' files need to be monitored
                app_path(),
                config_path(),
                base_path() . '/process',
                base_path() . '/support',
                base_path() . '/resource',
                base_path() . '/.env',
            ], glob(base_path() . '/plugin/*/app'), glob(base_path() . '/plugin/*/config'), glob(base_path() . '/plugin/*/api')),
            // Files with these suffixes will be monitored
            'monitorExtensions' => [
                'php', 'html', 'htm', 'env'
            ],
            'options' => [
                'enable_file_monitor' => !in_array('-d', $argv) && DIRECTORY_SEPARATOR === '/', // Whether to enable file monitoring
                'enable_memory_monitor' => DIRECTORY_SEPARATOR === '/',                      // Whether to enable memory monitoring
            ]
        ]
    ]
];
```
`monitorDir` configures which directories to monitor for updates (the number of files in monitored directories should not be too large).
`monitorExtensions` configures which file suffixes in the `monitorDir` directories should be monitored.
When `options.enable_file_monitor` is `true`, file update monitoring is enabled (on Linux, file monitoring is enabled by default when running in debug mode).
When `options.enable_memory_monitor` is `true`, memory usage monitoring is enabled (memory monitoring is not supported on Windows).

> **Tip**
> On Windows, file update monitoring is only enabled when running `windows.bat` or `php windows.php`.
