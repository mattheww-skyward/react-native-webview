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

+ (dispatch_queue_t)cacheQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.rnc.webview.datastore", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (WKWebsiteDataStore *)dataStoreForProfileUUID:(NSUUID *)uuid {
    if (!uuid) {
        return [WKWebsiteDataStore defaultDataStore];
    }

    if (@available(iOS 17.0, macOS 14.0, *)) {
        // Handled below with caching.
    } else {
        return [WKWebsiteDataStore dataStoreForIdentifier:uuid];
    }

    NSString *key = uuid.UUIDString;
    __block WKWebsiteDataStore *result = nil;
    dispatch_sync([self cacheQueue], ^{
        NSMutableDictionary *cache = [self cache];
        result = cache[key];
        if (!result) {
            if (@available(iOS 17.0, macOS 14.0, *)) {
                result = [WKWebsiteDataStore dataStoreForIdentifier:uuid];
                if (result) {
                    cache[key] = result;
                }
            }
        }
    });
    return result;
}

+ (void)removeDataStoreForProfile:(NSString *)profile completion:(void(^)(NSError * _Nullable))completion {
    NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] called with profile.");
    if (!profile.length) {
        if (completion) {
            completion([NSError errorWithDomain:@"RNCWebsiteDataStoreManager"
                                           code:1
                                       userInfo:@{NSLocalizedDescriptionKey: @"Missing profile identifier"}]);
        }
        NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] missing profile identifier");
        return;
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:profile];
    if (!uuid) {
        if (completion) {
            completion([NSError errorWithDomain:@"RNCWebsiteDataStoreManager"
                                           code:2
                                       userInfo:@{NSLocalizedDescriptionKey: @"Invalid profile UUID"}]);
        }
        NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] invalid profile UUID");
        return;
    }

    NSString *key = uuid.UUIDString;
    NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] starting removal for key.");
    WKWebsiteDataStore *store = [self dataStoreForProfileUUID:uuid];
    NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] obtained store.");
    NSSet *allTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] all data types.");
    NSDate *epoch = [NSDate distantPast];
    NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] epoch.");

    NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] starting removal for key: %@, store: %@, types: %@, modifiedSince: %@", key, store, allTypes, epoch);

    [store removeDataOfTypes:allTypes modifiedSince:epoch completionHandler:^{
        NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] removeDataOfTypes completion handler called for key: %@", key);
        dispatch_async([self cacheQueue], ^{
            NSLog(@"[RNCWebsiteDataStoreManager][removeDataStoreForProfile] removing cache entry for key: %@", key);
            [[self cache] removeObjectForKey:key];
        });
        if (completion) completion(nil);
    }];
}

@end