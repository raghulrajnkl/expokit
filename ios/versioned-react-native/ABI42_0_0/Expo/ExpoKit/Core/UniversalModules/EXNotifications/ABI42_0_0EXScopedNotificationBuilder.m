// Copyright 2018-present 650 Industries. All rights reserved.

#import "ABI42_0_0EXScopedNotificationBuilder.h"
#import "ABI42_0_0EXScopedNotificationsUtils.h"

@interface ABI42_0_0EXScopedNotificationBuilder ()

@property (nonatomic, strong) NSString *experienceId;
@property (nonatomic, assign) BOOL isInExpoGo;

@end

@implementation ABI42_0_0EXScopedNotificationBuilder

- (instancetype)initWithExperienceId:(NSString *)experienceId
                 andConstantsBinding:(ABI42_0_0EXConstantsBinding *)constantsBinding
{
  if (self = [super init]) {
    _experienceId = experienceId;
    _isInExpoGo = [@"expo" isEqualToString:constantsBinding.appOwnership];
  }
  
  return self;
}

- (UNNotificationContent *)notificationContentFromRequest:(NSDictionary *)request
{
  UNMutableNotificationContent *content = [super notificationContentFromRequest:request];
  NSMutableDictionary *userInfo = [content.userInfo mutableCopy];
  if (!userInfo) {
    userInfo = [NSMutableDictionary dictionary];
  }
  userInfo[@"experienceId"] = _experienceId;
  [content setUserInfo:userInfo];
  
  if (content.categoryIdentifier && _isInExpoGo) {
    NSString *scopedCategoryIdentifier = [ABI42_0_0EXScopedNotificationsUtils scopedIdentifierFromId:content.categoryIdentifier
                                                                              forExperience:_experienceId];
    [content setCategoryIdentifier:scopedCategoryIdentifier];
  }
  
  return content;
}

@end
