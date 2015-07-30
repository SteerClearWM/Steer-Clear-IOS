# Steer-Clear-IOS
IOS repo for Steer Clear app

## How to Launch

***1.*** Run Backend
* Server needs to be running locally to be able to send requests. (PUSH & GET)
* To run server follow: https://github.com/RyanBeatty/Steer-Clear-Backend
* Note: runserver.py can run without the virtual environment running, however the database must already have been created.
* To test if server is running locally visit localhost:5000
* If server is running, you will receive a "Pulse".

***1.*** Install CocoaPods
* Go to your terminal and navigate to the Steer-Clear-IOS folder
* type in ``` $ sudo gem install cocoapods ``` to install Cocoapods on your computer
* type in ``` $ pod install ``` to have the pods intall in your build
***2.*** Launch "Steer Clear.xcworkspace" in Xcode
* In Apple's Navigation Bar, go to Product -> Clean
* Press Play and it will run in IOS simulator. 
