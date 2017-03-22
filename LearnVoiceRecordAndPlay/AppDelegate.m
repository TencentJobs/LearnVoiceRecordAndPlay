//
//  AppDelegate.m
//  LearnVoiceRecordAndPlay
//
//  Created by confiwang on 2017/3/22.
//  Copyright © 2017年 confiwang. All rights reserved.
//

#import "AppDelegate.h"

#import "CFVoiceRecordAndPlayWindowController.h"

@interface AppDelegate ()

@property (nonatomic, strong) CFVoiceRecordAndPlayWindowController *voiceRecordAndPlayWindowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.voiceRecordAndPlayWindowController = [[CFVoiceRecordAndPlayWindowController alloc] initWithWindowNibName:@"CFVoiceRecordAndPlayWindowController"];
    
    [self.voiceRecordAndPlayWindowController showWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
