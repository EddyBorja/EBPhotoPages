//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "EBPhotoPagesController.h"
#import "EBPhotoPagesNotifications.h"
#import "EBPhotoPagesFactory.h"
#import "EBPhotoViewController.h"
#import "EBCaptionView.h"
#import "EBShadedView.h"
#import "EBPhotoView.h"
#import "EBPhotoPagesOperation.h"
#import "EBPhotoPagesState.h"
#import "EBTagPopover.h"
#import "EBPhotoCommentProtocol.h"
#import "EBCommentCell.h"
#import <QuartzCore/QuartzCore.h>

static NSString *ContentOffsetKeyPath = @"contentOffset";
static NSString *CurrentPhotoIndexKeyPath = @"currentPhotoIndex";
static NSString *TagsHiddenKeyPath = @"tagsHidden";
static NSString *CommentsHiddenKeyPath = @"commentsHidden";
static NSString *kActionSheetTargetKey = @"actionSheetTarget";
static NSString *kActionSheetIndexKey= @"actionSheetTargetIndex";
 
@interface EBPhotoPagesController ()

@property (strong) NSDictionary *actionSheetTargetInfo; //info about the object the action sheet is currently handling
@property (assign) BOOL originalStatusBarVisibility;

@property (nonatomic, strong) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *tagBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *doneTaggingBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *activityBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *commentsBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *miscBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *commentsExitBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *toggleTagsBarButtonItem;

@property (weak) UIToolbar *upperToolbar;
@property (weak) UIToolbar *lowerToolbar;
@property (weak) UIView *screenDimmer;
@property (weak) UIView *upperGradient;
@property (weak) UIView *lowerGradient;
@property (weak) UILabel *taggingLabel;
@property (weak) EBCaptionView *captionView;

@property (strong) NSOperationQueue *photoLoadingQueue;

@property (assign) NSInteger currentPhotoIndex;

@end

#pragma mark -
#pragma mark - EBPhotoPagesController

@implementation EBPhotoPagesController


- (id)init
{
    self = [super init];
    if (self) {
        NSAssert(0, @"EBPhotoPageViewController must be initialized with a data source.");
    }
    return self;
}

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
{
    return [self initWithDataSource:dataSource photoAtIndex:0];
}

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource photoAtIndex:(NSInteger)index
{
    return [self initWithDataSource:dataSource delegate:nil photoAtIndex:index];
}

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate
{
    return [self initWithDataSource:dataSource delegate:aDelegate photoAtIndex:0];
}


- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
       photoPagesFactory:(EBPhotoPagesFactory *)factory
{
    return [self initWithDataSource:dataSource delegate:nil photoPagesFactory:factory photoAtIndex:0];
}

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate
       photoPagesFactory:(EBPhotoPagesFactory *)factory
{
    return [self initWithDataSource:dataSource delegate:aDelegate photoPagesFactory:factory photoAtIndex:0];
}

- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate
            photoAtIndex:(NSInteger)index
{
    return [self initWithDataSource:dataSource delegate:aDelegate photoPagesFactory:nil photoAtIndex:index];
}


- (id)initWithDataSource:(id<EBPhotoPagesDataSource>)dataSource
                delegate:(id<EBPhotoPagesDelegate>)aDelegate
       photoPagesFactory:(EBPhotoPagesFactory *)factory
            photoAtIndex:(NSInteger)index
{
    NSDictionary *photoPageViewOptions = @{ UIPageViewControllerOptionInterPageSpacingKey : @20.0 };
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:photoPageViewOptions];
    if (self) {
        [self setPhotoPagesDelegate:aDelegate];
        [self setPhotosDataSource:dataSource];
        [self setPhotoPagesFactory:factory];
        [self initialize];
        [self setCurrentPhotoIndex:index];
        [self setOriginalStatusBarVisibility:[[UIApplication sharedApplication] isStatusBarHidden]];
    }
    return self;
}

#pragma mark - Initialization & Deallocation

- (void)initialize
{
    [self setTagsHidden:YES];
    [self setDelegate:self]; //UIPageViewController
    [self setDataSource:self]; //UIPageViewController
    [self setHidesBottomBarWhenPushed:YES];
    [self loadPhotoPagesFactory];
    [self loadOperationsQueue];
    [self setCommentsHidden:YES];
}

- (void)dealloc
{
    [self stopObservations];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIPageViewController DataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    if(viewController == nil){
        return nil;
    }
    
    NSAssert([viewController isKindOfClass:[EBPhotoViewController class]], @"EBPhotoPageViewController requires the use of EBPhotoViewController kind of classes.");
    EBPhotoViewController *photoViewController = (EBPhotoViewController *)viewController;
    NSInteger previousIndex = photoViewController.photoIndex - 1;
    UIViewController *newController = [self pageViewController:pageViewController viewControllerAtIndex:previousIndex];
    return newController;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if(viewController == nil){
        return nil;
    }
    
    NSAssert([viewController isKindOfClass:[EBPhotoViewController class]], @"EBPhotoPageViewController requires the use of EBPhotoViewController kind of classes.");
    EBPhotoViewController *photoViewController = (EBPhotoViewController *)viewController;
    NSInteger nextIndex = photoViewController.photoIndex + 1;
    UIViewController *newController = [self pageViewController:pageViewController viewControllerAtIndex:nextIndex];
    return newController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                   viewControllerAtIndex:(NSInteger)index
{
    if([self.photosDataSource photoPagesController:self
                           shouldExpectPhotoAtIndex:index]){
        EBPhotoViewController *newPhotoViewController = [self.photoPagesFactory
                                                          photoViewControllerWithIndex:index
                                                          forPhotoPagesController:self];
        [self loadDataForPhotoViewController:newPhotoViewController];
        return newPhotoViewController;
    }
    
    return nil;
}


//!!!: See comment below if bug is encountered
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if(completed){
        //(): viewControllers[0] is always the current displayed view controller for a UIPageViewController as of iOS 6.
        EBPhotoViewController *photoViewController = self.viewControllers[0];
        [self setCurrentPhotoIndex:photoViewController.photoIndex];
        
        [self.currentState photoPagesController:self
                     didTransitionToPageAtIndex:self.currentPhotoIndex];
        
        [self updateToolbarsWithPhotoAtIndex:photoViewController.photoIndex];
    }
}


- (void)updateToolbarsWithPhotoAtIndex:(NSInteger)index
{
    NSArray *upperItems = [self.photoPagesFactory
                           upperToolbarItemsForPhotoPagesController:self
                           inState:self.currentState];
    
    NSArray *lowerItems = [self.photoPagesFactory
                           lowerToolbarItemsForPhotoPagesController:self
                           inState:self.currentState];
    
    NSMutableArray *mutableUpperItems = [NSMutableArray arrayWithArray:upperItems];
    NSMutableArray *mutableLowerItems = [NSMutableArray arrayWithArray:lowerItems];
    

    BOOL taggingAllowed = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldAllowTaggingForPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
              shouldAllowTaggingForPhotoAtIndex:index] : YES;
    
    BOOL activitiesAllowed = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldAllowActivitiesForPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
           shouldAllowActivitiesForPhotoAtIndex:index] : YES;
    
    BOOL commentsAreViewable = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldShowCommentsForPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
              shouldShowCommentsForPhotoAtIndex:index] : YES;
    
    if([self.photosDataSource photoPagesController:self shouldExpectPhotoAtIndex:index] == NO){
        taggingAllowed = NO;
        activitiesAllowed = NO;
        commentsAreViewable = NO;
    }
    
    if(taggingAllowed == NO){
        [mutableUpperItems removeObject:self.tagBarButtonItem];
        [mutableLowerItems removeObject:self.tagBarButtonItem];
    }
   
    if(activitiesAllowed == NO){
        [mutableUpperItems removeObject:self.activityBarButtonItem];
        [mutableLowerItems removeObject:self.activityBarButtonItem];
    }
    
    if(commentsAreViewable == NO){
        [mutableUpperItems removeObject:self.commentsBarButtonItem];
        [mutableUpperItems removeObject:self.commentsBarButtonItem];
    }
    
    EBPhotoViewController *photoViewController = [self photoViewControllerWithIndex:index];
    
    BOOL photoHasTags = photoViewController.tagPopovers.count ? YES : NO;
    if(photoHasTags == NO){
        [mutableUpperItems removeObject:self.toggleTagsBarButtonItem];
        [mutableLowerItems removeObject:self.toggleTagsBarButtonItem];
    }
    
    NSInteger numberOfPhotoComments = photoViewController.comments.count;
    BOOL commentingAllowed = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldAllowCommentingForPhotoAtIndex:)] ?
                                            [self.photosDataSource photoPagesController:self shouldAllowCommentingForPhotoAtIndex:index] : YES;
    if(numberOfPhotoComments == 0 && commentingAllowed == NO){
        [mutableUpperItems removeObject:self.commentsBarButtonItem];
        [mutableLowerItems removeObject:self.commentsBarButtonItem];
    }
    
    UIImage *commentsIcon = [self.photoPagesFactory
                             iconForCommentsBarButtonItemForPhotoPagesController:self
                             forState:UIControlStateNormal
                             withCount:numberOfPhotoComments];
    
    UIImage *exitCommentsIcon = [self.photoPagesFactory
                                 iconForCommentsBarButtonItemForPhotoPagesController:self
                                 forState:UIControlStateSelected
                                 withCount:numberOfPhotoComments];
    
    [self.commentsBarButtonItem setImage:commentsIcon];
    [self.commentsExitBarButtonItem setImage:exitCommentsIcon];
    
    [self setUpperToolbarItems:mutableUpperItems];
    [self setUpperToolbarBackgroundForState:self.currentState];
    
    [self setLowerToolbarItems:mutableLowerItems];
    [self setLowerToolbarBackgroundForState:self.currentState];
}

- (void)updateTagsToggleButton
{
    if(self.toggleTagsBarButtonItem){
        UIControlState tagButtonState = self.tagsHidden ? UIControlStateNormal :
        UIControlStateSelected;
        UIImage *buttonImage = [self.photoPagesFactory iconForToggleTagsBarButtonItemForPhotoPagesController:self
                                                                                                    forState:tagButtonState];
        [self.toggleTagsBarButtonItem setImage:buttonImage];
    }
}


#pragma mark - Loading

- (void)loadView
{
    [super loadView];
    NSAssert(self.photoPagesFactory, @"Photo Pages Controller must have a factory object to build UI Components.");
    [self loadInitialPageWithIndex:self.currentPhotoIndex];
    [self setCaptionWithPhotoIndex:self.currentPhotoIndex];
    [self loadUpperGradient];
    [self loadLowerGradient];
    [self loadScreenDimmer];
    [self loadUpperToolbar];
    [self loadLowerToolbar];
    [self loadCaptionView];
    [self loadTaggingLabel];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setCurrentState:[EBPhotoPagesStateUninitialized new]];
    [self.currentState photoPagesControllerDidFinishLoadingView:self];
}

- (void)loadInitialPageWithIndex:(NSInteger)index
{
    if([self.photosDataSource photoPagesController:self shouldExpectPhotoAtIndex:index]){
        EBPhotoViewController *initialPage = [[EBPhotoViewController alloc] initWithIndex:index delegate:self];
        
        [self setViewControllers:@[initialPage]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
        
        [self loadDataForPhotoViewController:initialPage];
        [self setCurrentPhotoIndex:index];
    }
}

- (void)loadDataForPhotoViewController:(EBPhotoViewController *)photoViewController
{
    [self loadImageForPhotoViewController:photoViewController];
    [self loadCaptionForPhotoViewController:photoViewController];
    [self loadMetaDataForPhotoViewController:photoViewController];
    [photoViewController setTagsHidden:self.tagsHidden];
    [photoViewController setCommentsHidden:self.commentsHidden];
    [self loadTagsForPhotoViewController:photoViewController];
    [self loadCommentsForPhotoViewController:photoViewController];
}

- (void)loadImageForPhotoViewController:(EBPhotoViewController *)photoViewController
{
    EBImageLoadOperation *imageLoad = [[EBImageLoadOperation alloc]
                                        initWithPhotoPagesController:self
                                        photoViewController:photoViewController
                                        dataSource:self.photosDataSource];
    [self.photoLoadingQueue addOperation:imageLoad];
}

- (void)loadCaptionForPhotoViewController:(EBPhotoViewController *)photoViewController
{
    EBCaptionLoadOperation *captionLoad = [[EBCaptionLoadOperation alloc]
                                            initWithPhotoPagesController:self
                                            photoViewController:photoViewController
                                            dataSource:self.photosDataSource];
    [self.photoLoadingQueue addOperation:captionLoad];
}

- (void)loadMetaDataForPhotoViewController:(EBPhotoViewController *)photoViewController
{
    EBMetaDataLoadOperation *metaDataLoad = [[EBMetaDataLoadOperation alloc]
                                              initWithPhotoPagesController:self
                                              photoViewController:photoViewController
                                              dataSource:self.photosDataSource];
    [self.photoLoadingQueue addOperation:metaDataLoad];
}

- (void)loadTagsForPhotoViewController:(EBPhotoViewController *)photoViewController
{
    EBTagsLoadOperation *tagsLoad = [[EBTagsLoadOperation alloc]
                                      initWithPhotoPagesController:self
                                      photoViewController:photoViewController
                                      dataSource:self.photosDataSource];
    [self.photoLoadingQueue addOperation:tagsLoad];
}

- (void)loadCommentsForPhotoViewController:(EBPhotoViewController *)photoViewController
{
    BOOL commentingIsAllowed = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldAllowCommentingForPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
           shouldAllowCommentingForPhotoAtIndex:photoViewController.photoIndex] : NO;
    
    [photoViewController setCommentingEnabled:commentingIsAllowed];
    
    EBCommentsLoadOperation *commentsLoad = [[EBCommentsLoadOperation alloc]
                                              initWithPhotoPagesController:self
                                              photoViewController:photoViewController
                                                       dataSource:self.photosDataSource];
    [self.photoLoadingQueue addOperation:commentsLoad];
}

- (void)loadPhotoPagesFactory
{
    if(self.photoPagesFactory == nil){
        EBPhotoPagesFactory *newFactory = [EBPhotoPagesFactory new];
        [self setPhotoPagesFactory:newFactory];
    }
}

- (void)loadOperationsQueue
{
    [self setPhotoLoadingQueue:[NSOperationQueue new]];
    
    NSString *queueName = [NSString stringWithFormat:@"Photo Loading Queue %i", arc4random()];
    [self.photoLoadingQueue setName:queueName];
}

- (void)loadUpperGradient
{
    EBShadedView *upperGradient = [self.photoPagesFactory
                                   upperGradientViewForPhotoPagesController:self];
    [self.view addSubview:upperGradient];
    [self setUpperGradient:upperGradient];
}

- (void)loadLowerGradient
{
    EBShadedView *lowerGradient = [self.photoPagesFactory 
                                    lowerGradientViewForPhotoPagesController:self];
    [self.view addSubview:lowerGradient];
    [self setLowerGradient:lowerGradient];
}

- (void)loadScreenDimmer
{
    EBShadedView *dimView = [self.photoPagesFactory  screenDimmerForPhotoPagesController:self];
    [self.view addSubview:dimView];
    [self setScreenDimmer:dimView];
}

- (void)loadUpperToolbar
{
    UIToolbar *toolbar = [self.photoPagesFactory  upperToolbarForPhotoPagesController:self];
    [self.view addSubview:toolbar];
    [self setUpperToolbar:toolbar];
}

- (void)loadLowerToolbar
{
    UIToolbar *toolbar = [self.photoPagesFactory  lowerToolbarForPhotoPagesController:self];
    [self.view addSubview:toolbar];
    [self setLowerToolbar:toolbar];
}

- (void)loadCaptionView
{
    EBCaptionView *captionView = [self.photoPagesFactory captionViewForPhotoPagesController:self];
    [self.view addSubview:captionView];
    [self setCaptionView:captionView];
}

- (void)loadTaggingLabel
{
    UILabel *taggingLabel = [self.photoPagesFactory taggingLabelForPhotoPagesController:self];
    [self.view addSubview:taggingLabel];
    [self setTaggingLabel:taggingLabel];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCaptionWithPhotoIndex:self.currentPhotoIndex];
    [self beginObservations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setStatusBarDisabled:YES withAnimation:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setStatusBarDisabled:NO withAnimation:animated];
}

#pragma mark - Rotation Handling

- (BOOL)shouldAutorotate
{
    return [self.currentState shouldAutorotatePhotoPagesController:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
}


#pragma mark - Notification and Key Value observing

- (void)beginObservations
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEndSingleTouchOnPhotoWithNotification:)
                                                 name:EBPhotoViewTouchDidEndNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeSingleTapWithNotification:)
                                                 name:EBPhotoViewSingleTapNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeDoubleTapWithNotification:)
                                                 name:EBPhotoViewDoubleTapNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeLongPressWithNotification:) name:EBPhotoViewLongPressNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadNewCaptionWithNotification:)
                                                 name:EBPhotoViewControllerDidSetCaptionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadNewMetaDataWithNotification:)
                                                 name:EBPhotoViewControllerDidSetMetaDataNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadNewTagsWithNotification:)
                                                 name:EBPhotoViewControllerDidUpdateTagsNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoadNewCommentsWithNotification:) name:EBPhotoViewControllerDidUpdateCommentsNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(photoViewControllerDidCreateNewTagWithNotification:)name:EBPhotoViewControllerDidCreateTagNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(photoViewControllerDidBeginCommentingWithNotification:)
                                                 name:EBPhotoViewControllerDidBeginCommentingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(photoViewControllerDidEndCommentingWithNotification:) name:EBPhotoViewControllerDidEndCommentingNotification
                                               object:nil];
    
    
    [self.captionView addObserver:self
                       forKeyPath:ContentOffsetKeyPath
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    
    [self addObserver:self
           forKeyPath:CurrentPhotoIndexKeyPath
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [self addObserver:self
           forKeyPath:TagsHiddenKeyPath
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [self addObserver:self
           forKeyPath:CommentsHiddenKeyPath
              options:NSKeyValueObservingOptionNew
              context:nil];
}



- (void)stopObservations
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.captionView removeObserver:self forKeyPath:ContentOffsetKeyPath];
    [self removeObserver:self forKeyPath:CurrentPhotoIndexKeyPath];
    [self removeObserver:self forKeyPath:TagsHiddenKeyPath];
    [self removeObserver:self forKeyPath:CommentsHiddenKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.captionView && [keyPath isEqualToString:ContentOffsetKeyPath]){
        if(self.captionView.hidden || self.captionView.alpha == 0){
            [self setPhotoDimLevel:0.0];
            return;
        }
        
        if(self.captionView.contentOffset.y + self.captionView.contentInset.top > 10){
            [self setPhotoDimLevel:0.5];
        } else {
            [self setPhotoDimLevel:0.0];
        }
    }
    
    if(object == self && [keyPath isEqualToString:CurrentPhotoIndexKeyPath]){
        [self setCaptionWithPhotoIndex:self.currentPhotoIndex];
        [self setMetaDataWithPhotoIndex:self.currentPhotoIndex];
        [self updateToolbarsWithPhotoAtIndex:self.currentPhotoIndex];
    }
    
    NSString *notificationName;
    if(object == self && [keyPath isEqualToString:TagsHiddenKeyPath]){
        notificationName = self.tagsHidden ? EBPhotoPagesControllerDidToggleTagsOff :
                                             EBPhotoPagesControllerDidToggleTagsOn;

        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self];
        [self updateTagsToggleButton];
    }
    
    if(object == self && [keyPath isEqualToString:CommentsHiddenKeyPath]){
        notificationName = self.commentsHidden ? EBPhotoPagesControllerDidToggleCommentsOff :
                                                 EBPhotoPagesControllerDidToggleCommentsOn;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self];
    }
}

#pragma mark - State Transitions

- (void)enterBrowsingMode
{
    [self setCurrentState:[EBPhotoPagesStateBrowsing new]];
}

- (void)enterBrowsingModeWithInterfaceHidden
{
    [self setCurrentState:[EBPhotoPagesStateBrowsingInterfaceHidden new]];
}

- (void)enterTaggingMode
{
    [self setCurrentState:[EBPhotoPagesStateTaggingIdle new]];
}

- (void)enterTagEntryMode
{
    [self setCurrentState:[EBPhotoPagesStateTaggingNew new]];
}

- (void)enterCommentsMode
{
    [self setCurrentState:[EBPhotoPagesStateCommentingIdle new]];
}


#pragma mark - Setters


- (void)setStatusBarDisabled:(BOOL)disabled withAnimation:(BOOL)animated
{
    UIStatusBarAnimation animation = animated ? UIStatusBarAnimationFade :
    UIStatusBarAnimationNone;
    BOOL statusBarHidden = disabled ? YES : self.originalStatusBarVisibility;
    [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden
                                            withAnimation:animation];
}

- (void)setCurrentState:(id<EBPhotoPagesStateDelegate>)nextState
{
    BOOL allowTransition = [self.photoPagesDelegate respondsToSelector:@selector(photoPagesController:shouldTransitionfromCurrentState:toNewState:)] ?
    [self.photoPagesDelegate photoPagesController:self
                 shouldTransitionfromCurrentState:self.currentState
                                       toNewState:nextState] : YES;
    
    if(allowTransition){
        EBPhotoPagesState *previousState = self.currentState;
        [self.currentState photoPagesController:self willTransitionToState:nextState];
        _currentState = nextState;
        [self.currentState photoPagesController:self didTransitionFromState:previousState];
        
        [self updateToolbarsWithPhotoAtIndex:self.currentPhotoIndex];
    }
}

- (void)setCaptionWithPhotoIndex:(NSInteger)photoIndex
{
    EBPhotoViewController *photoViewController = [self photoViewControllerWithIndex:photoIndex];
    
    if(photoViewController.attributedCaption){
        [self.captionView performSelectorOnMainThread:@selector(setAttributedCaption:)
                                           withObject:photoViewController.attributedCaption
                                        waitUntilDone:NO];
    } else {
        [self.captionView performSelectorOnMainThread:@selector(setCaption:)
                                           withObject:photoViewController.caption
                                        waitUntilDone:NO];
    }
}

- (void)setCommentsWithPhotoAtIndex:(NSInteger)photoIndex
{
    //EBPhotoViewController *photoViewController = [self photoViewControllerWithIndex:photoIndex];
    
}

- (void)setMetaDataWithPhotoIndex:(NSInteger)photoIndex
{
    NSLog(@"update meta data %li", (long)photoIndex);
    
}

- (void)setInterfaceHidden:(BOOL)hidden
{
    CGFloat alpha = hidden ? 0.0 : 1.0;
    
    [self setUpperBarAlpha:alpha];
    [self setCaptionAlpha:alpha];
    [self setLowerBarAlpha:alpha];
    [self setPhotoDimLevel:0.0];
    [self setUpperGradientAlpha:alpha];
    [self setLowerGradientAlpha:alpha];
    [self setTaggingLabelHidden:YES];
    
    if(hidden){
        [self setTagsHidden:YES];
    }
}



- (void)setCaptionAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut|
                                UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.captionView setAlpha:alpha];
                         if(alpha == 0.0){
                             [self.captionView resetContentOffset];
                         }
                     }completion:nil];
}

- (void)setCommentsTableViewAlpha:(CGFloat)alpha
{
    /*[UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut|
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.commentsTableView setAlpha:alpha];
                         if(alpha == 0.0){
                             [self.commentsTableView setContentOffset:CGPointZero];
                         }
                     }completion:nil];*/
}


- (void)setPhotoDimLevel:(CGFloat)alpha
{
    [self setAlpha:alpha forView:self.screenDimmer];
}

- (void)setUpperBarAlpha:(CGFloat)alpha
{
    [self setAlpha:alpha forView:self.upperToolbar];
}

- (void)setLowerBarAlpha:(CGFloat)alpha
{
    [self setAlpha:alpha forView:self.lowerToolbar];
}

- (void)setUpperGradientAlpha:(CGFloat)alpha
{
    [self setAlpha:alpha forView:self.upperGradient];
}

- (void)setLowerGradientAlpha:(CGFloat)alpha
{
    [self setAlpha:alpha forView:self.lowerGradient];
}

- (void)setAlpha:(CGFloat)alpha forView:(UIView *)view
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut|
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [view setAlpha:alpha];
                     }completion:nil];
}


- (void)setLowerToolbarBackgroundForState:(EBPhotoPagesState *)state
{
    UIImage *backgroundImage = [self.photoPagesFactory
                                lowerToolbarBackgroundForPhotoPagesController:self
                                                                      inState:state];
    [self.lowerToolbar setBackgroundImage:backgroundImage
                       forToolbarPosition:UIToolbarPositionAny
                               barMetrics:UIBarMetricsDefault];
}

- (void)setUpperToolbarBackgroundForState:(EBPhotoPagesState *)state
{
    UIImage *backgroundImage = [self.photoPagesFactory
                                upperToolbarBackgroundForPhotoPagesController:self
                                                                      inState:state];
    
    [self.upperToolbar setBackgroundImage:backgroundImage
                       forToolbarPosition:UIToolbarPositionAny
                               barMetrics:UIBarMetricsDefault];
}

- (void)setTaggingLabelHidden:(BOOL)hidden
{
    if(self.taggingLabel.hidden == hidden){
        return;
    }
    
    CGFloat duration = 0.2;
    CGFloat delay = hidden ? 0.0 : 0.4;
    CGFloat newAlpha = hidden ? 0.0 : 1.0;
    CGSize moveDistance = CGSizeMake(0, 20);
    CGRect startFrame = hidden ? self.taggingLabel.frame : CGRectOffset(self.taggingLabel.frame,
                                                                        moveDistance.width,
                                                                        moveDistance.height);
    CGRect endFrame = hidden ? CGRectOffset(self.taggingLabel.frame, moveDistance.width,
                                            moveDistance.height) :
    self.taggingLabel.frame;
    
    CGRect originalFrame = self.taggingLabel.frame;
    [self.taggingLabel setHidden:NO];
    [self.taggingLabel setFrame:startFrame];
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.taggingLabel setAlpha:newAlpha];
                         [self.taggingLabel setFrame:endFrame];
                     }completion:^(BOOL finished){
                         [self.taggingLabel setFrame:originalFrame];
                         [self.taggingLabel setHidden:hidden];
                     }
     ];
}

- (void)setTitle:(NSString *)title forBarButton:(UIBarButtonItem *)barButton
{
    NSAssert(barButton, @"Must have a button to edit.");
    NSAssert(title, @"Button title cannot be nil");
    
    UIButton *buttonView = (UIButton *)[barButton customView];
    NSAssert([buttonView isKindOfClass:[UIButton class]], @"Expected barButtonItem to have UIButton for custom view.");
    
    [buttonView setTitle:title forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [buttonView sizeToFit];
                     }completion:nil];
}

- (void)setUpperToolbarItems:(NSArray *)items
{
    NSAssert(self.upperToolbar, @"Must have an upper toolbar to add items to.");
    [self.upperToolbar setItems:items animated:YES];
}

- (void)setLowerToolbarItems:(NSArray *)items
{
    NSAssert(self.lowerToolbar, @"Must have an upper toolbar to add items to.");
    [self.lowerToolbar setItems:items animated:YES];
}


- (void)setComments:(NSArray *)comments forPhotoAtIndex:(NSInteger)index
{
    for(NSObject *comment in comments){
        NSAssert([comment conformsToProtocol:@protocol(EBPhotoCommentProtocol)],
                 @"Comment objects must conform to EBPhotoCommentProtocol");
    }
    
    EBPhotoViewController *photoViewController = [self photoViewControllerWithIndex:index];
    if(photoViewController){
        [photoViewController setComments:comments];
    }
}


#pragma mark - Getters

- (EBPhotoViewController *)currentPhotoViewController
{
    return [self photoViewControllerWithIndex:self.currentPhotoIndex];
}

- (EBPhotoViewController *)photoViewControllerWithIndex:(NSInteger)photoIndex
{
    for(EBPhotoViewController *photoViewController in self.viewControllers){
        if(photoViewController.photoIndex == photoIndex){
            return photoViewController;
        }
    }
    return nil;
}

- (UIBarButtonItem *)doneBarButtonItem
{
    if(_doneBarButtonItem == nil){
        UIBarButtonItem *newDoneButton = [self.photoPagesFactory doneBarButtonItemForPhotoPagesController:self];
        [self setDoneBarButtonItem:newDoneButton];
    }
    
    return _doneBarButtonItem;
}

- (UIBarButtonItem *)cancelBarButtonItem
{
    if(!_cancelBarButtonItem){
        UIBarButtonItem *newCancelButton = [self.photoPagesFactory cancelBarButtonItemForPhotoPagesController:self];
        [self setCancelBarButtonItem:newCancelButton];
    }
    
    return _cancelBarButtonItem;
}

- (UIBarButtonItem *)tagBarButtonItem
{
    if(_tagBarButtonItem == nil){
        UIBarButtonItem *newTagButton = [self.photoPagesFactory tagBarButtonItemForPhotoPagesController:self];
        [self setTagBarButtonItem:newTagButton];
    }
    
    return _tagBarButtonItem;
}

- (UIBarButtonItem *)doneTaggingBarButtonItem
{
    if(_doneTaggingBarButtonItem == nil){
        UIBarButtonItem *newDoneTaggingButton = [self.photoPagesFactory doneTaggingBarButtonItemForPhotoPagesController:self];
        [self setDoneTaggingBarButtonItem:newDoneTaggingButton];
    }
    
    return _doneTaggingBarButtonItem;
}

- (UIBarButtonItem *)activityBarButtonItem
{
    if(_activityBarButtonItem == nil){
        UIBarButtonItem *activityButton = [self.photoPagesFactory activityBarButtonItemForPhotoPagesController:self];
        [self setActivityBarButtonItem:activityButton];
    }
    
    return _activityBarButtonItem;
}

- (UIBarButtonItem *)commentsBarButtonItem
{
    if(_commentsBarButtonItem == nil){
        EBPhotoViewController *currentPhotoViewController = [self currentPhotoViewController];
        NSInteger numberOfComments = currentPhotoViewController.comments.count;
        UIBarButtonItem *commentButton = [self.photoPagesFactory commentsBarButtonItemForPhotoPagesController:self count:numberOfComments];
        [self setCommentsBarButtonItem:commentButton];
    }
    
    return _commentsBarButtonItem;
}

- (UIBarButtonItem *)miscBarButtonItem
{
    if(_miscBarButtonItem == nil){
        UIBarButtonItem *miscButton = [self.photoPagesFactory
            miscBarButtonItemForPhotoPagesController:self];
        [self setMiscBarButtonItem:miscButton];
    }
    
    return _miscBarButtonItem;
}


- (UIBarButtonItem *)commentsExitBarButtonItem
{
    if(_commentsExitBarButtonItem == nil){
        EBPhotoViewController *currentPhotoViewController = [self currentPhotoViewController];
        NSInteger numberOfComments = currentPhotoViewController.comments.count;
        UIBarButtonItem *commentExitButton = [self.photoPagesFactory commentsExitBarButtonItemForPhotoPagesController:self count:numberOfComments];
        [self setCommentsExitBarButtonItem:commentExitButton];
    }
    
    return _commentsExitBarButtonItem;
}

- (UIBarButtonItem *)toggleTagsBarButtonItem
{
    if(_toggleTagsBarButtonItem == nil){
        UIBarButtonItem *toggleButton = [self.photoPagesFactory toggleTagsBarButtonItemForPhotoPagesController:self];
        [self setToggleTagsBarButtonItem:toggleButton];
    }
    
    return _toggleTagsBarButtonItem;
}

#pragma mark - Event Hooks

- (void)didEndSingleTouchOnPhotoWithNotification:(NSNotification *)aNotification
{
    EBPhotoView *photoView = aNotification.object;
    NSAssert([photoView isKindOfClass:[EBPhotoView class]], @"Expected EBPhotoView kind of class.");
    
    NSDictionary *touchInfo = aNotification.userInfo;
    NSValue *normalPointValue = touchInfo[@"normalizedPointInPhoto"];
    CGPoint normalizedPoint = [normalPointValue CGPointValue];
    
    EBPhotoViewController *currentPhotoViewController = [self currentPhotoViewController];
    if(currentPhotoViewController.photoView == photoView){
        [self.currentState photoPagesController:self
                    didTouchPhotoViewController:currentPhotoViewController
                              atNormalizedPoint:normalizedPoint];
    }
}

- (void)didRecognizeSingleTapWithNotification:(NSNotification *)aNotification
{
    NSAssert(self.currentState, @"EBPhotoPagesController has a nil state. This is invalid");
    NSDictionary *tapInfo = aNotification.userInfo;
    UITapGestureRecognizer *singleTap = tapInfo[@"touchGesture"];
    
    BOOL respondToSingleTap = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldHandleSingleTapGesture:forPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
                   shouldHandleSingleTapGesture:singleTap
                                forPhotoAtIndex:self.currentPhotoIndex] : YES;
  
    if(respondToSingleTap){
        [self.currentState photoPagesController:self
                            didReceiveSingleTap:singleTap
                               withNotification:aNotification];
    }
}

- (void)didRecognizeDoubleTapWithNotification:(NSNotification *)aNotification
{
    NSAssert(self.currentState, @"EBPhotoPagesController has a nil state. This is invalid");
    NSDictionary *tapInfo = aNotification.userInfo;
    UITapGestureRecognizer *doubleTap = tapInfo[@"touchGesture"];
    
    BOOL respondToDoubleTap = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldHandleDoubleTapGesture:forPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
                   shouldHandleDoubleTapGesture:doubleTap
                                forPhotoAtIndex:self.currentPhotoIndex] : YES;
    
    if(respondToDoubleTap){
        [self.currentState photoPagesController:self
                            didReceiveDoubleTap:doubleTap
                               withNotification:aNotification];
    }

}

- (void)didRecognizeLongPressWithNotification:(NSNotification *)aNotification
{
    NSAssert(self.currentState, @"EBPhotoPagesController has a nil state. This is invalid");
    NSDictionary *tapInfo = aNotification.userInfo;
    UILongPressGestureRecognizer *longPress = tapInfo[@"touchGesture"];
    NSMutableDictionary *photoInfo = [NSMutableDictionary dictionaryWithDictionary:tapInfo];
    photoInfo[@"currentPhotoIndex"] = [NSNumber numberWithInteger:self.currentPhotoIndex];
    NSNotification *notification = [NSNotification notificationWithName:aNotification.name
                                                                    object:aNotification.object
                                                                  userInfo:photoInfo];

    BOOL respondToLongPress = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldHandleLongPressGesture:forPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
                   shouldHandleLongPressGesture:longPress
                                forPhotoAtIndex:self.currentPhotoIndex] : YES;
    
    
    if(respondToLongPress){
        [self.currentState photoPagesController:self
                            didReceiveLongPress:longPress
                               withNotification:notification];
    }
}


- (void)didLoadNewCaptionWithNotification:(NSNotification *)aNotification
{
    NSAssert([aNotification.object isKindOfClass:[EBPhotoViewController class]],
             @"Expected notification from EBPhotoViewController kind of class.");
    EBPhotoViewController *photoViewController = aNotification.object;
    
    if(self.currentPhotoIndex == photoViewController.photoIndex){
        [self setCaptionWithPhotoIndex:photoViewController.photoIndex];
    }
}

- (void)didLoadNewMetaDataWithNotification:(NSNotification *)aNotification
{
    NSAssert([aNotification.object isKindOfClass:[EBPhotoViewController class]],
             @"Expected notification from EBPhotoViewController kind of class.");
    EBPhotoViewController *photoViewController = aNotification.object;
    
    if(photoViewController.photoIndex == self.currentPhotoIndex){
        [self setMetaDataWithPhotoIndex:photoViewController.photoIndex];
    }
}

- (void)didLoadNewTagsWithNotification:(NSNotification *)aNotification
{
    NSAssert([aNotification.object isKindOfClass:[EBPhotoViewController class]],
             @"Expected notification from EBPhotoViewController kind of class.");
    EBPhotoViewController *photoViewController = aNotification.object;
    
    if(photoViewController.photoIndex == self.currentPhotoIndex){
        [self updateToolbarsWithPhotoAtIndex:self.currentPhotoIndex];
    }
}

- (void)didLoadNewCommentsWithNotification:(NSNotification *)aNotification
{
    NSAssert([aNotification.object isKindOfClass:[EBPhotoViewController class]],
             @"Expected notification from EBPhotoViewController kind of class.");
    EBPhotoViewController *photoViewController = aNotification.object;
    
    if(photoViewController.photoIndex == self.currentPhotoIndex){
        [self updateToolbarsWithPhotoAtIndex:self.currentPhotoIndex];
    }
}

- (void)photoViewControllerDidCreateNewTagWithNotification:(NSNotification *)aNotification
{
    NSAssert([aNotification.object isKindOfClass:[EBPhotoViewController class]],
             @"Expected notification from EBPhotoViewController kind of class.");
    
    EBTagPopover *tag = aNotification.userInfo[@"tagPopover"];
    NSNumber *taggedPhotoIndex = aNotification.userInfo[@"taggedPhotoIndex"];
    
    [self.currentState photoPagesController:self
                         didFinishAddingTag:tag
                            forPhotoAtIndex:taggedPhotoIndex.integerValue];
}


- (void)photoViewControllerDidBeginCommentingWithNotification:(NSNotification *)aNotification
{
    [self setCurrentState:[EBPhotoPagesStateCommentingNew new]];
}

- (void)photoViewControllerDidEndCommentingWithNotification:(NSNotification *)aNotification
{
    [self setCurrentState:[EBPhotoPagesStateCommentingIdle new]];
}

- (void)didSelectActivityButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectActivityButton:sender];
}

- (void)didSelectMiscButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectMiscButton:sender];
}

- (void)didSelectCommentsButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectCommentsButton:sender];
}

- (void)didSelectDoneButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectDoneButton:sender];
}

- (void)didSelectCancelButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectCancelButton:sender];
}

- (void)didSelectTagButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectTagButton:sender];
}

- (void)didSelectTagDoneButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectDoneButton:sender];
}

- (void)didSelectToggleTagsButton:(id)sender
{
    [self.currentState photoPagesController:self didSelectToggleTagsButton:sender];
}


#pragma mark - Actions


- (void)dismiss
{
    [self.photoLoadingQueue cancelAllOperations];
    
    BOOL shouldDismiss = [self.photoPagesDelegate respondsToSelector:@selector(shouldDismissPhotoPagesController:)] ?
    [self.photoPagesDelegate shouldDismissPhotoPagesController:self] : YES;
    

    if(shouldDismiss){
        
        if([self.photoPagesDelegate respondsToSelector:
            @selector(photoPagesControllerWillDismiss:)]){
            [self.photoPagesDelegate photoPagesControllerWillDismiss:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoPagesControllerWillDismissNotification object:self];
        
        
        [self dismissViewControllerAnimated:YES completion:^{
            if([self.photoPagesDelegate respondsToSelector:
                @selector(photoPagesControllerDidDismiss:)]){
                [self.photoPagesDelegate photoPagesControllerDidDismiss:self];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoPagesControllerDidDismissNotification object:self];
        }];
    }

}


- (void)presentActivitiesForPhotoViewController:(EBPhotoViewController *)photoViewController
{
    NSAssert([photoViewController isKindOfClass:[EBPhotoViewController class]], @"Expected EBPhotoViewController kind of class.");
    
    UIImage *image = [photoViewController image];
    
    NSString *caption =
    photoViewController.attributedCaption ? [photoViewController.attributedCaption string]:
    photoViewController.caption;
    
    UIActivityViewController *activityViewController;
    
    if([self.photosDataSource
        respondsToSelector:@selector(activityViewControllerForImage:withCaption:atIndex:)]){
        activityViewController =  [self.photosDataSource
                                   photoPagesController:self
                                   activityViewControllerForImage:image
                                   withCaption:caption
                                   atIndex:photoViewController.photoIndex];
    }
    
    if(activityViewController == nil){
        activityViewController =
        [self.photoPagesFactory activityViewControllerForPhotoPagesController:self
                                                                  withImage:image
                                                                    caption:caption];
    }
    
    
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed){
        [self setUpperBarAlpha:1.0];
        [self setLowerBarAlpha:1.0];
    }];
    
    [self presentViewController:activityViewController
                             animated:YES
                           completion:nil];
    
    [self setUpperBarAlpha:0];
    [self setLowerBarAlpha:0];
}

- (void)cancelCurrentTagging
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoPagesControllerDidCancelTaggingNotification object:self];
}

- (void)startCommenting
{
    [self.currentPhotoViewController startCommenting];
}

- (void)cancelCommenting
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoPagesControllerDidCancelCommentingNotification object:self];
}


#pragma mark - Action Sheet Delegate

- (void)showActionSheetForPhotoAtIndex:(NSInteger)index
{
    BOOL showDefaultActionSheet = [self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldAllowDeleteForPhotoAtIndex:)] ?
    [self.photosDataSource photoPagesController:self
               shouldAllowDeleteForPhotoAtIndex:index] : YES;
    
    
    if(showDefaultActionSheet){
        UIActionSheet * actionSheet = [self.photoPagesFactory photoPagesController:self
                                                        actionSheetForPhotoAtIndex:index];
        NSDictionary *targetInfo = @{kActionSheetTargetKey:
                                         [self photoViewControllerWithIndex:index]};
        
        [actionSheet setDelegate:self];
        [self setActionSheetTargetInfo:targetInfo];
        [actionSheet showInView:self.view];
        
        [self setUpperBarAlpha:0];
        [self setLowerBarAlpha:0];
    }
}

- (void)showActionSheetForTagPopover:(EBTagPopover *)tagPopover
                      inPhotoAtIndex:(NSInteger)index
{
    UIActionSheet *actions = [self.photoPagesFactory
                              photoPagesController:self
                              actionSheetForTagPopover:tagPopover
                              inPhotoAtIndex:index];
    [actions setDelegate:self];
    NSDictionary *targetInfo = @{kActionSheetTargetKey : tagPopover,
                                 kActionSheetIndexKey : [NSNumber numberWithInteger:index]};
    [self setActionSheetTargetInfo:targetInfo];
    [actions showInView:self.view];
    
    [self setUpperBarAlpha:0];
    [self setLowerBarAlpha:0];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == [self.photoPagesFactory tagIdForTagActionSheet]){
        [self tagActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    } else if (actionSheet.tag == [self.photoPagesFactory tagIdForPhotoActionSheet]) {
        [self photoActionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

- (void)tagActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSAssert([self.actionSheetTargetInfo isKindOfClass:[NSDictionary class]],
            @"Expected action sheet target for tagActionSheet to be an NSDictionary kind of class!");
    EBTagPopover *tagPopover = self.actionSheetTargetInfo[kActionSheetTargetKey];
    NSNumber *indexNumber = self.actionSheetTargetInfo[kActionSheetIndexKey];
    NSInteger index = [indexNumber integerValue];
    if(buttonIndex == actionSheet.destructiveButtonIndex){
        [self deleteTagPopover:tagPopover inPhotoAtIndex:index];
    }
}

- (void)photoActionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //blank
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == [self.photoPagesFactory tagIdForTagActionSheet]){
        [self tagActionSheet:actionSheet didDismissWithButtonAtIndex:buttonIndex];
    } else if (actionSheet.tag == [self.photoPagesFactory tagIdForPhotoActionSheet]) {
        [self photoActionSheet:actionSheet didDismissWithButtonAtIndex:buttonIndex];
    }
}

- (void)tagActionSheet:(UIActionSheet *)actionSheet didDismissWithButtonAtIndex:(NSInteger)buttonIndex
{
    EBTagPopover *tagPopover = self.actionSheetTargetInfo[kActionSheetTargetKey];
    NSAssert([tagPopover isKindOfClass:[EBTagPopover class]], @"Expected object with kActionSheetTargetKey to be EBPhotoViewController kind of class.");
    
}

- (void)photoActionSheet:(UIActionSheet *)actionSheet didDismissWithButtonAtIndex:(NSInteger)buttonIndex
{
    NSAssert([self.actionSheetTargetInfo isKindOfClass:[NSDictionary class]],
             @"Expected action sheet target for photoActionSheet to be an NSDictionary kind of class!");
    
    EBPhotoViewController *photoViewController = self.actionSheetTargetInfo[kActionSheetTargetKey];
    NSAssert([photoViewController isKindOfClass:[EBPhotoViewController class]], @"Expected object with kActionSheetTargetKey to be EBPhotoViewController kind of class.");
    
    if(buttonIndex == actionSheet.destructiveButtonIndex){
        [self deletePhotoAtIndex:photoViewController.photoIndex];
    }
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    [self performActionOnPhotoAtIndex:photoViewController.photoIndex
                       forButtonTitle:buttonTitle];
    
    [self setActionSheetTargetInfo:nil];
    
    [self setUpperBarAlpha:1.0];
    [self setLowerBarAlpha:1.0];
}

- (void)performActionOnPhotoAtIndex:(NSInteger)index forButtonTitle:(NSString *)buttonTitle
{
    
    if([buttonTitle isEqualToString:[self.photoPagesFactory actionSheetReportButtonTitle]]){
        NSLog(@"Reporting photo.");
        if([self.photosDataSource
           respondsToSelector:@selector(photoPagesController:didReportPhotoAtIndex:)]){
            [self.photosDataSource photoPagesController:self didReportPhotoAtIndex:index];
        }
    } else if ([buttonTitle isEqualToString:[self.photoPagesFactory actionSheetTagPhotoButtonTitle]]){
        NSLog(@"Tagging photo.");
        [self didSelectTagButton:self];
    } else {
        NSLog(@"Unknown action sheet command.");
    }
    
}

- (void)deletePhotoAtIndex:(NSInteger)index
{
    [self.photosDataSource photoPagesController:self
                          didDeletePhotoAtIndex:index];
    
    NSInteger nextIndex = index;
    while(nextIndex >= 0){
        if([self.photosDataSource photoPagesController:self shouldExpectPhotoAtIndex:nextIndex]){
            break;
        };
        nextIndex--;
    }
    
    if(nextIndex >= 0){
        
        [self.captionView setCaption:nil];
        UIViewController *nextPage = [self pageViewController:self
                                    viewControllerAtIndex:nextIndex];
    
        __weak EBPhotoPagesController *controller = self;
        [self setViewControllers:@[nextPage]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:^(BOOL finished) {
                [controller setCurrentPhotoIndex:nextIndex];
                    }];
    } else {
        [self dismiss];
    }
}

- (void)deleteTagPopover:(EBTagPopover *)tagPopover inPhotoAtIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.5f
                          delay:0.05f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
//                         tagPopover.transform = CGAffineTransformMakeScale(0.0, 0.0);
                         [tagPopover setTransform:CGAffineTransformMakeTranslation(0.0f, 400.0f)];
                         [tagPopover setAlpha:0.0f];
                     } completion:^(BOOL finished) {
                             [tagPopover removeFromSuperview];
                     }];

    [self.photosDataSource photoPagesController:self
                            didDeleteTagPopover:tagPopover
                                 inPhotoAtIndex:index];
}



#pragma mark - EBPhotoViewControllerDelegate

- (BOOL)photoViewController:(EBPhotoViewController *)controller
           canDeleteComment:(id<EBPhotoCommentProtocol>)comment
{
    NSAssert([controller isKindOfClass:[EBPhotoViewController class]], @"Expected EBPhotoViewController kind of class.");
    BOOL result = NO;
    if([self.photosDataSource respondsToSelector:@selector(photoPagesController:shouldAllowDeleteForComment:forPhotoAtIndex:)]){
        result = [self.photosDataSource photoPagesController:self
                                            shouldAllowDeleteForComment:comment
                                             forPhotoAtIndex:controller.photoIndex];
    }
    
    return result;
}

- (void)photoViewController:(EBPhotoViewController *)controller
           didDeleteComment:(id<EBPhotoCommentProtocol>)comment
{
    NSAssert([controller isKindOfClass:[EBPhotoViewController class]], @"Expected EBPhotoViewController kind of class.");
    [self.photosDataSource photoPagesController:self
                               didDeleteComment:comment
                                forPhotoAtIndex:controller.photoIndex];
}

- (EBTagPopover *)photoViewController:(EBPhotoViewController *)controller
                      tagPopoverForTag:(id<EBPhotoTagProtocol>)tag
{
    NSAssert([controller isKindOfClass:[EBPhotoViewController class]], @"Expected EBPhotoViewController kind of class.");
    return [self.photoPagesFactory photoPagesController:self
                                       tagPopoverForTag:tag
                                         inPhotoAtIndex:controller.photoIndex];
}

- (void)photoViewController:(EBPhotoViewController *)controller didPostNewComment:(NSString *)comment
{
    
    NSAssert([controller isKindOfClass:[EBPhotoViewController class]], @"Expected EBPhotoViewController kind of class.");
    if([self.photosDataSource respondsToSelector:@selector(photoPagesController:didPostComment:forPhotoAtIndex:)]){
        [self.photosDataSource photoPagesController:self
                                     didPostComment:comment
                                    forPhotoAtIndex:controller.photoIndex];
    }
    
    [self loadCommentsForPhotoViewController:controller];
}


- (void)photoViewController:(EBPhotoViewController *)controller
        didSelectTagPopover:(EBTagPopover *)tagPopover
{
    NSAssert([controller isKindOfClass:[EBPhotoViewController class]], @"Expected EBPhotoViewController kind of class.");
    [self.currentState photoPagesController:self
                        didSelectTagPopover:tagPopover
                             inPhotoAtIndex:controller.photoIndex];
}


- (BOOL)photoViewController:(EBPhotoViewController *)controller
 shouldConfigureCommentCell:(EBCommentCell *)cell
          forRowAtIndexPath:(NSIndexPath *)indexPath
                withComment:(id<EBPhotoCommentProtocol>)comment
{
    BOOL configureCell = [self.photoPagesDelegate respondsToSelector:@selector(photoPagesController:shouldConfigureCommentCell:forRowAtIndexPath:withComment:)] ?
    [self.photoPagesDelegate photoPagesController:self shouldConfigureCommentCell:cell forRowAtIndexPath:indexPath withComment:comment] : YES;
    
    return configureCell;
}


- (EBCommentsView *)commentsViewForPhotoViewController:(EBPhotoViewController *)controller
{
    return [self.photoPagesFactory photoPagesController:self commentsViewForPhotoViewController:controller];
}


#pragma mark -
#pragma mark -
@end
