def workspace
  return 'Demo.xcworkspace'
end

def configuration
  return 'Debug'
end

def targets
  return [
    :ios,
    :macos,
    :tvos,
  ]
end

def schemes
  return {
    ios: 'Demo',
    macos: 'RxViewModelTests-macOS',
    tvos: 'RxViewModelTests-tvOS'
  }
end

def sdks
  return {
    ios: 'iphonesimulator',
    macos: 'macosx',
    tvos: 'appletvsimulator9.2'
  }
end

def devices
  return {
    ios: "name='iPhone 6s'",
    macos: "arch='x86_64'",
    tvos: "name='Apple TV 1080p'"
  }
end

def xcodebuild_in_demo_dir(tasks, platform, xcprety_args: '')
  sdk = sdks[platform]
  scheme = schemes[platform]
  destination = devices[platform]

  Dir.chdir('Demo') do
    sh "set -o pipefail && xcodebuild -workspace '#{workspace}' -scheme '#{scheme}' -configuration '#{configuration}' -sdk #{sdk} -destination #{destination} #{tasks} | bundle exec xcpretty -c #{xcprety_args}"
  end
end

def pods()
  sh "bundle exec pod install --project-directory=Demo"
end

def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

desc 'Bootstrap'
task :bootstrap do
  # Added for now because Travis was failing to find RxSwift ~> 2.5"
  sh "bundle exec pod repo update"
  pods()
end

desc 'Generates the Pods workspace'
task :pods do
  pods()
end

desc 'Build the Demo app.'
task :build do
  xcodebuild_in_demo_dir 'build', :ios
end

desc 'Clean build directory.'
task :clean do
  xcodebuild_in_demo_dir 'clean', :ios
end

namespace "test" do
  desc 'Build, then run tests for iOS.'
  task :iOS do
    xcodebuild_in_demo_dir 'build test', :ios, xcprety_args: '--test'
    sh "killall Simulator"
  end

  desc 'Build, then run tests for macOS.'
  task :macOS do
    xcodebuild_in_demo_dir 'build test', :macos, xcprety_args: '--test'
    sh "killall Simulator"
  end

  desc 'Build, then run tests for tvOS.'
  task :tvOS do
    xcodebuild_in_demo_dir 'build test', :tvos, xcprety_args: '--test'
    sh "killall Simulator"
  end
end
