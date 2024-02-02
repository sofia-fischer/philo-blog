---
title: "Gitlab Feature Flags (for Backends)"

date: 2024-02-15T10:20:44+02:00

draft: false

description: Feature Flags are both - a hit on the bullshit bingo and case for a trigger warning. This blog post is about how they
  can help, and how to use them in Gitlab.

tags: [ "DevOps", "Development" ]
---

{{< lead >}}
Feature Flags are both - a hit on the bullshit bingo and case for a trigger warning. This blog post is about how they
can help, and how to use them in Gitlab.
{{< /lead >}}

## About Feature Flags

Feature flags are a way to control the reachability of a feature in your application. For a basic implementation a
simple if-else statement can be used.

```php
// todo: set to false before release
if (false) {
    $this->someGreatNewFeature();
} else {
    $this->oldFeature();
}
```

In a more advanced solution, there might be a setting in a config, or even an environment variable to toggle a feature
on or off. Again the next step might be an if statement depending on the user who is logged in, if they have a certain
permission or "developer cookie".
But the most recent approach is to use a Feature Flag Service with an Api call to toggle it without a deployment.

### Why Feature Flags?

Feature Flags are a development tool that is very easy to sell. Business loves it, as they can see the new features
before they are completely released; Quality Assurance loves it, as they can test the new features without big hassle
with production data; database enthusiasts love it, as they can see the data behavior and performance in an early stage;
and release managers love it, as they can release the new feature step by step, maybe starting with a small group of
users who are a selected, well known, edge case free group of users.

There is a new epic to be released, and the mvp only satisfies a fraction of the possible users - feature flag can be
the tool to control the continuous release of the epic to more and more users.
Unsure if the release will work well? Only redirect a small percentage of the users to the new feature, and see if
exceptions are hitting the monitoring, and roll back if necessary.
Not sure if the build is even useful? Only release it to half the users and see which groups results in better KPIs (
A/B Testing).
Two systems deployed separately with the same code and new features should only be released to one of the systems?
Feature Flags again can solve the problem.
Also there are different kind of Feature Flags - from a certain point of view a permission system is a feature flag.
Some users may have access to a feature, that stay hidden for others. [^types]

[^types]: [Types and usages of Feature Flags](https://martinfowler.com/articles/feature-toggles.html)

### Red Flag Feature Flags?

Feature flags come with downsides. The most obvious is the introduction of technical dept. Every Feature Flag introduced
in the code is on a certain level an if statement with a guaranteed future removal. At some point the feature is
activated for all users, or removed completely.

With that planned obsolescence, there is added complexity. The simpler the feature flag is designed, the bigger the
hassle to remove it, while on the other hand any work in designing nice feature flag mechanism is also work put into
technical dept. At one point people might ask "What code is currently running?", "Is that feature now used by
everyone?", "Where did we put that flag again?", "Why does that work for Jeff, and not me?", "That worked on a different
environment!". Inconsistency is never a good thing, and Feature Flags are a way to introduce it [^danger].
[^danger]: [Danger of Feature Flags](https://jeromedane.medium.com/feature-flags-are-dangerous-88ef9d6c9f04)

{{< alert >}}
Feature Flags are a release tool, not a configuration tool. They should be short lived, used for a specific purpose, and
keep in mind you always have to clean after them. And I repeat myself, they are short lived (days or weeks)
{{< /alert >}}
[^best]

[^best]: [Best Practices](https://docs.getunleash.io/topics/feature-flags/feature-flag-best-practices)

![Corgi with a flag](/images/2024-02-feature-flags.png)

## Feature Flags in Gitlab

Depending on the User Case, different choices in Technology should be made. For a permission system there are better
solutions that anything that calls itself feature flag, and for A/B testing many Feature Flag libraries are not enough
focused on metrics.

In my Use Case I was looking for a simple implementation, an accessible overview of the current
feature flags, and a way to control the feature flags by user or context without a deployment. Gitlab offers an Unleash
Hosting which served my needs, bonus points to automatically track and display usages of feature flags in the code, and
not tracking a lot of metrics I don't need.

### Adding Gitlab Feature Flags with the stupid questions answered

All together Gitlab Feature flags are easy to implement, and if you can avoid typos in the feature flag definition I
am confident you can make it around two hours faster than I was ;)

#### Adding the Unleash Client

**What is Unleash? ** Unleash is the Feature Flag Service Gitlab uses. Even the self-hosted Gitlab offers the Unleash
API to control Feature Flags that you can easily configure in the Gitlab UI. It is also possible to host Unleash
without Gitlab.

I found the PHP Client more versatile than the Symfony Client [^client]. While digging through the Unleash Client I
found clean written, supporting a lot of the Unleash API, and a very good documentation. Gitlab does not support all of
the possible Features, which I consider as a good thing, as it keeps the Feature Flags simple and easy to use.
[^client]: [Php Unleash Client](https://github.com/Unleash/unleash-client-php)

For the implementation the Unleash Docs are great help [^unleash]. Mind that the AppName is the Gitlab Environment.
[^unleash]: [Unleash Docs](https://docs.getunleash.io/reference/sdks/php#gitlab-specifics)

```php
public class FeatureFlagService
{
    private Unleash $unleash;
    private UnleashContext $context;

    public function __construct()
    {
        // configs can be found in the Gitlab GUI
        $this->unleash = UnleashBuilder::createForGitlab()
            ->withInstanceId('H9sU9yVHVAiWFiLsH2Mo') // this is an api key, keep it secret
            ->withAppUrl('https://git.example.com/api/v4/feature_flags/unleash/1') // url to unleash api
            ->withGitlabEnvironment('Production') // this is the environment name in Gitlab
            ->build();
        $this->context = new UnleashContext();
    }
    
    public function isEnabled(string $feature, bool $default = true): bool
    {
        return $this->unleash->isEnabled($feature, $this->context, $default);
    }
    
    public function setUser(string $id): bool
    {
        return $this->context->setCurrentUserId($id);
    }
}
```

#### Some words on the Context

The most interesting part of the Unleash Client is the Context. The Context holds the information about the user, as
Feature Flags usually close to the user and therefore in the front end. But from data perspective it can be more
interesting context to enable features on a subset of the entities. Use Cases for this are some kind of metrics, or the
replacement of a feature set with a new solutions in different service.

#### Using the Feature Flags

The Service can be injected into the Authentication Middleware to set the User, and then used in the Controller to check
if the Feature is enabled.

```php

class NewController
{
    public function get(Request $request, FeatureFlagService $featureFlagService)
    {
        $featureFlagService->setUser($request->getUser());
        if (!$featureFlagService->isEnabled('new-feature')) {
            return new JsonResponse('Feature not enabled', 404);
        } 
        
        return $this->newFeature();
    }
}
```

#### Gitlab UI and First Test / Troubleshooting

This part is trivial, Gitlab offers a nice documentation of the GUI and it is mostly self-explanatory. [^gitlab]
The interface allows the developer to define a Feature Flag, toggle it usages, limit it to a certain user or a
predefined user group, and to see the usages of the Feature Flag in the code. No additional metrics are tracked.

[^gitlab]: [Gitlab Feature Flags Docs](https://docs.gitlab.com/ee/operations/feature_flags.html)

With the first feature tested, it might work out of the box.
If it doesn't work, check if the Feature Flag is defined in the Gitlab UI and the spelling matches the one in the code.
To check if Gitlab is reachable and the credentials are working, the Unleash API can be called directly.

```bash
curl -L -X GET 'https://git.example.com/api/v4/feature_flags/unleash/1/client/features' \
-H 'Accept: application/json' \
-H 'Authorization: H9sU9yVHVAiWFiLsH2Mo'
```

Or the still somewhat supported legacy API that does use a different Header

```bash
curl -L -X GET 'https://git.example.com/api/v4/feature_flags/unleash/1/client/features' \
-H 'Accept: application/json' \
-H 'UNLEASH-INSTANCEID: H9sU9yVHVAiWFiLsH2Mo'
```

[^api]: [Unleash API](https://docs.getunleash.io/reference/api/unleash/get-all-client-features)

#### Clean up your Test Flags

## Conclusion

Feature Flags are a powerful tool to control the release of new features, and the experience to use such a tool with
such an easy set up makes it tempting to just experiment with it. 

Happy Coding!
