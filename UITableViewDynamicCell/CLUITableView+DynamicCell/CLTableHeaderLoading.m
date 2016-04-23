//
//  CLTableHeaderLoading.m
//  DemoCustomTableView
//
//  Created by Vũ Trường Giang on 4/23/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "CLTableHeaderLoading.h"
#import "CLIndicatorView.h"

@interface CLTableHeaderLoading ()

@property (strong, nonatomic) CLIndicatorView *indicatorView;

@end

@implementation CLTableHeaderLoading

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _indicatorView = [[CLIndicatorView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_indicatorView];
        self.indicatorView.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicatorView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    _indicatorView.isAnimating = isAnimating;
}

- (BOOL)isAnimating
{
    return _indicatorView.isAnimating;
}

- (void)dealloc
{
    self.indicatorView = nil;
}

- (void)rotateIndicator:(CGFloat)angle
{
    [self.indicatorView rotate:angle];
}

@end
