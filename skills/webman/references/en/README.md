# What is webman

Webman is a high-performance service framework built on Workerman, integrating HTTP, WebSocket, TCP, UDP, and other modules. Through advanced technologies such as resident memory, coroutines, and connection pools, Webman not only breaks through the performance bottlenecks of traditional PHP but also greatly expands its application scenarios.

In addition, Webman provides a powerful plugin mechanism that enables developers to quickly integrate and reuse functional modules developed by other developers. Whether building websites, developing HTTP APIs, implementing instant messaging, building IoT systems, or developing games, TCP/UDP services, Unix Socket services, and more, Webman handles all of these effortlessly with outstanding performance and flexibility.

# Philosophy of webman

**Maximum extensibility and performance with a minimal core.**

Webman provides only the most essential features (routing, middleware, session, custom process interface). All other functionality is reused from the Composer ecosystem, which means you can use the most familiar components in webman. For databases, developers can choose Laravel's [illuminate/database](./db/tutorial.md), ThinkPHP's [ThinkORM](./db/thinkorm.md), or other components like `Medoo`. Integrating them into webman is straightforward.

# Key Features of webman

1. **High Stability.** Webman is based on Workerman, which has consistently been an industry-leading socket framework with minimal bugs and high stability.

2. **Ultra-High Performance.** Webman performs 10–100x better than traditional PHP-FPM frameworks and roughly 2x better than Go frameworks such as Gin and Echo.

3. **High Reusability.** No modification needed—you can reuse the existing Composer ecosystem as-is.

4. **High Extensibility.** Supports custom processes, so it can do anything Workerman can do.

5. **Super Simple and Easy to Use.** Very low learning curve, with code style identical to traditional frameworks.

6. **Supports [Binary Packaging](./others/bin.md).** Can run directly without a PHP environment.

7. **Released under the MIT License.** The most permissive and developer-friendly open source license.

# Project Links

GitHub: https://github.com/walkor/webman **Don't hesitate to give it a star!**

Gitee: https://gitee.com/walkor/webman **Don't hesitate to give it a star!**

# Third-Party Authoritative Benchmark Data

[![](../assets/img/benchmark1.png)](https://www.techempower.com/benchmarks/#section=data-r20&hw=ph&test=db&l=zik073-sf)

With database query workloads, Webman achieves 390,000 QPS on a single machine, nearly 80x higher than the Laravel framework on traditional PHP-FPM architecture.

[![](../assets/img/benchmarks-go.png)](https://www.techempower.com/benchmarks/#section=data-r20&hw=ph&test=db&l=zik073-sf)

With database query workloads, Webman performs roughly twice as well as comparable Go web frameworks.

The above data is from [techempower.com](https://www.techempower.com/benchmarks/#section=data-r20&hw=ph&test=db&l=zik073-sf).
