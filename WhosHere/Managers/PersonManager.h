//
//  PersonManager.h
//  OnlineStatusTask
//
//  Created by Aydar Mukhametzyanov on 25/06/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

#define PERSONS_DATA_CHANGED_NOTIFICATION @"PersonsDataChangedNotification"
#define TIMER_TICK_NOTIFICATION @"TimerTickNotification"
#define PM [PersonManager shared]

@interface PersonManager : NSObject

@property (nonatomic, retain) NSMutableArray* onlinePersons;
@property (nonatomic, retain) Person* selfPerson;

+ (instancetype)shared;

- (void)loadOnlinePersonsListWithCompletion:(void(^)(BOOL success))completeBlock;
- (void)setSelfOnlineStatus:(BOOL)isOnline completion:(void(^)(BOOL success))completeBlock;

@end
