//
//  NJAnalyticsDelegateProxy.h
//  NJStatisticSDK
//
//  Created by lufei on 2020/9/21.
//  Copyright © 2020 test. All rights reserved.
//

#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NJAnalyticsDelegateProxy : NSProxy <UITableViewDelegate>

+ (instancetype) proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
