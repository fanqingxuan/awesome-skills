# Crontab Scheduling Component

## Description

`workerman/crontab` is similar to Linux crontab, but supports second-level scheduling.

Time format:

```
0   1   2   3   4   5
|   |   |   |   |   |
|   |   |   |   |   +------ day of week (0 - 6) (Sunday=0)
|   |   |   |   +------ month (1 - 12)
|   |   |   +-------- day of month (1 - 31)
|   |   +---------- hour (0 - 23)
|   +------------ min (0 - 59)
+-------------- sec (0-59) [optional; if omitted, minimum granularity is minutes]
```

## Project URL

https://github.com/walkor/crontab
  
## Installation
 
```php
composer require workerman/crontab
```
  
## Usage

**Step 1: Create process file `app/process/Task.php`**

```php
<?php
namespace app\process;

use Workerman\Crontab\Crontab;

class Task
{
    public function onWorkerStart()
    {
    
        // Run every second
        new Crontab('*/1 * * * * *', function(){
            echo date('Y-m-d H:i:s')."\n";
        });
        
        // Run every 5 seconds
        new Crontab('*/5 * * * * *', function(){
            echo date('Y-m-d H:i:s')."\n";
        });
        
        // Run every minute
        new Crontab('0 */1 * * * *', function(){
            echo date('Y-m-d H:i:s')."\n";
        });
        
        // Run every 5 minutes
        new Crontab('0 */5 * * * *', function(){
            echo date('Y-m-d H:i:s')."\n";
        });
        
        // Run on the first second of every minute
        new Crontab('1 * * * * *', function(){
            echo date('Y-m-d H:i:s')."\n";
        });
      
        // Run at 7:50 every day (note: second field omitted here)
        new Crontab('50 7 * * *', function(){
            echo date('Y-m-d H:i:s')."\n";
        });
        
    }
}
```
  
**Step 2: Configure process to start with webman**
  
Open config file `config/process.php` and add the following:

```php
return [
    ....other config omitted....
  
    'task'  => [
        'handler'  => app\process\Task::class
    ],
];
```
  
**Step 3: Restart webman**

> Note: Scheduled tasks do not run immediately; they begin counting and executing from the next minute.

## Notes
Crontab is not asynchronous. For example, if a task process sets two timers A and B, both running every second, but task A takes 10 seconds to complete, then B must wait for A to finish before running, causing B to be delayed.
If your logic is sensitive to timing intervals, run time-sensitive scheduled tasks in separate processes to avoid interference from other tasks. Example `config/process.php` configuration:

```php
return [
    ....other config omitted....
  
    'task1'  => [
        'handler'  => process\Task1::class
    ],
    'task2'  => [
        'handler'  => process\Task2::class
    ],
];
```
Put time-sensitive tasks in `process/Task1.php` and other tasks in `process/Task2.php`.

For more on `config/process.php`, see [Custom Processes](../process.md)
