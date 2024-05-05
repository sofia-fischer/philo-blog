---
title: "Event Sourcing for long living projects"

date: 2024-04-28T10:20:44+02:00

draft: false

description: Event Sourcing is a software pattern for stateful entity management. Instead of storing the current state of an Entity,
  only the state changes are stored. This blog post is about the advantages and disadvantages of the pattern, and how to
  avoid some challenges I faced in long living projects.

tags: [ "Development", "Software Pattern", "Symfony"]
---

{{< lead >}}
Event Sourcing is a software pattern for stateful entity management. Instead of storing the current state of an Entity,
only the state changes are stored. This blog post is about the advantages and disadvantages of the pattern, and how to
avoid some challenges I faced in long living projects.
{{< /lead >}}

## About Event Sourcing

Event Sourcing is a software pattern for stateful entity management. Instead of storing the current state of an (
aggregate) entity, the state is derived from a sequence of (domain) events.

To implement such a pattern, the entity must have some kind of livecycle. This can be a finite state machine, for
example the state of an order (`placed`, `paid`, `shipped`, `delivered`, `returnRequested` ...); or a tracking of state
like a bank account (`+12.4€`, `-0.33€`, `+145.29`, ...).
In any case, the final entity state is derived from the sequence of events that happened to the entity.

### Implementation Idea

Arbitrary Idea for the Implementation: "As a Dog Owner, I want a system to track the contest results of my dog".

Let's start with the event requirements.
The Product/Dog Owner wants a list of all the contests, and track the current state of their dog. This includes if the
current local Dog License is passed or not, what the last achievement was, and what the all-time record ranking of the
dog is.

```php
abstract class Achievement
{
    public readonly DateTime $recordedAt = new DateTime();
    
    public function __construct(private string $contestIdentifier, DateTimeImmutable $recordedAt = null)
    {
        $this->recordedAt = $recordedAt ?? new DateTime();        
    }
}

class ObedienceAchievement extends Achievement
{
    public function __construct(private string $contestIdentifier, private int $points, private int $ranking, DateTimeImmutable $recordedAt = null)
    {
        parent::__construct($this->contestIdentifier, $recordedAt);
    }
}

class DogLicenseAchievement extends Achievement
{
    public function __construct(private string $contestIdentifier, private bool $passed, DateTimeImmutable $recordedAt = null)
    {
        parent::__construct($this->contestIdentifier, $recordedAt);
    }
}


// The Event Table
CREATE TABLE achievements (
    id UUID NOT NULL,
    dog_id UUID NOT NULL,
    context_identifier VARCHAR NOT NULL,
    recorded_at TIMESTAMP NOT NULL,
    data JSON NOT NULL,
);
```

This makes storing new achievements very easy, the controller can do a single, very fast query to add the newest
achievement to the database without caring about any state change.
Because of the different event types with different data, the `data` column is a JSON column, like no developer ever
regretted adding json data fields in relational databases. The `dogId` is not part of the event, but part of the table
to ensure a foreign relation to a dogs table, which holds data that does not change the state, e.g. the breed, owner, or
birthday.

Now to the entity, the Dog. Ignoring the contents of the dogs table, the Dog Entity is made up of an apply function,
which on instantiation applies each event until the current state is reproduced.

```php
class Dog
{
    private array $achievements = [];
    private bool $dogLicensePassed = false;
    private ?int $allTimeRanking = null;
    private ?int $lastObediencePoints = null;
    private ?DateTime $lastAchievement = null;
    
    public function apply(array $achievements): void
    {
        $this->achievements[] = $achievement;
        
        foreach ($achievements as $achievement) {
            $this->lastAchievement = $achievement->recordedAt;
        
            switch (true) {
                case $achievement instanceof ObedienceAchievement:
                    $this->lastObediencePoints = $achievement->points;
                    $this->allTimeRanking = $this->allTimeRanking === null 
                        ? $achievement->ranking 
                        : min($this->allTimeRanking, $achievement->ranking);
                    break;
                case $achievement instanceof DogLicenseAchievement:
                    $this->dogLicensePassed = $achievement->passed;
                    break;
            }
        }
    }
}
```

The `apply` function is called with the events from the database, and the entity is in the correct state. For this
pattern a repository is pattern that will help to control the hydration from the DB. [^eventSourcing]

[^eventSourcing]: Implementation idea and code snippets are inspired by the book "Implementing Domain-Driven Design" by
Vaughn Vernon.

### Advantages

Especially when coming from Eloquents Active Record Pattern, this seems a bit complicated, and require some awareness of
the benefits of segregating storing state changes and querying the state.

* **Audit Trail**: The event table is a perfect audit trail, as it holds all the changes to the entity. For some
  projects of the financial sector this can be required by law, for others a history is "only" a required user feature,
  and worst case this is great to replay the state of the entity at any given point in time for debugging. [^auditTrail]
* **Scalability**: The event table is append only, which makes it very easy to scale the database. The only thing that
  needs to be ensured is that the events are stored in the correct order. Also horizontal scaling can become very easy
  as splitting by `dog_id` can be done.
* **Performance**: The event table is very fast to write, and the separation of query and command ensures that the
  database is not blocked by long running queries. For many use cases the reliability of storing has a higher priority.
* **Simplicity**: Since years devs (in my bubble) are discussing event sourcing as great pattern, so many devs are aware
  of the pattern and will know their way around the code.
* **Testing**: Any testcase can be defined and prepared by the starting list of events, and the expected state of the
  entity. This makes testing very easy, and the tests very readable.

[^auditTrail]: [Audit Trailing via event sourcing](https://event-driven.io/en/audit_log_event_sourcing/)

### Disadvantages

* **Memory**: Besides the really big table that holds the event data, in our case with the potentially big JSON column,
  the entity in memory can become quite big. When one entity is loaded, all events need to be applied to the entity, and
  therefore fetched into RAM. Those are problems that are manageable, but need to be considered.
* **Eventual consistency**: The entity is not in a consistent state at any given point in time. There might be two
  events simultaneously that change the same state, and the order of the events is important. Again here are technical
  solutions like locking, or business solutions like making each event idempotent.
* **Querying**: The json column might hold events of different types, and the query to get the current state of the
  entity can become quite complex. This can be solved by a view, or by storing important information as separate
  columns (like in this case `contestIdentifier`). But when the Product/Dog Owner wants to know if one dog is the best
  of breed in all Obedience Contests, the query can become quite complex, when also all other achievements have to be
  sorted out.
* **Serialization**: The JSON column might hold old events, former versions. The serialization of the events might
  change, and the entity might not be able to apply the old events. This can be solved by versioning the events and a
  custom deserialization.

## Event Sourcing in long living projects

In theory many software patterns are great, but implementing them in a long living project can reveal some challenges.
I would like to share some solutions of the challenges I faced.

### The database decision

If the goal of the event sourcing is only storing the current value over time - hold your horses dear PHP Devs - maybe a
relational database is not what you are looking for. Time series databases might be an option. On the other hand if you
don't need to query too much, and just hold the maybe changing data points, a document oriented database might the
easiest solution.

If you go the for the relational database, most probably because you have a somewhat structured data model and the
requirement to query large sets of data points based on properties in typed columns, there still might be a need for a
json column. If I could choose to avoid it, I would. If the feature sets does not allow avoiding it, I highly recomend
Postgres' jsonb column (with or without an index) over mariaDbs json column. [^jsonb]

[^jsonb]: [Postgres JSONB](https://www.postgresql.org/docs/current/datatype-json.html)

### Event Versioning using a discriminator map

The day might come in which the event structure changes. A new field is added to an event, an old event is obsolete -
one day there will be an event stored in the database that is not easily applied to the entity. An implementation where
this can not happen, because all events are serialized to the same class, with the identifier stored in an enum to hide
the complexity of versioning is possible - which would make this paragraph obsolete. Often the different events are
instantiated to different classes.

{{< alert >}}
Decisions like how to name the identifier and what process to follow when an event is changed should be discussed in the
team and best case documented in e.g. Architecture Decision Records.
{{< /alert >}}

There needs to be an identifier to the type. In the easiest implementation the fully classified class name is stored in
the database - which would cause migrations on a directory name change. Therefore, the identifier should be a string.
As the string should be only used by the constant, it doesn't need to be human-readable.

```php
// a string identifier with version
public const ACHIEVED_OBEDIENCE = 'achieved.v1.obidience';
// a string that is non human-readable, to decouple class name and identifier
public const ACHIEVED_OBEDIENCE_V2 = 'achieved.cda6d2f8-feaf-4818-a061-95228e0f3957';
```

In Laravel this can be handled by Morph Maps and a Morph Many Relationship [^MorphMaps].

[^MorphMaps]: [Laravel Morph Maps](https://laravel.com/docs/11.x/eloquent-relationships#custom-polymorphic-types)

```php
Relation::enforceMorphMap([
    Achievement::ACHIEVED_OBEDIENCE_V1, Achievement::ACHIEVED_OBEDIENCE_V2 => ObedienceAchievement::class,
    Achievement::ACHIEVED_DOG_LICENSE_V1 => DogLicenseAchievement::class,
]);
```

In Symfony the instantiation often happens more declarative, which also might cause a lot more boilerplate code. But
Symfony does support a similar feature [^discriminators]. These exact implementation will not be discussed here, as I
personally had multiple problems implementing it. On one hand in this particular project the attributes were not an
option, on the other I require the discriminator map to be in code for better maintainability (if you can not click on
it, you will not maintain it); also, I found myself debugging the Injection of the resulting serializer very hard -
please feel free to teach me better and share your implementation.

[^discriminators]: [Symfony Discriminator Map](https://symfony.com/doc/current/components/serializer.html#serializing-interfaces-and-abstract-classes)

```php
public function fromArray(array $row): Achievement
{
    $identifier = $data['identifier'];
    
    return match ($identifier) {
        self::ACHIEVED_OBEDIENCE_V2 => new ObedienceAchievement($row['contestIdentifier'], $row['points'], $row['ranking'], $row['recordedAt']),
        // historically there was no contest identifier in the past, however all contests before the change had the same identifier
        self::ACHIEVED_OBEDIENCE_V1 => new ObedienceAchievement('Obedience Trail 2023', $row['points'], $row['ranking'], $row['recordedAt']),
        default => throw new InvalidArgumentException('Unknown identifier: ' . $identifier),
    };
}
```

### Event deserialization

Repository classes containing to instantiate entities from the database are sometimes quite big and messy.
A cleaner solution for this problem that comes in handy with instantiating events from json or from a raw database row
is using a normalizer. [^normalizer]

[^normalizer]: [Symfony Normalizer](https://symfony.com/doc/current/serializer/custom_normalizer.html)

```php
class AchievementNormalizer implements NormlizerInterface, DenormalizerInterface
{
    private const ACHIEVEMENTS_MAP = [
        Achievement::ACHIEVED_OBEDIENCE_V1, Achievement::ACHIEVED_OBEDIENCE_V2 => ObedienceAchievement::class,
        Achievement::ACHIEVED_DOG_LICENSE_V1 => DogLicenseAchievement::class,
    ];
    
    public function __construct(private ObjectNormalizer $normalizer) {}
    
    public function normalize($object, string $format = null, array $context = []): array
    {
        $this->normalizer->normalize($object, $format, $context);
    }
    
    public function denormalize($data, string $type, string $format = null, array $context = []): Achievement
    {
        $identifier = $data['identifier'] ?? throw new InvalidArgumentException('No identifier found');
        if ($identifier == '*the super old identifier we do barely support*'){
            return new DepricatedAchievement($identifier);
        }
    
        $type = self::ACHIEVEMENTS_MAP[$identifier] ?? throw new InvalidArgumentException('Unknown type: ' . $identifier);
        
        return $this->normalizer->denormalize($data, $type, $format, $context);
    }
    
    public function supportsDenormalization($data, string $type, string $format = null): bool
    {
        return $type === Achievement::class;
    }
    
    public function getSupporedClass(): array
    {
        return[Achievement::class => true];
    }
}
```

Having a special normalizer for this enables the developer to have a clean repository class, but still provides a place
to hook into the deserialization process, set defaults for old fields, or throw exceptions for unknown fields.
The discriminator map is hold in code, so any code editor can jump to the events, and back.

A test could look like:

```php
public function testSerializeAndDeserialize(): void
{
    $achievement = new ObedienceAchievement('Obedience Trail 2023', 100, 1);
    $encodedAchievement = $this->serializer->serialize($achievement, 'json');
    
    $achievementArray = json_decode($encodedAchievement, true);
    $this->assertArrayHasKey('identifier', $achievementArray);
    $this->assertEquals(Achievement::ACHIEVED_OBEDIENCE_V2, $achievementArray['identifier']);
    
    $deserialized = $this->serializer->deserialize($encodedAchievement, Achievement::class, 'json');
    $this->assertInstanceOf(ObedienceAchievement::class, $deserialized);
}
```

Also, a test that grabs all achievements from the directory folder and checks if they can be deserialized should be
added to ensure that the map is always updated when a developer adds a new achievement.

## Conclusion

Event Sourcing is a great pattern, and for certain use cases the best solution. The implementation can be quite tricky,
but if the team works through the current and future challenges, the pattern can be a great addition to the project.

Happy Coding :)
