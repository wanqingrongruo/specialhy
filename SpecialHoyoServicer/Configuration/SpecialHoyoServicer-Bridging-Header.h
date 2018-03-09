//
//  SpecialHoyoServicer-Bridging-Header.h
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/13.
//  Copyright © 2017年 roni. All rights reserved.
//

#ifndef SpecialHoyoServicer_Bridging_Header_h
#define SpecialHoyoServicer_Bridging_Header_h

//#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h> // 空数据

#import "PAirSandbox.h"  // 沙盒管理

#import "Udesk.h"  // 即时通讯 udesk

#import "JPUSHService.h"// 引入JPush功能所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max // iOS10注册APNs所需头文件
#import <UserNotifications/UserNotifications.h>
#endif

//#import <Bugly/Bugly.h> // bugly - bug 统计


#import "WXApi.h" // 微信支付
#import <CommonCrypto/CommonDigest.h>


#import "MLEmojiLabel.h"

#endif /* SpecialHoyoServicer_Bridging_Header_h */
