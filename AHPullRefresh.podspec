Pod::Spec.new do |s|
  s.name         = "AHPullRefresh"
  s.version      = "1.0.2"
  s.summary      = "扩展UIScrollView，支持下拉刷新和上拉刷新"
  s.homepage     = "https://github.com/AnsonHui/AHPullRefresh"
  s.license      = "MIT"
  s.author             = { "黄辉" => "fantasyhui@126.com" }
  s.source       = { :git => "https://github.com/AnsonHui/AHPullRefresh.git", :tag => s.version }
  s.source_files  = "Classes/*.swift"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.dependency "AHCategories", "~> 1.0.1"
  s.dependency "AHAutoLayout-Swift", "~> 1.0.0"
end
