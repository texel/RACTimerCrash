//
//  AppDelegate.m
//  RACTimerCrash
//
//  Created by Leigh Caplan on 12/29/14.
//  Copyright (c) 2014 Onehub. All rights reserved.
//

#import "AppDelegate.h"
#import "AFHTTPClient.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.client = [[AFHTTPClient alloc]
    initWithBaseURL:[[NSURL alloc] initWithString:@"http://localhost:3000"]
  ];

  NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                          diskCapacity:0
                                                              diskPath:nil];
  [NSURLCache setSharedURLCache:sharedCache];

  self.command = [[RACCommand alloc]
    initWithEnabled:RACObserve(self, runTimer)
        signalBlock:^RACSignal *(id input) {
          NSLog(@"Executing command triggered by %@", input);

          [self.client getPath:@"/"
               parameters:@{}
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Success!");
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%li", (unsigned long)[[NSURLCache sharedURLCache] currentDiskUsage]);
                    NSLog(@"Error!");
                  }];

          return [RACSignal return:@YES];
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
//  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2
//                                                    target:self
//                                                  selector:@selector(getThing)
//                                                  userInfo:nil
//                                                   repeats:YES];
}

- (void)getThing
{
  AFHTTPClient *client = [[AFHTTPClient alloc]
    initWithBaseURL:[[NSURL alloc] initWithString:@"http://www.apple.com"]
  ];

//          return [[client rac_getPath:@"/" parameters:@{}] doError:^ (NSError *error) {
//            NSLog(@"Error!");
//          }];


  [client getPath:@"/"
       parameters:@{}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success!");
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error!");
          }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

@end
