


#import <Foundation/Foundation.h>
#import "Person.h"

#define NM [NotificationsManager sharedManager]

@interface NotificationsManager : NSObject

+ (instancetype)sharedManager;

- (void) cancelAllNotifications;
- (void) scheduleNotificationForPerson:(Person*)person;

@end
