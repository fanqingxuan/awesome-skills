# Multilingual

Multilingual support uses the [symfony/translation](https://github.com/symfony/translation) component.

## Installation
```
composer require symfony/translation
```

## Creating Language Packs
webman stores language packs in the `resource/translations` directory by default (create it if it does not exist). To change this directory, configure it in `config/translation.php`.
Each language corresponds to a subfolder, and language definitions are stored in `messages.php` by default. Example structure:
```
resource/
└── translations
    ├── en
    │   └── messages.php
    └── zh_CN
        └── messages.php
```

All language files return an array, for example:
```php
// resource/translations/en/messages.php

return [
    'hello' => 'Hello webman',
];
```

## Configuration

`config/translation.php`

```php
return [
    // Default locale
    'locale' => 'zh_CN',
    // Fallback locale: when a translation cannot be found in the current language, translations from fallback locales will be attempted
    'fallback_locale' => ['zh_CN', 'en'],
    // Directory where language files are stored
    'path' => base_path() . '/resource/translations',
];
```

## Translation

Use the `trans()` method for translation.

Create language file `resource/translations/zh_CN/messages.php` as follows:
```php
return [
    'hello' => '你好 世界!',
];
```

Create file `app/controller/UserController.php`
```php
<?php
namespace app\controller;

use support\Request;

class UserController
{
    public function get(Request $request)
    {
        $hello = trans('hello'); // 你好 世界!
        return response($hello);
    }
}
```

Visiting `http://127.0.0.1:8787/user/get` will return "你好 世界!"

## Changing Default Language

Use the `locale()` method to switch languages.

Add language file `resource/translations/en/messages.php` as follows:
```php
return [
    'hello' => 'hello world!',
];
```

```php
<?php
namespace app\controller;

use support\Request;

class UserController
{
    public function get(Request $request)
    {
        // Switch language
        locale('en');
        $hello = trans('hello'); // hello world!
        return response($hello);
    }
}
```
Visiting `http://127.0.0.1:8787/user/get` will return "hello world!"

You can also use the 4th parameter of the `trans()` function to temporarily switch the language. For example, the above example is equivalent to:
```php
<?php
namespace app\controller;

use support\Request;

class UserController
{
    public function get(Request $request)
    {
        // 4th parameter switches language
        $hello = trans('hello', [], null, 'en'); // hello world!
        return response($hello);
    }
}
```

## Setting Language Explicitly for Each Request
translation is a singleton, meaning all requests share the same instance. If a request sets the default language using `locale()`, it will affect all subsequent requests in that process. Therefore, we should set the language explicitly for each request. For example, use the following middleware:

Create file `app/middleware/Lang.php` (create the directory if it does not exist) as follows:
```php
<?php
namespace app\middleware;

use Webman\MiddlewareInterface;
use Webman\Http\Response;
use Webman\Http\Request;

class Lang implements MiddlewareInterface
{
    public function process(Request $request, callable $handler) : Response
    {
        locale(session('lang', 'zh_CN'));
        return $handler($request);
    }
}
```

Add the global middleware in `config/middleware.php` as follows:
```php
return [
    // Global middleware
    '' => [
        // ... other middleware omitted
        app\middleware\Lang::class,
    ]
];
```


## Using Placeholders
Sometimes a message contains variables that need to be translated, for example
```php
trans('hello ' . $name);
```
In such cases, use placeholders to handle it.

Update `resource/translations/zh_CN/messages.php` as follows:
```php
return [
    'hello' => '你好 %name%!',
];
```
When translating, pass the placeholder values through the second parameter:
```php
trans('hello', ['%name%' => 'webman']); // 你好 webman!
```

## Handling Plurals
In some languages, sentence structure differs based on quantity. For example, `There is %count% apple` is correct when `%count%` is 1, but incorrect when it is greater than 1.

In such cases, use the **pipe** (`|`) to list plural forms.

Add `apple_count` to language file `resource/translations/en/messages.php` as follows:
```php
return [
    // ...
    'apple_count' => 'There is one apple|There are %count% apples',
];
```

```php
trans('apple_count', ['%count%' => 10]); // There are 10 apples
```

We can even specify numeric ranges to create more complex plural rules:
```php
return [
    // ...
    'apple_count' => '{0} There are no apples|{1} There is one apple|]1,19] There are %count% apples|[20,Inf[ There are many apples'
];
```

```php
trans('apple_count', ['%count%' => 20]); // There are many apples
```

## Specifying Language File

The default language file name is `messages.php`, but you can create language files with other names.

Create language file `resource/translations/zh_CN/admin.php` as follows:
```php
return [
    'hello_admin' => '你好 管理员!',
];
```

Specify the language file using the 3rd parameter of `trans()` (omit the `.php` extension).
```php
trans('hello', [], 'admin', 'zh_CN'); // 你好 管理员!
```

## More Information
See [symfony/translation documentation](https://symfony.com/doc/current/translation.html)
