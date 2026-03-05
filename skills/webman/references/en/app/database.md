# Database

Since most plugins install [webman-admin](https://www.workerman.net/plugin/82), it is recommended to reuse the `webman-admin` database configuration directly.

Models inheriting from the base class `plugin\admin\app\model\Base` will automatically use the webman-admin database configuration.
```php
<?php

namespace plugin\foo\app\model;

use plugin\admin\app\model\Base;

class Orders extends Base
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'foo_orders';

    /**
     * The primary key associated with the table.
     *
     * @var string
     */
    protected $primaryKey = 'id';
    
}
```

You can also access the webman-admin database via `plugin.admin.mysql`, for example:

```php
Db::connection('plugin.admin.mysql')->table('user')->first();
```


## Using Your Own Database

Plugins can also choose to use their own database. For example, `plugin/foo/config/database.php`:

```php
return  [
    'default' => 'mysql',
    'connections' => [
        'mysql' => [ // mysql is the connection name
            'driver'      => 'mysql',
            'host'        => '127.0.0.1',
            'port'        => 3306,
            'database'    => 'database',
            'username'    => 'username',
            'password'    => 'password',
            'charset'     => 'utf8mb4',
            'collation'   => 'utf8mb4_general_ci',
        ],
        'admin' => [ // admin is the connection name
            'driver'      => 'mysql',
            'host'        => '127.0.0.1',
            'port'        => 3306,
            'database'    => 'database',
            'username'    => 'username',
            'password'    => 'password',
            'charset'     => 'utf8mb4',
            'collation'   => 'utf8mb4_general_ci',
        ],
    ],
];
```

The reference format is `Db::connection('plugin.{plugin}.{connection_name}');`, for example:

```php
use support\Db;
Db::connection('plugin.foo.mysql')->table('user')->first();
Db::connection('plugin.foo.admin')->table('admin')->first();
```

To use the main project's database, simply call it directly:

```php
use support\Db;
Db::table('user')->first();
// Assuming the main project also has an admin connection configured
Db::connection('admin')->table('admin')->first();
```

#### Configuring the Database for the Model

You can create a Base class for the Model and set the `$connection` property to use the plugin's own database connection:

```php
<?php

namespace plugin\foo\app\model;

use DateTimeInterface;
use support\Model;

class Base extends Model
{
    /**
     * @var string
     */
    protected $connection = 'plugin.foo.mysql';

}
```

All models in the plugin that inherit from Base will then automatically use the plugin's own database.

## Automatic Database Import

Running `php webman app-plugin:create foo` creates the foo plugin, including `plugin/foo/api/Install.php` and `plugin/foo/install.sql`.

> **Tip**
> If the install.sql file is not generated, try upgrading `webman/console` with: `composer require webman/console ^1.3.6`

#### Importing the Database When Installing a Plugin

When a plugin is installed, the `install` method in Install.php runs and automatically executes the SQL statements in `install.sql`, thereby importing the database tables.

The content of `install.sql` should include table creation and any historical schema changes. Each statement must end with `;`, for example:

```sql
CREATE TABLE `foo_orders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `order_id` varchar(50) NOT NULL COMMENT 'Order ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `total_amount` decimal(10,2) NOT NULL COMMENT 'Amount to pay',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='Orders';

CREATE TABLE `foo_goods` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `name` varchar(50) NOT NULL COMMENT 'Name',
  `price` int NOT NULL COMMENT 'Price',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='Goods';
```

**Changing the Database Connection**

By default, `install.sql` is imported into the webman-admin database. To import into a different database, modify the `$connection` property in `Install.php`:

```php
<?php

class Install
{
    // Specify the plugin's own database
    protected static $connection = 'plugin.admin.mysql';
    
    // ...
}
```

**Testing**

Run `php webman app-plugin:install foo` to install the plugin. After that, check the database to confirm that the `foo_orders` and `foo_goods` tables have been created.

#### Changing Table Structure During Plugin Upgrade

When a plugin upgrade requires new tables or schema changes, append the corresponding SQL statements to the end of `install.sql`. Each statement must end with `;`. For example, adding a `foo_user` table and a `status` column to `foo_orders`:

```sql
CREATE TABLE `foo_orders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `order_id` varchar(50) NOT NULL COMMENT 'Order ID',
  `user_id` int NOT NULL COMMENT 'User ID',
  `total_amount` decimal(10,2) NOT NULL COMMENT 'Amount to pay',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='Orders';

CREATE TABLE `foo_goods` (
 `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
 `name` varchar(50) NOT NULL COMMENT 'Name',
 `price` int NOT NULL COMMENT 'Price',
 PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='Goods';


CREATE TABLE `foo_user` (
 `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
 `name` varchar(50) NOT NULL COMMENT 'Name'
 PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='User';

ALTER TABLE `foo_orders` ADD `status` tinyint NOT NULL DEFAULT 0 COMMENT 'Status';
```

During upgrade, the `update` method in Install.php runs and executes the statements in `install.sql`. New statements are executed; previously applied statements are skipped, so the database changes are applied correctly during upgrades.

#### Deleting Database on Plugin Uninstall

When a plugin is uninstalled, the `uninstall` method in Install.php is called. It automatically parses `install.sql` for CREATE TABLE statements and drops those tables, removing the database tables when the plugin is uninstalled.

If you prefer to run only your own `uninstall.sql` instead of the automatic table deletion, create `plugin/{plugin_name}/uninstall.sql`. In that case, the `uninstall` method will execute only the statements in `uninstall.sql`.
