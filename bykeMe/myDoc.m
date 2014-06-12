//
//  myDoc.m
//  OnTheBeach
//
//  Created by Riccardo Rizzo on 05/06/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "myDoc.h"

@implementation myDoc

@synthesize data;

-(id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSData *nData = [NSKeyedArchiver archivedDataWithRootObject:data];
    return [NSData dataWithData:nData];
}

-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if([contents length] > 0) {
        
        self.data = [NSKeyedUnarchiver unarchiveObjectWithData:contents];
        //self.text = [[NSString alloc] initWithBytes:[contents bytes] length:[contents length] encoding:NSUTF8StringEncoding];
    }
    else {
        self.data = [[NSMutableArray alloc] init];
    }
    return YES;
}
@end
