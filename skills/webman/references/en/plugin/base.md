# Basic Plugins

Basic plugins are generally common components that are typically installed via Composer, with code placed under the vendor directory. During installation, custom configurations (middleware, processes, routes, etc.) can be automatically copied to the `{main project}config/plugin` directory. Webman will automatically recognize the configuration in this directory and merge it into the main configuration, allowing plugins to intervene in any phase of webman's lifecycle.

For more, refer to [Creating Basic Plugins](create.md).
