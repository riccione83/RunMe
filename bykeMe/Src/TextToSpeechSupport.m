//
//  TextToSpeechSupport.m
//  RunMe!
//
//  Created by Riccardo Rizzo on 22/04/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

#import "TextToSpeechSupport.h"

@implementation TextToSpeechSupport

-(id)init {
    self = [super init];
    if(self) {
        language = NSLocalizedString(@"LANGUAGE", nil);
    }
    return self;
}

-(void)speech:(NSString *)textToSpeech {
    NSString *string = textToSpeech;
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:language];  //en-US
    utterance.rate = 0.1;
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    synthesizer.delegate = self;
    [synthesizer speakUtterance:utterance];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    [self.delegate restartMusic];
}

@end
