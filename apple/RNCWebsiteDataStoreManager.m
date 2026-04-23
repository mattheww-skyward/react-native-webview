#import "RNCWebsiteDataStoreManager.h"

@implementation RNCWebsiteDataStoreManager

+ (NSMutableDictionary<NSString *, WKWebsiteDataStore *> *)cache {
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary new];
    });
    return dict;
}

+ (WKWebsiteDataStore *)dataStoreForProfileUUID:(NSUUID *)uuid {
    if (!uuid) {
        return [WKWebsiteDataStore defaultDataStore];
    }
    NSString *key = uuid.UUIDString;
    NSMutableDictionary *cache = [self cache];
    WKWebsiteDataStore *store = cache[key];
    if (store) {
        NSLog(@"RNCWebsiteDataStoreManager: cache hit for %@", key);
        return store;
    }

    if (@available(iOS 17.0, macOS 14.0, *)) {
        NSLog(@"RNCWebsiteDataStoreManager: creating data store for %@ (iOS17 API)", key);
        WKWebsiteDataStore *newStore = [WKWebsiteDataStore dataStoreForIdentifier:uuid];
        if (newStore) {
            cache[key] = newStore;
            return newStore;
        }
    } else {
        NSLog(@"RNCWebsiteDataStoreManager: dataStoreForIdentifier unavailable, falling back to defaultDataStore for %@", key);
    }

    WKWebsiteDataStore *defaultStore = [WKWebsiteDataStore defaultDataStore];
    cache[key] = defaultStore;
    return defaultStore;
}

+ (void)flushCookiesForProfile:(NSString *)profile completion:(void(^)(NSError * _Nullable))completion {
    if (!profile) {
        if (completion) completion(nil);
        return;
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:profile];
    WKWebsiteDataStore *store = [self dataStoreForProfileUUID:uuid];
    NSLog(@"RNCWebsiteDataStoreManager: flushCookiesForProfile start %@", profile);
    [store.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
        NSLog(@"RNCWebsiteDataStoreManager: getAllCookies returned %lu cookies", (unsigned long)cookies.count);
        if (completion) completion(nil);
    }];
}

@end
