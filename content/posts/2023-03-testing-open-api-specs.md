---
title: "Testing Open Api files"

date: 2023-03-28T14:20:44+02:00

draft: false

description: "Using Tests to verify the type and nullable correctness of an Open Api file is one way to ensure a usable
documentation (if the file cannot be generated). This blog post is the result of a use case on testing requests and
responses to Open Api conformity."

tags: ["Development", "Testing", "DevOps"]
---

{{< lead >}}
Using Tests to verify the type and nullable correctness of an Open Api file is one way to ensure a usable
documentation (if the file cannot be generated). This blog post is the result of a use case on testing requests and
responses to Open Api conformity.
{{< /lead >}}

## Use Case

PHP Apis are famous for their inconsistent typing and the lack of respect of nullable values. This is a problem, because
other languages do (thankfully) not cast any value to any other value without complaining neither on compile time nor on
run time.
PHP Developer have nether the less started to use Open Api files to document their Apis - and often enough included
their typing inconsistency in their Open Api file.
While some are in the great position to generate the Open Api file, others might require a handwritten and maintained
Open Api file (or a combination of both).

The Base Assumption therefore is: Developers have to maintain the Open Api File by hand - or as user story: As a
Developer, I want a Test to fail if the Open Api file is conflicting with the actual Api.

![Casting Corgi](/images/2023-03-tests.png)

## Mise en place: Reading and validating the Open Api File

Fortunately, there is at least one great library that can read an Open Api file and hold it as an object, as well as
writing it to a file [^php-openapi].

[^php-openapi]: [Read and write OpenAPI 3.0.x YAML and JSON files and make the content accessible in PHP objects](https://github.com/cebe/php-openapi)

The Library does a great job at making the Open Api file accessible in PHP. In case a third party is consuming the Open
Api File (like readme.io), this also enables you to write a Command that will generate a fresh open Api File with
resolved cross file references (in case you want to generate parts of your Open Api file ;) ).

One other library that I will use in this post is using the above to validate Requests and Responses against the Open
File. [^openapi-psr7-validator]

[^openapi-psr7-validator]: [OpenAPI PSR-7 Validator](https://github.com/osteel/openapi-httpfoundation-testing)

## Request Validation

Easy steps first: The Request usually does not cause any problems on PHP Apis. Any value that comes it, and should be a
boolean but is a string, a number, or anything else will be easily converted to a boolean. Although some Api consumers
might not share PHPs view of an empty string as falsy value.

### Using defined data providers / test sets

If there are already defined test sets to be used in the API, and those are used by the developer for new features (
maybe even enhanced regularly), it is easy to use those test sets to validate the Open Api file.

So a simple tests would just use the same data set used for testing the Api (or Api validation) and validate the test
request data against the Open Api definition [^openapi-psr7-validator]. Any changes made to the test files (e.g. for a
new feature) or an updated Test file will automatically be validated against the Open Api file.

PRO

+ Easy to implement
+ Easy to maintain / debug
+ Deterministic

CON

- The tests are only as good as the test data set

### Contract Testing using Open Api as Contract

{{< alert "circle-info" >}} **Contract Testing**:
Contract testing is a methodology for ensuring that two separate systems (such as two microservices) are compatible and
can communicate with one other. It captures the interactions that are exchanged between each service, storing them in a
contract, which then can be used to verify that both parties adhere to it. [^contractTesting]
{{< /alert >}}

[^contractTesting]: [Contract Testing explained](https://pactflow.io/blog/what-is-contract-testing/)

So, the idea is to assume the Open Api is the Contract between the Api and the Api Consumer.
The Consumer should be able to send any kind of request that conforms the Open Api, and the Api should be able to
respond.

Using e.g. the Laravel Generator, writing a Request Generator is not hard.

```php
    /**
     * @param  \cebe\openapi\spec\Schema|\cebe\openapi\spec\Operation  $schema
     * @param $pointer
     */
    public function mockData(Schema $schema, $pointer = 'root')
    {
        if (! empty($schema->oneOf) || ! empty($schema->anyOf)) {
            $options = $schema->oneOf ?? $schema->anyOf;
            $randomIndex = $this->faker->numberBetween(0, count($options) - 1);

            return $this->mockData($options[$randomIndex], $pointer . '->' . $randomIndex);
        }

        if (! empty($schema->allOf)) {
            return $this->mockAllOf($schema->allOf, $pointer);
        }

        return match ($schema->type) {
            Type::INTEGER => $this->faker->numberBetween($schema->minimum, $schema->maximum),
            Type::NUMBER => $this->faker->randomFloat(4, $schema->minimum, $schema->maximum),
            Type::BOOLEAN => $this->faker->boolean(),
            Type::STRING => $this->mockString($schema),
            Type::ARRAY => $this->mockArray($schema, $pointer),
            Type::OBJECT => $this->mockObject($schema, $pointer),
            default => throw new \Exception('Unsupported datatype ' . $schema->type . ' at ' . $pointer),
        };
    }
```

I am looking forward to publish the code as soon as I can. For now, this is all I dare to show, at least the
learning of handing down the pointer to give accurate error messages in case of failure is some value. The Types and
Schema are used using the Open Api Library [^php-openapi], while the Faker is the Laravel Generator [^faker].

[^faker]: [Faker that Laravel uses as well](https://github.com/FakerPHP/Faker)

PRO

+ Might test the Api through every option eventually
+ Can point out bugs in the code beyond the Open Api file verification

CON

- Non-deterministic => Make sure the failing messages contain the exact request that failed!
- Not straight forward to implement
- Might need constant attention as it might return errors weeks after a bug was introduced
- Has limits

The Limits: E.g Laravel Validation goes far beyond the Open Api file. Validations like "exits in database" are near to
impossible to implement in the Open Api file; validations like "required if another field is set" are possible, but
working with the OneOf, AnyOf, AllOf causes more trouble down the road.

## Response Validation

The Response Validation is more delicate, as this causes more problems for the Api Consumer - while Laravel Resources
are especially frustrating to keep correctly typed; even other Frameworks have similar problems.

The same as for the Request Validation, the same applies for the Response Validation. This can either be the DataSets to
test the Resources (if such datasets exist) or the Test Sets to test the Api can run on the response of a Controller.
Of cause, using random generated input data, and then checking the resulting response would be the most complete way to
test.

```php
    public function testOpenApiGetUserResponse()
    {
        $user = User::factory()->create();
        $response = $this->get(route('user.index'));
        $response->assertSuccessful();
        $this->assertValidAgainstOpenApi($response, '/users');
    }

    /**
     * Assert that a Response is fits to a path in the specified Open Api File
     *
     * Debugging Hint fot the OneOfMany switch:
     * The Exception with more information why a sub schema failed is thrown in
     * vendor/league/openapi-psr7-validator/src/Schema/SchemaValidator.php
     */
    protected function assertValidAgainstOpenApi(
        \Illuminate\Testing\TestResponse $response,
        string $path,
        string $method = 'get',
    ): void {
        $result = ValidatorBuilder::fromYaml(config('openapi.path'))
            ->getValidator()
            ->validate($response->baseResponse, $path, $method);

        $this->assertTrue($result);
    }
```

## Conclusion

Don't be the PHP Developer that Api consumers hate because their Open Api file feels like an inspiration for the typing
in the Api Parameters and Responses. If you can not generate a correct Open Api file, write a test that will remind you
to maintain it.

Happy Coding :)
