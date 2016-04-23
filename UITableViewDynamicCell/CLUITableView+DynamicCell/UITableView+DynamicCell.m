//
//  UITableView+DynamicCell.m
//  SwitchableMultipleEnvironmentsDemo
//
//  Created by Vũ Trường Giang on 4/21/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "UITableView+DynamicCell.h"
#import "CLTableHeaderLoading.h"
#import "CLTableFooterLoading.h"
#import <objc/runtime.h>

#define DEFAULT_REFRESH_VIEW_HEIGHT 50

static char krefreshDelegateKey;
static char kenableRefreshKey;
static char kenableLoadMoreKey;
static char kisLoadingKey;
static char kisLoadingMoreKey;
static char kHeaderViewKey;

@implementation UITableView (DynamicCell)


#pragma mark -
#pragma mark Getter/Setter Method
// Get/Set Delegate
-(id<UITableViewDynamicDelegate>)refreshDelegate{
    return objc_getAssociatedObject(self, &krefreshDelegateKey);
}
-(void)setRefreshDelegate:(id<UITableViewDynamicDelegate>)refreshDelegate{
    objc_setAssociatedObject(self, &krefreshDelegateKey, refreshDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(BOOL)isLoadingMore{
    NSNumber *isLoadingMoreKeyNumber = objc_getAssociatedObject(self, &kisLoadingMoreKey);
    return [isLoadingMoreKeyNumber boolValue];
}
-(void)setIsLoadingMore:(BOOL)isLoadingMore{
    objc_setAssociatedObject(self, &kisLoadingMoreKey, @(isLoadingMore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//Get set Enable Refresh
-(BOOL)enabledRefresh{
    NSNumber *enabledRefreshNumber = objc_getAssociatedObject(self, &kenableRefreshKey);
    return [enabledRefreshNumber boolValue];
}
-(void)setEnabledRefresh:(BOOL)enabledRefresh{
    CLTableHeaderLoading *_headerView=[[CLTableHeaderLoading alloc] initWithFrame:CGRectMake(0.0, 0, self.frame.size.width, DEFAULT_REFRESH_VIEW_HEIGHT)];
    [self setHeaderView:_headerView];
    
    if (self.headerView) {
        [self.headerView setHidden:!enabledRefresh];
    }
    objc_setAssociatedObject(self, &kenableRefreshKey, @(enabledRefresh), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//Get set Enable Load more
-(BOOL)enabledLoadMore{
    NSNumber *enabledLoadMoreNumber = objc_getAssociatedObject(self, &kenableLoadMoreKey);
    return [enabledLoadMoreNumber boolValue];
}
-(void)setEnabledLoadMore:(BOOL)enabledLoadMore{
    if (!enabledLoadMore) {
        self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else{
        CLTableFooterLoading *view =[[CLTableFooterLoading alloc] initWithFrame:CGRectMake(0.0, 0, self.frame.size.width, DEFAULT_REFRESH_VIEW_HEIGHT)];
        self.tableFooterView = view;
    }
    objc_setAssociatedObject(self, &kenableLoadMoreKey, @(enabledLoadMore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//Get Set isLoading
-(BOOL)isLoading{
    NSNumber *isLoadingNumber = objc_getAssociatedObject(self, &kisLoadingKey);
    return [isLoadingNumber boolValue];
}
-(void)setIsLoading:(BOOL)isLoading{
    objc_setAssociatedObject(self, &kisLoadingKey, @(isLoading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Get Set Header View
-(UIView *)headerView{
    return objc_getAssociatedObject(self, &kHeaderViewKey);
}
-(void)setHeaderView:(UIView *)headerView{
    if (self.headerView) {
        [self.headerView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &kHeaderViewKey,
                             headerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [headerView setFrame:CGRectMake(0.0, -headerView.frame.size.height, self.frame.size.width, headerView.frame.size.height)];
    [headerView setHidden:!self.enabledRefresh];
    [self addSubview:headerView];
}


#pragma mark - Method Swizzling

+ (void)load
{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(reloadData);
        SEL swizzledSelector = @selector(swizzled_reloadData);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
- (void)swizzled_reloadData
{
    [self swizzled_reloadData];
    NSLog(@"This is custom reload Data");
    self.isLoading = NO;
    self.headerView.isAnimating = NO;
    
    [self relocatePullToRefreshView];
    if (self.enabledLoadMore) {
        if (![self canShowLoadMore]) {

        }
    }
}

#pragma mark - Public Method
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    //Loadmore
    if (!self.isLoadingMore && self.enabledLoadMore && [self canShowLoadMore]) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < [self footerLoadMoreHeight]) {
            if (!self.isLoading){
                [self loadMore];
            }
            
        }
    }
    
    //Refresh
    float offset = self.headerView.frame.size.height;
    CGFloat topOffset = [self topContentOffset];
    if (!self.isLoading && self.enabledRefresh && topOffset > -offset && topOffset <= 0)
    {
        if (!self.headerView.isAnimating)
        {
            [self.headerView rotateIndicator:2*M_PI * (fabs(topOffset) / offset)];
        }
    }
    if (self.isLoading && topOffset > -offset && topOffset <= 0)
    {
        [scrollView setContentInset:UIEdgeInsetsMake(self.headerView.frame.size.height, 0, 0, 0)];
    }
}

#pragma mark - Pull to refresh Method
/*
 * Relocate pull-to-refresh view
 */
- (void)relocatePullToRefreshView
{
    CGFloat yOrigin = 0.0f;
    
    if ([self contentSize].height >= CGRectGetHeight([self frame])) {
        yOrigin=self.contentSize.height;
    } else {
        
        yOrigin = CGRectGetHeight([self frame]);
    }
}
- (void)checkToReload
{
    CGFloat offset = self.tableFooterView.frame.size.height;
    CGFloat topOffset = [self topContentOffset];
    if (topOffset <= -offset && self.enabledRefresh && !self.isLoading) {
        //refresh
        if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(refreshData:completion:)])
        {
            self.headerView.isAnimating = YES;
            self.isLoading = YES;
            [self.refreshDelegate refreshData:self completion:^{
    
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UIView animateWithDuration:0.25f animations:^{
                        //                    self.headerView.alpha = 0;
                        [self setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                    } completion:^(BOOL finished) {
                        self.headerView.isAnimating = NO;
                        self.isLoading = NO;
                    }];
                });
            }];
        }
    }

}

/*
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 */
- (CGFloat)bottomContentOffset
{
    CGFloat offset = 0.0f;
    
    if ([self contentSize].height < CGRectGetHeight([self frame])) {
        
        offset = [self contentOffset].y;
        
    } else {
        
        offset = self.frame.size.height - self.contentSize.height + self.contentOffset.y;
    }
    
    return offset;
}

- (CGFloat)topContentOffset
{
    return self.contentOffset.y;
}


-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    [self relocatePullToRefreshView];
}



#pragma mark - Load More Method


- (void) loadMoreCompleted
{
    
    self.isLoadingMore = NO;
    ((CLTableFooterLoading*)self.tableFooterView).isAnimating = NO;
    NSLog(@"Did Finish load");
}

- (BOOL) loadMore
{
    //Send message to delegate
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(willBeginLoadMoreData)]) {
        NSLog(@"Did Finish load");
        [self.refreshDelegate willBeginLoadMoreData];
    }else{
        NSLog(@"%s Delegate not responds to selector", __PRETTY_FUNCTION__);
    }
    
    if (self.isLoadingMore)
        return NO;
    ((CLTableFooterLoading*)self.tableFooterView).isAnimating = YES;
    
    //Send message to delegate
    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(loadMoreData:completion:)]) {
        NSLog(@"Start load");
        __weak typeof(self) weakSelf = self;
        [self.refreshDelegate loadMoreData:self completion:^{
            if (weakSelf) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf loadMoreCompleted];
            }
        }];
    }else{
        NSLog(@"%s Delegate not responds to selector", __PRETTY_FUNCTION__);
    }
    
    
    self.isLoadingMore = YES;
    return YES;
}

- (CGFloat) footerLoadMoreHeight
{
    if (self.tableFooterView)
        return self.tableFooterView.frame.size.height;
    else
        return DEFAULT_REFRESH_VIEW_HEIGHT;
}

-(BOOL)canShowLoadMore{
    if (self.frame.size.height>self.contentSize.height) {
        return NO;
    }
    else{
        return YES;
    }
}



@end
