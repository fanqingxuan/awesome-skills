# Configuration File

Plugin configuration works the same as in a standard webman project, but plugin configuration generally only applies to the current plugin and does not affect the main project.
For example, the value of `plugin.foo.app.controller_suffix` only affects the plugin's controller suffix, and has no effect on the main project.
For example, the value of `plugin.foo.app.controller_reuse` only affects whether the plugin reuses controllers, and has no effect on the main project.
For example, the value of `plugin.foo.middleware` only affects the plugin's middleware, and has no effect on the main project.
For example, the value of `plugin.foo.view` only affects the views used by the plugin, and has no effect on the main project.
For example, the value of `plugin.foo.container` only affects the container used by the plugin, and has no effect on the main project.
For example, the value of `plugin.foo.exception` only affects the plugin's exception handling class, and has no effect on the main project.

However, because routing is global, the routes configured by a plugin also affect the global routing.

## Retrieving Configuration
To retrieve a plugin's configuration, use `config('plugin.{plugin}.{specific_config}');`. For example, to retrieve all configuration from `plugin/foo/config/app.php`, use `config('plugin.foo.app')`.
Likewise, the main project or other plugins can use `config('plugin.foo.xxx')` to retrieve the foo plugin's configuration.

## Unsupported Configuration
Application plugins do not support the `server.php` and `session.php` configurations, nor do they support the `app.request_class`, `app.public_path`, and `app.runtime_path` configurations.
