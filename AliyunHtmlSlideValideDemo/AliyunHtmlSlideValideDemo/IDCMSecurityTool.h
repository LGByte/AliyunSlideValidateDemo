//
//  IDCMSecurityTool.h
//  IDCMExchange
//
//  Created by huangyi on 2018/6/26.
//  Copyright © 2018年 IDC. All rights reserved.
//

#import "IDCMSecurityTool.h"

#define ipAddress @""
/*
 
 "BusinessCode": "45c3a3d5-63ab-487f-b699-6b9d056ce238",
 "BehaviorCode": "9dd1bf9c-1faf-410c-ad71-68dc9657f90c",
*/

@interface IDCMSecurityTool : NSObject 

/**
 // 初始化
 @param phoneString 可传空，不需要
 @param naviController 当前控制器
 @return IDCMSecurityTool
 */
+ (instancetype)securityToolWithPhoneString:(NSString *)phoneString
                             naviController:(UINavigationController *)naviController;
// 开始验证
- (void)securityWithSuccessCallback:(void (^)(NSString *BehaviorCode))successCallback
                       failCallback:(void(^)(void))failCallback;


// 信号用法
+ (RACSignal *)securitySingalWithNavi:(UINavigationController *)navi
                          handleBlock:(void(^)(NSString *BehaviorCode))block;

+ (RACSignal *)securitySingalWithNavi:(UINavigationController *)navi
                          withBusinessType:(NSString *)phoneString
                          handleBlock:(void(^)(NSString *BehaviorCode))block ;
@end




