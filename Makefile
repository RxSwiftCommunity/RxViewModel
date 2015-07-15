bootstrap:
	bundle install --path="vendor/bundle"
	bundle update
	bundle exec pod install
	bundle exec pod update

bundle: 
	bundle exec pod install

update:
	bundle install
	bundle update
	bundle exec pod install
	bundle exec pod update
