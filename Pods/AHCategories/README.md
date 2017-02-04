## AHCategories

Tools for settings UIView's frame and make UIColor with Hexadecimal values. 

## Usage

```swift
// layout
let label = UILabel(frame: CGRect(x: 40, y: 40, width: 200, height: 30))
label.backgroundColor = UIColor(argb: 0xff343434) // ARGB
label.ahLeft = 10
label.ahTop = 50
label.ahCenterX = self.view.ahCenterX
label.ahCenterY = self.view.ahCenterY
print("\(label.screenFrame())")
```

## CocoaPods

CocoaPods is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate AHCategories into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'AHCategories'
```

Then, run the following command:

```bash
$ pod install
```
