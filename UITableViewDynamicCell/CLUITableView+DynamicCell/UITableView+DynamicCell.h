//
//  UITableView+DynamicCell.h
//
//  Created by Vũ Trường Giang on 4/21/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLTableHeaderLoading.h"
#import "CLTableFooterLoading.h"

@class CLTableHeaderLoading;

@protocol UITableViewDynamicDelegate;
typedef void(^RefreshCompletion)();

@interface UITableView (DynamicCell)

#pragma mark - Propeties

/*
 * Store default insets
 */
@property (nonatomic, assign) UIEdgeInsets defaultInset;

/*
 * loading view
 */
@property (strong, nonatomic) CLTableHeaderLoading *headerView;

/*
 * set UITableViewDynamicDelegate
 */
@property (nonatomic, assign) id <UITableViewDynamicDelegate> refreshDelegate;

/*
 * if YES, when pull down, activityIndicator will show on header of table
 */
@property (nonatomic, readwrite) BOOL enabledRefresh;

/*
 * if YES, when pull up, activityIndicator will show on bottom of table
 */
@property (nonatomic, readwrite) BOOL enabledLoadMore;

/*
 * readonly, check table is reloading
 */
@property (nonatomic, readonly) BOOL  isLoading;

/*
 * readonly, check table is reloading
 */
@property (nonatomic, readwrite) BOOL isLoadingMore;


#pragma mark - Public Method

/*
 * call to update content offset
 */
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;
/*
 * check drag offset to determine reload
 */
- (void)checkToReload;
/*
 * Relocate pull-to-refresh view
 */
- (void)relocatePullToRefreshView;

@end

@protocol UITableViewDynamicDelegate <NSObject>

@optional
-(void)willBeginRefreshData;
- (void)refreshData:(UITableView*)tableView completion:(RefreshCompletion)completion;

//Load more Data delegate method
-(void)willBeginLoadMoreData;
- (void)loadMoreData:(UITableView*)tableView completion:(RefreshCompletion)completion;

@end
