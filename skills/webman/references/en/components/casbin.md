# Casbin

## Introduction

Casbin is a powerful and efficient open-source access control framework. Its permission management mechanism supports multiple access control models.

## Project Address

https://github.com/teamones-open/casbin

## Installation

```php
composer require teamones/casbin
```

## Casbin Official Website

For detailed usage, please refer to the official Chinese documentation. This document only covers how to configure and use Casbin in webman.

https://casbin.org/docs/zh-CN/overview

## Directory Structure

```
.
├── config                        Configuration directory
│   ├── casbin-restful-model.conf Configuration file for the permission model
│   ├── casbin.php                Casbin configuration
......
├── database                      Database files
│   ├── migrations                Migration files
│   │   └── 20210218074218_create_rule_table.php
......
```

## Database Migration File

```php
<?php

use Phinx\Migration\AbstractMigration;

class CreateRuleTable extends AbstractMigration
{
    /**
     * Change Method.
     *
     * Write your reversible migrations using this method.
     *
     * More information on writing migrations is available here:
     * http://docs.phinx.org/en/latest/migrations.html#the-abstractmigration-class
     *
     * The following commands can be used in this method and Phinx will
     * automatically reverse them when rolling back:
     *
     *    createTable
     *    renameTable
     *    addColumn
     *    addCustomColumn
     *    renameColumn
     *    addIndex
     *    addForeignKey
     *
     * Any other destructive changes will result in an error when trying to
     * rollback the migration.
     *
     * Remember to call "create()" or "update()" and NOT "save()" when working
     * with the Table class.
     */
    public function change()
    {
        $table = $this->table('rule', ['id' => false, 'primary_key' => ['id'], 'engine' => 'InnoDB', 'collation' => 'utf8mb4_general_ci', 'comment' => 'Rule table']);

        // Add data fields
        $table->addColumn('id', 'integer', ['identity' => true, 'signed' => false, 'limit' => 11, 'comment' => 'Primary key ID'])
            ->addColumn('ptype', 'char', ['default' => '', 'limit' => 8, 'comment' => 'Rule type'])
            ->addColumn('v0', 'string', ['default' => '', 'limit' => 128])
            ->addColumn('v1', 'string', ['default' => '', 'limit' => 128])
            ->addColumn('v2', 'string', ['default' => '', 'limit' => 128])
            ->addColumn('v3', 'string', ['default' => '', 'limit' => 128])
            ->addColumn('v4', 'string', ['default' => '', 'limit' => 128])
            ->addColumn('v5', 'string', ['default' => '', 'limit' => 128]);

        // Execute creation
        $table->create();
    }
}
```

## Casbin Configuration

For permission rule model configuration syntax, see: https://casbin.org/docs/zh-CN/syntax-for-models

```php
<?php

return [
    'default' => [
        'model' => [
            'config_type' => 'file',
            'config_file_path' => config_path() . '/casbin-restful-model.conf', // Permission rule model configuration file
            'config_text' => '',
        ],
        'adapter' => [
            'type' => 'model', // model or adapter
            'class' => \app\model\Rule::class,
        ],
    ],
    // Multiple permission models can be configured
    'rbac' => [
        'model' => [
            'config_type' => 'file',
            'config_file_path' => config_path() . '/casbin-rbac-model.conf', // Permission rule model configuration file
            'config_text' => '',
        ],
        'adapter' => [
            'type' => 'model', // model or adapter
            'class' => \app\model\RBACRule::class,
        ],
    ],
];
```

### Adapter

The current composer package adapts to the model methods of think-orm. For other ORMs, please refer to vendor/teamones/src/adapters/DatabaseAdapter.php

Then modify the configuration:

```php
return [
    'default' => [
        'model' => [
            'config_type' => 'file',
            'config_file_path' => config_path() . '/casbin-restful-model.conf', // Permission rule model configuration file
            'config_text' => '',
        ],
        'adapter' => [
            'type' => 'adapter', // Configure type as adapter mode here
            'class' => \app\adapter\DatabaseAdapter::class,
        ],
    ],
];
```

## Usage Instructions

### Import

```php
# Import
use teamones\casbin\Enforcer;
```

### Two Usage Methods

```php
# 1. Use default configuration
Enforcer::addPermissionForUser('user1', '/user', 'read');

# 2. Use custom rbac configuration
Enforcer::instance('rbac')->addPermissionForUser('user1', '/user', 'read');
```

### Common API Introduction

For more API usage, please refer to the official documentation:

- Management API: https://casbin.org/docs/zh-CN/management-api
- RBAC API: https://casbin.org/docs/zh-CN/rbac-api

```php
# Add permission for user

Enforcer::addPermissionForUser('user1', '/user', 'read');

# Delete permission for user

Enforcer::deletePermissionForUser('user1', '/user', 'read');

# Get all permissions for user

Enforcer::getPermissionsForUser('user1');

# Add role for user

Enforcer::addRoleForUser('user1', 'role1');

# Add permission for role

Enforcer::addPermissionForUser('role1', '/user', 'edit');

# Get all roles

Enforcer::getAllRoles();

# Get all roles for user

Enforcer::getRolesForUser('user1');

# Get users by role

Enforcer::getUsersForRole('role1');

# Check if user belongs to a role

Enforcer::hasRoleForUser('user1', 'role1');

# Delete user role

Enforcer::deleteRoleForUser('user1', 'role1');

# Delete all roles for user

Enforcer::deleteRolesForUser('user1');

# Delete role

Enforcer::deleteRole('role1');

# Delete permission

Enforcer::deletePermission('/user', 'read');

# Delete all permissions for user or role

Enforcer::deletePermissionsForUser('user1');
Enforcer::deletePermissionsForUser('role1');

# Check permission, returns true or false

Enforcer::enforce("user1", "/user", "edit");
```
