//
//  CLIndicatorView.h
//
//  Created by Vũ Trường Giang on 4/23/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLIndicatorView : UIView

@property (nonatomic, readwrite) BOOL isAnimating;

- (void)rotate:(CGFloat)angle;
@end
