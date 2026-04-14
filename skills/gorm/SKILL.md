---
name: gorm
description: "GORM (Go ORM) development assistant. Use when the user needs to: (1) Create GORM models, (2) Define database schemas, (3) Perform CRUD operations, (4) Handle associations and relationships, (5) Write complex queries, (6) Implement migrations, (7) Use hooks and callbacks, (8) Query data, (9) Insert data, (10) Update data, (11) Delete data, (12) Create tables, (13) Modify tables, or any other GORM development tasks. Triggers on phrases like \"创建 GORM 模型\", \"数据库查询\", \"GORM 关联\", \"GORM 开发\", \"查询数据\", \"写入数据\", \"更新数据\", \"删除数据\", \"创建表\", \"修改表\", \"操作数据库\", \"create GORM model\", \"database query\", \"GORM associations\", \"query data\", \"insert data\", \"update data\", \"delete data\", \"create table\", \"modify table\"."
---

# GORM 开发指南

GORM 是 Go 语言最流行的 ORM 库，提供完整的数据库操作功能。

## ⚠️ 重要说明

**本 skill 专注于 GORM 的传统 API（Traditional API），不使用泛型方式。**

所有示例代码均使用传统的链式调用方式，确保与现有代码和 GORM 插件的完全兼容性。

### 传统 API vs 泛型 API

```go
// ✅ 使用传统 API（推荐）
var user User
db.Where("name = ?", "John").First(&user)
db.Create(&user)
db.Model(&user).Update("age", 30)

// ❌ 不使用泛型 API
// result := gorm.Query[User](db).Where("name = ?", "John").First()
```

## 快速开始

### 安装

```bash
go get -u gorm.io/gorm
go get -u gorm.io/driver/mysql
go get -u gorm.io/driver/postgres
go get -u gorm.io/driver/sqlite
```

### 连接数据库

```go
package main

import (
    "gorm.io/driver/mysql"
    "gorm.io/gorm"
)

func main() {
    // MySQL
    dsn := "user:password@tcp(127.0.0.1:3306)/dbname?charset=utf8mb4&parseTime=True&loc=Local"
    db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
    if err != nil {
        panic("failed to connect database")
    }

    // PostgreSQL
    // dsn := "host=localhost user=gorm password=gorm dbname=gorm port=9920 sslmode=disable"
    // db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

    // SQLite
    // db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
}
```

## 模型定义

### 基础模型

```go
type User struct {
    ID        uint           `gorm:"primaryKey"`
    Name      string         `gorm:"size:100;not null"`
    Email     string         `gorm:"uniqueIndex;size:100"`
    Age       int            `gorm:"default:0"`
    Birthday  *time.Time
    CreatedAt time.Time
    UpdatedAt time.Time
    DeletedAt gorm.DeletedAt `gorm:"index"`
}
```

### 使用 gorm.Model

```go
type User struct {
    gorm.Model
    Name  string
    Email string
}

// gorm.Model 包含:
// ID        uint
// CreatedAt time.Time
// UpdatedAt time.Time
// DeletedAt gorm.DeletedAt
```

### 字段标签

```go
type User struct {
    ID        uint      `gorm:"primaryKey"`
    Name      string    `gorm:"size:100;not null;index"`
    Email     string    `gorm:"uniqueIndex;size:100"`
    Age       int       `gorm:"default:18"`
    Active    bool      `gorm:"default:true"`
    Salary    float64   `gorm:"type:decimal(10,2)"`
    Profile   string    `gorm:"type:text"`
    Extra     string    `gorm:"-"` // 忽略该字段
}
```

## CRUD 操作

### 创建

```go
// 创建单条记录
user := User{Name: "John", Email: "john@example.com", Age: 30}
result := db.Create(&user)
// user.ID 返回插入数据的主键
// result.Error 返回错误
// result.RowsAffected 返回插入记录的条数

// 批量创建
users := []User{
    {Name: "John", Email: "john@example.com"},
    {Name: "Jane", Email: "jane@example.com"},
}
db.Create(&users)

// 使用 Map 创建
db.Model(&User{}).Create(map[string]interface{}{
    "Name": "John",
    "Age":  30,
})
```

### 查询

```go
// 获取第一条记录
var user User
db.First(&user)
// SELECT * FROM users ORDER BY id LIMIT 1;

// 获取最后一条记录
db.Last(&user)

// 根据主键查询
db.First(&user, 10)
// SELECT * FROM users WHERE id = 10;

// 查询所有记录
var users []User
db.Find(&users)

// 条件查询
db.Where("name = ?", "John").First(&user)
db.Where("name = ? AND age >= ?", "John", 20).Find(&users)
db.Where("name IN ?", []string{"John", "Jane"}).Find(&users)
db.Where("name LIKE ?", "%john%").Find(&users)

// Struct 条件
db.Where(&User{Name: "John", Age: 20}).First(&user)

// Map 条件
db.Where(map[string]interface{}{"name": "John", "age": 20}).Find(&users)

// Not 条件
db.Not("name = ?", "John").Find(&users)

// Or 条件
db.Where("name = ?", "John").Or("name = ?", "Jane").Find(&users)

// 选择特定字段
db.Select("name", "age").Find(&users)

// 排序
db.Order("age desc, name").Find(&users)

// 限制和偏移
db.Limit(10).Offset(5).Find(&users)

// 分组和聚合
db.Model(&User{}).Select("name, sum(age) as total").Group("name").Having("total > ?", 100).Find(&results)
```

### 更新

```go
// 更新单个字段
db.Model(&user).Update("name", "John Doe")

// 更新多个字段
db.Model(&user).Updates(User{Name: "John", Age: 30})
db.Model(&user).Updates(map[string]interface{}{"name": "John", "age": 30})

// 更新选定字段
db.Model(&user).Select("name").Updates(map[string]interface{}{"name": "John", "age": 30})
// 只更新 name

// 批量更新
db.Model(&User{}).Where("active = ?", true).Update("name", "hello")

// 使用表达式更新
db.Model(&User{}).Update("age", gorm.Expr("age + ?", 1))
```

### 删除

```go
// 删除记录
db.Delete(&user)
// DELETE FROM users WHERE id = 10;

// 根据主键删除
db.Delete(&User{}, 10)
db.Delete(&User{}, []int{1, 2, 3})

// 批量删除
db.Where("name = ?", "John").Delete(&User{})

// 软删除（需要 DeletedAt 字段）
db.Delete(&user)
// UPDATE users SET deleted_at = '当前时间' WHERE id = 10;

// 永久删除
db.Unscoped().Delete(&user)

// 查询包含软删除的记录
db.Unscoped().Where("age = ?", 20).Find(&users)
```

## 关联关系

### Belongs To

```go
type User struct {
    gorm.Model
    Name      string
    CompanyID int
    Company   Company
}

type Company struct {
    gorm.Model
    Name string
}

// 查询时预加载
db.Preload("Company").Find(&users)
```

### Has One

```go
type User struct {
    gorm.Model
    Name    string
    Profile Profile
}

type Profile struct {
    gorm.Model
    UserID uint
    Bio    string
}

// 预加载
db.Preload("Profile").Find(&users)
```

### Has Many

```go
type User struct {
    gorm.Model
    Name   string
    Orders []Order
}

type Order struct {
    gorm.Model
    UserID uint
    Amount float64
}

// 预加载
db.Preload("Orders").Find(&users)
```

### Many To Many

```go
type User struct {
    gorm.Model
    Name  string
    Roles []Role `gorm:"many2many:user_roles;"`
}

type Role struct {
    gorm.Model
    Name  string
    Users []User `gorm:"many2many:user_roles;"`
}

// 预加载
db.Preload("Roles").Find(&users)

// 添加关联
db.Model(&user).Association("Roles").Append(&role)

// 删除关联
db.Model(&user).Association("Roles").Delete(&role)

// 清空关联
db.Model(&user).Association("Roles").Clear()
```

## 高级查询

### 子查询

```go
db.Where("amount > (?)", db.Table("orders").Select("AVG(amount)")).Find(&orders)
```

### 原生 SQL

```go
// 原生查询
db.Raw("SELECT name, age FROM users WHERE name = ?", "John").Scan(&result)

// 执行原生 SQL
db.Exec("UPDATE users SET age = ? WHERE name = ?", 30, "John")
```

### 事务

```go
// 自动事务
db.Transaction(func(tx *gorm.DB) error {
    if err := tx.Create(&user).Error; err != nil {
        return err
    }
    if err := tx.Create(&order).Error; err != nil {
        return err
    }
    return nil
})

// 手动事务
tx := db.Begin()
defer func() {
    if r := recover(); r != nil {
        tx.Rollback()
    }
}()

if err := tx.Create(&user).Error; err != nil {
    tx.Rollback()
    return err
}

if err := tx.Create(&order).Error; err != nil {
    tx.Rollback()
    return err
}

tx.Commit()
```

## Hooks

```go
func (u *User) BeforeCreate(tx *gorm.DB) error {
    // 创建前执行
    u.UUID = uuid.New()
    return nil
}

func (u *User) AfterCreate(tx *gorm.DB) error {
    // 创建后执行
    return nil
}

func (u *User) BeforeUpdate(tx *gorm.DB) error {
    // 更新前执行
    return nil
}

func (u *User) AfterUpdate(tx *gorm.DB) error {
    // 更新后执行
    return nil
}

func (u *User) BeforeDelete(tx *gorm.DB) error {
    // 删除前执行
    return nil
}

func (u *User) AfterDelete(tx *gorm.DB) error {
    // 删除后执行
    return nil
}

func (u *User) AfterFind(tx *gorm.DB) error {
    // 查询后执行
    return nil
}
```

## 迁移

```go
// 自动迁移
db.AutoMigrate(&User{}, &Order{}, &Company{})

// 检查表是否存在
db.Migrator().HasTable(&User{})

// 创建表
db.Migrator().CreateTable(&User{})

// 删除表
db.Migrator().DropTable(&User{})

// 重命名表
db.Migrator().RenameTable(&User{}, &UserInfo{})

// 添加列
db.Migrator().AddColumn(&User{}, "Age")

// 删除列
db.Migrator().DropColumn(&User{}, "Age")

// 修改列
db.Migrator().AlterColumn(&User{}, "Age")

// 创建索引
db.Migrator().CreateIndex(&User{}, "Email")

// 删除索引
db.Migrator().DropIndex(&User{}, "Email")
```

## 最佳实践

1. **使用连接池**：配置合适的连接池参数
2. **预加载关联**：避免 N+1 查询问题
3. **使用事务**：保证数据一致性
4. **软删除**：使用 DeletedAt 字段
5. **索引优化**：为常用查询字段添加索引
6. **批量操作**：使用批量插入/更新提升性能
7. **错误处理**：始终检查 Error 返回值
8. **使用 Context**：支持超时和取消操作

## 官方文档参考

详细文档请参考 `references/` 目录下的官方文档。
