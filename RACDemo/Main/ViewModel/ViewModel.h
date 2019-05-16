//
//  ViewModel.h
//  RACDemo
//
//  Created by starkda on 2019/5/15.
//  Copyright © 2019年 starkda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewModel : NSObject
///亚男接口
@property (nonatomic, strong) RACCommand *websocketurlCommand;
@end

NS_ASSUME_NONNULL_END
