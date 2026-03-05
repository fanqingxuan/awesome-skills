# Packaging

For example, packaging the foo application plugin:

* Set the version number in `plugin/foo/config/app.php` (**important**)
* Delete any unnecessary files in `plugin/foo`, especially temporary files used for testing upload functionality under `plugin/foo/public`
* If your project includes database table creation and similar operations, configure `plugin/foo/install.sql` accordingly. See [Automatic Database Import](database.md#automatic-database-import)
* If your project has its own separate database and Redis configuration, remove these configurations first. They should be prompted through an installation wizard when the application is first accessed (you need to implement this yourself), allowing the administrator to fill them in manually and generate them.
* If your project includes webman admin backend menus, configure `plugin/foo/config/menu.php` so that these menus are automatically set when the plugin is installed. See [webman-admin import menus](https://www.workerman.net/doc/webman-admin/app-development/menu.html)
* Restore any other files that need to be restored to their original state
* After completing the above steps, go to the `{main project}/plugin/` directory
* Linux users: run `zip -r foo.zip foo` to generate foo.zip
* Windows users: right-click the foo folder and select "Compress to ZIP file" to generate foo.zip

**foo.zip is the packaged file. Refer to the next chapter [Publishing Plugin](publish.md)**
