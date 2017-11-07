# Kitemetrics iOS Client SDK

<!-- [![CI Status](http://img.shields.io/travis/Kitefaster/Kitemetrics.svg?style=flat)](https://travis-ci.org/Kitefaster/Kitemetrics)
[![Version](https://img.shields.io/cocoapods/v/Kitemetrics.svg?style=flat)](http://cocoapods.org/pods/Kitemetrics)
[![License](https://img.shields.io/cocoapods/l/Kitemetrics.svg?style=flat)](http://cocoapods.org/pods/Kitemetrics)
[![Platform](https://img.shields.io/cocoapods/p/Kitemetrics.svg?style=flat)](http://cocoapods.org/pods/Kitemetrics) -->

The Kitemetrics iOS Client SDK automatically logs Apple Search Ads keyword attributions, installs, and user sessions. In addition, you can log sign up and other custom events.  Reports are available from [http://kitemetrics.com/](http://kitemetrics.com/?utm_source=github&utm_medium=readme&utm_campaign=cp).

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Example](#example)
- [Documentation](#documentation)
- [Notes](#notes)
- [License](#license)

## Requirements

- iOS 8.0+
- Xcode 9.0+
- Objective-C or Swift 4.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build Kitemetrics

To integrate Kitemetrics into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Kitemetrics'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually

If you do not want to use the CocoaPods dependency manager, you can integrate Kitemetrics into your project manually by copy/pasting the files into your project or by adding as a git submodule.

## Usage

#### Initialize the session in AppDelegate
##### Swift 4.0
```swift
import Kitemetrics

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      Kitemetrics.shared.initSession(apiKey: "API_KEY")
      return true
  }
```

##### Objective-C
```objective-c
@import Kitemetrics;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Kitemetrics shared] initSessionWithApiKey:@"API_KEY"];
    return YES;
}
```

#### Log Purchase Events
##### Swift 4.0
```swift
    Kitemetrics.shared.logInAppPurchase(skProduct, quantity: 1)
    //It is recommended to include the purchaseType if known
    Kitemetrics.shared.logInAppPurchase(skProduct, quantity: 1, purchaseType: KFPurchaseType.appleInAppNonConsumable)

    //If the SKProduct is unavailable you can log a purchase directly as
    Kitemetrics.shared.logPurchase(productIdentifier: "productId", price: Decimal(0.99), currencyCode: "USD", quantity: 1, purchaseType: .eCommerce)
```

##### Objective-C
```objective-c
    [[Kitemetrics shared] logInAppPurchase:skProduct quantity:1];
    //It is recommended to include the purchaseType if known
    [[Kitemetrics shared] logInAppPurchase:skProduct quantity:1 purchaseType:KFPurchaseTypeAppleInAppNonConsumable];

    //If the SKProduct is unavailable you can log a purchase directly as
    NSDecimal price = [[[NSDecimalNumber alloc] initWithFloat:0.99f] decimalValue];
    [[Kitemetrics shared] logPurchaseWithProductIdentifier:@"productId" price:price currencyCode:@"USD" quantity:1 purchaseType:KFPurchaseTypeECommerce];
```

Full list of pre-defined and custom events are available at the full [documentation](http://kitemetrics.com/docs/?utm_source=github&utm_medium=readme&utm_campaign=cp).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Documentation

Full documentation is available at [http://kitemetrics.com/docs/](http://kitemetrics.com/docs/?utm_source=github&utm_medium=readme&utm_campaign=cp).

## Notes

Kitemetrics uses the Advertising Identifier (IDFA).  When submitting an app to Apple you should answer "Yes" to the Advertising Identifier question and check the box next to "Attribute an action taken within this app to a previously served advertisement".

## License

The Kitemetrics iOS client SDK is available under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). See the LICENSE file for more info.
