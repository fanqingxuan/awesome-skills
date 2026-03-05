# Phar Packaging

Phar is a kind of packaging file in PHP similar to JAR. You can use Phar to package your webman project into a single Phar file for easy deployment.

**Very grateful to [fuzqing](https://github.com/fuzqing) for the PR.**

> **Note**
> You need to disable the `phar` configuration option in `php.ini`, by setting `phar.readonly = 0`.

## Install Command Line Tool
`composer require webman/console`

## Packaging
Execute the command `php webman build:phar` in the root directory of the webman project. This will generate a `webman.phar` file in the `build` directory.

> Packaging related configurations are in `config/plugin/webman/console/app.php`.

## Start and Stop Commands
**Start**
`php webman.phar start` or `php webman.phar start -d`

**Stop**
`php webman.phar stop`

**Check Status**
`php webman.phar status`

**Check Connection Status**
`php webman.phar connections`

**Restart**
`php webman.phar restart` or `php webman.phar restart -d`

## Notes
* Packaged projects do not support reload; you need to restart to update the code.

* To avoid excessive package size and memory usage, you can set the `exclude_pattern` and `exclude_files` options in `config/plugin/webman/console/app.php` to exclude unnecessary files.

* Running webman.phar will generate a `runtime` directory in the same directory as webman.phar, used for storing temporary files such as logs.

* If your project uses an `.env` file, you need to place the `.env` file in the same directory as webman.phar.

* Never store user-uploaded files inside the Phar package, as operating on user-uploaded files via the `phar://` protocol is very dangerous (Phar deserialization vulnerability). User-uploaded files must be stored separately on disk outside the Phar package. See below.

* If your business needs to upload files to the `public` directory, you need to separate the `public` directory and place it in the same directory as webman.phar. In this case, you need to configure `config/app.php`.
```
'public_path' => base_path(false) . DIRECTORY_SEPARATOR . 'public',
```
The business can use the helper function `public_path($relative_path)` to find the actual location of the public directory.

* webman.phar does not support custom processes on Windows.
