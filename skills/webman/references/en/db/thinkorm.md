# think-orm

[webman/think-orm](https://github.com/webman-php/think-orm) is a database component based on [top-think/think-orm](https://github.com/top-think/think-orm). It supports connection pooling and works in both coroutine and non-coroutine environments.

## Installation

`composer require -W webman/think-orm`

A restart is required after installation (reload does not take effect).

## Configuration

Modify the configuration file `config/think-orm.php` according to your actual needs.

## Documentation

https://www.kancloud.cn/manual/think-orm

## Usage

```php
<?php
namespace app\controller;

use support\Request;
use support\think\Db;

class FooController
{
    public function get(Request $request)
    {
        $user = Db::table('user')->where('uid', '>', 1)->find();
        return json($user);
    }
}
```

## Creating Models

Think-orm models extend `support\think\Model`, as shown below:

```php
<?php
namespace app\model;

use support\think\Model;

class User extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'user';

    /**
     * The primary key associated with the table.
     *
     * @var string
     */
    protected $pk = 'id';

}
```

You can also create think-orm models using the following command:

```
php webman make:model table_name
```

> **Tip**
> This command requires `webman/console`. Install it with `composer require webman/console ^1.2.13`.

> **Note**
> If `make:model` detects that the main project uses `illuminate/database`, it will create Illuminate-based model files instead of think-orm. In that case, add the `tp` parameter to force think-orm model generation: `php webman make:model table_name tp` (upgrade `webman/console` if it does not work).
