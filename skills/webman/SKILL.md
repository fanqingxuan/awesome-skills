---
name: webman
description: "Webman framework development assistant. Use when the user needs to: (1) Create Webman controllers, (2) Create Webman models, (3) Configure routes, (4) Create middleware, (5) Implement services, (6) Handle validation, or any other Webman development tasks. Triggers on phrases like \"创建 Webman 控制器\", \"生成模型\", \"配置路由\", \"Webman 开发\"."
---

# Webman 开发指南

Webman 高性能 PHP 框架开发助手，专注于控制器、模型、路由、中间件的快速开发。

## 常用命令

```bash
# 启动服务
php start.php start

# 调试模式启动（前台运行）
php start.php start -d

# 守护进程模式启动
php start.php start -d

# 停止服务
php start.php stop

# 重启服务
php start.php restart

# 平滑重启（不中断服务）
php start.php reload

# 平滑停止
php start.php stop -g

# 查看状态
php start.php status

# 查看连接状态
php start.php connections

# 创建控制器
php webman make:controller UserController

# 创建模型
php webman make:model User

# 创建中间件
php webman make:middleware AuthMiddleware

# 数据库迁移
php webman migrate

# 清除缓存
php webman cache:clear
```

## 快速示例

### 控制器

```php
<?php
namespace app\controller;

use support\Request;

class UserController
{
    public function index(Request $request)
    {
        return json(['code' => 0, 'data' => []]);
    }

    public function show(Request $request, $id)
    {
        return json(['code' => 0, 'data' => ['id' => $id]]);
    }
}
```

### 服务类

```php
<?php
namespace app\service;

use app\model\User;

class UserService
{
    public function create(array $data): User
    {
        return User::create($data);
    }

    public function update(int $id, array $data): bool
    {
        $user = User::find($id);
        return $user ? $user->update($data) : false;
    }

    public function delete(int $id): bool
    {
        $user = User::find($id);
        return $user ? $user->delete() : false;
    }
}
```

### 验证器

```php
<?php
namespace app\validate;

class UserValidate
{
    protected $rule = [
        'name'  => 'require|max:25',
        'email' => 'require|email',
    ];

    protected $message = [
        'name.require' => '名称必须',
        'email.require' => '邮箱必须',
        'email.email' => '邮箱格式错误',
    ];
}
```

## 目录结构

```
app/
├── controller/     # 控制器
├── model/         # 模型
├── middleware/    # 中间件
├── service/       # 服务层
├── validate/      # 验证器
└── view/          # 视图
config/
├── app.php        # 应用配置
├── database.php   # 数据库配置
├── route.php      # 路由配置
└── middleware.php # 中间件配置
```

## 内存泄漏注意事项

Webman 是常驻内存框架，需要注意避免内存泄漏。以下是需要避免的做法：

### 避免使用无限膨胀的 static 数组

```php
// ❌ 错误示例 - 会导致内存泄漏
class Foo
{
    public static $data = [];
    public function index(Request $request)
    {
        self::$data[] = time(); // 数组无限增长
        return response('hello');
    }
}

// ✅ 正确做法 - 使用局部变量
class Foo
{
    public function index(Request $request)
    {
        $data = []; // 请求结束后自动回收
        $data[] = time();
        return response('hello');
    }
}
```

### 避免单例中的无限膨胀数组

```php
// ❌ 错误示例 - 单例中的数组无限增长
class Cache
{
    protected static $instance;
    public $data = [];

    public static function instance()
    {
        if (!self::$instance) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    public function set($key, $value)
    {
        $this->data[$key] = $value; // key 无限增长会泄漏
    }
}

// ✅ 正确做法 - 限制数组大小或使用 Redis
class Cache
{
    protected static $instance;
    public $data = [];
    private $maxSize = 1000;

    public function set($key, $value)
    {
        if (count($this->data) >= $this->maxSize) {
            array_shift($this->data); // 移除最旧的元素
        }
        $this->data[$key] = $value;
    }
}
```

### 避免使用 global 关键字的数组

```php
// ❌ 错误示例
class Index
{
    public function index(Request $request)
    {
        global $data;
        $data[] = time(); // 全局数组无限增长
        return response('hello');
    }
}

// ✅ 正确做法 - 使用依赖注入或容器
class Index
{
    public function index(Request $request)
    {
        $data = $request->get('data', []);
        return response('hello');
    }
}
```

### 内存泄漏规避建议

1. **尽量不使用** `global`、`static` 关键字的数组，如果使用确保其不会无限膨胀
2. **对于不熟悉的类**，尽量不使用单例，用 `new` 关键字初始化
3. **如果需要单例**，检查其是否有无限膨胀的数组属性
4. **使用 Redis/Memcached** 等外部缓存替代内存缓存
5. **定期清理数据**，为长生命周期的数组设置大小限制

> **提示**: webman 自带的 monitor 进程会监控内存使用，当内存即将达到 `memory_limit` 时会自动安全重启进程。

## 官方文档参考

详细文档请参考 `references/` 目录下的官方文档。


### 路由配置

```php
<?php
// config/route.php
use Webman\Route;

// 基础路由
Route::get('/users', [app\controller\UserController::class, 'index']);
Route::get('/users/{id}', [app\controller\UserController::class, 'show']);

// 路由组
Route::group('/api', function () {
    Route::get('/users', [app\controller\UserController::class, 'index']);
    Route::post('/users', [app\controller\UserController::class, 'store']);
});

// 资源路由
Route::resource('/users', app\controller\UserController::class);
```

### 模型

```php
<?php
namespace app\model;

use support\Model;

class User extends Model
{
    protected $table = 'users';

    protected $fillable = ['name', 'email'];

    protected $hidden = ['password'];
}
```

### 中间件

```php
<?php
namespace app\middleware;

use Webman\MiddlewareInterface;
use Webman\Http\Response;
use Webman\Http\Request;

class AuthMiddleware implements MiddlewareInterface
{
    public function process(Request $request, callable $handler): Response
    {
        // 验证逻辑
        if (!$request->session()->get('user_id')) {
            return json(['code' => 401, 'msg' => 'Unauthorized']);
        }

        return $handler($request);
    }
}
