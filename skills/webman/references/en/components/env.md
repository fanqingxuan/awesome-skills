# ENV Component vlucas/phpdotenv

## Description
`vlucas/phpdotenv` is an environment variable loading component used to differentiate configurations for different environments (such as development, testing, etc.).

## Project Repository

https://github.com/vlucas/phpdotenv
  
## Installation
 
```php
composer require vlucas/phpdotenv
 ```
  
## Usage

### Create a new `.env` file in the project root
**.env**
```
DB_HOST = 127.0.0.1
DB_PORT = 3306
DB_NAME = test
DB_USER = foo
DB_PASSWORD = 123456
```

### Modify the configuration file
**config/database.php**
```php
return [
    // Default database
    'default' => 'mysql',

    // Various database configurations
    'connections' => [
        'mysql' => [
            'driver'      => 'mysql',
            'host'        => getenv('DB_HOST'),
            'port'        => getenv('DB_PORT'),
            'database'    => getenv('DB_NAME'),
            'username'    => getenv('DB_USER'),
            'password'    => getenv('DB_PASSWORD'),
            'unix_socket' => '',
            'charset'     => 'utf8',
            'collation'   => 'utf8_unicode_ci',
            'prefix'      => '',
            'strict'      => true,
            'engine'      => null,
        ],
    ],
];
```

> **Tip**
> It is recommended to add the `.env` file to your `.gitignore` list to avoid committing it to the code repository. Add a `.env.example` configuration sample file to the repository. When deploying the project, copy `.env.example` as `.env` and modify the configuration in `.env` according to the current environment. This allows the project to load different configurations in different environments.

> **Note**
> `vlucas/phpdotenv` may have bugs in the PHP TS version (Thread Safe). Please use the NTS version (Non-Thread Safe). You can check the current PHP version by executing `php -v`.

## More Information

Visit https://github.com/vlucas/phpdotenv
  
