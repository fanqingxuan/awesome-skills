# Controllers

Create a new controller file `app/controller/FooController.php`.

```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function index(Request $request)
    {
        return response('hello index');
    }
    
    public function hello(Request $request)
    {
        return response('hello webman');
    }
}
```

When accessing `http://127.0.0.1:8787/foo`, the page returns `hello index`.

When accessing `http://127.0.0.1:8787/foo/hello`, the page returns `hello webman`.

Of course, you can change the routing rules through the routing configuration, see [Routing](route.md).

> **Tips:**
> If a 404 error occurs, please open `config/app.php`, set `controller_suffix` to `Controller`, and restart.

## Controller Suffix
Starting from version 1.3, webman supports setting the controller suffix in `config/app.php`. If `controller_suffix` in `config/app.php` is set to empty `''`, the controller will be like this:

`app\controller\Foo.php`.

```php
<?php
namespace app\controller;

use support\Request;

class Foo
{
    public function index(Request $request)
    {
        return response('hello index');
    }
    
    public function hello(Request $request)
    {
        return response('hello webman');
    }
}
```

It is strongly recommended to set the controller suffix to `Controller`, which can avoid conflicts between controller and model class names and improve security at the same time.

## Explanation
- The framework will automatically pass the `support\Request` object to the controller, which can be used to get user input data (get, post, header, cookie, etc.), see [Request](request.md).
- The controller can return numbers, strings, or `support\Response` objects, but cannot return other types of data.
- `support\Response` objects can be created using helper functions such as `response()`, `json()`, `xml()`, `jsonp()`, `redirect()`, etc.

## Controller Parameter Binding

#### Example
Webman supports automatic binding of request parameters to controller method parameters. For example:

```php
<?php
namespace app\controller;
use support\Response;

class UserController
{
    public function create(string $name, int $age): Response
    {
        return json(['name' => $name, 'age' => $age]);
    }
}
```

You can pass the values of `name` and `age` via `GET` or `POST`, or pass them through route parameters. For example:

```php
Route::any('/user/{name}/{age}', [app\controller\UserController::class, 'create']);
```

The priority order is: `route parameters` > `GET` > `POST` parameters.

#### Default Values

Suppose we access `/user/create?name=tom`, we will get the following error:

```html
Missing input parameter age
```

The reason is that we did not pass the `age` parameter. This can be solved by setting a default value for the parameter. For example:

```php
<?php
namespace app\controller;
use support\Response;

class UserController
{
    public function create(string $name, int $age = 18): Response
    {
        return json(['name' => $name, 'age' => $age]);
    }
}
```

#### Parameter Types
When we access `/user/create?name=tom&age=not_int`, we will get the following error:

> **Tips:**
> For convenience in testing, we pass parameters directly in the browser address bar. In actual development, parameters should be passed via `POST`.

```html
Input age must be of type int, string given
```

This is because the received data will be converted according to the type. If conversion fails, a `support\exception\InputTypeException` exception will be thrown. Since the `age` parameter cannot be converted to `int` type, we get the above error.

#### Custom Error Messages
You can customize error messages such as `Missing input parameter age` and `Input age must be of type int, string given` using localization. Refer to the following commands:

```
composer require symfony/translation
mkdir resource/translations/zh_CN/ -p
echo "<?php
return [
    'Input :parameter must be of type :exceptType, :actualType given' => 'Input parameter :parameter must be of type :exceptType, given type is :actualType',
    'Missing input parameter :parameter' => 'Missing input parameter :parameter',
];" > resource/translations/zh_CN/messages.php
php start.php restart
```

#### Other Types
Webman supports parameter types such as `int`, `float`, `string`, `bool`, `array`, `object`, and `class instances`. For example:

```php
<?php
namespace app\controller;
use support\Response;

class UserController
{
    public function create(string $name, int $age, float $balance, bool $vip, array $extension): Response
    {
        return json([
            'name' => $name,
            'age' => $age,
            'balance' => $balance,
            'vip' => $vip,
            'extension' => $extension,
        ]);
    }
}
```

When we access `/user/create?name=tom&age=18&balance=100.5&vip=true&extension[foo]=bar`, we will get the following result:

```json
{
  "name": "tom",
  "age": 18,
  "balance": 100.5,
  "vip": true,
  "extension": {
    "foo": "bar"
  }
}
```

#### Class Instance
Webman supports passing class instances through parameter type hints. For example:

**app\service\Blog.php**
```php
<?php
namespace app\service;
class Blog
{
    private $title;
    private $content;
    public function __construct(string $title, string $content)
    {
        $this->title = $title;
        $this->content = $content;
    }
    public function get()
    {
        return [
            'title' => $this->title,
            'content' => $this->content,
        ];
    }
}
```

**app\controller\BlogController.php**
```php
<?php
namespace app\controller;
use app\service\Blog;
use support\Response;

class BlogController
{
    public function create(Blog $blog): Response
    {
        return json($blog->get());
    }
}
```

When we access `/blog/create?blog[title]=hello&blog[content]=world`, we will get the following result:

```json
{
  "title": "hello",
  "content": "world"
}
```

#### Model Instance

**app\model\User.php**
```php
<?php
namespace app\model;
use support\Model;
class User extends Model
{
    protected $connection = 'mysql';
    protected $table = 'user';
    protected $primaryKey = 'id';
    public $timestamps = false;
    // Add fillable fields here to prevent unsafe fields from being passed from the frontend
    protected $fillable = ['name', 'age'];
}
```

**app\controller\UserController.php**
```php
<?php
namespace app\controller;
use app\model\User;
class UserController
{
    public function create(User $user): int
    {
        $user->save();
        return $user->id;
    }
}
```

When we access `/user/create?user[name]=tom&user[age]=18`, we will get a result similar to:

```json
1
```

## Controller Lifecycle

When `controller_reuse` in `config/app.php` is `false`, each request will initialize the corresponding controller instance once, and the controller instance will be destroyed after the request ends. This is the same as the running mechanism of traditional frameworks.

When `controller_reuse` in `config/app.php` is `true`, all requests will reuse the controller instance. That is, once the controller instance is created, it resides in memory and is reused by all requests.

> **Note:**
> When controller reuse is enabled, requests should not change any properties of the controller because these changes will affect subsequent requests. For example:

```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    protected $model;
    
    public function update(Request $request, $id)
    {
        $model = $this->getModel($id);
        $model->update();
        return response('ok');
    }
    
    public function delete(Request $request, $id)
    {
        $model = $this->getModel($id);
        $model->delete();
        return response('ok');
    }
    
    protected function getModel($id)
    {
        // This method will retain the model after the first request update?id=1
        // If another request delete?id=2 is made, the data of 1 will be deleted
        if (!$this->model) {
            $this->model = Model::find($id);
        }
        return $this->model;
    }
}
```

> **Tips:**
> Returning data in the controller's `__construct()` constructor will have no effect. For example:

```php
<?php
namespace app\controller;

use support\Request;

class FooController
{
    public function __construct()
    {
        // Returning data in the constructor has no effect; the browser will not receive this response
        return response('hello'); 
    }
}
```

## Difference Between Controller Non-Reuse and Reuse
The differences are as follows:

#### Non-Reuse Controller
A new controller instance will be created for each request, and the instance will be released and memory reclaimed after the request is finished. Non-reuse controllers are similar to traditional frameworks and conform to the habits of most developers. Due to the repeated creation and destruction of controllers, the performance will be slightly worse than that of reuse controllers (about 10% worse in helloworld benchmark, which can be largely ignored with real business logic).

#### Reuse Controller
If the controller is reused, a controller is only created once per process, and the instance is not released after the request is finished. Subsequent requests in the current process will reuse this instance. Reuse controllers have better performance but do not conform to the habits of most developers.

#### The following cases cannot use controller reuse

When a request will change the properties of the controller, controller reuse should not be enabled, because these property changes will affect subsequent requests.

Some developers like to do some initialization for each request in the controller's constructor `__construct()`. In this case, controller reuse cannot be used, because the constructor of the current process will only be called once, not for each request.
