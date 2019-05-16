//
//  ViewController.m
//  RACDemo
//
//  Created by starkda on 2019/5/15.
//  Copyright © 2019年 starkda. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel.h"
#import <ReactiveObjC.h>
#import "MBProgressHUD+Extension.h"
#import <YYWebImage.h>

@interface ViewController ()
@property (nonatomic, strong) ViewModel *viewModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor yellowColor];
    [self setupSignal];
    
    //这是系统的给btn添加点击事件
    [self.黄亚男Btn addTarget:self action:@selector(lalala) forControlEvents:UIControlEventTouchUpInside];
    
    @weakify(self)
    //这是rac给btn添加点击事件
    [[self.黄亚男BtnTwo rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        NSLog(@"我是第二个黄亚男");
    }];
    
}

- (void)setupSignal {
    //这是比钱烁还不正经的网络请求
    @weakify(self)
    [[self.loadDataBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [MBProgressHUD showMessag:@""];
        //如果接口有参数从这里拼
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [self.viewModel.websocketurlCommand execute:dict];
    }];
    
    //网络请求成功回调
    [self.viewModel.websocketurlCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [MBProgressHUD hideHUD];
        NSDictionary *result = (NSDictionary *)x;
        
        NSArray *arr = result[@"subjects"];
        int value = arc4random_uniform(arr.count-1);
        self.textLab.text = result[@"subjects"][value][@"title"];
        
        // 可以设置占位图
        [self.imgView yy_setImageWithURL:[NSURL URLWithString:result[@"subjects"][value][@"images"][@"large"]] placeholder:nil];
        
    }];
    
    //网络请求失败回调
    [self.viewModel.websocketurlCommand.errors subscribeNext:^(NSError * _Nullable x) {
        @strongify(self)
        [MBProgressHUD hideHUD];
    }];
}

- (void)lalala{
    NSLog(@"我叫钱老二");
}

- (ViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [ViewModel new];
    }
    return _viewModel;
}

@end
