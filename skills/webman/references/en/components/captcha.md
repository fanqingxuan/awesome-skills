# Captcha Component

Project address https://github.com/webman-php/captcha

## Installation
```
composer require webman/captcha
```

## Usage

**Create file `app/controller/LoginController.php`**

```php
<?php
namespace app\controller;

use support\Request;
use Webman\Captcha\CaptchaBuilder;

class LoginController
{
    /**
     * Test page
     */
    public function index(Request $request)
    {
        return view('login/index');
    }
    
    /**
     * Output captcha image
     */
    public function captcha(Request $request)
    {
        // Initialize captcha class
        $builder = new CaptchaBuilder;
        // Generate captcha
        $builder->build();
        // Store the value of the captcha in the session
        $request->session()->set('captcha', strtolower($builder->getPhrase()));
        // Get captcha image binary data
        $img_content = $builder->get();
        // Output captcha binary data
        return response($img_content, 200, ['Content-Type' => 'image/jpeg']);
    }

    /**
     * Check captcha
     */
    public function check(Request $request)
    {
        // Get the captcha field from the POST request
        $captcha = $request->post('captcha');
        // Compare with the captcha value in the session
        if (strtolower($captcha) !== $request->session()->get('captcha')) {
            return json(['code' => 400, 'msg' => 'The captcha entered is incorrect']);
        }
        return json(['code' => 0, 'msg' => 'ok']);
    }

}
```

**Create template file `app/view/login/index.html`**

```html
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Captcha Test</title>  
</head>
<body>
    <form method="post" action="/login/check">
       <img src="/login/captcha" /><br>
        <input type="text" name="captcha" />
        <input type="submit" value="Submit" />
    </form>
</body>
</html>
```

Enter the page `http://127.0.0.1:8787/login`, the interface will look similar to the following:
  ![](../../assets/img/captcha.png)

## Common Parameter Settings
```php
    /**
     * Output captcha image
     */
    public function captcha(Request $request)
    {
        $builder = new PhraseBuilder(4, 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ');
        $captcha = new CaptchaBuilder(null, $builder);
        $captcha->build();
        $request->session()->set('join', strtolower($captcha->getPhrase()));
        $img_content = $captcha->get();
        return response($img_content, 200, ['Content-Type' => 'image/jpeg']);
    }
```

For more interfaces and parameters, refer to https://github.com/webman-php/captcha
