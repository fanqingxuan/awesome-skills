# Event Handling
`webman/event` provides an elegant event mechanism that allows you to execute business logic without modifying the code, achieving decoupling between business modules. A typical scenario: when a new user is successfully registered, simply publish a custom event such as `user.register`, and each module can receive the event and execute the corresponding business logic.

## Installation
`composer require webman/event`

## Subscribing to Events
Event subscriptions are configured through the `config/event.php` file.

```php
<?php
return [
    'user.register' => [
        [app\event\User::class, 'register'],
        // ...other event handling functions...
    ],
    'user.logout' => [
        [app\event\User::class, 'logout'],
        // ...other event handling functions...
    ]
];
```

**Note:**
- `user.register`, `user.logout`, etc. are event names (string type). It is recommended to use lowercase words separated by dots (`.`).
- One event can have multiple event handling functions; they are invoked in the order specified in the configuration.

## Event Handling Functions
Event handling functions can be any class methods, functions, or closure functions.

For example, create the event handling class `app/event/User.php` (create the directory if it does not exist).

```php
<?php
namespace app\event;
class User
{
    function register($user)
    {
        var_export($user);
    }
 
    function logout($user)
    {
        var_export($user);
    }
}
```

## Publishing Events
Use `Event::dispatch($event_name, $data);` or `Event::emit($event_name, $data);` to publish an event. For example:

```php
<?php
namespace app\controller;
use support\Request;
use Webman\Event\Event;
class User
{
    public function register(Request $request)
    {
        $user = [
            'name' => 'webman',
            'age' => 2
        ];
        Event::dispatch('user.register', $user);
    }
}
```

There are two functions for publishing events: `Event::dispatch($event_name, $data);` and `Event::emit($event_name, $data);` — both take the same parameters.  
The difference is that `emit` catches exceptions internally: if one handler throws an exception, other handlers will still run.  
`dispatch` does not catch exceptions; if any handler throws, execution stops and the exception is propagated upward.

> **Tip**
> The `$data` parameter can be any data, such as an array, a class instance, or a string.

## Wildcard Event Listening
Wildcard registration allows you to handle multiple events with the same listener. For example, in `config/event.php`:

```php
<?php
return [
    'user.*' => [
        [app\event\User::class, 'deal']
    ],
];
```

You can obtain the concrete event name via the second parameter `$event_data` of the event handling function.

```php
<?php
namespace app\event;
class User
{
    function deal($user, $event_name)
    {
        echo $event_name; // concrete event name, e.g. user.register, user.logout, etc.
        var_export($user);
    }
}
```

## Stopping Event Broadcasting
When an event handling function returns `false`, broadcasting for that event will stop.

## Closure Functions for Event Handling
Event handling functions can be class methods or closure functions. For example:

```php
<?php
return [
    'user.login' => [
        function($user){
            var_dump($user);
        }
    ]
];
```

## Viewing Events and Listeners
Use the command `php webman event:list` to view all events and listeners configured in the project.

## Support Scope
Along with the main project, both [base plugins](../plugin/base.md) and [app plugins](../app/app.md) support `event.php` configuration.
**Base plugin config file:** `config/plugin/vendor/plugin-name/event.php`
**App plugin config file:** `plugin/plugin-name/config/event.php`

## Notes
Event handling is not asynchronous. Events are not suitable for slow operations; slow business logic should be handled with message queues, such as [webman/redis-queue](https://www.workerman.net/plugin/12).
