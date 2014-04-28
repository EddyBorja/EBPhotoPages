//
//  EBViewController.m
//  EBPhotoPageViewControllerDemo
//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "DEMOViewController.h"
#import "DEMOComment.h"
#import "DEMOPhoto.h"
#import "DEMOTag.h"
#import <QuartzCore/QuartzCore.h>
#import "EBPhotoPagesController.h"
#import "EBPhotoPagesFactory.h"
#import "EBTagPopover.h"


@interface DEMOViewController ()

@end

@implementation DEMOViewController

- (void)loadView
{
    [super loadView];
    
    [self setSimulateLatency:NO];
   
    
    NSArray *photo1Comments = @[
                                [DEMOComment commentWithProperties:@{@"commentText": @"This is a comment!",
                                 @"commentDate": [NSDate dateWithTimeInterval:-252750 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"aaronalfred.jpg"],
                                 @"authorName" : @"Aaron Alfred"}]
                                ];
    
    NSArray *photo5Comments = @[
                                [DEMOComment commentWithProperties:@{@"commentText": @"Looks fun, and greasy!",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-232500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"vladarbatov.jpg"],
                                                                     @"authorName" : @"VLADARBATOV"}]
                                ];
    
    NSArray *photo1Tags = @[
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.565, 0.74)],
                                                         @"tagText" : @"Eddy Borja"}],
                            ];
    
    NSArray *photo13Tags = @[
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6874, 0.74)],
                                                         @"tagText" : @"Eddy Borja (爱迪)"}],
                            ];
    
    NSArray *photo0Tags = @[
                             [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6874, 0.53)],
                                                          @"tagText" : @"Karla"}],
                             ];


    
    NSArray *photo2Comments = @[
                                [DEMOComment commentWithProperties:@{@"commentText": @"What is this?",
                                 @"commentDate": [NSDate dateWithTimeInterval:-2341500 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"iqonicd.jpg"],
                                 @"authorName" : @"IqonICD"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"It's a Lego minifig.",
                                 @"commentDate": [NSDate dateWithTimeInterval:-2262500 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"billskenney.jpg"],
                                 @"authorName" : @"Bill S. Kenney"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Pretty cool.",
                                 @"commentDate": [NSDate dateWithTimeInterval:-212500 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"liang.jpg"],
                                 @"authorName" : @"liang"}],
                                ];
    
    NSArray *photo2Tags = @[
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.11, 0.6)],
                             @"tagText" : @"Sword"}],
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.60, 0.37)],
                             @"tagText" : @"minifig"}],
                            ];
    
    NSArray *photo8Tags = @[
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.5, 0.65)],
                                                         @"tagText" : @"guts!"}],
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.6, 0.3)],
                                                         @"tagText" : @"ZOmBiE!!"}],
                            ];
    
    NSArray *photo8Comments = @[
                                [DEMOComment commentWithProperties:@{@"commentText": @"GDC?",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-2741500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"kaelifa.jpg"],
                                                                     @"authorName" : @"Kaelifa"}],
                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Yup.",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-2499500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"eddyborja.jpg"],
                                                                     @"authorName" : @"Eddy Borja"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"I want a 3D Printer...",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-2299500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"tjrus.jpg"],
                                                                     @"authorName" : @"TJRus"}],
                                ];
    
    NSArray *photo3Comments = @[
                                [DEMOComment commentWithProperties:@{@"commentText": @"Super hot peppers.",
                                 @"commentDate": [NSDate dateWithTimeInterval:-2991500 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"g3d.jpg"],
                                 @"authorName" : @"g3d"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Wow, that's a lot of peppers.",
                                 @"commentDate": [NSDate dateWithTimeInterval:-2881500 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"amandabuzard.jpg"],
                                 @"authorName" : @"AmandaBuzard"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"I don't know what this means....",
                                 @"commentDate": [NSDate dateWithTimeInterval:-27700 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"ateneupopular.jpg"],
                                 @"authorName" : @"ateneupopular"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"How much did these cost?",
                                 @"commentDate": [NSDate dateWithTimeInterval:-26000 sinceDate:[NSDate date]],
                                 @"authorImage": [UIImage imageNamed:@"theaccordance.jpg"],
                                 @"authorName" : @"The Accordance"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Pretty cheap, got the seeds from Australia.",
                                    @"commentDate": [NSDate dateWithTimeInterval:-21500 sinceDate:[NSDate date]],
                                    @"authorImage": [UIImage imageNamed:@"eddyborja.jpg"],
                                    @"authorName" : @"Eddy Borja"}],
                                ];
    
    NSArray *photo3Tags = @[
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.42, 0.12)],
                             @"tagText" : @"Damn"}],
                            ];
    
    NSArray *photo11Tags = @[
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.5, 0.55)],
                                                         @"tagText" : @"Team GoThriftGo"}],
                            ];
    
    NSArray *photo11Comments = @[
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Congrats!",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-2446500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"adellecharles.jpg"],
                                                                     @"authorName" : @"Adelle Charles"}],
                                [DEMOComment commentWithProperties:@{@"commentText": @"follow up Series A round $2.2 million USD!",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-2346500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"billskenney.jpg"],
                                                                     @"authorName" : @"Bill S. Kenney"}],
                                
                                ];
    
    NSArray *photo13Comments = @[
                                 
                                 [DEMOComment commentWithProperties:@{@"commentText": @"走在街上",
                                                                      @"commentDate": [NSDate dateWithTimeInterval:-4446500 sinceDate:[NSDate date]],
                                                                      @"authorImage": [UIImage imageNamed:@"eddyborja.jpg"],
                                                                      @"authorName" : @"Eddy Borja"}],
                                 
                                 ];
    
    NSArray *photo0Comments = @[
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Great photo!",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-241500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"megdraws.jpg"],
                                                                     @"authorName" : @"Meg Draws"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Pretty.",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-21800 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"iqonicd.jpg"],
                                                                     @"authorName" : @"IqonICD"}],
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"Wow!",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-2600 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"karsh.jpg"],
                                                                     @"authorName" : @"karsh"}],
                                ];
    
    NSArray *photo6Tags = @[
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                             @"tagText" : @"0,0"}],
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)],
                             @"tagText" : @"Center"}],
                            [DEMOTag tagWithProperties:@{@"tagPosition" : [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                             @"tagText" : @"1,1"}],
                            ];
    
    NSArray *photo6Comments = @[
                                
                                [DEMOComment commentWithProperties:@{@"commentText": @"That's a cool feature, it's always annoying when small images get blown up and pixelated.",
                                                                     @"commentDate": [NSDate dateWithTimeInterval:-2221500 sinceDate:[NSDate date]],
                                                                     @"authorImage": [UIImage imageNamed:@"kerem.jpg"],
                                                                     @"authorName" : @"Kerem"}],
                                ];
    
    
    [self setPhotos:@[
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo1.jpg",
      @"attributedCaption" : [[NSAttributedString alloc] initWithString:@"The author of EBPhotoPages."],
        @"tags": photo1Tags,
        @"comments" : photo1Comments,
      }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo2.jpg",
        @"caption": @"A Dungeon crawler!",
        @"tags" : photo2Tags,
        @"comments" : photo2Comments
      }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo6.png",
        @"caption": @"This photo demonstrates how the EBPhotoPagesController can prevent an image from being stretched if it's smaller than the bounds of the scrollview. The content mode switches from AspectFit to Center.",
        @"tags" : photo6Tags,
        @"comments" : photo6Comments,
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo3.jpg",
        @"caption": @"Ghost Peppers",
        @"tags" : photo3Tags,
        @"comments" : photo3Comments,
      }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo4.jpg",
        @"caption": @"San Francisco, a land where code is king.",
      }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo5.jpg",
        @"caption" : @"A new Instagram comic series drawn by Eddy with only markers and crackers.",
        @"comments" : photo5Comments,
      }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo7.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo8.jpg",
        @"caption": @"This is a 3D printed zombie!",
        @"tags" : photo8Tags,
        @"comments" : photo8Comments,
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo9.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo10.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo11.jpg",
        @"caption": @"Startup Weekend Trophy - 1st place",
        @"tags" : photo11Tags,
        @"comments" : photo11Comments,
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo12.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo17.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo13.jpg",
        @"caption": @"IBM China",
        @"tags" : photo13Tags,
        @"comments" : photo13Comments,
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo14.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo15.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo16.jpg"
        }],
     
     [DEMOPhoto photoWithProperties:
      @{@"imageFile": @"photo0.jpg",
        @"comments" : photo0Comments,
        @"caption"  : @"#selfie",
        @"tags" : photo0Tags,
        }],
     
     ]];
    
    DEMOPhoto *photo;
    
    photo = self.photos[0];
    //[photo setDisabledDelete:YES];
    
    photo = self.photos[12];
    [photo setDisabledActivities:YES];
    [photo setDisabledCommenting:YES];
    [photo setDisabledMiscActions:YES];

    
    photo = self.photos[3];
    [photo setDisabledCommenting:YES];
    
    photo = self.photos[4];
    [photo setDisabledActivities:YES];
    
    photo = self.photos[5];
    [photo setDisabledTagging:YES];
    [photo setDisabledDeleteForTags:YES];
    [photo setDisabledActivities:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setAlpha:0];
    [UIView animateWithDuration:0.2
                          delay:0.25
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view setAlpha:1.0];
                     }completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didSelectViewPhotos:(id)sender
{    
    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self];
    [self presentViewController:photoPagesController animated:YES completion:nil];
}


- (IBAction)didToggleLatency:(id)sender
{
    UISwitch *toggle = sender;
    
    [self setSimulateLatency:toggle.on];
}


#pragma mark - EBPhotoPagesDataSource

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if(index < self.photos.count){
        return YES;
    }
    
    return NO;
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
                imageAtIndex:(NSInteger)index
           completionHandler:(void (^)(UIImage *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
        if(self.simulateLatency){
            sleep(arc4random_uniform(2)+arc4random_uniform(2));
        }
        
        handler(photo.image);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
            attributedCaptionForPhotoAtIndex:(NSInteger)index
                           completionHandler:(void (^)(NSAttributedString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
        if(self.simulateLatency){
            sleep(arc4random_uniform(2)+arc4random_uniform(2));
        }
        
        handler(photo.attributedCaption);
    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
            captionForPhotoAtIndex:(NSInteger)index
                 completionHandler:(void (^)(NSString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
        if(self.simulateLatency){
            sleep(arc4random_uniform(2)+arc4random_uniform(2));
        }
        
        handler(photo.caption);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     metaDataForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSDictionary *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
        if(self.simulateLatency){
            sleep(arc4random_uniform(2)+arc4random_uniform(2));
        }
        
        handler(photo.metaData);
    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
         tagsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
        if(self.simulateLatency){
            sleep(arc4random_uniform(2)+arc4random_uniform(2));
        }
        
        handler(photo.tags);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
     commentsForPhotoAtIndex:(NSInteger)index
           completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        DEMOPhoto *photo = self.photos[index];
        if(self.simulateLatency){
            sleep(arc4random_uniform(2)+arc4random_uniform(2));
        }
        
        handler(photo.comments);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
  numberOfcommentsForPhotoAtIndex:(NSInteger)index
                completionHandler:(void (^)(NSInteger))handler
{
    DEMOPhoto *photo = self.photos[index];
    if(self.simulateLatency){
        sleep(arc4random_uniform(2)+arc4random_uniform(2));
    }
    
    handler(photo.comments.count);
}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
    //Do something about this image someone reported.
}



- (void)photoPagesController:(EBPhotoPagesController *)controller
            didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment
             forPhotoAtIndex:(NSInteger)index
{
    DEMOPhoto *photo = self.photos[index];
    NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:photo.comments];
    [remainingComments removeObject:deletedComment];
    [photo setComments:[NSArray arrayWithArray:remainingComments]];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
         didDeleteTagPopover:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    DEMOPhoto *photo = self.photos[index];
    NSMutableArray *remainingTags = [NSMutableArray arrayWithArray:photo.tags];
    id<EBPhotoTagProtocol> tagData = [tagPopover dataSource];
    [remainingTags removeObject:tagData];
    [photo setTags:[NSArray arrayWithArray:remainingTags]];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index
{
    NSLog(@"Delete photo at index %li", (long)index);
    DEMOPhoto *deletedPhoto = self.photos[index];
    NSMutableArray *remainingPhotos = [NSMutableArray arrayWithArray:self.photos];
    [remainingPhotos removeObject:deletedPhoto];
    [self setPhotos:remainingPhotos];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo
{
    NSLog(@"add new tag %@", tagText);
    
    DEMOPhoto *photo = self.photos[index];
    
    DEMOTag *newTag = [DEMOTag tagWithProperties:@{
                                                   @"tagPosition" : [NSValue valueWithCGPoint:tagLocation],
                                                   @"tagText" : tagText}];
    
    NSMutableArray *mutableTags = [NSMutableArray arrayWithArray:photo.tags];
    [mutableTags addObject:newTag];
    
    [photo setTags:[NSArray arrayWithArray:mutableTags]];
    
}


- (void)photoPagesController:(EBPhotoPagesController *)controller
              didPostComment:(NSString *)comment
             forPhotoAtIndex:(NSInteger)index
{
    DEMOComment *newComment = [DEMOComment
                               commentWithProperties:@{@"commentText": comment,
                                                       @"commentDate": [NSDate date],
                                                       @"authorImage": [UIImage imageNamed:@"guestAv.png"],
                                                       @"authorName" : @"Guest User"}];
    [newComment setUserCreated:YES];
    
    DEMOPhoto *photo = self.photos[index];
    [photo addComment:newComment];
    
    [controller setComments:photo.comments forPhotoAtIndex:index];
}



#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledTagging){
        return NO;
    }
    
    return YES;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)controller
            shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment
             forPhotoAtIndex:(NSInteger)index
{
    //We assume all comment objects used in the demo are of type DEMOComment
    DEMOComment *demoComment = (DEMOComment *)comment;
    
    if(demoComment.isUserCreated){
        //Demo user can only delete his or her own comments.
        return YES;
    }
    
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowCommentingForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledCommenting){
        return NO;
    } else {
        return YES;
    }
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledActivities){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowMiscActionsForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledMiscActions){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledDelete){
        return NO;
    } else {
        return YES;
    }
}





- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
     shouldAllowDeleteForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    DEMOPhoto *photo = (DEMOPhoto *)self.photos[index];
    if(photo.disabledDeleteForTags){
        return NO;
    }
    
    return YES;
}




- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldAllowEditingForTag:(EBTagPopover *)tagPopover
              inPhotoAtIndex:(NSInteger)index
{
    if(!self.photos.count){
        return NO;
    }
    
    if(index > 0){
        return YES;
    }
    
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowReportForPhotoAtIndex:(NSInteger)index
{
    return YES;
}


#pragma mark - EBPPhotoPagesDelegate


- (void)photoPagesControllerDidDismiss:(EBPhotoPagesController *)photoPagesController
{
    NSLog(@"Finished using %@", photoPagesController);
}



@end
