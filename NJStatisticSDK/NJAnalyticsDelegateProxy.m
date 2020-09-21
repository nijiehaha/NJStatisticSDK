//
//  NJAnalyticsDelegateProxy.m
//  NJStatisticSDK
//
//  Created by lufei on 2020/9/21.
//  Copyright © 2020 test. All rights reserved.
//

#import "NJAnalyticsDelegateProxy.h"
#import "NJStatisticSDK.h"

@interface NJAnalyticsDelegateProxy()

@property (nonatomic, weak) id delegate;

@end

@implementation NJAnalyticsDelegateProxy

+ (instancetype)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate{
    
    NJAnalyticsDelegateProxy *proxy = [NJAnalyticsDelegateProxy alloc];
    proxy.delegate = delegate;
    return proxy;
    
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    
    return [(NSObject *)self.delegate methodSignatureForSelector:sel];
    
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    
    [invocation invokeWithTarget:self.delegate];
    
    if (invocation.selector == @selector(tableView:didSelectRowAtIndexPath:)) {
        
        invocation.selector = NSSelectorFromString(@"sensorsData_tableView:didSelectRowAtIndexPath:");
        
        [invocation invokeWithTarget:self];
        
    }
    
}

- (void)sensorsData_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[NJStatisticTool sharedInstance] trackAppClickWithTableview:tableView didSelectRowAtIndexPath:indexPath properties:nil];
    
}

@end
