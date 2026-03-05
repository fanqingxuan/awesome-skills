# Directory structure
```
.
├── app                           Application directory
│   ├── controller                Controller directory
│   ├── model                     Model directory
│   ├── view                      View directory
│   ├── middleware                Middleware directory
│   │   └── StaticFile.php        Built-in static file middleware
│   ├── process                   Custom process directory
│   │   ├── Http.php              Http process
│   │   └── Monitor.php           Monitor process
│   └── functions.php             Business custom functions are written here
├── config                        Configuration directory
│   ├── app.php                   Application configuration
│   ├── autoload.php              Files configured here will be automatically loaded
│   ├── bootstrap.php             Callback configuration that runs on onWorkerStart when the process starts
│   ├── container.php             Container configuration
│   ├── dependence.php            Container dependency configuration
│   ├── database.php              Database configuration
│   ├── exception.php             Exception configuration
│   ├── log.php                   Log configuration
│   ├── middleware.php            Middleware configuration
│   ├── process.php               Custom process configuration
│   ├── redis.php                 Redis configuration
│   ├── route.php                 Route configuration
│   ├── server.php                Server configuration (ports, number of processes, etc.)
│   ├── view.php                  View configuration
│   ├── static.php                Static file switch and static file middleware configuration
│   ├── translation.php           Multilingual configuration
│   └── session.php               Session configuration
├── public                        Static resource directory
├── runtime                       Application runtime directory, requires write permission
├── start.php                     Service start file
├── vendor                        Directory for third-party libraries installed by Composer
└── support                       Library adaptation (including third-party libraries)
    ├── Request.php               Request class
    ├── Response.php              Response class
    ├── Setup.php                 Installation wizard script
    └── bootstrap.php             Initialization script after process startup
```
