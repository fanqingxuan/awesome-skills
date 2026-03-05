# Directory Structure

```
plugin/
└── foo
    ├── app
    │   ├── controller
    │   │   └── IndexController.php
    │   ├── exception
    │   │   └── Handler.php
    │   ├── functions.php
    │   ├── middleware
    │   ├── model
    │   └── view
    │       └── index
    │           └── index.html
    ├── config
    │   ├── app.php
    │   ├── autoload.php
    │   ├── container.php
    │   ├── database.php
    │   ├── exception.php
    │   ├── log.php
    │   ├── middleware.php
    │   ├── process.php
    │   ├── redis.php
    │   ├── route.php
    │   ├── static.php
    │   ├── thinkorm.php
    │   ├── translation.php
    │   └── view.php
    ├── public
    └── api
```

An application plugin has the same directory structure and configuration files as webman. In practice, the development experience is virtually identical to developing a regular webman application.

Plugin directories and naming follow the PSR-4 specification. Since plugins are placed in the `plugin` directory, all namespaces begin with `plugin`, for example `plugin\foo\app\controller\UserController`.

## About the api Directory

Each plugin has an `api` directory. If your application provides internal interfaces for other applications to call, place those interfaces in the `api` directory.

Note: the interfaces referred to here are function-call interfaces, not network/HTTP interfaces.

For example, the email plugin provides an `Email::send()` interface at `plugin/email/api/Email.php` for other applications to call when sending emails. Additionally, `plugin/email/api/Install.php` is auto-generated for the webman-admin plugin market to execute install or uninstall operations.
