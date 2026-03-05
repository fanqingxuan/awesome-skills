# Awesome Skills

Agent Skills for PHP framework development with best practices and coding standards.

**License**: MIT | **Agent Skills**

## 📚 Overview

This repository provides Agent Skills for building modern PHP applications with:

- **Framework Support** - Hyperf 3.1 and Webman framework
- **Best Practices** - Industry-standard patterns and conventions
- **Memory Safety** - Guidelines for long-running process frameworks
- **Quick Development** - Code generation and common patterns

## 🚀 Installation

### Using npx (Recommended)

```bash
# Install Hyperf skill
npx skills add https://github.com/fanqingxuan/awesome-skills --skill hyperf

# Install Webman skill
npx skills add https://github.com/fanqingxuan/awesome-skills --skill webman
```

### Using Claude Code Marketplace

```bash
/plugin marketplace add fanqingxuan/awesome-skills
/plugin install hyperf@awesome-skills
/plugin install webman@awesome-skills
```

## 📦 Available Skills

### hyperf

**Description**: Hyperf 3.1 framework development assistant for building high-performance microservices.

**When to use**:
- Creating Hyperf controllers, models, commands
- Implementing services and dependency injection
- Configuring routes and middleware
- Working with async/coroutine features

**Coverage**:
- ✅ Controllers & Routes
- ✅ Models & Database
- ✅ Commands & Services
- ✅ Middleware & Validation
- ✅ Dependency Injection

**Triggers**: "创建 Hyperf 控制器", "生成模型", "创建命令", "Hyperf 开发"

---

### webman

**Description**: Webman framework development assistant for building fast and simple web applications.

**When to use**:
- Creating Webman controllers, models, routes
- Implementing middleware and services
- Handling validation and responses
- Avoiding memory leaks in long-running processes

**Coverage**:
- ✅ Controllers & Routes
- ✅ Models & Database
- ✅ Middleware & Services
- ✅ Validation & Responses
- ✅ Memory Leak Prevention

**Triggers**: "创建 Webman 控制器", "生成模型", "配置路由", "Webman 开发"

## 🎯 Usage

### Automatic Activation

Skills are automatically activated when working with respective framework projects. The AI will apply these rules when:

- Creating new controllers, services, or models
- Configuring routes and middleware
- Implementing business logic
- Reviewing code structure

### Explicit Activation

For best results, prefix your prompt:

```
use hyperf skill

Create a User controller with CRUD operations
```

```
use webman skill

Create an authentication middleware
```

## 📖 Documentation

### Hyperf

Complete Hyperf 3.1 documentation available in `skills/hyperf/references/zh-cn/`:

- Controllers: `controller.md`
- Models: `db/model.md`
- Commands: `command.md`
- Routes: `router.md`
- Validation: `validation.md`
- Dependency Injection: `di.md`

### Webman

Complete Webman documentation available in `skills/webman/references/zh-cn/`:

- Memory Management: `others/memory-leak.md`
- And more...

## ⚠️ Important Notes

### Memory Leak Prevention (Webman & Hyperf)

Both frameworks are long-running process frameworks. Avoid:

1. **Infinite static arrays**
   ```php
   // ❌ Bad
   public static $data = [];
   self::$data[] = $value; // Grows infinitely
   ```

2. **Singleton with growing arrays**
   ```php
   // ❌ Bad
   Cache::instance()->set(time(), $value); // Unlimited keys
   ```

3. **Global arrays**
   ```php
   // ❌ Bad
   global $data;
   $data[] = $value; // Never cleaned
   ```

**Solution**: Use local variables, Redis/Memcached, or limit array sizes.

## 🛠️ Development

See `AGENTS.md` for guidelines on contributing new skills and reference files.

### Quick Start

1. Clone the repository
2. Add new skill directory in `skills/`
3. Create `SKILL.md` with proper YAML frontmatter
4. Add reference documentation in `references/`
5. Test with `npx skills add`

### SKILL.md Format

```yaml
---
name: skill-name
description: "Skill description with proper quoting for colons: like this"
---

# Skill Content
...
```

## 📄 License

MIT License - see LICENSE file for details.

## 🔗 Related Resources

- [Hyperf Official Documentation](https://hyperf.wiki/)
- [Webman Official Documentation](https://www.workerman.net/doc/webman/)
- [Agent Skills Specification](https://github.com/anthropics/claude-code)
- [PHP The Right Way](https://phptherightway.com/)

---

**Version**: 1.0.0
**Last Updated**: 2026-03-05
