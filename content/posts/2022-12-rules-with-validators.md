---
title: "Laravel Validations"

date: 2022-12-26T14:20:44+02:00

draft: false

description: "Validations are great for ensuring that the data you receive is in the format you expect, while also
handling a lot of
edge cases (like ids that are not in the database). This ensures not only a fast failing of the request, but also gives
the user (or front-end developer) a clear error message. Laravel offers great tools, in which I would like to dig deeper
up to a final form of unintended usage - like Recursive Validations."

tags: ["Development", "Laravel", "Validation"]
---

{{< lead >}}
Validations are great for ensuring that the data you receive is in the format you expect, while also handling a lot of
edge cases (like ids that are not in the database). This ensures not only a fast failing of the request, but also gives
the user (or front-end developer) a clear error message. Laravel offers great tools, in which I would like to dig deeper
up to a final form of unintended usage - like Recursive Validations.
{{< /lead >}}

## Validation in Form Requests

A custom FormRequest can have a `function rules()` which returns an array of rules, which are used to validate the data.
The magic behind this function includes the `Validator` class (`Illuminate\Validation\Validator`) which loops over all
key-value pairs, resolves the corresponding Rule (like 'min:2' into Rule::min(2)) and checks if they fail.
The 'old school' Rules are classes that implement a `function passes()` that will return a boolean whether the given
data is valid or not; based on that a translated error message is added to an Error Bag (and depending on the '
stopOnFirstFailure' the loop continues [^discovery].

All this happens by magic if correctly injected in the Controller Method.

[^discovery]: [That and more explained in the Laravel Docs](https://laravel.com/docs/9.x/validation).

```php
<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class OrderRequest extends FormRequest
{
    public function rules()
    {
        return [
            'name' => ['nullable', 'integer', 'min:1', 'max:100'],
            'game_id' => ['required', 'exists:games,id'],
            // mind, that the Rules can be called as static methods
            'role' => ['required', Rule::in(['knight', 'thief', 'ghost', 'wizard'])],
            // and that they may get closures as parameters
            // (this will return the default error message)
            'items' => [Rule::requiredIf(fn () => $this->role === 'thief'), 'array'],
            // or that a custom rule can be implemented as closure
            // this will return special error messages
            'spells' => ['array', function ($attribute, $value, $fail) {
                if ($this->role !== 'wizard') {
                    $fail('Only wizards can cast spells');
                }
                
                if (count($value) > 3) {
                    $fail('A wizard can only cast 3 spells');
                }
            }],
        ];
    }
}
```

## Custom Rules

Often enough, these validations will contain some duplication. For example, in this RPG example, the `game_id` may only
belong to a game which is not finished yet. This can be implemented as a custom rule.
Laravel provides this using Invokable Rules, which contain a single method: __invoke. This method receives the
attribute name, its value, and a callback that should be invoked on failure with the validation error message.

```php
<?php

declare(strict_types=1);

namespace App\Http\Rules;

use Illuminate\Contracts\Validation\InvokableRule;

class UnfinishedGameRule implements InvokableRule
{
    /**
     * @param  string  $attribute
     * @param  mixed  $value
     * @param  \Closure(string): \Illuminate\Translation\PotentiallyTranslatedString  $fail
     */
    public function __invoke($attribute, $value, $fail): void
    {
        $game = Game::find($value);
        
        if ($game->isFinished()) {
            $fail('The game is already finished');
        }
    }
}
```

This rule can be used in the FormRequest as
follows:

`$request->validate(['game_id' => ['required', 'exists:games,id', new UnfinishedGameRule]]);`

Rules offer some quite nice additions, like adding parameters to the Rule using its constructor, or implementing
the `DataAwareRule` Interface which allows you to access the data of the request.

## Validations in Rules

In theory, this should be enough ... but when working with complex objects, it would be so nice to have a validation
inside the Rule Object. Just implementing a new Validator inside of the Rule would be a nice solution, but leads to some
problems:

1. The Validator will not return the correct error message, as it is not aware of the full attribute name (e.g. `name`
   instead of `items.0.name`)
2. The nesting of the Error Bag will be messed up
3. The original Validator will not be aware of the new rules, so it will not be able to access the data using $request->
   safe('name')
4. `dependentRules` will not be displayed using the correct attribute name (e.g. if one value must be greater than
   another, the error message will not be displayed correctly)

To solve this, we can use the `ValidatorAwareRule` Interface, which allows us to inject the Validator into the Rule.

```php
<?php

declare(strict_types=1);

namespace App\Http\Rules;

use Illuminate\Contracts\Validation\InvokableRule;
use Illuminate\Contracts\Validation\ValidatorAwareRule;
use Illuminate\Support\Facades\Validator as ValidatorFacade;
use Illuminate\Validation\Validator;

class ItemRule implements InvokableRule, ValidatorAwareRule
{
    protected Validator $validator;

    public function __invoke($attribute, $value, $fail): void
    {
        // 1. fix attribute name
        $attributeNames = collect($this->rules($value))->keys()
            ->mapWithKeys(fn (string $key) => [$key => $attribute . '.' . $key])
            ->toArray();

        $validator = ValidatorFacade::make($value, $this->rules($value), $this->messages())
            ->setAttributeNames($attributeNames);

        // 2. The errors will be added to the parent validator.
        foreach ($validator->errors()->getMessages() as $key => $message) {
            $this->validator->getMessageBag()->add($attribute . '.' . $key, $message[0] ?? 'Validation failed');
        }
    }

    public function setValidator($validator): static
    {
        $this->validator = $validator;

        return $this;
    }

    protected function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:100'],
            'description' => ['nullable', 'string', 'min:2', 'max:100'],
            'price' => ['required', 'numeric', 'min:0', 'max:1000'],
            'amount' => ['required', 'integer', 'min:1', 'max:100'],
        ];
    }
    protected function messages(): array
    {
        return [];
    }
}
```

### Fixing the problems of Validations in Rules

1. Fixing the Attribute name

Prefixing the attribute names will cause the error message to correctly display the path, e.g. "The items.0.name field
is required" instead of "The name field is required".

BUT, this will not work if Rule again includes a nested Rule, as the attribute name will need to be prefixed again.
Assuming that the array separator `.` is used, the contained attribute can be prefixed again.
This code is not even close to a readable, good solution; if you have a better idea, please let me know.

```php
// The errors will be added to the parent validator.
foreach ($validator->errors()->getMessages() as $key => $message) {
   $newMessage = is_array($message) ? $message[0] : $message;

   // If the rule is nested, we need to replace the {key} placeholder with the parent key.
   if (str_contains((string) $newMessage, (string) $key) && str_contains((string) $key, '.')) {
       $newMessage = str_replace($key, $attribute . '.' . $key, (string) $newMessage);
   }

   $this->validator->getMessageBag()->add($attribute . '.' . $key, $newMessage);
}
```

2. Fixing the Error Bag

The errors will be added to the parent validator, so both the messages and the errors will not be empty. Mind
that I only add the first error message.

Conveniently, the Validators will bubble their ErrorBags up, so this allows for recursive usage of nested Rules.

3. Fixing the Rules

Because this is an array (I suppose), this works just fine without adding the rules to the original Validator. In other
cases code like this might be helpful:

```php
  // The rules will be added to the parent validator to access the attributes using e.g. $request->safe('key)
  $newRules = collect($validator->getRules())
      ->mapWithKeys(fn ($rules, $key) => [$attribute . '.' . $key => $rules])
      ->toArray();

  $this->validator->addRules($newRules);
```

4. Fixing the Dependent Rule messages

This will work with the fix of 1.

### Recursive Rules

{{< alert "circle-info" >}} **New Feature Unlocked**:
For the validation of recursive data structures - this is one implementation idea.
Adding a private property of the current nesting level to the Rule and incrementing it on each call of the Rule will
enable the validation of the whole data without too much extra code, and enforce changing maximum nesting levels.
{{< /alert >}}

Example for nesting:

 ```php
 public function rules(): array
 {
     return [
         'name' => ['required', 'string', 'min:2', 'max:100'],
         'description' => ['nullable', 'string', 'min:2', 'max:100'],
         'price' => ['required', 'numeric', 'min:0', 'max:1000'],
         'amount' => ['required', 'integer', 'min:1', 'max:100'],
         'subItems' => $this->currentNestingLevel >= 3 ? ['prohibited'] : ['nullable', 'array'],
         'subItems.*' => ['nullable', new self($this->currentNestingLevel + 1)],
     ];
 }
 ```

## Conclusion

If such a complex validation is needed, it might be a good idea to use a custom Rule.
If that custom Rule would benefit from implementing its own validation, this is possible with some workarounds.
If recursive validation is needed, this can be achieved by enhancing the Rule with a private property for the nesting
level.

If, on the other hand, the validation is not that complex, keep it simple.

Happy Coding :) 






