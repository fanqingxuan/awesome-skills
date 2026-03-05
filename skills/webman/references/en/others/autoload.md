# Autoloading

## Loading PSR-0 compliant files via Composer
webman follows the `PSR-4` autoloading specification. If your project needs to load PSR-0 compliant libraries, follow these steps:

- Create an `extend` directory to store PSR-0 compliant libraries
- Edit `composer.json` and add the following under `autoload`:

```json
"psr-0" : {
    "": "extend/"
}
```
The final result should look like this:
![](../../assets/img/psr0.png)

- Run `composer dumpautoload`
- Run `php start.php restart` to restart webman (Note: a full restart is required for changes to take effect)

## Loading specific files via Composer

- Edit `composer.json` and add the files to load under `autoload.files`:
```
"files": [
    "./support/helpers.php",
    "./app/helpers.php"
]
```

- Run `composer dumpautoload`
- Run `php start.php restart` to restart webman (Note: a full restart is required for changes to take effect)

> **Note**
> Files configured in `autoload.files` in composer.json are loaded before webman starts. Files loaded via the framework's `config/autoload.php` are loaded after webman starts.
> Changes to files in composer.json's `autoload.files` require a restart to take effect; reload will not work. Files loaded via the framework's `config/autoload.php` support hot-reload; changes take effect on reload.


## Loading specific files via the framework
Some files may not comply with the PSR specification and cannot be autoloaded. You can load them by configuring `config/autoload.php`, for example:
```php
return [
    'files' => [
        base_path() . '/app/functions.php',
        base_path() . '/support/Request.php', 
        base_path() . '/support/Response.php',
    ]
];
```
 > **Note**
 > `autoload.php` is configured to load `support/Request.php` and `support/Response.php` because the same files exist in `vendor/workerman/webman-framework/src/support/`. By loading them via `autoload.php`, we prioritize the versions in the project root directory, allowing you to customize these files without modifying the ones in `vendor`. If you do not need to customize them, you can omit these two entries.
