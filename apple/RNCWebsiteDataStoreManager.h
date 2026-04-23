#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNCWebsiteDataStoreManager : NSObject

+ (WKWebsiteDataStore *)dataStoreForProfileUUID:(NSUUID * _Nullable)uuid;

+ (void)flushCookiesForProfile:(NSString * _Nullable)profile completion:(void(^)(NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
