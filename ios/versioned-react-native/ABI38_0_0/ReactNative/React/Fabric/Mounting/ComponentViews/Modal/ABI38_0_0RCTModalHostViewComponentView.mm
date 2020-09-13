/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI38_0_0RCTModalHostViewComponentView.h"

#import <ABI38_0_0React/ABI38_0_0UIView+React.h>
#import <ABI38_0_0React/components/modal/ModalHostViewComponentDescriptor.h>
#import <ABI38_0_0React/components/modal/ModalHostViewState.h>
#import <ABI38_0_0React/components/rncore/EventEmitters.h>
#import <ABI38_0_0React/components/rncore/Props.h>

#import "ABI38_0_0RCTConversions.h"
#import "ABI38_0_0RCTFabricModalHostViewController.h"

using namespace ABI38_0_0facebook::ABI38_0_0React;

#if !TARGET_OS_TV
static UIInterfaceOrientationMask supportedOrientationsMask(ModalHostViewSupportedOrientationsMask mask)
{
  UIInterfaceOrientationMask supportedOrientations = 0;

  if (mask & ModalHostViewSupportedOrientations::Portrait) {
    supportedOrientations |= UIInterfaceOrientationMaskPortrait;
  }

  if (mask & ModalHostViewSupportedOrientations::PortraitUpsideDown) {
    supportedOrientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
  }

  if (mask & ModalHostViewSupportedOrientations::Landscape) {
    supportedOrientations |= UIInterfaceOrientationMaskLandscape;
  }

  if (mask & ModalHostViewSupportedOrientations::LandscapeLeft) {
    supportedOrientations |= UIInterfaceOrientationMaskLandscapeLeft;
  }

  if (mask & ModalHostViewSupportedOrientations::LandscapeRight) {
    supportedOrientations |= UIInterfaceOrientationMaskLandscapeRight;
  }

  if (supportedOrientations == 0) {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      return UIInterfaceOrientationMaskAll;
    } else {
      return UIInterfaceOrientationMaskPortrait;
    }
  }

  return supportedOrientations;
}
#endif

static std::tuple<BOOL, UIModalTransitionStyle> animationConfiguration(ModalHostViewAnimationType const animation)
{
  switch (animation) {
    case ModalHostViewAnimationType::None:
      return std::make_tuple(NO, UIModalTransitionStyleCoverVertical);
    case ModalHostViewAnimationType::Slide:
      return std::make_tuple(YES, UIModalTransitionStyleCoverVertical);
    case ModalHostViewAnimationType::Fade:
      return std::make_tuple(YES, UIModalTransitionStyleCrossDissolve);
  }
}

static UIModalPresentationStyle presentationConfiguration(ModalHostViewProps const &props)
{
  if (props.transparent) {
    return UIModalPresentationOverFullScreen;
  }
  switch (props.presentationStyle) {
    case ModalHostViewPresentationStyle::FullScreen:
      return UIModalPresentationFullScreen;
    case ModalHostViewPresentationStyle::PageSheet:
      return UIModalPresentationPageSheet;
    case ModalHostViewPresentationStyle::FormSheet:
      return UIModalPresentationFormSheet;
    case ModalHostViewPresentationStyle::OverFullScreen:
      return UIModalPresentationOverFullScreen;
  }
}

static ModalHostViewOnOrientationChangeStruct onOrientationChangeStruct(CGRect rect)
{
  auto orientation = rect.size.width < rect.size.height ? ModalHostViewOnOrientationChangeOrientationStruct::Portrait
                                                        : ModalHostViewOnOrientationChangeOrientationStruct::Landscape;
  return {orientation};
}

@interface ABI38_0_0RCTModalHostViewComponentView () <ABI38_0_0RCTFabricModalHostViewControllerDelegate>

@end

@implementation ABI38_0_0RCTModalHostViewComponentView {
  ABI38_0_0RCTFabricModalHostViewController *_viewController;
  ModalHostViewShadowNode::ConcreteState::Shared _state;
  BOOL _shouldAnimatePresentation;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const ModalHostViewProps>();
    _props = defaultProps;
    _shouldAnimatePresentation = YES;
    _viewController = [ABI38_0_0RCTFabricModalHostViewController new];
    _viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    _viewController.delegate = self;
  }

  return self;
}

- (BOOL)isViewControllerPresented
{
  return _viewController.presentingViewController != nil;
}

- (void)ensurePresentedOnlyIfNeeded
{
  BOOL shouldBePresented = !self.isViewControllerPresented && self.window;
  if (shouldBePresented) {
    UIViewController *controller = [self ABI38_0_0ReactViewController];
    return [controller
        presentViewController:_viewController
                     animated:_shouldAnimatePresentation
                   completion:^{
                     if (!self->_eventEmitter) {
                       return;
                     }

                     assert(std::dynamic_pointer_cast<ModalHostViewEventEmitter const>(self->_eventEmitter));
                     auto eventEmitter = std::static_pointer_cast<ModalHostViewEventEmitter const>(self->_eventEmitter);
                     eventEmitter->onShow(ModalHostViewOnShowStruct{});
                   }];
  }

  BOOL shouldBeHidden = self.isViewControllerPresented && !self.superview;
  if (shouldBeHidden) {
    [_viewController dismissViewControllerAnimated:_shouldAnimatePresentation completion:nil];
  }
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];
  [self ensurePresentedOnlyIfNeeded];
}

- (void)didMoveToSuperview
{
  [super didMoveToSuperview];
  [self ensurePresentedOnlyIfNeeded];
}

#pragma mark - ABI38_0_0RCTFabricModalHostViewControllerDelegate

- (void)boundsDidChange:(CGRect)newBounds
{
  if (_eventEmitter) {
    assert(std::dynamic_pointer_cast<ModalHostViewEventEmitter const>(_eventEmitter));

    auto eventEmitter = std::static_pointer_cast<ModalHostViewEventEmitter const>(_eventEmitter);
    eventEmitter->onOrientationChange(onOrientationChangeStruct(newBounds));
  }

  if (_state != nullptr) {
    auto newState = ModalHostViewState{ABI38_0_0RCTSizeFromCGSize(newBounds.size)};
    _state->updateState(std::move(newState));
  }
}

#pragma mark - ABI38_0_0RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<ModalHostViewComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &newProps = *std::static_pointer_cast<const ModalHostViewProps>(props);

#if !TARGET_OS_TV
  _viewController.supportedInterfaceOrientations = supportedOrientationsMask(newProps.supportedOrientations);
#endif

  std::tuple<BOOL, UIModalTransitionStyle> result = animationConfiguration(newProps.animationType);
  _shouldAnimatePresentation = std::get<0>(result);
  _viewController.modalTransitionStyle = std::get<1>(result);

  _viewController.modalPresentationStyle = presentationConfiguration(newProps);

  [super updateProps:props oldProps:oldProps];
}

- (void)updateState:(ABI38_0_0facebook::ABI38_0_0React::State::Shared const &)state
           oldState:(ABI38_0_0facebook::ABI38_0_0React::State::Shared const &)oldState
{
  _state = std::static_pointer_cast<const ModalHostViewShadowNode::ConcreteState>(state);
}

- (void)mountChildComponentView:(UIView<ABI38_0_0RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  [_viewController.view insertSubview:childComponentView atIndex:index];
}

- (void)unmountChildComponentView:(UIView<ABI38_0_0RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  [childComponentView removeFromSuperview];
}

@end