# Execution Flow

## Process Startup Flow

When executing `php start.php start`, the execution flow is as follows:

1. Load the configurations under config/
2. Set Worker-related configurations such as `pid_file`, `stdout_file`, `log_file`, `max_package_size`, etc.
3. Create the webman process and listen on the port (default: 8787)
4. Create custom processes based on the configuration
5. After the webman process and custom processes are started, the following logic is executed (all within `onWorkerStart`):
   ① Load the files set in `config/autoload.php`, such as `app/functions.php`
   ② Load the middlewares set in `config/middleware.php` (including `config/plugin/*/*/middleware.php`)
   ③ Execute the `start` method of the classes set in `config/bootstrap.php` (including `config/plugin/*/*/bootstrap.php`) for initializing modules, such as Laravel database connection
   ④ Load the routes defined in `config/route.php` (including `config/plugin/*/*/route.php`)

## Request Handling Flow

1. Check if the request URL corresponds to a static file under public. If yes, return the file (end of request). If not, proceed to step 2.
2. Determine whether the URL matches a route. If not matched, proceed to step 3; if matched, proceed to step 4.
3. Check whether the default route is disabled. If yes, return 404 (end of request). If not, proceed to step 4.
4. Find the middlewares for the requested controller, execute middleware pre-operations in order (onion model request phase), execute the controller's business logic, execute middleware post-operations (onion model response phase), and conclude the request. (See [Middleware Onion Model](https://www.workerman.net/doc/webman/middleware.html#%E4%B8%AD%E9%97%B4%E4%BB%B6%E6%B4%8B%E8%91%B1%E6%A8%A1%E5%9E%8B))
