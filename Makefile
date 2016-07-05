bootstrap:
	gem install bundler --no-doc --no-ri
	bundle install --path=".vendor/bundle"
	bundle exec pod repo update
	bundle exec pod install --project-directory=Example/

pods: 
	bundle exec pod install --project-directory=Example/

update:
	bundle install
	bundle update
	bundle exec pod install
