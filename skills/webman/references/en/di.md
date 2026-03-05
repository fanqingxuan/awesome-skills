# Dependency Auto-Injection

In webman, dependency auto-injection is an optional feature and is disabled by default. If you need dependency auto-injection, it is recommended to use [php-di](https://php-di.org/doc/getting-started.html). The following describes how to use `php-di` with webman.

## Installation

```
composer require php-di/php-di:^7.0
```

Modify the configuration `config/container.php`. The final content should be as follows:

```php
$builder = new \DI\ContainerBuilder();
$builder->addDefinitions(config('dependence', []));
$builder->useAutowiring(true);
$builder->useAttributes(true);
return $builder->build();
```

> The `config/container.php` file must ultimately return a container instance that complies with the `PSR-11` specification. If you do not wish to use `php-di`, you can create and return another PSR-11 compliant container instance here. The default configuration only provides basic webman container functionality.

## Constructor Injection

Create a new file `app/service/Mailer.php` (create the directory if it does not exist) with the following content:

```php
<?php
namespace app\service;

class Mailer
{
    public function mail($email, $content)
    {
        // Send mail code omitted
    }
}
```

The content of `app/controller/UserController.php` is as follows:

```php
<?php
namespace app\controller;

use support\Request;
use app\service\Mailer;

class UserController
{

    public function __construct(private Mailer $mailer)
    {
    }

    public function register(Request $request)
    {
        $this->mailer->mail('hello@webman.com', 'Hello and welcome!');
        return response('ok');
    }
}
```

Normally, the following code would be needed to instantiate `app\controller\UserController`:

```php
$mailer = new Mailer;
$user = new UserController($mailer);
```

When using `php-di`, developers do not need to manually instantiate `Mailer` in the controller — webman will do it automatically. If there are other class dependencies during the instantiation of `Mailer`, webman will also automatically instantiate and inject them. No initialization work is required from the developer.

> **Note**
> Only instances created by the framework or `php-di` support dependency auto-injection. Instances created manually with `new` cannot use dependency auto-injection. If you need injection, use the `support\Container` interface instead of `new`, for example:

```php
use app\service\UserService;
use app\service\LogService;
use support\Container;

// Instances created with new cannot use dependency injection
$user_service = new UserService;
// Instances created with new cannot use dependency injection
$log_service = new LogService($path, $name);

// Instances created with Container can use dependency injection
$user_service = Container::get(UserService::class);
// Instances created with Container can use dependency injection
$log_service = Container::make(LogService::class, [$path, $name]);
```

## Attribute Injection

In addition to constructor dependency auto-injection, you can also use attribute injection. Continuing with the previous example, modify `app\controller\UserController` as follows:

```php
<?php
namespace app\controller;

use support\Request;
use app\service\Mailer;
use DI\Attribute\Inject;

class UserController
{
    #[Inject]
    private Mailer $mailer;

    public function register(Request $request)
    {
        $this->mailer->mail('hello@webman.com', 'Hello and welcome!');
        return response('ok');
    }
}
```

This example uses the `#[Inject]` attribute for injection and automatically injects the instance into the member variable based on the object type. The effect is the same as constructor injection, but the code is more concise.

> **Note**
> Webman does not support controller parameter injection before version 1.4.6. For example, the following code is not supported when webman<=1.4.6:

```php
<?php
namespace app\controller;

use support\Request;
use app\service\Mailer;

class UserController
{
    // Controller parameter injection is not supported before version 1.4.6
    public function register(Request $request, Mailer $mailer)
    {
        $mailer->mail('hello@webman.com', 'Hello and welcome!');
        return response('ok');
    }
}
```

## Custom Constructor Injection

Sometimes the parameters passed to the constructor may not be class instances but strings, numbers, arrays, or other non-object data. For example, the Mailer constructor may need to receive the SMTP server IP and port:

```php
<?php
namespace app\service;

class Mailer
{
    private $smtpHost;

    private $smtpPort;

    public function __construct($smtp_host, $smtp_port)
    {
        $this->smtpHost = $smtp_host;
        $this->smtpPort = $smtp_port;
    }

    public function mail($email, $content)
    {
        // Send mail code omitted
    }
}
```

This case cannot use constructor auto-injection directly, because `php-di` cannot determine the values of `$smtp_host` and `$smtp_port`. In such cases, custom injection can be used.

Add the following code to `config/dependence.php` (create the file if it does not exist):

```php
return [
    // ... Other configurations omitted

    app\service\Mailer::class =>  new app\service\Mailer('192.168.1.11', 25);
];
```

When dependency injection needs to obtain an instance of `app\service\Mailer`, it will automatically use the `app\service\Mailer` instance created in this configuration.

Note that `config/dependence.php` uses `new` to instantiate the `Mailer` class. This is fine for this example, but if the `Mailer` class depends on other classes or uses attribute injection internally, initialization with `new` will not perform dependency auto-injection. The solution is to use custom interface injection and initialize classes via `Container::get(class name)` or `Container::make(class name, [constructor parameters])`.

## Custom Interface Injection

In real projects, it is preferable to program against interfaces rather than concrete classes. For example, `app\controller\UserController` should depend on `app\service\MailerInterface` instead of `app\service\Mailer`.

Define the `MailerInterface` interface:

```php
<?php
namespace app\service;

interface MailerInterface
{
    public function mail($email, $content);
}
```

Define the implementation of `MailerInterface`:

```php
<?php
namespace app\service;

class Mailer implements MailerInterface
{
    private $smtpHost;

    private $smtpPort;

    public function __construct($smtp_host, $smtp_port)
    {
        $this->smtpHost = $smtp_host;
        $this->smtpPort = $smtp_port;
    }

    public function mail($email, $content)
    {
        // Send mail code omitted
    }
}
```

Use `MailerInterface` instead of the concrete implementation:

```php
<?php
namespace app\controller;

use support\Request;
use app\service\MailerInterface;
use DI\Attribute\Inject;

class UserController
{
    #[Inject]
    private MailerInterface $mailer;

    public function register(Request $request)
    {
        $this->mailer->mail('hello@webman.com', 'Hello and welcome!');
        return response('ok');
    }
}
```

Define the implementation of `MailerInterface` in `config/dependence.php`:

```php
use Psr\Container\ContainerInterface;

return [
    app\service\MailerInterface::class => function(ContainerInterface $container) {
        return $container->make(app\service\Mailer::class, ['smtp_host' => '192.168.1.11', 'smtp_port' => 25]);
    }
];
```

When the application needs to use the `MailerInterface` interface, it will automatically use the `Mailer` implementation.

> The benefit of programming against interfaces is that when you need to replace a component, you do not need to change business code — only the concrete implementation in `config/dependence.php`. This is also very useful for unit testing.

## Other Custom Injection

Besides defining class dependencies, `config/dependence.php` can also define other values such as strings, numbers, arrays, etc.

For example, if `config/dependence.php` is defined as follows:

```php
return [
    'smtp_host' => '192.168.1.11',
    'smtp_port' => 25
];
```

You can inject `smtp_host` and `smtp_port` into class properties using `#[Inject]`:

```php
<?php
namespace app\service;

use DI\Attribute\Inject;

class Mailer
{
    #[Inject("smtp_host")]
    private $smtpHost;

    #[Inject("smtp_port")]
    private $smtpPort;

    public function mail($email, $content)
    {
        // Send mail code omitted
        echo "{$this->smtpHost}:{$this->smtpPort}\n"; // Will output 192.168.1.11:25
    }
}
```

# Lazy Loading

> Lazy loading is a design pattern that defers the creation or initialization of objects until they are actually needed.

This feature requires an additional dependency. The following package is a fork of `ocramius/proxy-manager`; the original repository does not support PHP 8.

```
composer require friendsofphp/proxy-manager-lts
```

Usage:

```php
<?php

use DI\Attribute\Injectable;
use DI\Attribute\Inject;

#[Injectable(lazy: true)]
class MyClass
{
    private string $name;

    public function __construct()
    {
        echo "MyClass instantiated\n";
        $this->name = "Lazy Loaded Object";
    }

    public function getName(): string
    {
        return $this->name;
    }
}

class Controller
{
    #[Inject]
    public MyClass $myClass;

    public function getClass()
    {
        echo "Proxy class name: " . get_class($this->myClass) . "\n";
        echo "name: " . $this->myClass->getName();

    }
}
```

Output:

```
Proxy class name: ProxyManagerGeneratedProxy\__PM__\app\web\MyClass\Generated98d2817da63e3c088c808a0d4f6e9ae0
MyClass instantiated
name: Lazy Loaded Object
```

This example shows that when a class declared with the `#[Injectable]` attribute is injected, a proxy class is first created. The actual class is only instantiated when any of its methods are called.

# Circular Dependencies

Circular dependencies occur when multiple classes depend on each other, forming a closed dependency loop.

- Direct circular dependency
  - Module A depends on module B, and module B depends on module A
  - Forms a cycle: A → B → A

- Indirect circular dependency
  - Involves multiple modules in a dependency cycle
  - For example: A → B → C → A

When using attribute injection, `php-di` will automatically detect circular dependencies and throw an exception. If needed, use the following approach instead:

```php
class userController
{

    // Remove this code
    // #[Inject]
    // private UserService userService;

    public function getUserName()
    {
        $userService = Container::get(UserService::class);
        return $userService->getName();
    }
}
```

## More Information

Please refer to the [php-di documentation](https://php-di.org/doc/getting-started.html).
