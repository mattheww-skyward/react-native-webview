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

    NSString *key = uuid.UUIDString;
    WKWebsiteDataStore *store = [self dataStoreForProfileUUID:uuid];
    NSSet *allTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *epoch = [NSDate distantPast];

    [store removeDataOfTypes:allTypes modifiedSince:epoch completionHandler:^{
        dispatch_async([self cacheQueue], ^{
            [[self cache] removeObjectForKey:key];
            if (completion) completion(nil);
        });
    }];
}

@end