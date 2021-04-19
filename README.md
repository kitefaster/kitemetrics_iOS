# Kitemetrics® iOS Client SDK

The Kitemetrics® iOS Client SDK automatically logs Apple Search Ads keyword attributions, installs, and user sessions. In addition, you can log other custom events and assign them to a KPI.  Reports are available from [http://kitemetrics.com/](http://kitemetrics.com/?utm_source=github&utm_medium=readme&utm_campaign=cp).

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

> CocoaPods 1.1.0+ is required to build the SDK

To integrate the SDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

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

also run the following update command to ensure you have the latest version:

```bash
$ pod update Kitemetrics
```

### Manually

If you do not want to use the CocoaPods dependency manager, you can integrate the SDK into your project manually by copy/pasting the files into your project or by adding as a git submodule.

## Usage

#### Initialize the session in AppDelegate
##### Swift 5.0
```swift
import Kitemetrics

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      Kitemetrics.shared.initSession(withApiKey: "API_KEY")
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

#### Attribute intsalls to Apple Search Ads

Kitemetrics will automatically attribute installs to Apple Search Ads.

However if your app requestes permission from the user to track via the `ATTrackingManager`, you can also get the clickDate by calling `Kitemetrics.shared.attributeWithTrackingAuthorization()` in the completion handler.

```swift
ATTrackingManager.requestTrackingAuthorization(completionHandler: {_ in Kitemetrics.shared.attributeWithTrackingAuthorization() })
```

#### Log Purchase Events

Kitemetrics will automatically log purchase events.

Full list of pre-defined and custom events are available at the full [documentation](http://kitemetrics.com/docs/?utm_source=github&utm_medium=readme&utm_campaign=cp).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Documentation

Full documentation is available at [http://kitemetrics.com/docs/](http://kitemetrics.com/docs/?utm_source=github&utm_medium=readme&utm_campaign=cp).

## Notes

The SDK uses the Advertising Identifier (IDFA).  When submitting an app to Apple you should answer "Yes" to the Advertising Identifier question and check the box next to "Attribute an action taken within this app to a previously served advertisement".

## License

The iOS client SDK is available under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). See the LICENSE file for more info.

Kitemetrics® is a registered trademark of Kitemetrcs.
