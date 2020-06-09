#import "NJStatisticTool.h"
#include <sys/sysctl.h>

@interface NJStatisticTool()

@property (nonatomic, strong) NSDictionary<NSString *, id> *automaticProperties;

/// 标记应用是否已收到 UIApplicationWillresignActiveNotification 本地通知
@property (nonatomic) BOOL applicationWillResignActive;

/// 是否为被动启动
@property (nonatomic, getter=isLaunchedPassively) BOOL launchedPassively;

@end

static NSString * const NJStatisticVersion = @"1.0.0";

@implementation NJStatisticTool

- (instancetype)init {
    
    if (self = [super init]) {
        
        _automaticProperties = [self collectAutomaticProperties];
        
        /// 设置是否被动启动标记
        _launchedPassively = UIApplication.sharedApplication.backgroundTimeRemaining != UIApplicationBackgroundFetchIntervalNever;
        
        /// 添加应用程序状态监听
        [self setupListeners];
        
    }
    
    return self;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NJStatisticTool *)sharedInstance {
    
    static dispatch_once_t onceToken;
    static NJStatisticTool *tool = nil;
    dispatch_once(&onceToken, ^{
        tool = [[NJStatisticTool alloc] init];
    });
    return tool;

}

/// 自动收集预置属性
- (NSDictionary<NSString *, id> *)collectAutomaticProperties {
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    /// 操作系统类型
    properties[@"$os"] = @"iOS";
    /// SDK平台类型
    properties[@"$lib"] = @"iOS";
    /// 设备制造商
    properties[@"$manufacturer"] = @"Apple";
    /// SDK版本号
    properties[@"$lib_version"] = NJStatisticVersion;
    /// 手机型号
    properties[@"$model"] = [self deviceModel];
    /// 操作系统版本号
    properties[@"$os_version"] = UIDevice.currentDevice.systemVersion;
    /// 应用程序版本号
    properties[@"$app_version"] = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    
    return [properties copy];
    
}

/// 获取手机型号
- (NSString *)deviceModel {
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = @(answer);
    return results;
    
}

- (void)printEvent:(NSDictionary *)event {

#if DEBUG
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:event options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return NSLog(@"JSON Serialized Error: %@", error);
    }
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Event]: %@", json);
    
#endif
    
}

#pragma mark - Application lifecycle

- (void)setupListeners {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    /// 注册监听 UIApplicationDidEnterBackgroudNotification 本地通知
    /// 当应用进入后台，调用通知方法
    [center addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    /// 注册监听 UIApplicationDidBecomeActiveNotification 本地通知
    /// 当应用进入前台并处于活动状态之后，调用通知方法
    [center addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    /// 注册监听 UIApplicationWillResignActiveNotification 本地通知
    [center addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    /// 注册监听 UIApplicationDidFinishLaunchingNotification 本地通知
    [center addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    
}

- (void)applicationDidEnterBackground: (NSNotification *)notification {
    
    NSLog(@"Application did enter background");
    
    /// 还原标记位
    self.applicationWillResignActive = NO;
    
    /// 触发 $AppEnd 事件
    [self track:@"$AppEnd" properties:nil];
    
}

- (void)applicationDidBecomeActive: (NSNotification *)notification {
    
    NSLog(@"Application did become active");
    
    /// 还原标记位
    if (self.applicationWillResignActive) {
        self.applicationWillResignActive = NO;
        return;
    }
    
    /// 将被动启动标记设为 NO，正常记录事件
    self.launchedPassively = NO;
    
    /// 触发 $AppStart 事件
    [self track:@"$AppStart" properties:nil];
    
}

- (void)applicationWillResignActive: (NSNotification *)notification {
    
    /// 标记已经接收到 UIApplicationWillResignActiveNotification 本地通知
    self.applicationWillResignActive = YES;
    
}

- (void)applicationDidFinishLaunching: (NSNotification *)notification {
    
    NSLog(@"Application did finish launching");
    
    /// 触发被动启动事件 $AppStartPassively
    /*
     被动启动：由 iOS 系统触发，自动进入后台运行，被称为应用程序的被动启动
     **/
    if (self.isLaunchedPassively) {
        [self track:@"$AppStartPassively" properties:nil];
    }

}

@end

/// 事件触发，追踪
@implementation NJStatisticTool (Track)

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,id> *)properties {
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    
    /// 设置事件名称
    event[@"event"] = eventName;
    /// 设置事件发生的时间戳，单位为毫秒
    event[@"time"] = [NSNumber numberWithLong:NSDate.date.timeIntervalSince1970 * 1000];
    
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    /// 添加预置属性
    [eventProperties addEntriesFromDictionary:self.automaticProperties];
    /// 添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    
    /// 判断是否为被动启动
    if (self.isLaunchedPassively) {
        /// 添加应用程序状态属性
        eventProperties[@"$app_state"] = @"background";
    }
    
    /// 设置事件属性
    event[@"properties"] = eventProperties;
    
    /// 在 xcode 控制台打印事件日志
    [self printEvent:event];
    
}

@end


