# WeChat SDK

## Project URL

https://github.com/w7corp/easywechat
  
## Installation
 
```php
composer require w7corp/easywechat
```
  
## Usage

**config/wechat.php**

```php
<?php
return [
    /**
     * Account basic information. Obtain from WeChat Official Platform / Open Platform
     */
    'app_id'  => 'your-app-id',         // AppID
    'secret'  => 'your-app-secret',     // AppSecret
    'token'   => 'your-token',          // Token
    'aes_key' => '',                    // EncodingAESKey - MUST be filled in compatibility and security modes!!!

    /**
     * Whether to use Stable Access Token
     * Default: false
     * https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/getStableAccessToken.html
     * true = use, false = do not use
     */
    'use_stable_access_token' => false,

    /**
     * OAuth configuration
     *
     * scopes: Official Platform (snsapi_userinfo / snsapi_base), Open Platform: snsapi_login
     * redirect_url: Callback URL after OAuth authorization
     */
    'oauth' => [
        'scopes'   => ['snsapi_userinfo'],
        'redirect_url' => '/examples/oauth_callback.php',
    ],

    /**
     * HTTP request configuration (timeout, etc.). For available parameters, see:
     * https://github.com/symfony/symfony/blob/5.3/src/Symfony/Contracts/HttpClient/HttpClientInterface.php
     */
    'http' => [
        'timeout' => 5.0,
        // 'base_uri' => 'https://api.weixin.qq.com/', // Only use when you need to override the default URL (e.g. from abroad). Configure different URIs for different modules.

        'retry' => true, // Use default retry configuration
        //  'retry' => [
        //      // Retry only for the following status codes
        //      'status_codes' => [429, 500]
        //       // Maximum retry count
        //      'max_retries' => 3,
        //      // Request interval (milliseconds)
        //      'delay' => 1000,
        //      // If set, each retry wait time will be multiplied by this factor
        //      // (e.g. First: 1000ms; Second: 3 * 1000ms; etc.)
        //      'multiplier' => 3
        //  ],
    ],
];
```


**app\controller\OfficialAccount.php**

```php
<?php

namespace app\controller;

use EasyWeChat\OfficialAccount\Application;
use support\Request;
use Symfony\Component\HttpFoundation\HeaderBag;
use Symfony\Component\HttpFoundation\Request as SymfonyRequest;

// Authorization event callback URL: http://easywechat.com/OfficialAccount/server

class OfficialAccount
{
    public function server(Request $request)
    {
        $config = config('wechat');
        $app = new Application($config);
        $symfony_request = new SymfonyRequest($request->get(), $request->post(), [], $request->cookie(), [], [], $request->rawBody());
        $symfony_request->headers = new HeaderBag($request->header());
        $app->setRequestFromSymfonyRequest($symfony_request);//Must replace server request
        $server = $app->getServer();
        $response = $server->serve();

        return response($response->getBody()->getContents(), $response->getStatusCode(), $response->getHeaders());
    }
}
```
  
  
## More Information

Visit https://easywechat.com/6.x/official-account/examples.html

