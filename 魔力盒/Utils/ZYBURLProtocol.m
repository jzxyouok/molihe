//
//  ZYBURLProtocol.m
//  homework
//
//  Created by ssc on 16/1/29.
//  Copyright © 2016年 zyb. All rights reserved.
//

#import "ZYBURLProtocol.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>


@interface ZYBWebViewCachedData : NSObject <NSCoding>
@property (nonatomic, readwrite, strong) NSData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
@property (nonatomic, readwrite, strong) NSURLRequest *redirectRequest;
@end

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";
static NSString *const kRedirectRequestKey = @"redirectRequest";

@implementation ZYBWebViewCachedData
@synthesize data = data_;
@synthesize response = response_;
@synthesize redirectRequest = redirectRequest_;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self data] forKey:kDataKey];
    [aCoder encodeObject:[self response] forKey:kResponseKey];
    [aCoder encodeObject:[self redirectRequest] forKey:kRedirectRequestKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil) {
        [self setData:[aDecoder decodeObjectForKey:kDataKey]];
        [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];
        [self setRedirectRequest:[aDecoder decodeObjectForKey:kRedirectRequestKey]];
    }
    
    return self;
}
@end

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface ZYBURLProtocol()
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
- (void)appendData:(NSData *)newData;
@end

@implementation ZYBURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [request.URL.host rangeOfString:@"111.202.114.95"].location != NSNotFound) {
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  
    
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    __block BOOL useHttps = YES;

    
    if (useHttps) {
        mutableReqeust.URL = [NSURL URLWithString:[[mutableReqeust.URL absoluteString] stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@"https"]];
    }

 
    NSString *referer = [mutableReqeust.allHTTPHeaderFields objectForKey:@"referer"];
    if (referer && [self shouldUseCache:mutableReqeust.URL.absoluteString]) {
        ZYBWebViewCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
        if (cache && cache.response) {
            NSData *data = [cache data];
            NSURLResponse *response = [cache response];
            NSURLRequest *redirectRequest = [cache redirectRequest];
            if (redirectRequest) {
                [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
            } else {
                [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [[self client] URLProtocol:self didLoadData:data];
                [[self client] URLProtocolDidFinishLoading:self];
            }
        }
    }
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
}
#pragma mark -- private method
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain
{
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

- (NSString *)getSha1WithString:(NSString *)str
{
    if (str && str.length != 0) {
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        
        CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }
    return nil;
}

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [self getSha1WithString:[[aRequest URL] absoluteString]];
    return [cachesPath stringByAppendingPathComponent:fileName];
}

- (void)appendData:(NSData *)newData
{
    if ([self data] == nil) {
        [self setData:[newData mutableCopy]];
    }
    else {
        [[self data] appendData:newData];
    }
}

- (BOOL)shouldUseCache:(NSString *)urlStr{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {//8.0以下系统关闭缓存，有crash问题
        return NO;
    }
    urlStr = [urlStr lowercaseString];
    if (([urlStr hasSuffix:@".jpg"] || [urlStr hasSuffix:@".jpeg"] || [urlStr hasSuffix:@".css"] || [urlStr hasSuffix:@".js"] || [urlStr hasSuffix:@".png"] || [urlStr hasSuffix:@".gif"])){
        return YES;
    }
    return NO;
}
#pragma mark - NSURLConnectionDelegate
/*
    return:真正要被发送的请求。
    request:被重定向之后的请求。
    response:需要被重定向的请求（重定向之前的请求）
 */
- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    if (response != nil)
    {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
        [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:redirectableRequest];
        if ([self shouldUseCache:self.request.URL.absoluteString]) {
            NSString *cachePath = [self cachePathForRequest:[self request]];
            ZYBWebViewCachedData *cache = [ZYBWebViewCachedData new];
            [cache setResponse:response];
            [cache setData:[self data]];
            [cache setRedirectRequest:redirectableRequest];
            [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
        }
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        return redirectableRequest;
    }
    return request;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    if ([self shouldUseCache:self.request.URL.absoluteString]) {
        [self setResponse:response];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    if ([self shouldUseCache:self.request.URL.absoluteString]) {
        [self appendData:data];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    if ([self shouldUseCache:self.request.URL.absoluteString]) {
        NSString *cachePath = [self cachePathForRequest:[self request]];
        ZYBWebViewCachedData *cache = [[ZYBWebViewCachedData alloc] init];
        [cache setResponse:[self response]];
        [cache setData:[self data]];
        [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
        
        [self setConnection:nil];
        [self setData:nil];
        [self setResponse:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    if ([self shouldUseCache:self.request.URL.absoluteString]) {
        [self setConnection:nil];
        [self setData:nil];
        [self setResponse:nil];
    }
}

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (!challenge) {
        return;
    }
    /*
     * URL里面的host在使用HTTPDNS的情况下被设置成了IP，此处从HTTP Header中获取真实域名
     */
    NSString* host = [[connection.currentRequest allHTTPHeaderFields] objectForKey:@"host"];
    if (!host) {
        host = connection.currentRequest.URL.host;
    }
    /*
     * 判断challenge的身份验证方法是否是NSURLAuthenticationMethodServerTrust（HTTPS模式下会进行该身份验证流程），
     * 在没有配置身份验证方法的情况下进行默认的网络请求流程。
     */
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            /*
             * 验证完以后，需要构造一个NSURLCredential发送给发起方
             */
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } else {
            /*
             * 验证失败，进入默认处理流程
             */
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    } else {
        /*
         * 对于其他验证方法直接进行处理流程
         */
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

@end
