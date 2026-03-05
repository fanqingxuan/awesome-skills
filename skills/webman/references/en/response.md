# Response
The response is actually a `support\Response` object. To facilitate the creation of this object, webman provides some helper functions.

## Return any response

**Example**
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return response('hello webman');
    }
}
```

The implementation of the `response` function is as follows:
```php
function response($body = '', $status = 200, $headers = array())
{
    return new Response($status, $headers, $body);
}
```

You can also create an empty `response` object first and then use `$response->cookie()`, `$response->header()`, `$response->withHeaders()`, `$response->withBody()` to set the return content at the appropriate location.
```php
public function hello(Request $request)
{
    // Create an object
    $response = response();
    
    // .... Business logic omitted
    
    // Set cookie
    $response->cookie('foo', 'value');
    
    // .... Business logic omitted
    
    // Set http headers
    $response->header('Content-Type', 'application/json');
    $response->withHeaders([
                'X-Header-One' => 'Header Value 1',
                'X-Header-Tow' => 'Header Value 2',
            ]);

    // .... Business logic omitted

    // Set the data to be returned
    $response->withBody('Returned data');
    return $response;
}
```

## Return JSON
**Example**
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return json(['code' => 0, 'msg' => 'ok']);
    }
}
```
The `json` function is implemented as follows:
```php
function json($data, $options = JSON_UNESCAPED_UNICODE)
{
    return new Response(200, ['Content-Type' => 'application/json'], json_encode($data, $options));
}
```

## Return XML
**Example**
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        $xml = <<<XML
               <?xml version='1.0' standalone='yes'?>
               <values>
                   <truevalue>1</truevalue>
                   <falsevalue>0</falsevalue>
               </values>
               XML;
        return xml($xml);
    }
}
```
The `xml` function is implemented as follows:
```php
function xml($xml)
{
    if ($xml instanceof SimpleXMLElement) {
        $xml = $xml->asXML();
    }
    return new Response(200, ['Content-Type' => 'text/xml'], $xml);
}
```

## Return view
Create a new file `app/controller/FooController.php` as follows:
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return view('foo/hello', ['name' => 'webman']);
    }
}
```
Create a new file `app/view/foo/hello.html` as follows:
```html
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>webman</title>
</head>
<body>
hello <?=htmlspecialchars($name)?>
</body>
</html>
```

## Redirect
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return redirect('/user');
    }
}
```
The implementation of the `redirect` function is as follows:
```php
function redirect($location, $status = 302, $headers = [])
{
    $response = new Response($status, ['Location' => $location]);
    if (!empty($headers)) {
        $response->withHeaders($headers);
    }
    return $response;
}
```

## Header settings
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return response('hello webman', 200, [
            'Content-Type' => 'application/json',
            'X-Header-One' => 'Header Value' 
        ]);
    }
}
```
You can also use the `header` and `withHeaders` methods to set headers individually or in batches.
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return response('hello webman')
        ->header('Content-Type', 'application/json')
        ->withHeaders([
            'X-Header-One' => 'Header Value 1',
            'X-Header-Tow' => 'Header Value 2',
        ]);
    }
}
```
You can also set headers in advance and finally set the data to be returned.
```php
public function hello(Request $request)
{
    // Create an object
    $response = response();
    
    // .... Business logic omitted
  
    // Set http headers
    $response->header('Content-Type', 'application/json');
    $response->withHeaders([
                'X-Header-One' => 'Header Value 1',
                'X-Header-Tow' => 'Header Value 2',
            ]);

    // .... Business logic omitted

    // Set the data to be returned
    $response->withBody('Returned data');
    return $response;
}
```

## Set cookie
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return response('hello webman')
        ->cookie('foo', 'value');
    }
}
```
You can also set cookies in advance and finally set the data to be returned.
```php
public function hello(Request $request)
{
    // Create an object
    $response = response();
    
    // .... Business logic omitted
    
    // Set cookie
    $response->cookie('foo', 'value');
    
    // .... Business logic omitted

    // Set the data to be returned
    $response->withBody('Returned data');
    return $response;
}
```
The complete parameter list for the `cookie` method is as follows:
`cookie($name, $value = '', $max_age = 0, $path = '', $domain = '', $secure = false, $http_only = false)`

## Return file stream
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return response()->file(public_path() . '/favicon.ico');
    }
}
```
- webman supports sending very large files
- For large files (over 2M), webman will not read the entire file into memory at once, but will read and send the file in segments at the appropriate time
- webman optimizes file reading and sending speed based on the client's receiving speed to ensure the fastest file transmission while minimizing memory usage
- Data transmission is non-blocking and does not affect the processing of other requests
- The `file` method will automatically add the `if-modified-since` header and will check the `if-modified-since` header in the next request. If the file has not been modified, it will return 304 directly to save bandwidth
- The file being sent will automatically be sent to the browser using the appropriate `Content-Type` header
- If the file does not exist, it will automatically be converted to a 404 response

## Download file
```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function hello(Request $request)
    {
        return response()->download(public_path() . '/favicon.ico', 'filename.ico');
    }
}
```
The `download` method is basically the same as the `file` method, with the difference being that:
1. After setting the file name for download, the file will be downloaded instead of being displayed in the browser
2. The `download` method does not check the `if-modified-since` header
## Getting Output
Some libraries directly print the file content to the standard output, which means the data will be printed in the command line terminal and not sent to the browser. In this case, we need to capture the data into a variable using `ob_start();` and `ob_get_clean();`, and then send the data to the browser. For example:

```php
<?php

namespace app\controller;

use support\Request;

class ImageController
{
    public function get(Request $request)
    {
        // Create an image
        $im = imagecreatetruecolor(120, 20);
        $text_color = imagecolorallocate($im, 233, 14, 91);
        imagestring($im, 1, 5, 5,  'A Simple Text String', $text_color);

        // Start capturing the output
        ob_start();
        // Output the image
        imagejpeg($im);
        // Get the image content
        $image = ob_get_clean();
        
        // Send the image
        return response($image)->header('Content-Type', 'image/jpeg');
    }
}
```

## Chunked Response

Sometimes we want to send responses in chunks. You can refer to the following example.

```php
<?php

namespace app\controller;

use support\Request;
use support\Response;
use Workerman\Protocols\Http\Chunk;
use Workerman\Timer;

class IndexController
{
    public function index(Request $request): Response
    {
        // Get connection
        $connection = $request->connection;
        // Send HTTP body periodically
        $timer = Timer::add(1, function () use ($connection, &$timer) {
            static $i = 0;
            if ($i++ < 10) {
                // Send HTTP body
                $connection->send(new Chunk($i));
            } else {
                // Remove unused timer to prevent memory leaks from accumulating timers
                Timer::del($timer);
                // Output empty Chunk to notify client that response is complete
                $connection->send(new Chunk(''));
            }
        });
        // First output an HTTP header with Transfer-Encoding: chunked, then send HTTP body asynchronously
        return response()->withHeaders([
            "Transfer-Encoding" => "chunked",
        ]);
    }

}
```

If you are calling a large language model, refer to the following example.

```
composer require webman/openai
```

```php
<?php
namespace app\controller;
use support\Request;

use Webman\Openai\Chat;
use Workerman\Protocols\Http\Chunk;

class ChatController
{
    public function completions(Request $request)
    {
        $connection = $request->connection;
        // If https://api.openai.com is not accessible in your region, you can use https://api.openai-proxy.com instead
        $chat = new Chat(['apikey' => 'sk-xx', 'api' => 'https://api.openai.com']);
        $chat->completions(
            [
                'model' => 'gpt-3.5-turbo',
                'stream' => true,
                'messages' => [['role' => 'user', 'content' => 'hello']],
            ], [
            'stream' => function($data) use ($connection) {
                // Forward data to browser when OpenAI API returns
                $connection->send(new Chunk(json_encode($data, JSON_UNESCAPED_UNICODE) . "\n"));
            },
            'complete' => function($result, $response) use ($connection) {
                // Check for errors when response completes
                if (isset($result['error'])) {
                    $connection->send(new Chunk(json_encode($result, JSON_UNESCAPED_UNICODE) . "\n"));
                }
                // Return empty chunk to indicate response end
                $connection->send(new Chunk(''));
            },
        ]);
        // Return HTTP header first, data will be returned asynchronously
        return response()->withHeaders([
            "Transfer-Encoding" => "chunked",
        ]);
    }
}
```
