# MongoDB

webman uses [mongodb/laravel-mongodb](https://github.com/mongodb/laravel-mongodb) as the default MongoDB component. It is extracted from the Laravel project and works the same way as Laravel.

You must install the MongoDB extension for `php-cli` before using `mongodb/laravel-mongodb`.

> **Note**
> Use the command `php -m | grep mongodb` to check if the MongoDB extension is installed for `php-cli`. Note: Even if you have installed the MongoDB extension for `php-fpm`, it does not mean you can use it in `php-cli`, because `php-cli` and `php-fpm` are different applications and may use different `php.ini` configurations. Use the command `php --ini` to see which `php.ini` configuration file your `php-cli` is using.

## Installation

```php
composer require -W webman/database mongodb/laravel-mongodb ^4.8
```

A restart is required after installation (reload is not sufficient).

## Configuration
Add the `mongodb` connection in `config/database.php`, similar to the following:
```php
return [

    'default' => 'mysql',

    'connections' => [

         ...other configurations omitted here...

        'mongodb' => [
            'driver'   => 'mongodb',
            'host'     => '127.0.0.1',
            'port'     =>  27017,
            'database' => 'test',
            'username' => null,
            'password' => null,
            'options' => [
                // here you can pass more settings to the Mongo Driver Manager
                // see https://www.php.net/manual/en/mongodb-driver-manager.construct.php under "Uri Options" for a list of complete parameters that you can use

                'appname' => 'homestead'
            ],
        ],
    ],
];
```

## Example
```php
<?php
namespace app\controller;

use support\Request;
use support\Db;

class UserController
{
    public function db(Request $request)
    {
        Db::connection('mongodb')->table('test')->insert([1,2,3]);
        return json(Db::connection('mongodb')->table('test')->get());
    }
}
```

## Model Example
```php
<?php
namespace app\model;

use DateTimeInterface;
use support\MongoModel as Model;

class Test extends Model
{
    protected $connection = 'mongodb';

    protected $table = 'test';

    public $timestamps = true;

    /**
     * @param DateTimeInterface $date
     * @return string
     */
    protected function serializeDate(DateTimeInterface $date): string
    {
        return $date->format('Y-m-d H:i:s');
    }
}
```

## For more information, please visit

https://github.com/mongodb/laravel-mongodb
