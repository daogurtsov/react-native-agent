#import "RNInstana.h"
@import InstanaAgent;

// User
static NSString *currentUserId = @"";
static NSString *currentUserEmail = @"";
static NSString *currentUserName = @"";

// Error
static NSString *const kErrorDomain = @"com.instana.instana-agent-react-native";
static NSInteger const kErrorDomainCodeWrongRegex = -1;

@implementation RNInstana

RCT_EXPORT_MODULE(Instana)

RCT_EXPORT_METHOD(setup:(nonnull NSString *)key reportingUrl:(nonnull NSString *)reportingUrl)
{
    [Instana setupWithKey:key reportingURL:[NSURL URLWithString:reportingUrl]];
}

RCT_EXPORT_METHOD(setView:(nonnull NSString *)viewName)
{
    [Instana setViewWithName: viewName];
}

RCT_EXPORT_METHOD(setUserID:(nonnull NSString *)userID)
{
    currentUserId = userID;
    [self updateUser];
}

RCT_EXPORT_METHOD(setUserName:(nonnull NSString *)userName)
{
    currentUserName = userName;
    [self updateUser];
}

RCT_EXPORT_METHOD(setUserEmail:(nonnull NSString *)userEmail)
{
    currentUserEmail = userEmail;
    [self updateUser];
}

RCT_EXPORT_METHOD(setMeta:(nonnull NSString *)key value:(nonnull NSString*)value)
{
    [Instana setMetaWithValue:value key:key];
}

RCT_EXPORT_METHOD(reportEvent:(nonnull NSString *)name timestamp:(nullable int64_t)timestamp, duration:(nullable int64_t)duration) backendTracingID:(nullable NSString *)backendTracingID error:(nullable NSError *)error meta:(nullable <NSString *, NSString *> *)meta viewName:(nullable NSString *)viewName
{
    [Instana reportEvent: name timestamp: timestamp duration: duration backendTracingID: backendTracingID error: error meta: meta viewName: viewName];
}

// 2nd To ignore the viewName and use the current set name
RCT_EXPORT_METHOD(reportEvent:(nonnull NSString *)name timestamp:(nullable int64_t)timestamp, duration:(nullable int64_t)duration) backendTracingID:(nullable NSString *)backendTracingID error:(nullable NSError *)error meta:(nullable <NSString *, NSString *> *)meta
{
    [Instana reportEvent: name timestamp: timestamp duration: duration backendTracingID: backendTracingID error: error meta: meta];
}

RCT_EXPORT_METHOD(setIgnoreURLsByRegex:(nonnull NSArray <NSString*>*)regexArray resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    NSMutableArray <NSRegularExpression*> *regexItems = [@[] mutableCopy];
    NSMutableArray <NSError*> *errors = [@[] mutableCopy];
    for (NSString *pattern in regexArray) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: pattern options: 0 error: &error];
        if (error != nil) {
            [errors addObject:error];
        }
        if (regex != nil) {
            [regexItems addObject:regex];
        }
    }

    if ([errors count] > 0) {
        NSDictionary *userinfo = @{@"UnderlyingErrors":errors};
        NSError *error = [NSError errorWithDomain:kErrorDomain code:kErrorDomainCodeWrongRegex userInfo:userinfo];
        reject([NSString stringWithFormat:@"%ld", kErrorDomainCodeWrongRegex], @"Wrong RegularExpression pattern", error);
    } else {
        [Instana setIgnoreURLsMatching:regexItems];
        resolve(@"Success");
    }
}

RCT_EXPORT_METHOD(getSessionID:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([Instana sessionID]);
}

RCT_EXPORT_METHOD(getViewName:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([Instana viewName]);
}

- (void)updateUser {
     [Instana setUserWithId:currentUserId email:currentUserEmail name:currentUserName];
}

@end
