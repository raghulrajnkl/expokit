/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <ABI37_0_0React/ABI37_0_0RCTAdditionAnimatedNode.h>

@implementation ABI37_0_0RCTAdditionAnimatedNode

- (void)performUpdate
{
  [super performUpdate];
  NSArray<NSNumber *> *inputNodes = self.config[@"input"];
  if (inputNodes.count > 1) {
    ABI37_0_0RCTValueAnimatedNode *parent1 = (ABI37_0_0RCTValueAnimatedNode *)[self.parentNodes objectForKey:inputNodes[0]];
    ABI37_0_0RCTValueAnimatedNode *parent2 = (ABI37_0_0RCTValueAnimatedNode *)[self.parentNodes objectForKey:inputNodes[1]];
    if ([parent1 isKindOfClass:[ABI37_0_0RCTValueAnimatedNode class]] &&
        [parent2 isKindOfClass:[ABI37_0_0RCTValueAnimatedNode class]]) {
      self.value = parent1.value + parent2.value;
    }
  }
}

@end