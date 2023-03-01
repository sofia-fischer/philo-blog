---
title: "Laravel Custom Casts"

date: 2023-01-28T14:20:44+02:00

draft: false

description: "Casts are already a great feature of Laravel. They allow you to easily convert a value from the database
to the scalar
value actually needed. But in case of Arrays, especially in a Domain Driven Design context, the default Laravel Casts
are reaching their limits. In this post, I want to celebrate the power of Laravel Custom Casts and how an implementation
could look like."

tags: ["Development", "Laravel", "Casts", "Framework"]
---

{{< lead >}}
Casts are already a great feature of Laravel. They allow you to easily convert a value from the database to the scalar
value actually needed. But in case of Arrays, especially in a Domain Driven Design context, the default Laravel Casts
are reaching their limits. In this post, I want to celebrate the power of Laravel Custom Casts and how an implementation
could look like.
{{< /lead >}}

## Json in relational Databases

There are different types of databases - most common in the Laravel ecosystem are relational databases.
And they fulfill their purpose great - they hold structured, typed data; display relations between data; and are
known by most developers, which means people know how to use them and how to optimise them.
Still, sometimes the flexibility of Json objects is needed in a relational database - and although people love arguing
about when to use a document database instead, there are reasons not to: Maybe the flexibility, a situation in which
the developer is still drafting, or storing temporary data that is not meant to be analysed or queried [^whenJson].

[^whenJson]: [If you want to read about when to use json in a relational db](https://arctype.com/blog/json-database-when-use/)

## Laravel Casting

But if the decision was made and there is a json column in the database, how can it be used in the code?
My personal favorite is to use a custom cast, so lets hop into this little deep dive on casts.

The Laravel documentation offers the Array cast as best practice for json columns, which would look like
this [^laravelArrayCast]:

[^laravelArrayCast]: [Laravel Array Cast](https://laravel.com/docs/9.x/eloquent-mutators#array-and-json-casting).

```php
class User extends Model
{
    protected $casts = [
        'notification_settings' => 'array',
    ];
}
```

The function `Illuminate/Database/Eloquent/Concerns/HasAttributes::castAttribute`, holds the gigantic switch case that
calls the surprisingly simple code `return json_decode($value ?? '', ! $asObject)`.

What was stored as a json string in the database, is now decoded into an array - and now offers all the problems of
arrays, being untyped, doomed for misuse, only understandable with examples no one will keep up to date.
Or, we don't cast it to an array, but to a value object (call it Data Transfer Object if you feel like it, but please
don't appreciate it to DTO... please...). This is supported by Laravel and mentioned in the Documentation, but from my
point of view it is not practiced enough![^laravelCustomCast]

[^laravelCustomCast]: [Laravel Custom Cast Docs](https://laravel.com/docs/9.x/eloquent-mutators#value-object-casting)

![Casting Corgi](/images/2023-01-cast.png)

### Defining a Value Object

{{< alert "circle-info" >}} **Value Objects**:
Using objects instead of arrays has some benefits:

- The object describes a thing in the domain - by giving it a name communication with developers and business gets
  easier.
- The type of the data is clear, so the developer can use the IDE to autocomplete the properties.
- The data is immutable, so it can't be changed by accident.
- The data is valid as it is typed and can't be changed to an invalid state.
  {{< /alert >}}
  [^valueObjects]

[^valueObjects]: [Value Objects explained in Domain Driven Design in PHP by Buenosvinos](https://www.perlego.com/book/527020/domaindriven-design-in-php-pdf)

To make a value object out of the json column, we need to define a class that holds the data and can implements
the `JsonSerializable` trait. In this easy example that would not be necessary, but if the object gets bigger, this
function ensures that the value object is serialized in the desired way. I also included a default using the
constructor, it is not necessary as well, just a nice feature (if the Value Object is not replaced when the model is
saved, the Database Value will still be null)

```php
use JsonSerializable;
use Illuminate\Contracts\Support\Arrayable;

class NotificationSettings implements JsonSerializable, Arrayable
{
   public function __construct(
        public readonly bool $receivesAlerts = true,
        public readonly bool $receivesInfos = true,
        public readonly string $notificationTime = 'daily',
    ) {
    }
    
    public static function fromJson(string|null $value): self
    {
        if (!$value) {
            return new self();
        }

        $decoded = json_decode((string) $value, true);

        return new self(
            new NotificationMessageTypeBooleanGroup($decoded['receivesAlerts']),
            new NotificationMessageTypeBooleanGroup($decoded['receivesInfos']),
            new NotificationMessageTypeBooleanGroup($decoded['notificationTime']),
        );
    }

    public function jsonSerialize(): array
    {
        return [
            'receivesAlerts' => $this->errors,
            'receivesInfos' => $this->successfulReceivedMessages,
            'notificationTime' => $this->successfulSendMessages,
        ];
    }

    public function toArray(): array
    {
        return $this->jsonSerialize();
    }
}
```

{{< alert "circle-info" >}} **Arrayable**:
The `Arrayable` interface is used to ensure that the value object can be converted to an array.
This is a must if you use the Models toArray() function at any moment (which the framework does e.g. when using the
Laravel Request without JsonResources)
{{< /alert >}}

### Casting the Value Object

Now the value object needs to be connected to the User Model using a custom Cast.
The important thing is to implement the `CastsAttributes` interface, which requires the `get` and `set` methods.
I decided to put most of the logic in the Value Object class, a valid and maybe more pattern based approach would be to
put the logic in the Cast class.

```php
use App\Support\ValueObjectsNotificationSetting;
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

class NotificationSettingsCast implements CastsAttributes
{
    public function get($model, $key, $value, $attributes)
    {
      return NotificationSettings::fromJson($value);
    }

    public function set($model, $key, $value, $attributes)
    {
        return json_encode($value->jsonSerialize(), JSON_THROW_ON_ERROR);
    }
}
```

Last step to make it work is to add the cast to the User Model:

```php
    protected $casts = [
        'notification_settings' => NotificationSettingsCast::class,
    ];
```

### How the Cast is called by the Framework

Going back to the `Illuminate/Database/Eloquent/Concerns/HasAttributes::castAttribute`, if the switch case can not
handle the default case, the NotificationSettingsCast is identified as `isClassCastable`, and it's `get` method is
called with `$model` the User Model, `$key` the name of the column, `$value` the value of the column, and `$attributes`
the other attributes of the model as array.
Vise versa, the `set` method is called when the model is saved, and the value object is serialized to json.

## But wait, there is more! Other usages of Casts

Casts can also be used to fill "imaginary" columns, that are not stored in the database, but are calculated from other
sources. For example calculating the current State of a model, based on the timestamps of the model (or the existince of
certain Relations) can be performed by a Cast.

### Boolean Cast for Time Stamps

Often boolean values are stored as timestamps in the database, most common example would be the `email_verified_at`
column. While the information when the email was verfiied is interesting, most times in the code only the fact it is not
null is relevant.

For this use case, a parameter is passed to the cast, which is the name of the column that holds the timestamp.

```php
    protected $casts = [
        'is_email_verified' => DateToBoolenCast::class . ':email_verified_at',
    ];
```

In this setting requires a Castable class to inject the parameter into the Cast class.

```php
use Illuminate\Contracts\Database\Eloquent\Castable;

class DateToBoolenCast implements Castable
{
    public static function castUsing(array $arguments)
    {
        return new NullableEnumCast($arguments[0]);
    }
}
```

While the Cast class performs the actual casting.

```php
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

class NullableEnumCast implements CastsAttributes
{
    public function __construct(
        private readonly string $column,
    ) {
    }

    public function get($model, string $key, $value, array $attributes): bool
    {
        return (bool) $model->{$this->column};
    }

    /**
     * @param $model
     * @param  bool|null  $value
     * @return mixed
     */
    public function set($model, string $key, $value, array $attributes): ?string
    {
        if ($value) {
            $model->{$this->column} = now();
        }
    }
}
```

## Conclusion

Casts are a powerful tool to extend the functionality of the Eloquent ORM. They can be used to define Value Objects,
calculate states, or fix columns to a more readable type.

Happy Coding :)
