#import "RNCWebsiteDataStoreManager.h"

@implementation RNCWebsiteDataStoreManager
/*
 Hold references to per-profile `WKWebsiteDataStore` instances in a 
 cache so the same store instance is reused across WebViews ensuring
 auth tokens are persisted. This is needed because short lived webviews
 do not persist data to disk.
*/

+ (NSMutableDictionary<NSString *, WKWebsiteDataStore *> *)cache {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary new];
    });
    return dict;
}

+ (WKWebsiteDataStore *)dataStoreForProfileUUID:(NSUUID * _Nullable)uuid {
    /*
     Return the profile-specific `WKWebsiteDataStore` when available (iOS 17+/macOS 14+).
     @synchronized guards cache access to avoid races.
    */
    if (!uuid) {
        return [WKWebsiteDataStore defaultDataStore];
    }

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 170000) || \
    (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 140000)
    if (@available(iOS 17.0, macOS 14.0, *)) {
        NSString *key = uuid.UUIDString;
        WKWebsiteDataStore *result = nil;
        @synchronized([self cache]) {
            result = [self cache][key];
        }
        if (!result) {
            result = [WKWebsiteDataStore dataStoreForIdentifier:uuid];
            if (result) {
                @synchronized([self cache]) {
                    [self cache][key] = result;
                }
            }
        }
        return result;
    }
#endif

    return [WKWebsiteDataStore defaultDataStore];
}

+ (void)removeDataStoreForProfile:(NSString * _Nullable)profile completion:(void(^ _Nullable)(NSError * _Nullable))completion {
    if (!profile.length) {
        if (completion) {
            completion([NSError errorWithDomain:@"RNCWebsiteDataStoreManager"
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey: @"Missing profile identifier"}]);
        }
        return;
    }

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:profile];
    if (!uuid) {
        if (completion) {
            completion([NSError errorWithDomain:@"RNCWebsiteDataStoreManager"
                                           code:2
                                       userInfo:@{NSLocalizedDescriptionKey: @"Invalid profile UUID"}]);
        }
        return;
    }

    if (@available(iOS 17.0, macOS 14.0, *)) {
        NSString *key = uuid.UUIDString;
        dispatch_async(dispatch_get_main_queue(), ^{
            WKWebsiteDataStore *store = [self dataStoreForProfileUUID:uuid];
            if (!store) {
                if (completion) completion(nil);
                return;
            }

            NSSet *allTypes = [WKWebsiteDataStore allWebsiteDataTypes];
            NSDate *epoch = [NSDate distantPast];
            [store removeDataOfTypes:allTypes modifiedSince:epoch completionHandler:^{
                @synchronized([self cache]) {
                    [[self cache] removeObjectForKey:key];
                }
                if (completion) completion(nil);
            }];
        });
    } else {
        if (completion) completion(nil);
    }
}

@end