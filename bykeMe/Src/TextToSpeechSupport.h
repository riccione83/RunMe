//
//  TextToSpeechSupport.h
//  RunMe!
//
//  Created by Riccardo Rizzo on 22/04/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MainDelegate

- (void)restartMusic;

@end

@interface TextToSpeechSupport : NSObject <AVSpeechSynthesizerDelegate> {
    
    NSString *language;
}

@property (nonatomic) id<MainDelegate> delegate;

-(void)speech:(NSString *)textToSpeech;

@end
