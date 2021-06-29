// Copyright 2018-present 650 Industries. All rights reserved.

#import "ABI39_0_0EXScopedNotificationSchedulerModule.h"
#import "ABI39_0_0EXScopedNotificationsUtils.h"
#import "ABI39_0_0EXScopedNotificationSerializer.h"

@interface ABI39_0_0EXScopedNotificationSchedulerModule ()

@property (nonatomic, strong) NSString *scopeKey;

@end

// TODO: (@lukmccall) experiences may break one another by trying to schedule notifications of the same identifier.
// See https://github.com/expo/expo/pull/8361#discussion_r429153429.
@implementation ABI39_0_0EXScopedNotificationSchedulerModule

- (instancetype)initWithScopeKey:(NSString *)scopeKey
{
  if (self = [super init]) {
    _scopeKey = scopeKey;
  }

  return self;
}

- (NSArray * _Nonnull)serializeNotificationRequests:(NSArray<UNNotificationRequest *> * _Nonnull) requests;
{
  NSMutableArray *serializedRequests = [NSMutableArray new];
  for (UNNotificationRequest *request in requests) {
    if ([ABI39_0_0EXScopedNotificationsUtils shouldNotificationRequest:request beHandledByExperience:_scopeKey]) {
      [serializedRequests addObject:[ABI39_0_0EXScopedNotificationSerializer serializedNotificationRequest:request]];
    }
  }
  return serializedRequests;
}

- (void)cancelNotification:(NSString *)identifier resolve:(ABI39_0_0UMPromiseResolveBlock)resolve rejecting:(ABI39_0_0UMPromiseRejectBlock)reject
{
  __block NSString *scopeKey = _scopeKey;
  [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
    for (UNNotificationRequest *request in requests) {
      if ([request.identifier isEqual:identifier]) {
        if ([ABI39_0_0EXScopedNotificationsUtils shouldNotificationRequest:request beHandledByExperience:scopeKey]) {
          [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];
        }
        break;
      }
    }
    resolve(nil);
  }];
}

- (void)cancelAllNotificationsWithResolver:(ABI39_0_0UMPromiseResolveBlock)resolve rejecting:(ABI39_0_0UMPromiseRejectBlock)reject
{
  __block NSString *scopeKey = _scopeKey;
  [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
    NSMutableArray<NSString *> *toRemove = [NSMutableArray new];
    for (UNNotificationRequest *request in requests) {
      if ([ABI39_0_0EXScopedNotificationsUtils shouldNotificationRequest:request beHandledByExperience:scopeKey]) {
        [toRemove addObject:request.identifier];
      }
    }
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:toRemove];
    resolve(nil);
  }];
}

@end
