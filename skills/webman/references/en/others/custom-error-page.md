# Custom 404

If you want to dynamically control the 404 content, for example, return JSON data `{"code:"404", "msg":"404 not found"}` for AJAX requests and return the `app/view/404.html` template for page requests, please refer to the following example.

> The example below uses PHP native templates. Other templates such as `twig`, `blade`, `think-template` follow the same principle.

**Create the file `app/view/404.html`**
```html
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>404 not found</title>
</head>
<body>
<?=htmlspecialchars($error)?>
</body>
</html>
```

**Add the following code in `config/route.php`:**
```php
use support\Request;
use Webman\Route;

Route::fallback(function(Request $request){
    // Return JSON for AJAX requests
    if ($request->expectsJson()) {
        return json(['code' => 404, 'msg' => '404 not found']);
    }
    // Return the 404.html template for page requests
    return view('404', ['error' => 'some error'])->withStatus(404);
});
```

# Custom 405

Since webman-framework 1.5.23, the fallback callback supports a `status` parameter. A status of 404 means the request does not exist; 405 means the current request method is not supported (e.g., accessing a route defined with `Route::post()` via GET).

```php
use support\Request;
use Webman\Route;

Route::fallback(function(Request $request, $status) {
    $map = [
        404 => '404 not found',
        405 => '405 method not allowed',
    ];
    return response($map[$status], $status);
});
```

# Custom 500

**Create `app/view/500.html`**

```html
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>500 Internal Server Error</title>
</head>
<body>
Custom error template:
<?=htmlspecialchars($exception)?>
</body>
</html>
```

**Create `app/exception/Handler.php`** (create the directory if it does not exist)
```php
<?php

namespace app\exception;

use Throwable;
use Webman\Http\Request;
use Webman\Http\Response;

class Handler extends \support\exception\Handler
{
    /**
     * Render the response
     * @param Request $request
     * @param Throwable $exception
     * @return Response
     */
    public function render(Request $request, Throwable $exception) : Response
    {
        $code = $exception->getCode();
        // Return JSON data for AJAX requests
        if ($request->expectsJson()) {
            return json(['code' => $code ? $code : 500, 'msg' => $exception->getMessage()]);
        }
        // Return the 500.html template for page requests
        return view('500', ['exception' => $exception], '')->withStatus(500);
    }
}
```

**Configure `config/exception.php`**
```php
return [
    '' => \app\exception\Handler::class,
];
```
