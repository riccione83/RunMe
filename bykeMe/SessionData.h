//
//  SessionFile.h
//  RunMe!
//
//  Created by Riccardo Rizzo on 19/04/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionData : NSObject {
    NSMutableArray *Dates;
    NSMutableArray *Distances;
    NSMutableArray *MaxSpeeds;
    NSMutableArray *AvgSpeeds;
    NSMutableArray *Altitudes;
    NSMutableArray *Rythms;
    NSMutableArray *imagesSession;
    
    NSString *Date;
    NSInteger Distance;
    NSInteger MaxSpeed;
    NSInteger AvgSpeed;
    NSInteger Altitude;
    NSString *Rythm;
    UIImage *imageSession;
    
}

-(BOOL)saveNewSession:(NSMutableArray*)data;
-(BOOL)saveSessions;
-(BOOL)loadSession;

@property (strong, nonatomic) NSMutableArray *Dates;
@property (strong, nonatomic) NSMutableArray *Distances;
@property (strong, nonatomic) NSMutableArray *MaxSpeeds;
@property (strong, nonatomic) NSMutableArray *AvgSpeeds;
@property (strong, nonatomic) NSMutableArray *Altitudes;
@property (strong, nonatomic) NSMutableArray *Rythms;
@property (strong, nonatomic) NSMutableArray *imagesSession;

@end
