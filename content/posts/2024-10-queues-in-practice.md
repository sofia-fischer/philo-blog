---
title: "Consuming and Publishing to an external Service with Symfony Messenger"

date: 2024-10-20T10:20:44+02:00

draft: true

description: Implementing a Queue Request / Response with Symfony Messenger to explore the benefits of asynchronous communication
  between services

tags: [ "Symfony", "Queue", "Software Pattern", "Development" ]
---

{{< lead >}}
Implementing a Queue Request / Response with Symfony Messenger to explore the benefits of asynchronous communication
between services
{{< /lead >}}

## Queues

Queues are a way to manage asynchronous communication between different parts of a system.

Message queues are like a mailbox where messages are stored by one service, and independently / asynchronously picked up
by (another or the same) service for processing.

Queues come with great benefits:

* Decoupling of services of different technologies or even programming languages
* Control of the flow of messages and therefore the system performance
* Increase loose coupling and scalability

{{< alert "circle-info" >}}
**How well is a Queue Performing?** The main attributes to look at are the Queue Age (the age of the oldest message in
queue) and the Queue Size (the number of messages in the queue). A queue with one thousand messages doesn't need to be a
Problem if the oldest message is only a second
{{< /alert >}}

### AMQP

AMQP 0-9-1 (Advanced Message Queuing Protocol) is a messaging protocol that enables conforming client applications to
communicate with conforming messaging middleware brokers, or
> A defined set of messaging capabilities called the "Advanced Message Queuing Protocol
> Model" (AMQ model). The AMQ model consists of a set of components that route and store messages
> within the broker service, plus a set of rules for wiring these components together.
[^ampqp]: [AMQP 0-9-1 Specification](https://www.amqp.org/specification/0-9-1/amqp-org-download)

```goat
 ┌────────┐        ┌────────┐               ┌─────┐         ┌────────┐
 │Producer│        │Exchange│               │Queue│         │Consumer│
 └───┬────┘        └───┬────┘               └──┬──┘         └───┬────┘
     │                 │                       │                │     
     │Publishes Message│                       │                │     
     │────────────────>│                       │                │     
     │                 │                       │                │     
     │                 │Routes Message to Queue│                │     
     │                 │──────────────────────>│                │     
     │                 │                       │                │     
     │                 │                       │Consumes Message│     
     │                 │                       │<───────────────│     
 ┌───┴────┐        ┌───┴────┐               ┌──┴──┐         ┌───┴────┐
 │Producer│        │Exchange│               │Queue│         │Consumer│
 └────────┘        └────────┘               └─────┘         └────────┘
```

In the AMQP model messages are published to an exchange, a metaphorical letter box.
The Exchange routes the message to a queue based often on the routing key, or other defined rules.
A Binding is a link between an exchange and a queue, defining the routing rules for messages.
The Queue stores the message until a consumer retrieves it.
After the consumer processes the message, it acknowledges receipt, allowing the broker to remove the message from the
queue.

The AMQP model provides different types of exchanges:

* **Direct Exchange**: Routes messages with a routing key are routed to a queue with the same name.
* **Fanout Exchange**: Routes messages to all queues bound to it, regardless of the routing key.
* **Topic Exchange**: Routes messages to one or more queues based on wildcard matches between the routing key and the
  queue names.

The protocol itself is implemented by various brokers, such as RabbitMQ, or Kafka. A broker is a service that
receives, stores, and forwards messages.

## Implementing a Queue Request / Response with Symfony Messenger

Symfony Messenger provides a powerful way to handle message. I very much enjoyed going through the implementation in
more detail in a previous post [The Symfony Messanger step by step]({{< ref "posts/2024-01-symfony-queues.md" >}}).

While the Symfony documentation[^symfonyMessanger] works out of the box for having one queue with the Php Application
producing and consuming all messages, to utilize the main benefit of queues I had to look through some documentation or
examples to understand what was happening.

[^symfonyMessanger]: [Symfony Messenger](https://symfony.com/doc/current/messenger.html)

The use case I want to cover is that I want to produce a message in my application and dispatch it so that a different
service can consumes it, and again dispatches the result for my application to consume.
In use cases of very long processing times I found this solution to be very useful instead of an HTTP request.

### Dispatching the Request to a Queue

In Symfony the only requirement for a message is that it can be serialized.
I want `RequestMessage` to be produced by my application, but a different service will consume it.

```injectablephp
readonly class RequestMessage
{
    public function __construct(public string $content)
    {
    }
}
```

To dispatch the message, I need to inject the `MessageBusInterface` into a Service from which I will dispatch
the message.

```injectablephp
class RequestMessageClient
{
    public function __construct(private MessageBusInterface $bus) {}
    
    public function __invoke(RequestMessage $message)
    {
        $this->bus->dispatch($message);
    }
}
```

### Listening to the Response Message

I can again have any serializable class as `ResponseMessage`.

```injectablephp
readonly class ResponseMessage
{
    public function __construct(public string $content, public int $code)
    {
    }
}
```

The only special thing on the Listener is that I need to define the transport from which it will consume messages.

```injectablephp
#[AsMessageHandler(fromTransport: 'external_messages')]
class ResponseMessageListener
{
    public function __invoke(ResponseMessage $message)
    {
        // ... do some business
    }
}
```

### Wiring the Transport in Symfony config

```yaml
# config/packages/messenger.yaml
framework:
  parameters:
    amqp_dsn: 'amqp://gues:guest@rabbitmq:5672/'
  messenger:
    transports:
      internal_messages:
        ...
      external_messages: # (1)
        dsn: '%amqp_dsn%' # (2)
        serializer: App\Serializer\ExternalMessageSerializer  # (3)
        options:
          exchange: # (4)
            name: 'queue.external'
            type: topic
            # The Messages I dispatch from this transport will have this routing key
            default_publish_routing_key: 'queue.external.request'
          queues: # (5)
            # I don't want to consume our own messages
            # queue.external.request:
            #   binding_keys: ['queue.external.request']
            queue.external.response:
              binding_keys: [ 'queue.external.response' ]

    routing: # (6)
      # I want to send my RequestMessage to the external_messages queue
      'App\Message\RequestMessage': external_messages
```

1. Define the transport for external messages. There might be already a transport defined for internal messages, or a
   synchron transport for testing.
2. Define the DSN for the RabbitMQ server. I did assume there is a (Docker) RabbitMQ server running.
3. The default Serializer will deserialize based on fully classified class names. When working with other services this
   is no option; independently it is a great feature to have an Anti Corruption Layer. The solution is a custom Message
   Serializer. Just in case, this step is missing when error message appears
   `Could not decode message using PHP serialization`.
4. The exchange, so the postbox for messages, is defined here. I want to use a topic exchange, because I want to use the
   same exchange for dispatching and consuming my messages. I defined the routing key for the messages I will dispatch,
   so the exchange can route them correctly to the queue that will store my requests.
5. The queues that will be used for consuming messages are defined here. I want to consume the response messages, but I
   don't want to consume my own request messages.
6. The routing defines which transport will be used for which dispatched message class. I maybe want to use my internal
   message queue by default, and only send my `RequestMessage` to the external transport.

### The MessageSerializer

The majority the Serializer is shamelessly copied from the Symfony Messanger Serializer [^symfonySerializer], and there
is for sure a cleaner solution to handle the serialization of the stamps.
[^symfonySerializer]: [Symfony Messenger Serializer](https://github.com/symfony/symfony/blob/7.1/src/Symfony/Component/Messenger/Transport/Serialization/Serializer.php)

Also other blogs provided a simpler solution without stamps[^medium].
[^medium]: [Consume External Messages Using Symfony Messenger](https://medium.com/@sfmok/consume-external-messages-using-symfony-messenger-92f7490d1194)

```injectablephp
use App\Message\ResponseMessage;
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\Exception\MessageDecodingFailedException;
use Symfony\Component\Messenger\Transport\Serialization\SerializerInterface as MessageSerializerInterface;
use Symfony\Component\Serializer\SerializerInterface;

class ExternalMessageSerializer implements MessageSerializerInterface
{
    private const STAMP_HEADER_PREFIX = 'X-Message-Stamp-';

    public function __construct(private SerializerInterface $serializer)
    {
    }
    
     /**
     * Decodes an envelope and its message from an encoded-form.
     *
     * The `$encodedEnvelope` parameter is a key-value array that
     * describes the envelope and its content, that will be used by the different transports.
     *
     * @throws MessageDecodingFailedException
     */
    public function decode(array $encodedEnvelope): Envelope
    {
        $body = $encodedEnvelope['body'];

        try {
            $message = $this->serializer->deserialize($body, ResponseMessage::class, 'json');
        } catch (\Throwable $throwable) {
            throw new MessageDecodingFailedException($throwable->getMessage())
        }

        $stamps = [];
        foreach ($encodedEnvelope['headers'] as $name => $value) {
            if (!str_starts_with($name, self::STAMP_HEADER_PREFIX)) {
              continue;
            }
            
            try {
                $stamps[] = $this->serializer->deserialize($value, substr($name, \strlen(self::STAMP_HEADER_PREFIX)).'[]', 'json');
            } catch (ExceptionInterface $e) {
                throw new MessageDecodingFailedException('Could not decode stamp: '.$e->getMessage(), $e->getCode(), $e);
            }
        }

        return new Envelope($message, $stamps);
    }

    /**
     * Encodes an envelope content (message & stamps) to a common format understandable by transports.
     * The encoded array should only contain scalars and arrays.
     *
     * Stamps that implement NonSendableStampInterface should not be encoded.
     */
    public function encode(Envelope $envelope): array
    {
        return [
            'body' => $this->serializer->serialize($envelope->getMessage(), 'json'),
            'headers' => [
                'type' => get_class($envelope->getMessage()),
                'stamps' => $this->serializer->serialize($envelope->all(), 'json'),
            ],
        ];
    }
}
```

{{< alert "circle-info" >}}

The MessageSerializer `@throws MessageDecodingFailedException` if the message cannot be decoded.
Throwing this exception will remove the message from the queue.
Any other exception will trigger a retry.

{{< /alert >}}

### Testing

Debugging with queues is a great way to ensure that your messages are being sent and received correctly.
And also a nice way to document the process.

This is more of an integration test, I would prefer to have dedicated tests with the test transport.

```injectablephp
class RequestMessageTest extends KernelTestCase
{
    public function testRouting(): void
    {
        /** @var AmqpTransport $transport */
        $transport = $this->getContainer()->get('messenger.transport.external_messages');
        
        $response = new ResponseMessage('Hello World', 200);
        
        // Send the response message to the queue with a routing key so that my transport can consume it
        $transport->send(new Envelope($response), [new AmqpStamp('queue.external.response')]);
        
        // Check if the message is consumed by the transport
        $envelope = iterator_to_array($transport->get())[0];
        $this->assertSame($response, $envelope->getMessage());
        $transport->ack($envelope);
    }
    
    public function testDispatching(): void
    {
        /** @var AmqpTransport $transport */
        $transport = $this->getContainer()->get('messenger.transport.external_messages');
        
        $request = new RequestMessage('Hello World');
        $client = $this->getContainer()->get(RequestMessageClient::class);
        $client($request);

        // Check that there is no consumable message
        $this->assertEmpty(iterator_to_array($transport->get()));
        
        // Check that the message is consumable by the other queue
        $envelope = iterator_to_array($transport->getFromQueues(['queue.external.request']))[0];
        $this->assertSame($request, $envelope->getMessage());
        $transport->ack($envelope);
    }
}
```

## Conclusion

Working with queues is a great way to decouple services and to ensure that your application can handle a high load of
requests. I definitely learned some things about the Symfony configuration and how it reflects in the RabbitMQ options.
Also, I am amazed by how easily the messages can be tested. 

Happy Coding :)
