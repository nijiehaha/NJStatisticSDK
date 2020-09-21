#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NJAnalyticsDynamicDelegate : NSObject

+ (void)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
