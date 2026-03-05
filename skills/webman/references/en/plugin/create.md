# Basic Plugin Generation and Publishing Process

## Principle
1. Taking the cross-domain plugin as an example, a plugin consists of three parts: the cross-domain middleware program file, the middleware configuration file `middleware.php`, and an `Install.php` generated automatically by command.
2. We use commands to package and publish these three files to Composer.
3. When users install the cross-domain plugin via Composer, the plugin's `Install.php` copies the cross-domain middleware program file and configuration file to `{main project}/config/plugin` for webman to load, enabling automatic configuration of the cross-domain middleware.
4. When users remove the plugin via Composer, `Install.php` removes the corresponding cross-domain middleware program file and configuration file, implementing automatic plugin uninstallation.

## Specifications
1. A plugin name consists of two parts: `vendor` and `plugin name`, e.g. `webman/push`, corresponding to the Composer package name.
2. Plugin configuration files are placed under `config/plugin/vendor/plugin name/` (the console command creates the config directory automatically). If a plugin needs no configuration, the auto-created config directory must be removed.
3. The plugin config directory only supports: `app.php` (main config), `bootstrap.php` (process bootstrap), `route.php` (routes), `middleware.php` (middleware), `process.php` (custom process), `database.php` (database), `redis.php` (redis), `thinkorm.php` (thinkorm). These are automatically recognized by webman.
4. Plugins access config with: `config('plugin.vendor.plugin name.config file.specific item');`, e.g. `config('plugin.webman.push.app.app_key')`.
5. For plugins with their own database config: `illuminate/database` uses `Db::connection('plugin.vendor.plugin name.specific connection')`, `thinkorm` uses `Db::connect('plugin.vendor.plugin name.specific connection')`.
6. If a plugin places business files under `app/`, it must avoid conflicts with the main project and other plugins.
7. Plugins should avoid copying files or directories into the main project where possible. For example, for the cross-domain plugin, only the config is copied; middleware files should stay under `vendor/webman/cros/src` instead of being copied.
8. Plugin namespaces should use PascalCase, e.g. `Webman/Console`.

## Example

**Install the `webman/console` command-line tool**

`composer require webman/console`

### Create a Plugin

Assume the plugin to create is named `foo/admin` (this is also the Composer project name and must be lowercase). Run:

`php webman plugin:create --name=foo/admin`

This creates `vendor/foo/admin` for plugin files and `config/plugin/foo/admin` for plugin config.

> Note
> `config/plugin/foo/admin` supports: `app.php`, `bootstrap.php`, `route.php`, `middleware.php`, `process.php`, `database.php`, `redis.php`, `thinkorm.php`. Format is the same as webman, and these are merged automatically.
> Use the `plugin` prefix to access, e.g. `config('plugin.foo.admin.app')`.


### Export Plugin

After development is complete, run:

`php webman plugin:export --name=foo/admin`

Export

> Note
> Export copies `config/plugin/foo/admin` to `vendor/foo/admin/src` and generates `Install.php`, which runs on install/uninstall.
> Default install: copy config from `vendor/foo/admin/src` to the project's `config/plugin`.
> Default uninstall: delete the plugin’s config files under the project’s `config/plugin`.
> You can modify `Install.php` to add custom install/uninstall logic.

### Submit Plugin
* Assume you already have [GitHub](https://github.com) and [Packagist](https://packagist.org) accounts.
* Create an `admin` repository on [GitHub](https://github.com) and push your code, e.g. `https://github.com/your-username/admin`.
* Go to `https://github.com/your-username/admin/releases/new` and create a release, e.g. `v1.0.0`.
* On [Packagist](https://packagist.org), click `Submit`, submit `https://github.com/your-username/admin`, and the plugin is published.

> **Tip**
> If Packagist reports a name conflict, use a different vendor name, e.g. change `foo/admin` to `myfoo/admin`.

When you update the plugin, push to GitHub, create a new release at `https://github.com/your-username/admin/releases/new`, then click `Update` on `https://packagist.org/packages/foo/admin` to refresh the version.

## Add Commands to a Plugin
Sometimes a plugin needs custom commands. For example, after installing `webman/redis-queue`, the project gains a `redis-queue:consumer` command. Users run `php webman redis-queue:consumer send-mail` to generate a `SendMail.php` consumer class, which speeds up development.

To add a `foo-admin:add` command to the `foo/admin` plugin, follow these steps.

### Create a Command

**Create `vendor/foo/admin/src/FooAdminAddCommand.php`**

```php
<?php

namespace Foo\Admin;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Input\InputArgument;

class FooAdminAddCommand extends Command
{
    protected static $defaultName = 'foo-admin:add';
    protected static $defaultDescription = 'Command description';

    /**
     * @return void
     */
    protected function configure()
    {
        $this->addArgument('name', InputArgument::REQUIRED, 'Add name');
    }

    /**
     * @param InputInterface $input
     * @param OutputInterface $output
     * @return int
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $name = $input->getArgument('name');
        $output->writeln("Admin add $name");
        return self::SUCCESS;
    }

}
```

> **Note**
> To avoid command conflicts between plugins, use the format `vendor-plugin:command`, e.g. all commands for `foo/admin` should be prefixed with `foo-admin:`, e.g. `foo-admin:add`.

### Add Configuration
**Create `config/plugin/foo/admin/command.php`**

```php
<?php

use Foo\Admin\FooAdminAddCommand;

return [
    FooAdminAddCommand::class,
    // Add more commands as needed...
];
```

> **Tip**
> `command.php` registers custom commands for the plugin. Each entry in the array is a command class. When users run the console, `webman/console` loads these commands. See [Console Commands](console.md) for more.

### Execute Export
Run `php webman plugin:export --name=foo/admin` to export and publish to Packagist. After installing `foo/admin`, users get the `foo-admin:add` command. Running `php webman foo-admin:add jerry` prints `Admin add jerry`.
