# webman Session Management

## Example
```php
<?php
namespace app\controller;

use support\Request;

class UserController
{
    public function hello(Request $request)
    {
        $name = $request->get('name');
        $session = $request->session();
        $session->set('name', $name);
        return response('hello ' . $session->get('name'));
    }
}
```

Get the `Workerman\Protocols\Http\Session` instance through `$request->session();` and use its methods to add, modify, or delete session data.

> **Note**
> Session data is automatically saved when the session object is destroyed.
> Storing the session object in a global variable prevents the session from being destroyed, which blocks automatic saving. In such cases, you must manually call `$session->save()` to persist the data.

## Get all session data
```php
$session = $request->session();
$all = $session->all();
```
Returns an array. If there is no session data, it returns an empty array.


## Get a value from the session
```php
$session = $request->session();
$name = $session->get('name');
```
Returns null if the value does not exist.

You can also pass a default value as the second parameter to the `get` method. If the corresponding value is not found in the session array, the default value is returned. For example:
```php
$session = $request->session();
$name = $session->get('name', 'tom');
```


## Store session data
Use the `set` method to store a single piece of data.
```php
$session = $request->session();
$session->set('name', 'tom');
```
The `set` method does not return a value. Session data is automatically saved when the session object is destroyed.

Use the `put` method to store multiple values at once.
```php
$session = $request->session();
$session->put(['name' => 'tom', 'age' => 12]);
```
Similarly, `put` does not return a value.


## Delete session data
Use the `forget` method to delete one or more session values.
```php
$session = $request->session();
// Delete a single item
$session->forget('name');
// Delete multiple items
$session->forget(['name', 'age']);
```

The system also provides a `delete` method. Unlike `forget`, it can only delete one item.
```php
$session = $request->session();
// Equivalent to $session->forget('name');
$session->delete('name');
```


## Get and delete a session value
```php
$session = $request->session();
$name = $session->pull('name');
```
This is equivalent to:
```php
$session = $request->session();
$value = $session->get('name');
$session->delete('name');
```
Returns null if the session value does not exist.


## Delete all session data
```php
$request->session()->flush();
```
Does not return a value. Session data is automatically removed from storage when the session object is destroyed.


## Check if a session value exists
```php
$session = $request->session();
$has = $session->has('name');
```
Returns false if the session value does not exist or is null; otherwise returns true.

```php
$session = $request->session();
$has = $session->exists('name');
```
The above also checks whether a session value exists. The difference is that `exists` returns true even when the session value is null.

## Helper function session()

webman provides the helper function `session()` to achieve the same functionality.
```php
// Get the session instance
$session = session();
// Equivalent to
$session = $request->session();

// Get a value
$value = session('key', 'default');
// Equivalent to
$value = session()->get('key', 'default');
// Equivalent to
$value = $request->session()->get('key', 'default');

// Assign values to the session
session(['key1'=>'value1', 'key2' => 'value2']);
// Equivalent to
session()->put(['key1'=>'value1', 'key2' => 'value2']);
// Equivalent to
$request->session()->put(['key1'=>'value1', 'key2' => 'value2']);

```


## Configuration file
The session configuration file is at `config/session.php`. Its contents look like:
```php
use Webman\Session\FileSessionHandler;
use Webman\Session\RedisSessionHandler;
use Webman\Session\RedisClusterSessionHandler;

return [
    // FileSessionHandler::class or RedisSessionHandler::class or RedisClusterSessionHandler::class 
    'handler' => FileSessionHandler::class,
    
    // When handler is FileSessionHandler::class, value is 'file',
    // When handler is RedisSessionHandler::class, value is 'redis'
    // When handler is RedisClusterSessionHandler::class, value is 'redis_cluster' (Redis cluster)
    'type'    => 'file',

    // Different handlers use different configurations
    'config' => [
        // Configuration when type is 'file'
        'file' => [
            'save_path' => runtime_path() . '/sessions',
        ],
        // Configuration when type is 'redis'
        'redis' => [
            'host'      => '127.0.0.1',
            'port'      => 6379,
            'auth'      => '',
            'timeout'   => 2,
            'database'  => '',
            'prefix'    => 'redis_session_',
        ],
        'redis_cluster' => [
            'host'    => ['127.0.0.1:7000', '127.0.0.1:7001', '127.0.0.1:7001'],
            'timeout' => 2,
            'auth'    => '',
            'prefix'  => 'redis_session_',
        ]
        
    ],

    'session_name' => 'PHPSID', // Cookie name for storing session_id
    'auto_update_timestamp' => false,  // Whether to auto-refresh session, default is off
    'lifetime' => 7*24*60*60,          // Session expiration time
    'cookie_lifetime' => 365*24*60*60, // Cookie expiration time for storing session_id
    'cookie_path' => '/',              // Cookie path for storing session_id
    'domain' => '',                    // Cookie domain for storing session_id
    'http_only' => true,               // Whether to enable httpOnly, default is on
    'secure' => false,                 // Enable session only over HTTPS, default is off
    'same_site' => '',                 // Used to prevent CSRF attacks and user tracking, options: strict/lax/none
    'gc_probability' => [1, 1000],     // Session garbage collection probability
];
```

## Security
When using sessions, it is not recommended to store class instances directly, especially instances of classes from untrusted sources. Deserialization can introduce security risks.

