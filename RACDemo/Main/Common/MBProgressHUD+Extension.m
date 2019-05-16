//
//  MBProgressHUD+Extension.m
//  Exam
//
//  Created by zhanghb on 15/7/16.
//  Copyright (c) 2015年 wihan. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

@implementation MBProgressHUD (Extension)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.5];
}


#pragma mark 显示错误信息
+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (void)showError:(NSString *)error toView:(UIView *)view{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    [self show:error icon:@"error.png" view:view];
}


#pragma mark 显示正确信息
+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}


#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessag:(NSString *)message
{
    return [self showMessag:message toView:nil];
}

+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}

#pragma mark 只显示文字信息
+ (MBProgressHUD *)onlyShowMessage:(NSString *)message toView:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
    return hud;
}

#pragma mark 隐藏弹框
+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

#pragma mark 自动弹出窗口，2秒后消失
+ (void)showTextDialog:(NSString *)msg view:(UIView *)view {
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    //初始化进度框，置于当前的View当中
    __block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    
    //如果设置此属性则当前的view不会置于后台
    HUD.dimBackground = NO;
    
    //设置对话框文字
    HUD.labelText = msg;
    HUD.mode = MBProgressHUDModeText;
    HUD.yOffset = 100.0f;
    
    //显示对话框
    [HUD showAnimated:YES whileExecutingBlock:^{
        //对话框显示时需要执行的操作
        sleep(2);
    } completionBlock:^{
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}

@end
