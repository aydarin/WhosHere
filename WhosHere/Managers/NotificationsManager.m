


#import "NotificationsManager.h"

@implementation NotificationsManager

+ (instancetype)sharedManager {
    static NotificationsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void) cancelAllNotifications
{
    NSLog(@"all notif cancelled");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void) scheduleNotificationForPerson:(Person*)person
{
    [self cancelAllNotifications];
    
    if (!person || !person.isOnline || !person.onlineSinceDate) {
        return;
    }
    
    NSString* text = @"Time is out";
    NSDate *date = [person.onlineSinceDate dateByAddingTimeInterval:person.maxOnlineTimeInterval];
    
    [self scheduleNotificationWithText:text date:date];
}

- (void) scheduleNotificationWithText:(NSString*)text date:(NSDate*) date
{
    if ([date compare:[NSDate date]] == NSOrderedAscending) return;
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = text;
    
	// Set the action button
    localNotif.alertAction = @"Look";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
	// Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

@end
