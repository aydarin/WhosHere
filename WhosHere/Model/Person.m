//
//  Person.m
//  OnlineStatusTask
//
//  Created by Aydar Mukhametzyanov on 25/06/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "Person.h"

@implementation Person

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setupDefaults];
        [self createPFPerson];
    }
    
    return self;
}

- (id)initWithPFPerson:(PFObject*)pfPerson
{
    self = [super init];
    
    if (self)
    {
        [self setupDefaults];
        self.pfPerson = pfPerson;
    }
    
    return self;
}

- (void)setupDefaults
{
    _maxOnlineTimeInterval = 3600;
    self.isOnline = NO;
    self.udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.onlineSinceDate = [NSDate date];
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    
    if ([object isKindOfClass:[Person class]])
    {
        Person* otherPerson = (Person*)object;
        
        isEqual = [self.udid isEqualToString:otherPerson.udid];
    }
    
    return isEqual;
}

- (void)setPfPerson:(PFObject *)pfPerson
{
    _pfPerson = pfPerson;
    
    [self updateFromPFPerson];
}

- (void)updateFromPFPerson
{
    _udid = _pfPerson[@"udid"];
    _onlineSinceDate = _pfPerson[@"online_since_date"];
    _isOnline = [_pfPerson[@"is_online"] boolValue];
}

- (void)writeToPFPerson
{
    _pfPerson[@"udid"] = _udid;
    _pfPerson[@"online_since_date"] = _onlineSinceDate;
    _pfPerson[@"is_online"] = @(_isOnline);
}

- (PFObject*)createPFPerson
{
    _pfPerson = [PFObject objectWithClassName:@"Person"];
    [self writeToPFPerson];
    
    return _pfPerson;
}

- (void)saveWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion
{
    [self writeToPFPerson];
    
    if (_isOnline)
    {
        [_pfPerson saveInBackgroundWithBlock:completion];
    }
    else
    {
        [_pfPerson deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded || error.code == 101)
            {
                [self createPFPerson];
            }
            
            if (completion) completion(succeeded, error);
        }];
    }
}

@end
