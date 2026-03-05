# Route Configuration File
The route configuration file for plugins is located at `plugin/plugin_name/config/route.php`.

## Default Route
Application plugin URL paths all start with `/app`. For example, the URL for `plugin\foo\app\controller\UserController` is `http://127.0.0.1:8787/app/foo/user`.

## Disable Default Route
To disable the default route for an application plugin, add the following to your route configuration:
```php
Route::disableDefaultRoute('foo');
```

## Handle 404 Callback
To set a fallback for an application plugin, pass the plugin name as the second parameter. For example:
```php
Route::fallback(function(){
    return redirect('/');
}, 'foo');
```
