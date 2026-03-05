# think-cache

think-cache is a component extracted from the thinkphp framework, with connection pool support added. It automatically supports both coroutine and non-coroutine environments.

## Installation
`composer require -W webman/think-cache`

Restart is required after installation (reload is ineffective)

### Configuration File

The configuration file is `config/think-cache.php`

## Usage

  ```php
  <?php
  namespace app\controller;
    
  use support\Request;
  use support\think\Cache;
  
  class UserController
  {
      public function db(Request $request)
      {
          $key = 'test_key';
          Cache::set($key, rand());
          return response(Cache::get($key));
      }
  }
  ```
## Provided API
```php
// Set cache
Cache::set('val','value',600);
// Check if cache exists
Cache::has('val');
// Get cache
Cache::get('val');
// Delete cache
Cache::delete('val');
// Clear cache
Cache::clear();
// Read and delete cache
Cache::pull('val');
// Write if not exists
Cache::remember('val',10);

// For numeric cache data
// Increment cache by 1
Cache::inc('val');
// Increment cache by 5
Cache::inc('val',5);
// Decrement cache by 1
Cache::dec('val');
// Decrement cache by 5
Cache::dec('val',5);

// Use cache tags
Cache::tag('tag_name')->set('val','value',600);
// Delete cache under a tag
Cache::tag('tag_name')->clear();
// Supports multiple tags
Cache::tag(['tag1','tag2'])->set('val2','value',600);
// Delete cache under multiple tags
Cache::tag(['tag1','tag2'])->clear();

// Use different cache stores
$redis = Cache::store('redis');

$redis->set('var','value',600);
$redis->get('var');
```


