# Logging
The usage of the log class is similar to that of the database.

```php
use support\Log;
Log::channel('plugin.admin.default')->info('test');
```

If you want to reuse the main project's log configuration, use the following directly:

```php
use support\Log;
Log::info('Log content');
// Assuming the main project has a log configuration named test
Log::channel('test')->info('Log content');
```
