// Copyright 2018-present 650 Industries. All rights reserved.

#if __has_include(<ABI39_0_0EXNotifications/ABI39_0_0EXNotificationsEmitter.h>)

#import "ABI39_0_0EXScopedNotificationsEmitter.h"
#import "ABI39_0_0EXScopedNotificationsUtils.h"
#import "ABI39_0_0EXScopedNotificationSerializer.h"

@interface ABI39_0_0EXScopedNotificationsEmitter ()

@property (nonatomic, strong) NSString *scopeKey;

@end

@implementation ABI39_0_0EXScopedNotificationsEmitter

- (instancetype)initWithScopeKey:(NSString *)scopeKey
{
  if (self = [super init]) {
    _scopeKey = scopeKey;
  }

  return self;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
  if ([ABI39_0_0EXScopedNotificationsUtils shouldNotification:response.notification beHandledByExperience:_scopeKey]) {
    [self.eventEmitter sendEventWithName:onDidReceiveNotificationResponse body:[ABI39_0_0EXScopedNotificationSerializer serializedNotificationResponse:response]];
  }

  completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
  if ([ABI39_0_0EXScopedNotificationsUtils shouldNotification:notification beHandledByExperience:_scopeKey]) {
    [self.eventEmitter sendEventWithName:onDidReceiveNotification body:[ABI39_0_0EXScopedNotificationSerializer serializedNotification:notification]];
  }

  completionHandler(UNNotificationPresentationOptionNone);
}

@end

#endif
