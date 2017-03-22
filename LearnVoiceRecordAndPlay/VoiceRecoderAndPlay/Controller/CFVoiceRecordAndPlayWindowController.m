//
//  CFVoiceRecordAndPlayWindowController.m
//  LearnVoiceRecordAndPlay
//
//  Created by confiwang on 2017/3/22.
//  Copyright © 2017年 confiwang. All rights reserved.
//

#import "CFVoiceRecordAndPlayWindowController.h"

#import <AVFoundation/AVFoundation.h>

@interface CFVoiceRecordAndPlayWindowController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, strong) AVAudioRecorder *audioRecoder;
@property(nonatomic, assign) double lowPassResults;
@property(nonatomic, strong) NSTimer *levelTimer;

@end

@implementation CFVoiceRecordAndPlayWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.lowPassResults = 0.0;
    [self prepareForRecording];
}

- (IBAction)recordPressed:(id)sender
{
    if (!self.audioRecoder.recording) {
        [self enableMettering:YES];
        [self.audioRecoder record];
    } else {
        [self.audioRecoder stop];
        [self enableMettering:NO];
    }
}

- (IBAction)playPressed:(id)sender {
    [self.audioRecoder stop];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecoder.url error:nil];
    [self.audioPlayer play];
}

- (void)prepareForRecording
{
    NSArray *recordingPathComponents =
    [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains
                               (NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"My-Recording.m4a",nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:recordingPathComponents];
    
    NSMutableDictionary *audioRecoderSettings = [[NSMutableDictionary alloc] init];
    
    [audioRecoderSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [audioRecoderSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [audioRecoderSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    NSError *error = nil;
    self.audioRecoder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:audioRecoderSettings error:&error];
    if (error){
        NSLog(@"Init audioRecorder error: %@",error);
    } else {
        self.audioRecoder.meteringEnabled = YES;
        self.audioRecoder.delegate = self;
        [self.audioRecoder prepareToRecord];
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"Recort ended");
    [self enableMettering:NO];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"Play ended");
}

-(void)checkRecordingMeters:(NSTimer *)timer
{
    //发送updateMeters消息来刷新平均和峰值功率。此计数是以对数刻度计量的，-160表示完全安静，0表示最大输入值
    [self.audioRecoder updateMeters];
    
    const double ALPHA = 0.05;
    float peakPower = [self.audioRecoder peakPowerForChannel:0];
    
    double peakPowerForChannel = pow(10, (0.05 * peakPower));
    self.lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * self.lowPassResults;
    
    NSLog(@"Meters: %f" , peakPower);
    NSLog(@"lowPassResults: %f \n" , self.lowPassResults);
}


//2. Call this method to run a loop timer to check the current mic activity
-(void)enableMettering:(BOOL)enable
{
    
    if(enable)
    {
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                       target:self
                                                     selector:@selector(checkRecordingMeters:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
    else
    {
        [self.levelTimer invalidate];
    }
}
@end
