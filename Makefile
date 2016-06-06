bootstrap:
	gem install bundler --no-doc --no-ri
	bundle install --path=".vendor/bundle"
	bundle exec pod install --project-directory=Example/

bundle: 
	bundle exec pod install

update:
	bundle install
	bundle update
	bundle exec pod install
