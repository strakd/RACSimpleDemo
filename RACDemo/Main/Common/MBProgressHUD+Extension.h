//
//  MBProgressHUD+Extension.h
//  Exam
//
//  Created by zhanghb on 15/7/16.
//  Copyright (c) 2015年 wihan. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Extension)
+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (MBProgressHUD *)showMessag:(NSString *)message;
+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view;

+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;

+ (void)showTextDialog:(NSString *)msg view:(UIView *)view;
+ (MBProgressHUD *)onlyShowMessage:(NSString *)message toView:(UIView *)view;
@end
