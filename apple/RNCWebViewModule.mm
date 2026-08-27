#import "RNCWebsiteDataStoreManager.h"
#import "RNCWebViewModule.h"

#import "RNCWebViewDecisionManager.h"

#import <React/RCTFabricComponentsPlugins.h>

@implementation RNCWebViewModule

RCT_EXPORT_MODULE(RNCWebViewModule)

RCT_EXPORT_METHOD(removeDataStore:(NSString *)profile resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  [RNCWebsiteDataStoreManager removeDataStoreForProfile:profile completion:^(NSError * _Nullable err) {
    resolve(@(err == nil));
  }];
}

RCT_EXPORT_METHOD(supportsProfiles:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  if (resolve) {
    resolve([RNCWebsiteDataStoreManager unsupportedProfilesProviderName]);
  }
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

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNCWebViewModuleSpecJSI>(params);
}

Class RNCWebViewModuleCls(void) {
  return RNCWebViewModule.class;
}

@end
