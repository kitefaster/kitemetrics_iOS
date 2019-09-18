# Installation & Update

To install or update the Kitemetrics iOS client see the [readme](https://github.com/kitefaster/kitemetrics_iOS/blob/master/README.md).

# Changelog

## 1.1.10(2019-09-18)

##### Enhancements

* Use Swift 5.0

## 1.1.9(2018-07-21)

##### Enhancements

* Improve polling.
* Increase retry cap.
* Send attribution immediatly.

## 1.1.8(2018-06-04)

##### Bug Fixes

* Fix simulator warning.  Update example project settings.

## 1.1.7(2018-05-10)

##### Enhancements

* Increase wait time between retries.  Add a cap to retries from Apple server errors.

## 1.1.6(2018-03-14)

##### Bug Fixes

* Add @objc to public functions to support Objective-C projects with Swift 4.

## 1.1.5(2018-03-09)

##### Bug Fixes

* Use Swift dictionary instead of NSDictionary

## 1.1.4(2018-03-08)

##### Bug Fixes

* Make conversion of Apple Search Ads Attribution Error to ADClientError optional

## 1.1.3(2017-11-07)

##### Enhancements

* Use Swift 4.0
* Update Example project for iPhone X

## 1.1.2 (2017-10-24)

##### Enhancements

* Increment .swift-version file to version 3.2
* Make Kitemetrics deviceId public

## 1.1.1 (2017-10-02)

##### Enhancements

* Improve time accuracy reporting when client device has inaccurate system time.

## 1.1.0 (2017-09-28)

##### Enhancements

* Can now log purchases directly when SKProduct is not available or for eCommerce transactions.
* Improve attribution retry due to click latency or server error with a max attempt limit and a 30 day window.

## 1.0.8 (2017-09-17)

##### Enhancements

* Improve log rotation when offline.
* Improve backoff when request times out or the server throws an error.

##### Bug Fixes

* Remove TrueTime library due to memory leak.  Will revisit including it after patch is pushed to trunk.

## 1.0.7 (2017-09-15)

##### Bug Fixes

* Only use TrueTime library for 64 bit devices due to crash in 32 bit devices.

## 1.0.6 (2017-09-14)

##### Enhancements

* Include TrueTime library for more accurate timestamp reporting.

##### Bug Fixes

* make the iAd framework optional for iOS 8 support.

## 1.0.5 (2017-08-14)

##### Enhancements

* Remove unnecessary DispatchQueue.main.async calls.


## 1.0.4 (2017-08-02)

##### Enhancements

* Update to pass iOS 11 compiler warnings.

##### Bug Fixes

* Improve version reporting.

## 1.0.3 (2017-07-13)

##### Enhancements

* Disable debug logging by default.
* Update readme.
