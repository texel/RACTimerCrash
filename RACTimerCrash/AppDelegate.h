//
//  AppDelegate.h
//  RACTimerCrash
//
//  Created by Leigh Caplan on 12/29/14.
//  Copyright (c) 2014 Onehub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RACSignal;
@class RACCommand;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property IBOutlet NSPopUpButton *threadMenu;
@property BOOL    runTimer;

@property RACSignal  *timer;
@property RACCommand *command;

@end

