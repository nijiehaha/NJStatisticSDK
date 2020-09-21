#import "NJAnalyticsDynamicDelegate.h"
#import "NJStatisticSDK.h"
#import <objc/runtime.h>

/// delegate 对象的子类前缀
static NSString *const NJDelegatePrefix = @"nj.SensorsData";
/// tableView:didSelectRowAtIndexPath: 方法指针类型
typedef void (* SensorsDidSelectImplementation)(id, SEL, UITableView *, NSIndexPath *);

@implementation NJAnalyticsDynamicDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /// 获取原始类
    Class cla = object_getClass(tableView);
    NSString *className = [NSStringFromClass(cla) stringByReplacingOccurrencesOfString:NJDelegatePrefix withString:@""];
    Class originalClass = object_getClass(className);
    
    /// 调用自己实现的方法
    SEL originalSelector = NSSelectorFromString(@"tableView:didSelectRowAtIndexPath:");
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    IMP originalImplementation = method_getImplementation(originalMethod);
    if (originalImplementation) {
        ((SensorsDidSelectImplementation)originalImplementation)(tableView.delegate, originalSelector, tableView, indexPath);
    }
    
    /// 埋点
    [[NJStatisticTool sharedInstance] trackAppClickWithTableview:tableView didSelectRowAtIndexPath:indexPath properties:nil];
    
}

+ (void)proxyWithTableViewDelegate:(id)delegate {
    
    SEL originalSelector = NSSelectorFromString(@"tableView:didSelectRowAtIndexPath:");
    if (![delegate respondsToSelector:originalSelector]){
        return;
    }
    
    /// 动态创建一个新类
    Class originalClass = object_getClass(delegate);
    NSString *originalClassName = NSStringFromClass(originalClass);
    if ([originalClassName hasPrefix:NJDelegatePrefix]) {
        return;
    }
    
    NSString *subclassName = [NJDelegatePrefix stringByAppendingString:originalClassName];
    Class subclass = NSClassFromString(subclassName);
    
    if (!subclass) {
        
        /// 注册一个新的子类，其父类为 originalClass
        subclass = objc_allocateClassPair(originalClass, [subclassName UTF8String], 0);
        
        /// 获取 NJAnalyticsDynamicDelegate 中的tableView:didSelectRowAtIndexPath: 方法指针
        Method method = class_getInstanceMethod(self, originalSelector);
        /// 获取方法的实现
        IMP methodIMP = method_getImplementation(method);
        /// 获取方法的编码类型
        const char *types = method_getTypeEncoding(method);
        
        /// 在 subclass 中添加 tableView:didSelectRowAtIndexPath: 方法
        if (!class_addMethod(subclass, originalSelector, methodIMP, types)) {
            NSLog(@"不能拷贝到目标方法");
        }
        
        if (class_getInstanceSize(originalClass) != class_getInstanceSize(subclass)) {
            return;
        }
        
        /// 将 delegate 对象设置成新创建的子类对象
        objc_registerClassPair(subclass);
        
    }
    
    if (object_setClass(delegate, subclass)) {
        NSLog(@"成功");
    }
    
}

@end
