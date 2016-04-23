//
//  CLIndicatorView.m
//
//  Created by Vũ Trường Giang on 4/23/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "CLIndicatorView.h"

@interface CLIndicatorView (){
    float currentValue;
    CGFloat height;
}

@property (nonatomic, strong) UIImageView* loadingImage;
@property (nonatomic, strong) UIImageView* cameraImage;
@property (nonatomic, strong) UIImageView* cameraBackgroundImage;
@property (nonatomic, strong) NSLayoutConstraint *contraintHeight;
@property (nonatomic, strong) NSLayoutConstraint *centerY;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation CLIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initLoadingProgress];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initLoadingProgress];
    }
    return self;
}
- (void)initLoadingProgress
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.backgroundColor = [UIColor clearColor];
    self.loadingImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_image_loading.png"]];
    self.cameraBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_image_video_gray.png"]];
    self.cameraImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_image_video_green.png"]];
    
    [self.loadingImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cameraImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cameraBackgroundImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.loadingImage];
    [self addSubview:self.cameraBackgroundImage];
    [self addSubview:self.cameraImage];
    
    self.cameraImage.contentMode=UIViewContentModeBottom;
    self.cameraImage.clipsToBounds = YES;
    
    // add contraint for loadingImage
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingImage
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingImage
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingImage
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeWidth
//                                                    multiplier:2.f constant:0.f]];
    
    [self.loadingImage addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingImage
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.loadingImage
                                                    attribute:NSLayoutAttributeHeight
                                                   multiplier:1.f
                                                     constant:0.f]];
    
    // add contraint for cameraBackgroundImage
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraBackgroundImage
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraBackgroundImage
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.f constant:0.f]];
    
    
    // add contraint for cameraImage
    height=self.cameraImage.frame.size.height;
    //    if(IS_IPHONE_6P)
    //    {
    //        height+=3;
    //    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraImage
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.f constant:0.f]];
    _contraintHeight=[NSLayoutConstraint constraintWithItem:self.cameraImage
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1.f constant:0.f];
    
    _centerY=[NSLayoutConstraint constraintWithItem:self.cameraImage
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.f constant:height/2];
    [self.cameraImage addConstraint:_contraintHeight];
    [self addConstraint:_centerY];
    currentValue=0.f;
    self.cameraImage.hidden=YES;
    self.isAnimating = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)startAnimate
{
    [self rotateImage];
    if(!_timer)
    {
        _timer= [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onTick) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
- (void) stopAnimate
{
    [self.cameraImage removeConstraint:_contraintHeight];
    [self removeConstraint:_centerY];
    [self.loadingImage.layer removeAllAnimations];
    [_timer invalidate];
    _timer=nil;
    self.cameraImage.hidden=YES;
    currentValue=0.f;
}
- (void)setIsAnimating:(BOOL)isAnimating
{
    if(isAnimating)
    {
        [self startAnimate];
    }
    else
    {
        [self stopAnimate];
    }
}
-(void) rotateImage
{
    [self.loadingImage.layer removeAllAnimations];
    CGFloat rotations=20;
    CGFloat duration=24;
    float repeat=100;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [self.loadingImage.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
-(void)onTick
{
    currentValue+=height/50;
    
    if(currentValue>height)
    {
        currentValue=0.f;
    }
    //    NSLog(@"ontick -- %f",currentValue);
    [self.cameraImage removeConstraint:_contraintHeight];
    [self removeConstraint:_centerY];
    _contraintHeight=[NSLayoutConstraint constraintWithItem:self.cameraImage
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1.f
                                                  constant:currentValue];
    CGRect frame=self.cameraImage.frame;
    frame.size.height=currentValue;
    self.cameraImage.frame=frame;
    _centerY=[NSLayoutConstraint constraintWithItem:self.cameraImage
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.f constant:(height-currentValue)/2];
    [self.cameraImage addConstraint:_contraintHeight];
    [self addConstraint:_centerY];
    self.cameraImage.hidden=NO;
}
- (void)rotate:(CGFloat)angle
{
    self.loadingImage.transform = CGAffineTransformMakeRotation(angle);
}

@end
