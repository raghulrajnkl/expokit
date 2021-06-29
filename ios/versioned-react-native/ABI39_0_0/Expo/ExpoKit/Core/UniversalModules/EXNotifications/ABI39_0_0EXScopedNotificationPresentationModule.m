// Copyright 2018-present 650 Industries. All rights reserved.

#import "ABI39_0_0EXScopedNotificationPresentationModule.h"
#import "ABI39_0_0EXScopedNotificationsUtils.h"
#import "ABI39_0_0EXScopedNotificationSerializer.h"

@interface ABI39_0_0EXScopedNotificationPresentationModule ()

@property (nonatomic, strong) NSString *scopeKey;

@end

@implementation ABI39_0_0EXScopedNotificationPresentationModule

- (instancetype)initWithScopeKey:(NSString *)scopeKey
{
  if (self = [super init]) {
    _scopeKey = scopeKey;
  }

  return self;
}

- (NSArray * _Nonnull)serializeNotifications:(NSArray<UNNotification *> * _Nonnull)notifications
{
  NSMutableArray *serializedNotifications = [NSMutableArray new];
  for (UNNotification *notification in notifications) {
    if ([ABI39_0_0EXScopedNotificationsUtils shouldNotification:notification beHandledByExperience:_scopeKey]) {
      [serializedNotifications addObject:[ABI39_0_0EXScopedNotificationSerializer serializedNotification:notification]];
    }
  }
  return serializedNotifications;
}

- (void)dismissNotificationWithIdentifier:(NSString *)identifier resolve:(ABI39_0_0UMPromiseResolveBlock)resolve reject:(ABI39_0_0UMPromiseRejectBlock)reject
{
  __block NSString *scopeKey = _scopeKey;
  [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
    for (UNNotification *notification in notifications) {
      if ([notification.request.identifier isEqual:identifier]) {
        if ([ABI39_0_0EXScopedNotificationsUtils shouldNotification:notification beHandledByExperience:scopeKey]) {
          [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[identifier]];
        }
        break;
      }
    }
    resolve(nil);
  }];
}

- (void)dismissAllNotificationsWithResolver:(ABI39_0_0UMPromiseResolveBlock)resolve reject:(ABI39_0_0UMPromiseRejectBlock)reject
{
  __block NSString *scopeKey = _scopeKey;
  [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
    NSMutableArray<NSString *> *toDismiss = [NSMutableArray new];
    for (UNNotification *notification in notifications) {
      if ([ABI39_0_0EXScopedNotificationsUtils shouldNotification:notification beHandledByExperience:scopeKey]) {
        [toDismiss addObject:notification.request.identifier];
      }
    }
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:toDismiss];
    resolve(nil);
  }];
}

@end
