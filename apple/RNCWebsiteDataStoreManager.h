#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNCWebsiteDataStoreManager : NSObject

+ (WKWebsiteDataStore *)dataStoreForProfileUUID:(NSUUID * _Nullable)uuid;

+ (void)removeDataStoreForProfile:(NSString * _Nullable)profile completion:(void(^ _Nullable)(NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
