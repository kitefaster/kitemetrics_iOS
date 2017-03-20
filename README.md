# Kitemetrics iOS Client SDK

<!-- [![CI Status](http://img.shields.io/travis/Kitefaster/Kitemetrics.svg?style=flat)](https://travis-ci.org/Kitefaster/Kitemetrics)
[![Version](https://img.shields.io/cocoapods/v/Kitemetrics.svg?style=flat)](http://cocoapods.org/pods/Kitemetrics)
[![License](https://img.shields.io/cocoapods/l/Kitemetrics.svg?style=flat)](http://cocoapods.org/pods/Kitemetrics)
[![Platform](https://img.shields.io/cocoapods/p/Kitemetrics.svg?style=flat)](http://cocoapods.org/pods/Kitemetrics) -->

The Kitemetrics iOS Client SDK logs user sessions, events and Apple Search Ads keyword attribution data over https and SSL to the Kitemetrics server.  Reports are available from http://kitemetrics.com/.

## Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Example](#example)
- [License](#license)

## Requirements

- iOS 8.0+  (iOS 7.0+ with manual install)
- Xcode 8.0+
- Objective-C or Swift 3.0+

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
    pod 'Kitemetrics', :git => 'git@github.com:kitefaster/kitemetrics_iOS.git', :branch => 'master'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually

If you want to support iOS 7 or prefer not to use the CocoaPods dependency manager, you can integrate Kitemetrics into your project manually by copy/pasting the files into your project or by adding as a git submodule.

## Usage

#### Initialize the session in AppDelegate.swift
##### Swift 3.0
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
    [[Kitemetrics shared] initSessionWithApiKey:@"API_KEY" userIdentifier:@""];
    return YES;
}
```

#### Log purchases and events
##### Swift 3.0
```swift
    Kitemetrics.shared.logAddToCart(skProduct, quantity: 1)
    Kitemetrics.shared.logPurchase(skProduct, quantity: 1)
    Kitemetrics.shared.logError("Test Error")
    Kitemetrics.shared.logEvent("Test Event")
    Kitemetrics.shared.logInvite(method: "Test Invite", code: "Test Code 001")
    Kitemetrics.shared.logSignUp(method: "Test User", userIdentifier: "Test User Id 001")
```

##### Objective-C
```objective-c
    [[Kitemetrics shared] logAddToCart:skProduct quantity:1];
    [[Kitemetrics shared] logPurchase:skProduct quantity:1];
    [[Kitemetrics shared] logError:@"Test Error"];
    [[Kitemetrics shared] logEvent:@"Test Event"];
    [[Kitemetrics shared] logInviteWithMethod:@"Test Invite" code: @"Test Code 001"];
    [[Kitemetrics shared] logSignUpWithMethod:@"Test User" userIdentifier:@"Test User Id 001"];
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License

The Kitemetrics iOS client SDK is available under the Apache License, Version 2.0. See the LICENSE file for more info.
