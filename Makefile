xcode:
	swift package generate-xcodeproj --xcconfig-overrides Package.xcconfig

build:
	swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"
	
build-on-ubuntu:
	swift build

release:
	swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"

release-on-ubuntu:
	swift build -c release

install:
	@make release
	mv ./.build/x86_64-apple-macosx10.10/release/SwiftBot /usr/local/bin
	
install-on-ubuntu:
	@make release-on-ubuntu
	mv ./.build/x86_64-unknown-linux/release/SwiftBot /usr/local/bin/swiftbot
