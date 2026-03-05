# How to Install webman

* PHP >= 8.1
* [Composer](https://getcomposer.org/) >= 2.0


## Linux: Install PHP + Composer (skip if already configured)
```
curl -sO https://www.workerman.net/install-php-and-composer && sudo bash install-php-and-composer
```
> **Note**
> The command above applies to Linux and macOS. Windows users need to install PHP separately.

You can also manually download the [static PHP build](https://www.workerman.net/download) provided by webman and extract it to use.

## 1. Create Project

```php
composer create-project workerman/webman:~2.0
```

> **Tip**
> If you get errors, you may be using a faulty Composer mirror. Run `composer config -g --unset repos.packagist` to remove the proxy.

## 2. Run

Enter the webman directory

#### Windows Users
Double-click `windows.bat` or run `php windows.php` to start

> **Tip**
> If you encounter errors, functions may be disabled. Refer to [Function Disable Check](others/disable-function-check.md) to re-enable them.

#### Linux Users
**Debug mode** (for development: output appears in the terminal, service stops when the terminal is closed)

```php
php start.php start
```

**Daemon mode** (for production: no terminal output, service keeps running after terminal is closed)

```php
php start.php start -d
```

#### Docker Users

Start all services and attach to the console
```php
docker-compose up
```

Run services in the background
```php
docker-compose up -d
```

> **Tip**
> If you encounter errors, functions may be disabled. Refer to [Function Disable Check](others/disable-function-check.md) to re-enable them.

## 3. Access

Open `http://ip-address:8787` in your browser.
