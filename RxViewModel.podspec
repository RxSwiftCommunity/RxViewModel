
Pod::Spec.new do |s|
  s.name             = "RxViewModel"
  s.version          = "0.1.0"
  s.summary          = "A blatant «imitation» of `ReactiveViewModel` using `RxCocoa`."
  s.description      = <<-DESC
Since [`ReactiveViewModel`](https://github.com/ReactiveCocoa/ReactiveViewModel) project felt on stagnation and there's not `Swift` or `Swift 2.0` implementation we found the need to implement something like this on `Swift`.

Given the fact that there's no `Swift` branch and the lack of interest in the project we felt it was better to give `RxSwift`/`RxCocoa` a chance and instead use it as the base for this reactive view model approach.
                       DESC
  s.homepage         = "https://github.com/esttorhe/RxViewModel"
  s.license          = 'MIT'
  s.author           = { "esttorhe" => "me@estebantorr.es" }
  s.source           = { :git => "https://github.com/esttorhe/RxViewModel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/esttorhe'

  s.platform     = :ios, '8.2'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.dependency 'RxCocoa'
    #, :branch => 'feature/swift2.0' <<== commented out for now because we would be depending on Swift 2.0
  s.frameworks = 'Foundation'
end
