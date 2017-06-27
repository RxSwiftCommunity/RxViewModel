# RxViewModel

[![codecov.io](https://codecov.io/github/RxSwiftCommunity/RxViewModel/coverage.svg?branch=master)](https://codecov.io/github/RxSwiftCommunity/RxViewModel?branch=master)
[![Build Status](https://travis-ci.org/RxSwiftCommunity/RxViewModel.svg?branch=master)](https://travis-ci.org/RxSwiftCommunity/RxViewModel)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)
[![License](https://img.shields.io/cocoapods/l/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)
[![Platform](https://img.shields.io/cocoapods/p/RxViewModel.svg?style=flat)](http://cocoapods.org/pods/RxViewModel)

# Model-View-ViewModel

`Model-View-ViewModel` (MVVM from now on) was created by [Microsoft][mvvm] and is defined as follows:

>The Model-View-ViewModel (MVVM) pattern is an application pattern that isolates the user interface from the underlying business logic. MVVM belongs to a class of patterns called Separated Presentation. These patterns provide a clean separation between the UI and the rest of the application. This improves the testability of the application and allows the application and its UI to evolve more easily and independently.
>
>The Model-View-ViewModel (MVVM) pattern helps you to cleanly separate the business and presentation logic of your application from its user interface (UI). Maintaining a clean separation between application logic and UI helps to address numerous development and design issues and can make your application much easier to test, maintain, and evolve. It can also greatly improve code re-use opportunities and allows developers and UI designers to more easily collaborate when developing their respective parts of the application.

It basically adds a new «separation layer» to break down the `MVC` pattern into more manageable pieces.

`MVC` on Cocoa hast always been a pain because it always translates to «Massive View Controller» due to the need to __many__ `delegates` that are usually implemented by one controller (e.g. when binding a tableview where you need a delegate for the tableview and also a delegate for the data source, etc).

`MVVM` separates the `View` from the `Model` via an «intermediate» class named `ViewModel`.

This intermediate class allows the binding of the `View` and the `Model` in a more clean and easy manner and also separates some logic as to how/when to load the data removing that responsability from the `View` and leaving pretty much only the `UI` specific code in it.

# `RxViewModel`

`RxViewModel` is the marriage between `MVVM` and `Rx` extensions

Long story short: a blatant «imitation» of [`ReactiveViewModel`][rvm] using [`RxCocoa`][rxcocoa].

Since [`ReactiveViewModel`][rvm] project felt on stagnation and there's not `Swift` or `Swift 2.0` implementation we found the need to implement something like this on `Swift`.

Given the fact that there's no `Swift` branch and the lack of interest in the project we felt it was better to give [`RxSwift`/`RxCocoa`][rxcocoa] a chance and instead use it as the base for this reactive view model approach.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

Simply add the following line to your Podfile:

```ruby
pod "RxViewModel"
```

And then run:

```console
pod install
```

### Carthage

Just add the following to your [`Cartfile`](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```swift
github "RxSwiftCommunity/RxViewModel"
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

`RxViewModel` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

[rvm]:https://github.com/ReactiveCocoa/ReactiveViewModel
[rxcocoa]:https://github.com/ReactiveX/RxSwift
[mvvm]:http://msdn.microsoft.com/en-us/library/gg430869(v=PandP.40).aspx
