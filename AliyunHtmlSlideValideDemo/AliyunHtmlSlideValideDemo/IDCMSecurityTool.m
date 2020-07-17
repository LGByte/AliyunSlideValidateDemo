//
//  IDCMSecurityTool.m
//  IDCMExchange
//
//  Created by huangyi on 2018/6/26.
//  Copyright © 2018年 IDC. All rights reserved.
//

#import "IDCMSecurityTool.h"
#import "IDCMCustomNavigationBar.h"
#import <MSAuthSDK/MSAuthVCFactory.h>
#import <SecurityGuardSDK/Open/OpenSecurityGuardManager.h>
#import <SecurityGuardSDK/Open/OpenSecurityBody/IOpenSecurityBodyComponent.h>
#import <SecurityGuardSDK/Open/OpenSecurityBody/OpenSecurityBodyDefine.h>
#import <SecurityGuardSDK/Open/OpenSecurityBody/IOpenSecurityBodyComponent.h>
#import "IDCMSliderViewController.h"

@interface IDCMSecurityTool () <MSAuthProtocol>
@property (nonatomic,copy) NSString *phoneString;
@property (nonatomic,weak) UINavigationController *naviController;
@property (nonatomic,copy) void (^successCallback)(NSString *BehaviorCode);
@property (nonatomic,copy) void(^failCallback)(void);
@end


@implementation IDCMSecurityTool
+ (instancetype)securityToolWithPhoneString:(NSString *)phoneString
                             naviController:(UINavigationController *)naviController {
    
    IDCMSecurityTool *tool = [[self alloc] init];
    tool.phoneString = phoneString;
    tool.naviController = naviController;
    return tool;
}

- (void)securityWithSuccessCallback:(void (^)(NSString *BehaviorCode))successCallback
                       failCallback:(void(^)(void))failCallback{
    self.successCallback = [successCallback copy];
    self.failCallback = [failCallback copy];
 // [tool getToken];
    [self checkAuthType:MSAuthTypeSlide  data:nil];
}

+ (RACSignal *)securitySingalWithNavi:(UINavigationController *)navi
                          handleBlock:(void(^)(NSString *BehaviorCode))block {
    IDCMSecurityTool *securityTool = [[self alloc] init];
    securityTool.naviController = navi;
    return
    [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [securityTool securityWithSuccessCallback:^(NSString *BehaviorCode){
            !block ?: block(BehaviorCode);
            [subscriber sendNext:BehaviorCode];
            [subscriber sendCompleted];
        } failCallback:^{
            [subscriber sendError:nil];
        }];
        return nil;
    }];
}
+ (RACSignal *)securitySingalWithNavi:(UINavigationController *)navi
                     withBusinessType:(NSString *)phoneString
                          handleBlock:(void(^)(NSString *BehaviorCode))block {
    IDCMSecurityTool *securityTool = [[self alloc] init];
    securityTool.naviController = navi;
    securityTool.phoneString = phoneString ;
    return
    [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [securityTool securityWithSuccessCallback:^(NSString *BehaviorCode){
            !block ?: block(BehaviorCode);
            [subscriber sendNext:BehaviorCode];
            [subscriber sendCompleted];
        } failCallback:^{
            [subscriber sendError:nil];
        }];
        return nil;
    }];
}
#pragma mark — 获取token
- (void)getToken {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<IOpenSecurityBodyComponent> sbComp = [[OpenSecurityGuardManager getInstance] getSecurityBodyComp];
        NSError* error = nil;
        NSString* wtoken = [sbComp getSecurityBodyDataEx: nil
                                                  appKey: nil
                                                authCode: @"0335"
                                             extendParam: nil
                                                    flag: OPEN_SECURITYBODY_FLAG_FORMAT_GENERAL //指定格式
                                                     env: OPEN_SECURITYBODY_ENV_ONLINE //指定环境
                                                   error: &error];
        NSLog(@"dojaqverX=%@",wtoken);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestDataWithToken:wtoken];
        });
    });
}

#pragma mark — 用token请求数据
- (void)requestDataWithToken:(NSString *)token {
    if (token == nil || ![token isKindOfClass:[NSString class]] || !token.length) {
        return;
    }
//    NSString *url = @"http://192.168.0.94:5000/api/values/getcheck";
//    NSDictionary *dcit = @{@"session" : token};
//    NSString *formaturl = @"http://%@:8080/action/wtoken=%@&&mail=%@&&phone=%@";
//    NSString *mail = @"test_hua@test.com";
//    NSString *url = [NSString stringWithFormat:formaturl,ipAddress,token,mail,self.phoneString];
//    [IDCMRequestList requestPostWithHud:YES url:url params:nil success:^(NSDictionary *response) {
//
//    } fail:^(NSError *error) {
//    }];
}

#pragma mark — 创建控制器
- (void)checkAuthType:(MSAuthType)type data:(NSString *)data {
    /**
    
    UIViewController *vc;

    BOOL langugeCan =
    [[IDCMUtilsMethod getPreferredLanguage] isEqualToString:@"zh-CN"] ||
    [[IDCMUtilsMethod getPreferredLanguage] isEqualToString:@"zh-Hant"];
    NSString *languge = langugeCan ? @"zh_CN" : @"en";
//    NSString *appkey = @"FFFFI0000000017C9A68";
    
    if (data == nil || ![data isKindOfClass:[NSString class]] || !data.length) {
        
        vc = [MSAuthVCFactory simapleVerifyWithType:type
                                           language:languge
                                           Delegate:self
                                           authCode:@"0335"
                                             appKey:nil];
    } else {
        vc = [MSAuthVCFactory vcWithAuthType:type
                                    jsonData:data
                                    language:languge
                                    Delegate:self
                                    authCode:@"0335"
                                      appKey:nil];
    }
    vc.fd_interactivePopDisabled = YES;
    vc.fd_prefersNavigationBarHidden = YES;
    
    IDCMCustomNavigationBar *navigationBar = [IDCMCustomNavigationBar new];
    [navigationBar.backButton setImage:[UIImage imageNamed:@"naviBlackIcon"]
                     forState:UIControlStateNormal];
    [navigationBar.backButton setImage:[UIImage imageNamed:@"naviBlackIcon"]
                     forState:UIControlStateHighlighted];
    navigationBar.height = kSafeAreaTop+40;
    navigationBar.width = vc.view.width;
    [vc.view addSubview:navigationBar];
    [[[navigationBar.backButton rac_signalForControlEvents:UIControlEventTouchUpInside]
      deliverOnMainThread] subscribeNext:^(UIControl *x) {
         !self.failCallback ?: self.failCallback();
     }];
    
    // MSASlideAuthVC
    
//     rootVC,
//     appKey,
//     authCode,
//     delegate,
//     gradient,
//     titleLable,
//     tipLabel1,
//     tipLabel2,
//     lockImageView,
//     rangeView,
//     slideObjectView,
//     slideTargetView,
//     logoView,
//     indicator,
//     retryCount,
//     retryButton,
//     noActiveTimer,
//     hash,
//     superclass,
//     description,
//     debugDescription
     
    UIView *slideView = (UIView *)([vc valueForKeyPath:@"slideView"]);
    
    UILabel *titleLabel = [slideView valueForKeyPath:@"titleLable"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    @weakify(titleLabel);
    [[RACObserve(titleLabel, frame) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        @strongify(titleLabel);
        titleLabel.width = vc.view.width - 50 * 2;
        titleLabel.top = kSafeAreaTop + 10;
        titleLabel.centerX = vc.view.width / 2;
    }];

    
    UIImageView *imageView = [slideView valueForKeyPath:@"logoView"];
    [imageView removeFromSuperview];
    
    [self.naviController pushViewController:vc animated:YES];
     */
    IDCMSliderViewController * sliderVC = [[IDCMSliderViewController alloc] init];
    sliderVC.fd_interactivePopDisabled = YES;
    sliderVC.fd_prefersNavigationBarHidden = YES;
    IDCMCustomNavigationBar *navigationBar = [IDCMCustomNavigationBar new];
    navigationBar.titlelable.text = LocalizedString(@"dk_security");
    navigationBar.titlelable.textColor = UIColor.blackColor;
    navigationBar.backgroundColor = UIColor.whiteColor ;
    [navigationBar.backButton setImage:[UIImage imageNamed:@"naviBlackIcon"]
                     forState:UIControlStateNormal];
    [navigationBar.backButton setImage:[UIImage imageNamed:@"naviBlackIcon"]
                     forState:UIControlStateHighlighted];
    navigationBar.height = kSafeAreaTop+40;
    navigationBar.width = sliderVC.view.width;
    [sliderVC.view addSubview:navigationBar];
    [[[navigationBar.backButton rac_signalForControlEvents:UIControlEventTouchUpInside]
      deliverOnMainThread] subscribeNext:^(UIControl *x) {
         !self.failCallback ?: self.failCallback();
     }];
    @weakify(self);
    sliderVC.sBlock = ^(NSDictionary * _Nonnull dcit) {
      @strongify(self);
        [self secondVerifyWithSessionId2:dcit];
    };
    [self.naviController pushViewController:sliderVC animated:YES];
}

#pragma mark 风险验证结果回传服务器
- (void)secondVerifyWithSessionId:(NSString *)sessionId {
    if (sessionId) {
        @weakify(self);
        
        [IDCMLoadingView loadingViewStartLoadingInKeyWindow];
        NSString *urlStr = [NSString stringWithFormat:@"/api/Aliyun/APPShooting?SessionId=%@",sessionId];
        [IDCMRequestList requestPostWithHud:NO url:urlStr params:nil success:^(NSDictionary *response) {
            
            @strongify(self);
            [IDCMLoadingView dismiss];
            if (response && [response isKindOfClass:[NSDictionary class]]) {
                NSString *Status = [NSString idcw_stringWithFormat:@"%@", response[@"Status"]];
                if ([Status boolValue]) {
                    DDLogDebug(@"成功");
                    NSDictionary *dict = response[@"Data"];
                    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                        NSString *BehaviorCode = dict[@"BehaviorCode"];
                        if (BehaviorCode == nil || ![BehaviorCode isKindOfClass:NSString.class]) {
                            BehaviorCode = @"";
                        }
                        return
                        !self.successCallback ?: self.successCallback(BehaviorCode);
                    }
                } else {
                    DDLogDebug(@"失败");
                }
            }
            !self.failCallback ?: self.failCallback();
            [self.naviController popViewControllerAnimated:YES];
        } fail:^(NSError *error) {
            DDLogDebug(@"失败");
            !self.failCallback ?: self.failCallback();
            [self.naviController popViewControllerAnimated:YES];
            [IDCMLoadingView dismiss];
        }];
    }
}
- (void)secondVerifyWithSessionId2:(NSDictionary *)data {
    /**
     
    sid = "010B3TrWzwsdkM2Lqh18cIU4NowBFFTGE8sH0ce9XZcM1xefKKF-ef3-nUgr2c4L7nyFCJ8x9dvaV9hFM5tywB_9ILksAsi_jOiYiArUQCcwdB868MvOl8tcUwL1pP4CnegoBxlNvGwAv8ayq1VKVnvsDwHZdAG8c_meY3xdzHWmvzOZRcBxtKL4AAKcDSJ8Re6kxKbGxBV0pf75bp_udHYw";
    sig = "05XqrtZ0EaFgmmqIQes-s-CA9rjQa20uf4QKrBiZrNPVl0e9dZ8h3u3Y4G7RPHDCnLY731gJ9G0fOeAHWZtIawKjfNCpOJmZY-GI7hAv1Sx2Rc61lO4c5xF4cmdomh5dU6fEI48IOD18y6-cDUuauqgn-iUcWq_t3SUGnJm453rpYYxDVI0Q9sPvVoSq0zEpzvv7wo0On1DmuTowy1emoSAKJbQkLgxPgXhYjcPWUkN_mJ5qhY_MrcYaNOV0HVaB0v01Ar3YahFiLVfGqfBS59zpGFyxcAmoe6BSYWP8PdOkonaPt0x-TkzHpxGEPYj1rimQH8POn3ISL-swyBNgL5BlLAgKFK0PAG0GGJs5xjVFhqR7VcIfZ8wiRomN2af9RiyvKBZsE9pxIcqIAIyyRM1T0ZFS1mz4z4HP5D9PkHdQRMxGUJ1Sk7bhIVvdGTN_NafgTTitbmZD86ADUcYZaqI9k66KdKmw4ns3NOtNUqnII";
    token = "FFFF0N0000000000635A:1591607123499:0.8340382137284943";
     */
    if (data) {
        @weakify(self);
        
        [IDCMLoadingView loadingViewStartLoadingInKeyWindow];
        NSString *urlStr = [NSString stringWithFormat:@"/api/Aliyun/PCSlider"];
        NSMutableDictionary * dictM = [[NSMutableDictionary alloc] initWithDictionary:data];
        [dictM setObject:self.phoneString forKey:@"BusinessType"];
        [dictM setObject:data[@"sid"] forKey:@"csessionid"];
        [dictM setObject:@"" forKey:@"value"];
        [IDCMRequestList requestPostWithHud:NO url:urlStr params:dictM success:^(NSDictionary *response) {
            
            @strongify(self);
            [IDCMLoadingView dismiss];
            if (response && [response isKindOfClass:[NSDictionary class]]) {
                NSString *Status = [NSString idcw_stringWithFormat:@"%@", response[@"Status"]];
                if ([Status boolValue]) {
                    DDLogDebug(@"成功");
                    NSDictionary *dict = response[@"Data"];
                    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                        NSString *BehaviorCode = dict[@"BehaviorCode"];
                        if (BehaviorCode == nil || ![BehaviorCode isKindOfClass:NSString.class]) {
                            BehaviorCode = @"";
                        }
                        return
                        !self.successCallback ?: self.successCallback(BehaviorCode);
                    }
                } else {
                    DDLogDebug(@"失败");
                }
            }
            !self.failCallback ?: self.failCallback();
            [self.naviController popViewControllerAnimated:YES];
        } fail:^(NSError *error) {
            DDLogDebug(@"失败");
            !self.failCallback ?: self.failCallback();
            [self.naviController popViewControllerAnimated:YES];
            [IDCMLoadingView dismiss];
        }];
    }
}
#pragma mark — MSAuthProtocol
- (void)verifyDidFinishedWithResult:(t_verify_reuslt)code
                              Error:(NSError *)error
                          SessionId:(NSString *)sessionId  {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error) {
            DDLogDebug(@"通过===");
        }
        if (sessionId) {
            [self secondVerifyWithSessionId:sessionId];
        } else {
            !self.failCallback ?: self.failCallback();
            [self.naviController popViewControllerAnimated:YES];
        }
    });
}



@end












