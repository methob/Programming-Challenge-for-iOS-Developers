//
//  AVPlayerOverlayViewController.m
//  AVPlayerOverlay
//
//  Created by Danilo Priore on 27/03/17.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

#import "AVPlayerOverlayViewController.h"

@interface AVPlayerOverlayViewController()

@property (nonatomic, strong) NSMutableArray<AVPlayerOverlayAction*> *registeredActions;

@end

@implementation AVPlayerOverlayViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        _registeredActions = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addTarget:(id)target action:(SEL)action forEvents:(AVPlayerOverlayEvents)event
{
    if (target && action)
    {
        __block BOOL exist = NO;
        [_registeredActions enumerateObjectsUsingBlock:^(AVPlayerOverlayAction * _Nonnull act, NSUInteger idx, BOOL * _Nonnull stop) {
            if (act.target == target && act.action == action && act.event == event) {
                exist = YES;
                *stop = YES;
            }
        }];
        
        if (!exist) {
            
            AVPlayerOverlayAction *act = [[AVPlayerOverlayAction alloc] init];
            act.target = target;
            act.action = action;
            act.event = event;
            
            [_registeredActions addObject:act];
        }
    }
}

- (void)sendActionsForEvent:(AVPlayerOverlayEvents)event
{
    [self sendActionsForEvent:event object:nil];
}

- (void)sendActionsForEvent:(AVPlayerOverlayEvents)event object:(id)object
{
    for (AVPlayerOverlayAction *action in _registeredActions) {
        if (action.event == event) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [action.target performSelector:action.action withObject:object];
#pragma clang diagnostic pop
        }
    }
}

@end
