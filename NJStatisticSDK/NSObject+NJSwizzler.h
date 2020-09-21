#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (NJSwizzler)

/**
 交换方法
 
 @param originalSEL 原始方法名
 @param alternateSEL 要交换的方法名称
 
*/
+ (BOOL)sensorsData_swizzleMethod:(SEL)originalSEL withMethod:(SEL)alternateSEL;

@end

NS_ASSUME_NONNULL_END
