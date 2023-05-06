//
//  UnityManager.h
//  Unity-iPhone
//
//  Created by Admin on 2021/5/13.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__ ((visibility("default")))
@interface UnityManager: NSObject

+ (UnityManager *)instance;

/* 展示Unity的view */
@property (nonatomic, weak) UIView *playView;
/* 接收Unity的回调 */
@property (nonatomic, copy) NSString * (^callback)(NSString *);

- (void)initUnityWithArgc:(int)argc argv:(char *_Nullable *_Nullable)argv;

- (void)recreateRenderingSurfaceIfNeeded;
- (void)recreateRenderingSurface;

- (void)send:(NSString *)json;

- (void)pauseGame;

- (BOOL)isPaused;

@end

NS_ASSUME_NONNULL_END
