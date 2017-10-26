
Pod::Spec.new do |s|
  s.name             = "RxViewModel"
  s.version          = "5.1.0"
  s.summary          = "`RxViewModel` is the marriage between `MVVM` and `Rx` extensions. A blatant «imitation» of `ReactiveViewModel` using `RxCocoa`."
  s.description      = <<-DESC
`RxViewModel` is the marriage between `MVVM` and `Rx` extensions

Since [`ReactiveViewModel`](https://github.com/ReactiveCocoa/ReactiveViewModel) project felt on stagnation and there's not `Swift` or `Swift 2.0` implementation we found the need to implement something like this on `Swift`.

Given the fact that there's no `Swift` branch and the lack of interest in the project we felt it was better to give `RxSwift`/`RxCocoa` a chance and instead use it as the base for this reactive view model approach.

Long story short: a blatant «imitation» of `ReactiveViewModel `using `RxCocoa`.
                       DESC
  s.homepage         = "https://github.com/RxSwiftCommunity/RxViewModel"
  s.license          = 'MIT'
  s.author           = { "esttorhe" => "me@estebantorr.es" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxViewModel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/esttorhe'

  s.ios.deployment_target  = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc = true

  s.source_files = 'Source/*.swift', 'Source/Categories/*.swift'
  s.dependency 'RxSwift', '~> 4.0'
  s.frameworks = 'Foundation'
end
