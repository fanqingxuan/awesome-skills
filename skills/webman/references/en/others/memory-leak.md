# About Memory Leaks
Webman is a resident memory framework, so we need to pay some attention to memory leaks. However, developers need not worry too much, because memory leaks occur only under very extreme conditions and are easy to avoid. The development experience with webman is basically the same as with traditional frameworks; there is no need to perform extra operations for memory management.

> **Tip**
> Webman's built-in monitor process monitors memory usage of all processes. When a process's memory usage is about to reach the value set by `memory_limit` in php.ini, it will automatically and safely restart the corresponding process to free memory, with no impact on your application.

## Memory Leak Definition
As the number of requests increases, continuous growth of webman's memory usage is normal. In general, once a process reaches a certain request volume (typically in the millions), memory will stop growing or occasionally increase slightly.

For most applications, a single process's memory usage will eventually stabilize at around 10M–100M. There is no need to worry if single-process memory stays under 100M.

Additionally, when handling large files, large requests, or reading large amounts of data from a database, PHP will allocate substantial memory. PHP may retain some of this memory for reuse instead of returning it all to the operating system, which can lead to high memory usage. Since the memory is reused, there is no need for concern.

> **Tip**
> For phar or binary-packed projects, if the package size is large, it is normal for the packaged project's memory usage to exceed 100M.

## How to Confirm a Memory Leak
If a process has handled over a million requests, memory usage exceeds 100M, and memory still grows after each request, a memory leak may be occurring.

## How to Locate a Memory Leak
A simple approach is to stress-test each API and identify which one continues to increase memory usage after millions of requests.

Once a problematic API is found, use a binary search approach: comment out half of the business logic at a time until you narrow down the exact code causing the issue.

## How Memory Leaks Occur
**A memory leak occurs only when both of the following conditions are met:**
1. There exists an array with a **long life cycle** (note: a long life cycle array; ordinary arrays are fine)
2. And this **long life cycle** array keeps growing indefinitely (the application keeps inserting data into it and never cleans it up)

A memory leak occurs only when **both** conditions are satisfied. If either condition is not met or only one is met, it is not a memory leak.

## Long Life Cycle Arrays

In webman, long life cycle arrays include:
1. Arrays with the `static` keyword
2. Array properties of singletons
3. Arrays with the `global` keyword

> **Note**
> Long life cycle data is allowed in webman, but you must ensure that the data remains bounded and the number of elements does not grow indefinitely.

The following examples illustrate each case.

### Infinitely Expanding static Array
```php
class Foo
{
    public static $data = [];
    public function index(Request $request)
    {
        self::$data[] = time();
        return response('hello');
    }
}
```

The `$data` array defined with the `static` keyword is a long life cycle array. In this example, the `$data` array keeps expanding with each request, causing a memory leak.

### Infinitely Expanding Singleton Array Property
```php
class Cache
{
    protected static $instance;
    public $data = [];
    
    public function instance()
    {
        if (!self::$instance) {
            self::$instance = new self;
        }
        return self::$instance;
    }
    
    public function set($key, $value)
    {
        $this->data[$key] = $value;
    }
}
```

Calling code
```php
class Foo
{
    public function index(Request $request)
    {
        Cache::instance()->set(time(), time());
        return response('hello');
    }
}
```

`Cache::instance()` returns a Cache singleton, which is a long life cycle instance. Although its `$data` property does not use the `static` keyword, because the class itself has a long life cycle, `$data` is also a long life cycle array. As different keys are continuously added to the `$data` array, the program's memory usage grows, causing a memory leak.

> **Note**
> If the keys added by `Cache::instance()->set(key, value)` are limited in number, there will be no memory leak, because the `$data` array does not expand indefinitely.

### Infinitely Expanding global Array
```php
class Index
{
    public function index(Request $request)
    {
        global $data;
        $data[] = time();
        return response($foo->sayHello());
    }
}
```
Arrays defined with the `global` keyword are not reclaimed when a function or class method completes, so they have a long life cycle. The above code will cause a memory leak as requests keep increasing. Similarly, arrays defined with the `static` keyword inside a function or method are also long life cycle arrays; if such an array keeps expanding, it will cause a memory leak, for example:
```php
class Index
{
    public function index(Request $request)
    {
        static $data = [];
        $data[] = time();
        return response($foo->sayHello());
    }
}
```

## Recommendations
Developers are advised not to focus excessively on memory leaks, as they rarely occur. If one does occur, stress testing can help find the code that causes the leak. Even if developers cannot locate the leak, webman's built-in monitor service will safely restart the affected process when appropriate, freeing memory.

If you do want to minimize the risk of memory leaks, consider these recommendations:
1. Avoid using arrays with the `global` or `static` keyword where possible; if you use them, ensure they do not grow indefinitely.
2. For unfamiliar classes, prefer initializing with the `new` keyword rather than using singletons. If a singleton is needed, check whether it has array properties that can grow indefinitely.
