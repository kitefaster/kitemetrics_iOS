# Installation & Update

To install or update the Kitemetrics iOS client see the [readme](https://github.com/kitefaster/kitemetrics_iOS/blob/master/README.md).

# Changelog

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
