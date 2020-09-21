//
//  UIScrollView+SensorsData.h
//  NJStatisticSDK
//
//  Created by lufei on 2020/9/21.
//  Copyright © 2020 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJAnalyticsDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (SensorsData)

@property (nonatomic, strong, nullable) NJAnalyticsDelegateProxy *sensorsData_delegateProxy;

@end

NS_ASSUME_NONNULL_END
