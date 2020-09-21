#import "UITableView+SensorsData.h"
#import "NSObject+NJSwizzler.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NJStatisticSDK.h"
#import "NJAnalyticsDynamicDelegate.h"
#import "NJAnalyticsDelegateProxy.h"
#import "UIScrollView+SensorsData.h"

@implementation UITableView (SensorsData)

+(void)load {
    
    [UITableView sensorsData_swizzleMethod:@selector(setDelegate:) withMethod:@selector(sensorsData_setDelegate:)];
        
}

- (void)sensorsData_setDelegate:(id<UITableViewDelegate>)delegate {
    
    /// 调用原始的代理方法
//    [self sensorsData_setDelegate:delegate];
    
    /// 方案一：方法交换
    /// 交换 delegate 对象中的 tabelView:didSelecteRowAtIndexPath: 方法
//    [self sensorsData_swizzleDidSelectRowAtIndexPathMethodWithDelegete:delegate];
    
    /// 方案二：动态子类
//    [NJAnalyticsDynamicDelegate proxyWithTableViewDelegate:delegate];
    
    /// 方案三：NSProxy 消息转发
    /// 销毁保存的委托对象
    self.sensorsData_delegateProxy = nil;
    if (delegate) {
        NJAnalyticsDelegateProxy *proxy = [NJAnalyticsDelegateProxy proxyWithTableViewDelegate:delegate];
        self.sensorsData_delegateProxy = proxy;
        [self sensorsData_setDelegate:proxy];
    } else {
        [self sensorsData_setDelegate:nil];
    }
    
    
}

static void sensorsData_tableViewDidSelectRow(id object, SEL selector, UITableView *tableView, NSIndexPath *indexPath) {
    
    SEL destinationSelector = NSSelectorFromString(@"sensorsData_tableView:didSelectRowAtIndexPath:");
    
    /// objc_msgSend 要调用 需要适当的转换成适当的函数指针类型
    ((void(*)(id, SEL, id, id))objc_msgSend)(object, destinationSelector, tableView, indexPath);
        
    /// 触发点击事件
    [[NJStatisticTool sharedInstance] trackAppClickWithTableview:tableView didSelectRowAtIndexPath:indexPath properties:nil];
    
}

- (void)sensorsData_swizzleDidSelectRowAtIndexPathMethodWithDelegete:(id)delegate {
    
    /// 获取 delegate 对象的类
    Class delgateClass = [delegate class];
    
    /// 方法名
    SEL sourceSelector = @selector(tableView:didSelectRowAtIndexPath:);
    
    if (![delegate respondsToSelector:sourceSelector]) {
        return;
    }
    
    SEL destinationSelctor = NSSelectorFromString(@"sensorsData_tableView:didSelectRowAtIndexPath:");
    /// 当 delegate 对象已经存在 sensorsData_tableView:didSelectRowAtIndexPath: 方法，说明已经交换，直接返回
    if ([delegate respondsToSelector:destinationSelctor]) {
        return;
    }
    
    Method sourceMethod = class_getInstanceMethod(delgateClass, sourceSelector);
    const char * encoding = method_getTypeEncoding(sourceMethod);
    if (!class_addMethod([delegate class], destinationSelctor, (IMP)sensorsData_tableViewDidSelectRow, encoding)) {
        return;
    }
    
    [delgateClass sensorsData_swizzleMethod:sourceSelector withMethod:destinationSelctor];
    
}

@end
