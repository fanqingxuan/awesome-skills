# Nginx Proxy

When webman needs to provide direct external access, it is recommended to add an nginx proxy in front of webman. This offers the following benefits:

- Static resources are handled by nginx, allowing webman to focus on business logic processing
- Multiple webman instances can share ports 80 and 443, distinguishing different sites by domain name, enabling multiple sites on a single server
- Allows php-fpm and webman architecture to coexist
- Nginx proxy SSL for https is simpler and more efficient
- Can strictly filter illegal requests from the external network

## Nginx Proxy Example
```
upstream webman {
    server 127.0.0.1:8787;
    keepalive 10240;
}

server {
  server_name site_domain;
  listen 80;
  access_log off;
  # Important: root must point to the public directory under webman, not the webman root directory
  root /your/webman/public;

  location / {
    try_files $uri @proxy;
  }

  location @proxy {
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_pass http://webman;
  }

  # Deny access to all files ending with .php
  location ~ \.php$ {
      return 404;
  }

  # Allow access to .well-known directory
  location ~ ^/\.well-known/ {
    allow all;
  }

  # Deny access to all files or directories starting with .
  location ~ /\. {
      return 404;
  }

}
```

Generally, developers only need to configure server_name and root with actual values; other fields do not need to be configured.

> **Note**
> It is especially important that the root option must point to the public directory under webman. Never set it to the webman root directory, otherwise all your files may be downloadable and accessible from the internet, including sensitive files such as database configuration.
