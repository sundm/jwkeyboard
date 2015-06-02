//
//  JwKeyboard.h
//  JwKeyboard
//
//  Created by 孙敦鸣 on 15/5/27.
//  Copyright (c) 2015年 www.jw-smart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PUSHPASSWORD @"push_password"

@protocol JwKeyboardDelegate <NSObject>

- (void) numberKeyboardInput:(NSInteger) number;
- (void) numberKeyboardBackspace;
- (void) changeKeyboardType;
@end

@interface JwKeyboard : UIView
{
    NSArray *arrLetter;
    NSMutableArray *digitalArray;
    NSString *mPan;
}
-(void) setPan:(NSString*)pan;
@property (nonatomic,assign) id<JwKeyboardDelegate> delegate;

@end
