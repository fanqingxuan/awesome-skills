# Slow Business Processing

Sometimes we need to handle slow business processes. To avoid slow business affecting other request handling in webman, different processing solutions can be used for these businesses depending on the situation.

## Option 1: Using Message Queue
Refer to [Redis Queue](../queue/redis.md) [Stomp Queue](../queue/stomp.md)

#### Advantages
Can handle sudden surges of business processing requests

#### Disadvantages
Cannot directly return results to the client. If pushing results is needed, it must be coordinated with other services, such as using [webman/push](https://www.workerman.net/plugin/2) to push processing results.

## Option 2: Adding a New HTTP Port

Add a new HTTP port to handle slow requests. These slow requests are processed by a specific group of processes through this port, and results are returned directly to the client after processing.

#### Advantages
Can return data directly to the client

#### Disadvantages
Cannot handle sudden surges of requests

#### Implementation Steps
Add the following configuration in `config/process.php`.
```php
return [
    // ... Other configurations are omitted here ...
    
    'task' => [
        'handler' => \Webman\App::class,
        'listen' => 'http://0.0.0.0:8686',
        'count' => 8, // Number of processes
        'user' => '',
        'group' => '',
        'reusePort' => true,
        'constructor' => [
            'requestClass' => \support\Request::class, // Request class setting
            'logger' => \support\Log::channel('default'), // Logger instance
            'appPath' => app_path(), // App directory location
            'publicPath' => public_path() // Public directory location
        ]
    ]
];
```

This way, slow interfaces can go through the group of processes at `http://127.0.0.1:8686/` without affecting business processing of other processes.

To make the frontend unaware of the port difference, you can add a proxy to port 8686 in nginx. Assuming slow interface request paths all start with `/task`, the nginx configuration would be similar to the following:
```
upstream webman {
    server 127.0.0.1:8787;
    keepalive 10240;
}

# Add a new 8686 upstream
upstream task {
   server 127.0.0.1:8686;
   keepalive 10240;
}

server {
  server_name webman.com;
  listen 80;
  access_log off;
  root /path/webman/public;

  # Requests starting with /task go to port 8686, please change /task to your desired prefix as needed
  location /task {
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header Host $host;
      proxy_http_version 1.1;
      proxy_set_header Connection "";
      proxy_pass http://task;
  }

  # Other requests go to the original 8787 port
  location / {
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header Host $host;
      proxy_http_version 1.1;
      proxy_set_header Connection "";
      if (!-f $request_filename){
          proxy_pass http://webman;
      }
  }
}
```

This way, when the client accesses `domain.com/task/xxx`, it will be processed by the separate 8686 port without affecting request processing on port 8787.

## Option 3: Using HTTP Chunked for Asynchronous Segmented Data Sending

#### Advantages
Can return data directly to the client

**Install workerman/http-client**

```
composer require workerman/http-client
```

**app/controller/IndexController.php**
```php
<?php
namespace app\controller;

use support\Request;
use support\Response;
use Workerman\Protocols\Http\Chunk;

class IndexController
{
    public function index(Request $request)
    {
        $connection = $request->connection;
        $http = new \Workerman\Http\Client();
        $http->get('https://example.com/', function ($response) use ($connection) {
            $connection->send(new Chunk($response->getBody()));
            $connection->send(new Chunk('')); // Send empty chunk to indicate end of response
        });
        // Send HTTP headers first, then send data asynchronously
        return response()->withHeaders([
            "Transfer-Encoding" => "chunked",
        ]);
    }
}
```

> **Note**
> This example uses the `workerman/http-client` client to asynchronously fetch HTTP results and return data. You can also use other async clients such as [AsyncTcpConnection](https://www.workerman.net/doc/workerman/async-tcp-connection/construct.html).
