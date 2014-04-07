//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import "EBPhotoPagesOperation.h"
#import "EBPhotoPagesController.h"
#import "EBPhotoViewController.h"

@interface EBPhotoPagesOperation ()

- (void)operationWillStart;
- (void)loadData;
- (void)operationDidFinish;
- (void)operationDidCancel;

@end


@implementation EBPhotoPagesOperation

- (void)main
{
    @autoreleasepool {
        NSAssert(self.photoPagesController, @"Must have a photo pages controller assigned.");
        NSAssert(self.photoViewController, @"Must have a photo view controller to pass image to");
        NSAssert(self.dataSource,@"Must have a datasource to retrieve image from");
        
        [self setLoadingFinished:NO];
        [self operationWillStart];
        [self loadData];
        [self operationDidFinish];
    }
}

- (void)operationWillStart
{
    [self.photoViewController performSelectorOnMainThread:@selector(operationWillStartLoading:)
                                               withObject:self
                                            waitUntilDone:NO];

}

- (void)loadData
{

}

- (void)operationDidFinish
{
    [self operationDidStopLoading];
}

- (void)operationDidCancel
{
    [self operationDidStopLoading];
}

- (void)operationDidStopLoading
{
    [self.photoViewController performSelectorOnMainThread:@selector(operationDidStopLoading:)
                                               withObject:self
                                            waitUntilDone:NO];
}


- (id)initWithPhotoPagesController:(EBPhotoPagesController *)photoPagesController
               photoViewController:(EBPhotoViewController *)photoViewController
                        dataSource:(id<EBPhotoPagesDataSource>)dataSource
{
    self = [super init];
    if (self) {
        [self setPhotoPagesController:photoPagesController];
        [self setPhotoViewController:photoViewController];
        [self setDataSource:dataSource];
    }
    return self;
}

@end

#pragma mark - Image Loading

@implementation EBImageLoadOperation

- (void)loadData
{
    
    if([self.dataSource respondsToSelector:@selector(photoPagesController:imageAtIndex:)]){
        [self performSelectorOnMainThread:@selector(loadImageOnMainThread)
                               withObject:nil
                            waitUntilDone:NO];
        
    } else if ([self.dataSource respondsToSelector:
                @selector(photoPagesController:imageAtIndex:completionHandler:)]){
        
        [self.dataSource photoPagesController:self.photoPagesController
                                 imageAtIndex:self.photoViewController.photoIndex
                            completionHandler:^(UIImage *image){
            
            [self.photoViewController performSelectorOnMainThread:@selector(setImage:)
                                                       withObject:image
                                                    waitUntilDone:YES];
        }];
    }
}

- (void)loadImageOnMainThread
{
    UIImage *image = [self.dataSource photoPagesController:self.photoPagesController
                                              imageAtIndex:self.photoViewController.photoIndex];
    
    [self.photoViewController performSelectorOnMainThread:@selector(setImage:)
                                               withObject:image
                                            waitUntilDone:NO];
}

@end

#pragma mark - Caption Loading

@implementation EBCaptionLoadOperation

-(void)loadData
{
    NSInteger photoIndex = self.photoViewController.photoIndex;
    
    NSAttributedString *attributedCaption = nil;
    NSString *caption = nil;
    
    //Attributed Captions first (takes priority over regular captions)
    if([self.dataSource respondsToSelector:
        @selector(photoPagesController:attributedCaptionForPhotoAtIndex:completionHandler:)]){
        [self.dataSource photoPagesController:self.photoPagesController
             attributedCaptionForPhotoAtIndex:self.photoViewController.photoIndex
                            completionHandler:^(NSAttributedString *attributedCaption){
                                
                [self.photoViewController performSelectorOnMainThread:@selector(setAttributedCaption:)
                                                           withObject:attributedCaption
                                                        waitUntilDone:NO];
        }];
        
    } else if([self.dataSource respondsToSelector:
        @selector(photoPagesController:attributedCaptionForPhotoAtIndex:)]){
        
        attributedCaption = [self.dataSource photoPagesController:self.photoPagesController
                                 attributedCaptionForPhotoAtIndex:photoIndex];
        
        if(attributedCaption){
            [self.photoViewController performSelectorOnMainThread:@selector(setAttributedCaption:)
                                                       withObject:attributedCaption
                                                    waitUntilDone:NO];
            return;
        }
    }
    
    //Regular captions second.
    if([self.dataSource respondsToSelector:
        @selector(photoPagesController:captionForPhotoAtIndex:completionHandler:)]){
        [self.dataSource photoPagesController:self.photoPagesController
                       captionForPhotoAtIndex:self.photoViewController.photoIndex
                            completionHandler:^(NSString *caption){
                                
                                [self.photoViewController performSelectorOnMainThread:@selector(setCaption:)
                                                                           withObject:caption
                                                                        waitUntilDone:NO];
                            }];
        
        
    } else if([self.dataSource respondsToSelector:
        @selector(photoPagesController:captionForPhotoAtIndex:)]){
        
        caption = [self.dataSource photoPagesController:self.photoPagesController
                                 captionForPhotoAtIndex:photoIndex];
        
        if(caption){
            [self.photoViewController performSelectorOnMainThread:@selector(setCaption:)
                                                       withObject:caption
                                                    waitUntilDone:NO];
            return;
        }
    }
}

@end


#pragma mark - Meta Data Loading

@implementation EBMetaDataLoadOperation

- (void)loadData
{
    if([self.dataSource respondsToSelector:
        @selector(photoPagesController:metaDataForPhotoAtIndex:)]){
        
        [self performSelectorOnMainThread:@selector(loadMetaDataOnMainThread)
                               withObject:nil
                            waitUntilDone:NO];
        
    } else if ([self.dataSource respondsToSelector:
                @selector(photoPagesController:metaDataForPhotoAtIndex:completionHandler:)]){
        
        [self.dataSource photoPagesController:self.photoPagesController
                      metaDataForPhotoAtIndex:self.photoViewController.photoIndex
                               completionHandler:^(NSDictionary *metaData){
                                   
                [self.photoViewController performSelectorOnMainThread:@selector(setMetaData:)
                                                           withObject:metaData
                                                        waitUntilDone:NO];
        }];
    }
}

- (void)loadMetaDataOnMainThread
{
    NSInteger photoIndex = self.photoViewController.photoIndex;
    NSDictionary *metaData = [self.dataSource photoPagesController:self.photoPagesController
                                           metaDataForPhotoAtIndex:photoIndex];
    [self.photoViewController performSelectorOnMainThread:@selector(setMetaData:)
                                               withObject:metaData
                                            waitUntilDone:NO];
}


@end

#pragma mark - Tags Loading

@implementation EBTagsLoadOperation

- (void)loadData
{
    if([self.dataSource respondsToSelector:@selector(photoPagesController:tagsForPhotoAtIndex:)]){

        [self performSelectorOnMainThread:@selector(loadTagsOnMainThread)
                               withObject:nil
                            waitUntilDone:NO];
        
    } else if ([self.dataSource respondsToSelector:
                @selector(photoPagesController:tagsForPhotoAtIndex:completionHandler:)]){
        
        [self.dataSource photoPagesController:self.photoPagesController
                          tagsForPhotoAtIndex:self.photoViewController.photoIndex
                            completionHandler:^(NSArray *tags){
            
            [self.photoViewController performSelectorOnMainThread:@selector(setTags:)
                                                       withObject:tags
                                                    waitUntilDone:NO];
        }];
    }
}

- (void)loadTagsOnMainThread
{
    NSArray *tags = [self.dataSource photoPagesController:self.photoPagesController
                                      tagsForPhotoAtIndex:self.photoViewController.photoIndex];
    [self.photoViewController setTags:tags];
}


@end


#pragma mark - Comments Loading

@implementation EBCommentsLoadOperation

- (void)loadData
{
    if([self.dataSource respondsToSelector:@selector(photoPagesController:commentsForPhotoAtIndex:)]){
        
        [self performSelectorOnMainThread:@selector(loadCommentsOnMainThread)
                               withObject:nil
                            waitUntilDone:NO];
        
    } else if ([self.dataSource respondsToSelector:
                @selector(photoPagesController:commentsForPhotoAtIndex:completionHandler:)]){
        
        [self.dataSource photoPagesController:self.photoPagesController
                      commentsForPhotoAtIndex:self.photoViewController.photoIndex
                            completionHandler:^(NSArray *comments){
            
            [self.photoViewController performSelectorOnMainThread:@selector(loadComments:)
                                                       withObject:comments
                                                    waitUntilDone:NO];
        }];
        
    }
    

}

- (void)loadCommentsOnMainThread
{
    NSArray *comments = [self.dataSource photoPagesController:self.photoPagesController
                                      commentsForPhotoAtIndex:self.photoViewController.photoIndex];
    [self.photoViewController loadComments:comments];
}

@end
