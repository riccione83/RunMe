//
//  FileSupport.m
//  bykeMe
//
//  Created by Riccardo Rizzo on 19/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "FileSupport.h"

@implementation FileSupport

@synthesize fileName;

-(NSString *) saveFilePath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *fname = [NSString stringWithFormat:@"%@%@",@"/",fileName];
    
    NSLog(@"%@",[[path objectAtIndex:0] stringByAppendingPathComponent:fname]);
    
    return  [[path objectAtIndex:0] stringByAppendingPathComponent:fname];
}

-(void) writeStringToFile:(NSString *) strToWrite {
    [strToWrite writeToFile:[self saveFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"String to file written");
}


-(void) writeDataToFile:(NSMutableArray *) arrToWrite fileToWrite:(NSString *)fname {
    fileName = fname;
    [arrToWrite writeToFile:[self saveFilePath] atomically:YES];
    NSLog(@"Data to file written");
}

-(void) writeDataToFile:(NSMutableArray *) arrToWrite {
    [arrToWrite writeToFile:[self saveFilePath] atomically:YES];
    NSLog(@"Data to file written");
}


-(NSMutableArray *) readDataFromFile:(NSString *)fName {
    
    fileName = fName;
    
    NSString *myPath = [self saveFilePath];
    
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
	if (fileExists)
	{
        
		NSMutableArray *values = [[NSMutableArray alloc] initWithContentsOfFile:myPath];
        return values;
    }
    return nil;
}

-(NSMutableArray *) readDataFromFile {
    NSString *myPath = [self saveFilePath];
    
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
	if (fileExists)
	{
        
		NSMutableArray *values = [[NSMutableArray alloc] initWithContentsOfFile:myPath];
        return values;
    }
    return nil;
}

-(NSString *) readStringFromFile {
    NSString *myPath = [self saveFilePath];
    
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
	if (fileExists)
	{
        
		NSString *values = [[NSString alloc] initWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Readed: %@",values);
        return values;
    }
    return @"";
}

-(BOOL) fileExist {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *fname_tmp = [NSString stringWithFormat:@"%@%@",@"/",fileName];

    NSString *fname = [[path objectAtIndex:0] stringByAppendingPathComponent:fname_tmp];
    
    if (![fileManager fileExistsAtPath:fname]) {
        return true;
        //[fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return false;
}




@end
