//
//  ViewController.h
//  AliyunHtmlSlideValideDemo
//
//  Created by cgw on 2019/12/2.
//  Copyright © 2019 bill. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SliderBlock)(NSDictionary * dcit);
@interface ViewController : UIViewController
@property (nonatomic, copy)SliderBlock sBlock ;

@end

