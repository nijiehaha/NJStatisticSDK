#import "NSObject+NJSwizzler.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (NJSwizzler)

+ (BOOL)sensorsData_swizzleMethod:(SEL)originalSEL withMethod:(SEL)alternateSEL {
    
    /// 获取原始方法
    Method originalMethod = class_getInstanceMethod(self, originalSEL);
    /// 当原始方法不存在时，返回 NO，表示 Swizzking 失败
    if (!originalMethod) {
        return NO;
    }
    
    /// 获取要交换的方法
    Method alternateMethod = class_getInstanceMethod(self, alternateSEL);
    /// 当需要交换的方法不存在时，返回 NO，表示 Swizzking 失败
    if (!alternateMethod) {
        return NO;
    }
    
    /// 交换两个方法的实现
    method_exchangeImplementations(originalMethod, alternateMethod);
    
    return YES;
    
    
}

@end
