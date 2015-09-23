# RxViewModel

[![Circle CI](https://circleci.com/gh/esttorhe/RxViewModel/tree/master.svg?style=svg)](https://circleci.com/gh/esttorhe/RxViewModel/tree/master)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)
[![License](https://img.shields.io/cocoapods/l/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)
[![Platform](https://img.shields.io/cocoapods/p/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)

# What's `RxViewModel`?

Long story short: a blatant «imitation» of [`ReactiveViewModel`][rvm] using [`RxCocoa`][rxcocoa].

Since [`ReactiveViewModel`][rvm] project felt on stagnation and there's not `Swift` or `Swift 2.0` implementation we found the need to implement something like this on `Swift`.

Given the fact that there's no `Swift` branch and the lack of interest in the project we felt it was better to give [`RxSwift`/`RxCocoa`][rxcocoa] a chance and instead use it as the base for this reactive view model approach.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

Simply add the following line to your Podfile:

```ruby
pod "RxViewModel", "~> 2.1.0"
```

And then run:

```console
pod install
```

### Carthage

Just add the following to your [`Cartfile`](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```swift
github "esttorhe/RxViewModel", ~> 2.1.0
```

And run:

```console
carthage update
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
