# Installation

There are two ways to install application plugins:

## Install from plugin market
Go to the [official webman-admin management panel](https://www.workerman.net/plugin/82), open the application plugin page and click the install button to install the corresponding application plugin.

## Install from source package
Download the application plugin archive from the application market, extract it and upload the extracted directory to `{main project}/plugin/` (create the plugin directory manually if it does not exist). Run `php webman app-plugin:install plugin-name` to complete the installation.

For example, if the downloaded archive is named ai.zip, extract it to `{main project}/plugin/ai` and run `php webman app-plugin:install ai` to complete the installation.


# Uninstallation

There are also two ways to uninstall application plugins:

## Uninstall from plugin market
Go to the [official webman-admin management panel](https://www.workerman.net/plugin/82), open the application plugin page and click the uninstall button to uninstall the corresponding application plugin.

## Uninstall from source package
Run `php webman app-plugin:uninstall plugin-name` to complete uninstallation. After that, manually delete the corresponding plugin directory under `{main project}/plugin/`.
