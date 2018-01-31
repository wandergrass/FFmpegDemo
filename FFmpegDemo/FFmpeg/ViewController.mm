//
//  ViewController.m
//  FFmpeg
//
//  Created by guojianfeng on 2017/12/19.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "ViewController.h"
#import "SJMoiveObject.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (nonatomic, strong) SJMoiveObject *video;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *url = @"vvdf";
    if (![url hasPrefix:@"rtsp://"]) {
        return;
    }
   self.video = [[SJMoiveObject alloc] initWithVideo:@"rtsp://wr"];
    if (self.video) {
        
        [NSTimer scheduledTimerWithTimeInterval: 1 / self.video.fps
                                         target:self
                                       selector:@selector(displayNextFrame:)
                                       userInfo:nil
                                        repeats:YES];
    }
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)displayNextFrame:(NSTimer *)timer{
    self.playImageView.image = self.video.currentImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
