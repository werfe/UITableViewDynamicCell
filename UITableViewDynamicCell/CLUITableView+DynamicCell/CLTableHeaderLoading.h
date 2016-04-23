//
//  CLTableHeaderLoading.h
//  DemoCustomTableView
//
//  Created by Vũ Trường Giang on 4/23/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLTableHeaderLoading : UIView

@property (assign, nonatomic) BOOL isAnimating;

- (void)rotateIndicator:(CGFloat)angle;

@end
