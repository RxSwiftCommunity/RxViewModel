bootstrap:
	bundle install --path="vendor/bundle"
	bundle update
	rm -rf Example/Podfile.lock
	bundle exec pod install --project-directory=Example/

bundle: 
	bundle exec pod install

update:
	bundle install
	bundle update
	bundle exec pod install
