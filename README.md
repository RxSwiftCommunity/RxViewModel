# RxViewModel

[![CI Status](http://img.shields.io/travis/esttorhe/RxViewModel.svg?style=flat)](https://travis-ci.org/esttorhe/RxViewModel)
[![Version](https://img.shields.io/cocoapods/v/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)
[![License](https://img.shields.io/cocoapods/l/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)
[![Platform](https://img.shields.io/cocoapods/p/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)

# What's `RxViewModel`?

Long story short: a blatant «imitation» of [`ReactiveViewModel`][rvm] using [`RxCocoa`][rxcocoa].

Since [`ReactiveViewModel`][rvm] project felt on stagnation and there's not `Swift` or `Swift 2.0` implementation we found the need to implement something like this on `Swift`.

Given the fact that there's no `Swift` branch and the lack of interest in the project we felt it was better to give [`RxSwift`/`RxCocoa`][rxcocoa] a chance and instead use it as the base for this reactive view model approach.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This project depends directly on [`RxCocoa`/`RxSwift`][rxcocoa] since its the driving force behind the «reactiveness» of the view model.

## Installation

RxViewModel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RxViewModel"
```

## Features

Currently `RxViewModel` supports the following features from [`ReactiveViewModel`][rvm] (*ALL of them :wink:):

- [x] `didBecomeActive`
- [x] `didBecomeInactive`
- [x] `forwardSignalWhileActive`
- [x] `throttleSignalWhileInactive`

## Author

__Esteban Torres__ 

- [![](https://img.shields.io/badge/twitter-esttorhe-brightgreen.svg)](https://twitter.com/esttorhe) 
- :email: me@estebantorr.es

## License

RxViewModel is available under the MIT license. See the LICENSE file for more info.

[rvm]:https://github.com/ReactiveCocoa/ReactiveViewModel
[rxcocoa]:https://github.com/kzaher/RxSwift
