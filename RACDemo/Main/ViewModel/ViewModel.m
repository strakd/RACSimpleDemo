//
//  ViewModel.m
//  RACDemo
//
//  Created by starkda on 2019/5/15.
//  Copyright © 2019年 starkda. All rights reserved.
//

#import "ViewModel.h"
#import "PSError.h"
#import "RLNetworkHelper.h"

@implementation ViewModel

- (instancetype)init {
    if (self = [super init]) {
        
        [self setupWebsocketurlCommand];
    }
    return self;
}
- (void)setupWebsocketurlCommand{
    @weakify(self);
    self.websocketurlCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSDictionary *inputDict) {
        @strongify(self);
        
        @weakify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            @weakify(self);
            ///url
            NSString *urlStr = @"https://api.douban.com/v2/movie/in_theaters?apikey=0b2bdeda43b5688921839c8ecb20399b&city=%E5%8C%97%E4%BA%AC&start=0&count=100&client=&udid=";
            ///发送请求
            NSURLSessionDataTask *postTask = [RLNetworkHelper POST:urlStr parameters:inputDict success:^(id responseObject) {
                NSLog(@"________%@_______",responseObject);
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
                
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
                [subscriber sendError:[PSError initWithResuletMsg:@"sdfdf"]];
                
            }];
            [postTask resume];
            return nil;
        }];
    }];
    
}

- (RACSignal *)initializationErrorWith:(NSString *)msg {
    return [RACSignal error:[PSError initWithResuletMsg:msg]];
}
@end
