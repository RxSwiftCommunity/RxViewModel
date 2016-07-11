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

def actions
  return {
    ios: 'build test',
    macos: 'test',
    tvos: 'test'
  }
end

def devices
  return {
    ios: "name='iPhone 6s'",
    macos: "arch='x86_64'",
    tvos: "name='Apple TV 1080p'"
  }
end

def xcodebuild_in_demo_dir(platform, xcprety_args: '')
  sdk = sdks[platform]
  scheme = schemes[platform]
  destination = devices[platform]
  tasks = actions[platform]

  Dir.chdir('Demo') do
    sh "set -o pipefail && xcodebuild -workspace '#{workspace}' -scheme '#{scheme}' -configuration '#{configuration}' -sdk #{sdk} -destination #{destination} #{tasks} | bundle exec xcpretty -c #{xcprety_args}"
  end
end

def pods()
  sh "bundle exec pod install --project-directory=Demo --repo-update"
end

def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

desc 'Bootstrap'
task :bootstrap do
  # Added for now because Travis was failing to find RxSwift ~> 2.5"
  #sh "bundle exec pod repo update"
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

desc 'Build, then run tests for passed in os.'
task :test, [:os] do |t, args|
  xcodebuild_in_demo_dir args.os.to_sym, xcprety_args: '--test'
end
