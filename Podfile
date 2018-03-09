# Uncomment the next line to define a global platform for your project

platform :ios, '9.0'

use_frameworks! # 使用 frameworks 动态库替换静态库链接, swift 默认使用
inhibit_all_warnings! # 屏蔽所有来自库的警告

target 'SpecialHoyoServicer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks

  pod 'Alamofire', '4.5.0' # 网络
  pod 'SwiftyJSON', '~>3.1.4' # JSON 解析
  # pod 'Alamofire-SwiftyJSON'
  pod 'Kingfisher'#, '~>3.10.2'  # 图片加载
  pod 'ESPullToRefresh'#, '~>2.6' # 刷新
  pod 'RealmSwift'  # 数据库引擎, 不控制版本,始终更新最新版本
  pod 'IQKeyboardManagerSwift'#, '~> 4.0.10' # 键盘监听
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git' # 颜色
  #pod 'CRNetworkButton'#, '~>1.0.2' # 按钮
  pod 'SnapKit'#, '~>3.2.0' # autolayout
  #pod 'MotionAnimation'  # 小动画
  pod 'Hero'#, '~>0.3.6' # 动画库
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git' #, :branch => 'swift3' # 动画库
  pod 'XLActionController'#, '~>3.0.1' # actionView
  pod 'PKHUD'#, '~> 4.2.3' # hud
  pod 'KRProgressHUD'#, '~>3.0.0'  # hud
  pod 'R.swift'  #一种书写方式 关于 image/color/font...
  pod 'DZNEmptyDataSet' # 空数据 - OC库 TO DO: 重写
  pod 'KMNavigationBarTransition'#, '~>1.1.5' # 导航处理
  #pod 'Fusuma', '~>1.2.0' # imagePicker
  pod 'BSImagePicker'#, '~>2.6.0' #
  pod 'SwiftMessages' #, '~>3.3.4' # alert
  #pod 'DateTimePicker' # datePicker
  pod 'swiftScan' # 二维码生成/扫描/..
  pod 'EFQRCode' # 二维码生成 --- 因为好看,所以另用了这个 ><
  pod 'SKPhotoBrowser' # 图片浏览
  pod 'JPush' # 极光推送
  pod 'Bugly' # bugly bug统计
  pod 'TZImagePickerController'
  
  # Pods for SpecialHoyoServicer

  target 'SpecialHoyoServicerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SpecialHoyoServicerUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
