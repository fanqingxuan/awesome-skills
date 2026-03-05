# Stomp Queue

Stomp is a Simple (Streaming) Text Orientated Messaging Protocol that provides an interoperable wire format allowing STOMP clients to communicate with any STOMP message broker. [workerman/stomp](https://github.com/walkor/stomp) implements the Stomp client and is mainly used for message queue scenarios such as RabbitMQ, Apollo, ActiveMQ, etc.

## Installation
`composer require webman/stomp`

## Configuration
The configuration file is located under `config/plugin/webman/stomp`

## Sending Messages
```php
<?php
namespace app\controller;

use support\Request;
use Webman\Stomp\Client;

class Index
{
    public function queue(Request $request)
    {
        // Queue name
        $queue = 'examples';
        // Data (serialization is required when passing an array, e.g. using json_encode, serialize, etc.)
        $data = json_encode(['to' => 'tom@gmail.com', 'content' => 'hello']);
        // Perform delivery
        Client::send($queue, $data);

        return response('redis queue test');
    }

}
```
> For compatibility with other projects, the Stomp component does not provide automatic serialization and deserialization. If sending array data, you must serialize it yourself and deserialize it when consuming.

## Consuming Messages
Create a new file `app/queue/stomp/MyMailSend.php` (class name can be arbitrary as long as it follows the PSR-4 standard).
```php
<?php
namespace app\queue\stomp;

use Workerman\Stomp\AckResolver;
use Webman\Stomp\Consumer;

class MyMailSend implements Consumer
{
    // Queue name
    public $queue = 'examples';

    // Connection name, corresponding to the connection in stomp.php
    public $connection = 'default';

    // When value is 'client', call $ack_resolver->ack() to notify the server of successful consumption
    // When value is 'auto', no need to call $ack_resolver->ack()
    public $ack = 'auto';

    // Consume
    public function consume($data, AckResolver $ack_resolver = null)
    {
        // If data is an array, deserialize it yourself
        var_export(json_decode($data, true)); // Outputs ['to' => 'tom@gmail.com', 'content' => 'hello']
        // Notify the server of successful consumption
        $ack_resolver->ack(); // Can be omitted when ack is 'auto'
    }
}
```

# Enable STOMP Protocol in RabbitMQ
RabbitMQ does not enable the STOMP protocol by default. Run the following command to enable it:
```
rabbitmq-plugins enable rabbitmq_stomp
```
Once enabled, the default STOMP port is 61613.
