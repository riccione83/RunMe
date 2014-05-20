//
//  FileSupport.h
//  bykeMe
//
//  Created by Riccardo Rizzo on 19/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSupport : NSObject {
    NSString *fileName;
}

@property (strong) NSString *fileName;

-(NSString *) saveFilePath;
-(void) writeStringToFile:(NSString *) strToWrite;
-(void) writeDataToFile:(NSMutableArray *) arrToWrite;
-(void) writeDataToFile:(NSMutableArray *) arrToWrite fileToWrite:(NSString *)fname;
-(NSMutableArray *) readDataFromFile;
-(NSMutableArray *) readDataFromFile:(NSString *)fName;
-(NSString *) readStringFromFile;
-(BOOL) fileExist;
    
@end
