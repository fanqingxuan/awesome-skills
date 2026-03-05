# Proper Use of Database Transactions

Using database transactions in webman is the same as in other frameworks. Here are the key points to note.

## Code Structure

The code structure is the same as in other frameworks (e.g., Laravel usage, think-orm is similar):

```php
Db::beginTransaction();
try {
    // ..business logic omitted...
    
    Db::commit();
} catch (\Throwable $exception) {
    Db::rollBack();
}
```

**Important:** You **must** use `\Throwable` and **must not** use `\Exception`, because business logic may trigger `Error`, which does not extend `Exception`.

## Database Connection

When operating on models within a transaction, pay special attention to whether the model has a connection configured. If the model specifies a connection, you must specify that connection when starting the transaction; otherwise the transaction will not work (think-orm is similar). For example:

```php
<?php

namespace app\model;
use support\Model;

class User extends Model
{

    // Connection specified for the model
    protected $connection = 'mysql';

    protected $table = 'users';

    protected $primaryKey = 'id';

}
```

When the model specifies a connection, you must specify the connection for begin, commit, and rollback:

```php
Db::connection('mysql')->beginTransaction();
try {
    // Business logic
    $user = new User;
    $user->name = 'webman';
    $user->save();
    Db::connection('mysql')->commit();
} catch (\Throwable $exception) {
    Db::connection('mysql')->rollBack();
}
```

## Finding Requests with Uncommitted Transactions

Sometimes a bug in business code causes a transaction to remain uncommitted. To quickly locate which controller method has an uncommitted transaction, you can install the `webman/log` component. After each request completes, it automatically checks for uncommitted transactions and logs them. The log keyword is `Uncommitted transactions`.

**Installing webman/log**

`composer require webman/log`

> **Note**
> You must **restart** after installation; reload will not take effect.
