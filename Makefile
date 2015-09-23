bootstrap:
	bundle install --path="vendor/bundle"
	bundle exec pod install --project-directory=Example/

bundle: 
	bundle exec pod install

update:
	bundle install
	bundle update
	bundle exec pod install
