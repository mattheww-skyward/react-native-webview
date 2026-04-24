#import "RNCWebsiteDataStoreManager.h"
#import "RNCWebViewModule.h"

#import "RNCWebViewDecisionManager.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTFabricComponentsPlugins.h>
#endif /* RCT_NEW_ARCH_ENABLED */

@implementation RNCWebViewModule

RCT_EXPORT_MODULE(RNCWebViewModule)


RCT_EXPORT_METHOD(flushCookies:(NSString *)profile resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  [RNCWebsiteDataStoreManager flushCookiesForProfile:profile completion:^(NSError * _Nullable err) {
    if (err) {
      reject(@"flush_error", @"Failed to flush cookies", err);
    } else {
      resolve(@(YES));
    }
  }];
}

RCT_EXPORT_METHOD(removeDataStore:(NSString *)profile resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  [RNCWebsiteDataStoreManager removeDataStoreForProfile:profile completion:^(NSError * _Nullable err) {
    if (err) {
      reject(@"remove_error", @"Failed to remove data store", err);
    } else {
      resolve(@(YES));
    }
  }];
}

RCT_EXPORT_METHOD(isFileUploadSupported:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  if (resolve) {
    resolve(@(YES));
  }
}

RCT_EXPORT_METHOD(shouldStartLoadWithLockIdentifier:(BOOL)shouldStart lockIdentifier:(double)lockIdentifier)
{
    [[RNCWebViewDecisionManager getInstance] setResult:shouldStart forLockIdentifier:(int)lockIdentifier];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNCWebViewModuleSpecJSI>(params);
}
#endif /* RCT_NEW_ARCH_ENABLED */

Class RNCWebViewModuleCls(void) {
  return RNCWebViewModule.class;
}

@end
