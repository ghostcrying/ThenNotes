//
//  UnityManager.m
//  Unity-iPhone
//
//  Created by Admin on 2021/5/13.
//

#import "UnityManager.h"

#import "UnityView.h"
#import "UnityInterface.h"
#import "UnityFramework.h"

extern "C" {
  
    //unity call native
    const char* UnityToNative(const char* data ){
        printf("UnityToNative");
        if (UnityManager.instance.callback == nil) {
            return NULL;
        }
        NSString* result = UnityManager.instance.callback([NSString stringWithUTF8String:data]);
        return strdup([result UTF8String]);
    }
    
}


@interface UnityManager()<UnityFrameworkListener>

@property(nonatomic, strong) UnityFramework* framework;

@end

@implementation UnityManager

#pragma mark - init

+ (UnityManager *)instance {
    static UnityManager *unity;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        if (unity == nil) {
            unity = [[UnityManager alloc] init];
        }
    });
  return unity;
}


#pragma mark - UnityFrameworkListener

- (void)unityDidQuit:(NSNotification *)notification {
    
}

- (void)unityDidUnload:(NSNotification *)notification {
    
}


#pragma mark - Public

- (void)initUnityWithArgc:(int)argc argv:(char * _Nullable *)argv {
    if (_framework == nil) {
        _framework = UnityFramework.getInstance;
    }
    [_framework setDataBundleId:"com.unity3d.framework"];
    [_framework registerFrameworkListener:self];
    [_framework runEmbeddedWithArgc:argc argv:argv appLaunchOpts:nil];

    // 注册Unity的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)recreateRenderingSurfaceIfNeeded {
    [self.framework.appController.unityView recreateRenderingSurfaceIfNeeded];
}

- (void)recreateRenderingSurface {
    [self.framework.appController.unityView recreateRenderingSurface];
}

- (void)send:(NSString *)json {
    [self.framework sendMessageToGOWithName:"PTUGame" functionName:"NativeToUnity" message: [json UTF8String]];
}

- (void)pauseGame {
    [self.framework pause:true];
}

- (BOOL)isPaused {
    return UnityIsPaused() == 1;
}

- (UIView *)playView {
    return self.framework.appController.rootView;
}


#pragma mark - notifications

- (void)appWillEnterForeground:(NSNotification *)notification {
    [self.framework.appController applicationWillEnterForeground: UIApplication.sharedApplication];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    [self.framework.appController applicationDidBecomeActive: UIApplication.sharedApplication];
}

- (void)appWillResignActive:(NSNotification *)notification {
    [self.framework.appController applicationWillResignActive:UIApplication.sharedApplication];
}

- (void)appWillTerminate:(NSNotification *)notification {
    [self.framework.appController applicationWillTerminate:UIApplication.sharedApplication];
}

- (void)appDidReceiveMemoryWarning:(NSNotification *)notification {
    [self.framework.appController applicationDidReceiveMemoryWarning:UIApplication.sharedApplication];
}

@end
