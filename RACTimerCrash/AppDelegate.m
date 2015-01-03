//
//  AppDelegate.m
//  RACTimerCrash
//
//  Created by Leigh Caplan on 12/29/14.
//  Copyright (c) 2014 Onehub. All rights reserved.
//

#import "AppDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking-RACExtensions/RACAFNetworking.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

  self.command = [[RACCommand alloc]
    initWithEnabled:RACObserve(self, runTimer)
        signalBlock:^RACSignal *(id input) {
          NSLog(@"Executing command triggered by %@", input);

          AFHTTPClient *client = [[AFHTTPClient alloc]
            initWithBaseURL:[[NSURL alloc] initWithString:@"http://localhost:4567"]
          ];

          return [[client rac_getPath:@"/" parameters:@{}] doError:^ (NSError *error) {
            NSLog(@"Error!");
          }];
        }];

  [self setupTimers];
}

- (void)setupTimers
{
  RACSignal *mainThreadTimer = [RACSignal interval:0.2 onScheduler:[RACScheduler mainThreadScheduler]];
  RACSignal *backgroundTimer = [RACSignal interval:0.2
                                       onScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]];

  self.threadMenu.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    if ([input indexOfSelectedItem] == 0) {
      self.timer = mainThreadTimer;
    }
    else {
      self.timer = backgroundTimer;
    }

    return [RACSignal empty];
  }];

  [self.threadMenu.rac_command execute:self.threadMenu];

  [[[RACObserve(self, timer) logNext] switchToLatest]
    subscribeNext:^(id x) {
      [self.command execute:@"command"];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

@end
