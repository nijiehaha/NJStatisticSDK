# NJStatisticSDK

iOS 全埋点 统计 SDK

# 目前实现的功能

+ 手动埋点

+ UITableView 的自动全埋点

+ 待续...

# 使用

```
#import <NJStatisticSDK/NJStatisticSDK.h>

NJStatisticTool *tool = [NJStatisticTool sharedInstance];
[tool track:@"test" properties:@{@"testKey": @"testValue"}];
```

# 安装

因为是一个用来练习的项目，所以不提供其他的安装方式，需要使用的朋友，可以直接下载源码使用QAQ
