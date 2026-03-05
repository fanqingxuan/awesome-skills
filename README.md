# Hyperf 3.1 开发技能

[![GitHub](https://img.shields.io/badge/GitHub-fanqingxuan%2Fhyperf--skill-blue)](https://github.com/fanqingxuan/hyperf-skill)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Hyperf 3.1 框架开发助手，专注于控制器、模型、命令行工具的快速开发。为 Claude Code 和其他 AI 编程助手提供 Hyperf 开发支持。

## 功能特性

- **快速生成代码** - 提供控制器、模型、命令行工具的生成指导
- **开发最佳实践** - 包含依赖注入、路由配置、验证器等核心概念
- **官方文档集成** - 完整的 Hyperf 3.1 官方中文文档
- **智能触发** - 自动识别 Hyperf 开发需求并提供帮助

## 安装

### 使用 npx skills（推荐）

```bash
npx skills add fanqingxuan/hyperf-skill
```

### 使用完整 URL

```bash
npx skills add https://github.com/fanqingxuan/hyperf-skill.git
```

### 手动安装

```bash
cd ~/.skills
git clone https://github.com/fanqingxuan/hyperf-skill.git fanqingxuan/hyperf-skill
```

## 使用场景

当你需要进行以下操作时，这个技能会自动触发：

- 创建 Hyperf 控制器
- 创建 Hyperf 模型
- 创建 Hyperf 命令行工具
- 实现服务层
- 配置路由
- 使用依赖注入
- 处理验证

## 触发关键词

- "创建 Hyperf 控制器"
- "生成模型"
- "创建命令"
- "Hyperf 开发"

## 快速开始

安装后，在 Claude Code 或支持 Agent Skills 的 AI 编程助手中，直接使用自然语言描述你的需求：

### 示例 1：创建控制器

```
你：创建一个用户管理的控制器
AI：使用 Hyperf 命令生成控制器...
```

```bash
php bin/hyperf.php gen:controller UserController
```

### 示例 2：创建模型

```
你：生成 User 模型
AI：使用 Hyperf 命令生成模型...
```

```bash
php bin/hyperf.php gen:model User
```

### 示例 3：创建命令

```
你：创建一个数据导入命令
AI：使用 Hyperf 命令生成命令行工具...
```

```bash
php bin/hyperf.php gen:command ImportDataCommand
```

## 支持的开发任务

- ✅ 创建 RESTful 控制器
- ✅ 创建数据库模型
- ✅ 创建命令行工具
- ✅ 实现服务层
- ✅ 配置路由
- ✅ 依赖注入
- ✅ 请求验证
- ✅ 中间件开发
- ✅ 异步队列
- ✅ 协程使用

## 文档结构

```
hyperf-skill/
├── skills/
│   └── hyperf-skill/
│       ├── SKILL.md              # 技能主文档
│       └── references/
│           └── zh-cn/            # Hyperf 官方中文文档
│               ├── controller.md
│               ├── db/
│               │   └── model.md
│               ├── command.md
│               ├── router.md
│               ├── validation.md
│               └── ...
├── LICENSE
└── README.md                     # 本文件
```

## 技能触发

这个技能会在以下情况自动触发：

- 用户说"创建 Hyperf 控制器"
- 用户说"生成模型"
- 用户说"创建命令"
- 用户说"Hyperf 开发"
- 任何涉及 Hyperf 3.1 框架开发的请求

## 版本要求

- **Hyperf 版本**: 3.1
- **PHP 版本**: 8.0+
- **Claude Code**: 最新版本

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 相关链接

- [Hyperf 官方文档](https://hyperf.wiki/)
- [Hyperf GitHub](https://github.com/hyperf/hyperf)
- [Claude Code](https://claude.ai/code)
- [Agent Skills 文档](https://github.com/anthropics/skills)

## 作者

[@fanqingxuan](https://github.com/fanqingxuan)

## 致谢

- Hyperf 团队提供的优秀框架
- Anthropic 提供的 Claude AI 和 Agent Skills 平台
