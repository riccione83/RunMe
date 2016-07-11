#import "HKManager.h"


static NSString *kHKManagerErrorDomain = @"HKManagerErrorDomain";
static NSString *kHKManagerErrorMessageKey = @"HKManagerErrorMessageKey";

#pragma mark - Custom unit

@interface HKUnit (HKManager)
+ (HKUnit *)heartBeatsPerMinuteUnit;
@end

@implementation HKUnit (HKManager)

+ (HKUnit *)heartBeatsPerMinuteUnit {
    return [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
}

@end


#pragma mark - Custom error

@implementation NSError (HKManager)
- (NSString *)hkManagerErrorMessage {
    return self.userInfo[kHKManagerErrorMessageKey];
}
+ (NSError *)hkManagerErrorWithMessage:(NSString *)errorMessage {
    return
    [NSError errorWithDomain:kHKManagerErrorDomain code:0 userInfo:@{kHKManagerErrorMessageKey: errorMessage}];
}
@end


#pragma mark - HKManager singleton functinality

@implementation HKManager

+ (instancetype)sharedManager {
    static HKManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HKManager new];
    });
    return manager;
}

#pragma mark - Authorizations
- (void)authorizeWithCompletion:(void (^)(NSError *error))completion {
    if(![HKHealthStore isHealthDataAvailable]) {
        if(completion) {
            completion([NSError hkManagerErrorWithMessage:@"This device has not support HealthKit"]);
        }
        return;
    }
    
    if(!store) {
        store = [HKHealthStore new];
    }

    [store requestAuthorizationToShareTypes:[self shareTypes]
                                  readTypes:[self readTypes] completion:^(BOOL success, NSError *error) {
                                      if(error && completion) {
                                          completion([NSError hkManagerErrorWithMessage:error.localizedDescription]);
                                      }
                                  }];
}

- (NSSet *)shareTypes {
    return [NSSet setWithObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
}

- (NSSet *)readTypes {
    return [NSSet set];
}

#pragma mark - Beats tracker

- (void)storeHeartBeatsAtMinute:(double)beats
                      startDate:(NSDate *)startDate endDate:(NSDate *)endDate
                     completion:(void (^)(NSError *error))compeltion
{
    HKQuantityType *rateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantity *rateQuantity = [HKQuantity quantityWithUnit:[HKUnit heartBeatsPerMinuteUnit]
                                                doubleValue:(double)beats];
    HKQuantitySample *rateSample = [HKQuantitySample quantitySampleWithType:rateType
                                                                   quantity:rateQuantity
                                                                  startDate:startDate
                                                                    endDate:endDate];
    
    [store saveObject:rateSample withCompletion:^(BOOL success, NSError *error) {
        if(compeltion) {
            compeltion(error);
        }
    }];
}


@end
