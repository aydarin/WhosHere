//
//  Person.h
//  OnlineStatusTask
//
//  Created by Aydar Mukhametzyanov on 25/06/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Person : NSObject

@property (nonatomic) BOOL isOnline;
@property (nonatomic, retain) NSString* udid;
@property (nonatomic, retain) NSDate* onlineSinceDate;
@property (nonatomic, readonly) NSTimeInterval maxOnlineTimeInterval;

@property (nonatomic, retain) PFObject* pfPerson;

- (id)init;
- (id)initWithPFPerson:(PFObject*)pfPerson;
- (void)saveWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion;

@end
