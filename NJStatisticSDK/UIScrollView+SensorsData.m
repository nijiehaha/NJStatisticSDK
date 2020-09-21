//
//  UIScrollView+SensorsData.m
//  NJStatisticSDK
//
//  Created by lufei on 2020/9/21.
//  Copyright © 2020 test. All rights reserved.
//

#import "UIScrollView+SensorsData.h"
#import <objc/runtime.h>

@implementation UIScrollView (SensorsData)

- (void)setSensorsData_delegateProxy:(NJAnalyticsDelegateProxy *)sensorsData_delegateProxy {
    
    objc_setAssociatedObject(self, @selector(setSensorsData_delegateProxy:), sensorsData_delegateProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (NJAnalyticsDelegateProxy *)sensorsData_delegateProxy {
    return objc_getAssociatedObject(self, @selector(sensorsData_delegateProxy));
}

@end
