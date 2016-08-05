## AHPullRefresh

Extension UIScrollView.
Add pull down refresh and pull up refresh.

## Usage

```swift

// 自定义下拉显示的View
let stopView = PullDownRefreshView(titles: ["再往下拉点，再拉一点点"], images: [UIImage(named: "loading_01")!])
let triggeredView = PullDownRefreshView(titles: ["对对对就酱紫，可以松手啦"], images: [UIImage(named: "loading_01")!])
let refreshAnimationView = PullDownRefreshView(titles: ["你懂的，偶在拼命加载中～(,,•́ . •̀,,)", "别着急，司机马上就到～～⁽⁽٩( ´͈ ᗨ `͈ )۶⁾⁾", "么么哒，就来啦～⊂(˃̶͈̀ε ˂̶͈́ ⊂ )"],
                                               images: [
                                               UIImage(named: "loading_01")!,
                                               UIImage(named: "loading_02")!,
                                               UIImage(named: "loading_03")!,
                                               UIImage(named: "loading_04")!,
                                               UIImage(named: "loading_05")!,
                                               UIImage(named: "loading_06")!,
                                               UIImage(named: "loading_07")!,
                                               UIImage(named: "loading_08")!])

// 自定义上拉显示的View
let noMorePullUpRefreshView = PullUpRefreshView(titles: ["暂时看完啦！你不加点料吗？"], images: [UIImage(named: "loading_01")!])
noMorePullUpRefreshView.userInteractionEnabled = true
let errorPullUpRefreshView = PullUpRefreshView(titles: ["只是加载失败而已，点一下这里就好"], images: nil)
errorPullUpRefreshView.userInteractionEnabled = true
let bottomRefreshView = PullUpRefreshView(titles: ["本宝宝在拼命加载中..."],
                                          images: [
                                          UIImage(named: "loading_01")!,
                                          UIImage(named: "loading_02")!,
                                          UIImage(named: "loading_03")!,
                                          UIImage(named: "loading_04")!,
                                          UIImage(named: "loading_05")!,
                                          UIImage(named: "loading_06")!,
                                          UIImage(named: "loading_07")!,
                                          UIImage(named: "loading_08")!])

// 下拉刷新
self.tableView.setCustomViewForTopRefreshState(stopView, forState: AHTopRefreshViewState.Stopped) // 继续下拉
self.tableView.setCustomViewForTopRefreshState(triggeredView, forState: AHTopRefreshViewState.Triggered) // 松手刷新
self.tableView.setCustomViewForTopRefreshState(refreshAnimationView, forState: AHTopRefreshViewState.Loading) // 加载中

self.tableView.addTopRefreshBlock({
    self.tableView.reloadData()
    self.tableView.stopTopRefreshAnimating()
})

// 上拉刷新
self.tableView.setCustomViewForBottomRefreshState(noMorePullUpRefreshView, forState: AHBottomRefreshViewState.NoMore) // 没有更多数据
self.tableView.setCustomViewForBottomRefreshState(bottomRefreshView, forState: AHBottomRefreshViewState.Loading) // 加载中
self.tableView.setCustomViewForBottomRefreshState(errorPullUpRefreshView, forState: AHBottomRefreshViewState.Error) // 加载失败

self.tableView.addBottomRefreshWithBlock({
    self.tableView.reloadData()
    self.tableView.stopBottomRefresh()

})
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

pod 'AHPullRefresh'
```

Then, run the following command:

```bash
$ pod install
```
