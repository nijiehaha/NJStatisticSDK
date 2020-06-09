#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NJStatisticTool : NSObject

/*
 @abstract
 获取 统计工具类 实例
 
 @return 返回单例
 
 **/
+ (NJStatisticTool *)sharedInstance;

@end

@interface NJStatisticTool (Track)

/// 触发追踪事件
/// @param eventName 事件名称
/// @param properties 事件属性
- (void)track:(NSString *)eventName properties:(nullable NSDictionary<NSString *, id> *)properties;

@end

NS_ASSUME_NONNULL_END
