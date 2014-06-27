//
//  PersonManager.m
//  OnlineStatusTask
//
//  Created by Aydar Mukhametzyanov on 25/06/14.
//  Copyright (c) 2014 Aydar Mukhametzyanov. All rights reserved.
//

#import "PersonManager.h"

const int LoadOnlinePersonsInterval = 10;

@implementation PersonManager
NSDate* _lastUpdatingDate;
BOOL _isLoading;
dispatch_source_t _timer;

+ (instancetype)shared {
    static PersonManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        
        _selfPerson = [[Person alloc] init];
        _isLoading = NO;
        [self startTimer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerTick) name:TIMER_TICK_NOTIFICATION object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimer];
}

#pragma mark - Requests

- (void)loadOnlinePersonsListWithCompletion:(void(^)(BOOL success))completeBlock
{
    NSLog(@"loadOnlinePersons");
    
    _isLoading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    __weak PersonManager* selfWeak = self;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSMutableArray* persons = [[NSMutableArray alloc] init];
        
        if (!error)
        {
            for (PFObject *object in objects)
            {
                Person* person = [[Person alloc] initWithPFPerson:object];
                [persons addObject:person];
            }
            
            selfWeak.onlinePersons = persons;
            [self popSelfPersonFromOnlinePersons];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONS_DATA_CHANGED_NOTIFICATION object:nil];
        }
        else
        {
            NSLog(@"Error loadOnlinePersons: %@ %@", error, [error userInfo]);
        }
        
        if (completeBlock) completeBlock(!error);
        
        _lastUpdatingDate = [NSDate date];
        _isLoading = NO;
    }];
}

- (void)setSelfOnlineStatus:(BOOL)isOnline completion:(void(^)(BOOL success))completeBlock
{
    NSLog(@"setSelfOnlineStatus: %d", isOnline);
    
    BOOL oldValue = _selfPerson.isOnline;
    _selfPerson.isOnline = isOnline;
    _selfPerson.onlineSinceDate = [NSDate date];
    
    [_selfPerson saveWithCompletion:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"Error save: %@ %@", error, [error userInfo]);
        
        if (!error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PERSONS_DATA_CHANGED_NOTIFICATION object:nil];
        }
        else
        {
            _selfPerson.isOnline = oldValue;
        }
    
        if (completeBlock) completeBlock(succeeded);
    }];
}

#pragma mark - Utils

- (void)popSelfPersonFromOnlinePersons
{
    if ([_onlinePersons containsObject:_selfPerson])
    {
        _selfPerson = _onlinePersons[[_onlinePersons indexOfObject:_selfPerson]];
        [_onlinePersons removeObject:_selfPerson];
    }
    else
    {
        _selfPerson.isOnline = NO;
        _selfPerson.onlineSinceDate = [NSDate date];
    }
}

- (NSMutableArray*)getRandomOnlinePersons
{
    int count = arc4random() % 15;
    NSMutableArray* persons = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        Person* person = [[Person alloc] init];
        person.udid = [NSString stringWithFormat:@"%d", arc4random() % 1000000];
        person.isOnline = YES;
        person.onlineSinceDate = [NSDate date];
        
        [persons addObject:person];
    }
    
    return persons;
}

#pragma mark - Timer

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)startTimer
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    double secondsToFire = 1.000f;
    
    _timer = CreateDispatchTimer(secondsToFire, queue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TIMER_TICK_NOTIFICATION object:nil];
    });
}

- (void)cancelTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)timerTick
{
    if (!_isLoading && PM.selfPerson.isOnline && !PM.selfPerson.pfPerson.isDirty)
    {
        NSDate* now = [NSDate date];
        
        if ([now timeIntervalSinceDate:_lastUpdatingDate] > LoadOnlinePersonsInterval)
        {
            [self loadOnlinePersonsListWithCompletion:nil];
        }
    }
}

@end
