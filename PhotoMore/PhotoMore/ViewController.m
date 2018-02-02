//
//  ViewController.m
//  PhotoMore
//
//  Created by 塞班客 on 2018/2/2.
//  Copyright © 2018年 cey. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+XHPhoto.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *btn;
@property (weak, nonatomic) IBOutlet UIImageView *imagview;
@property (weak, nonatomic) IBOutlet UIImageView *imageview1;
@end

@implementation ViewController
//
- (IBAction)btnClick:(id)sender {
    [self showCanEdit:YES photo:^(UIImage *photo) {
        self.imagview.image=photo;
    }];
}
//从相册多张照片选择
- (IBAction)moreBtnClick:(id)sender {
    self.maxnumerstr=@"9";//最多9张
    [self showCanEdit:YES photo:^(UIImage *photo) {
         self.imagview.image=photo;
    } andmorephoto:^(NSArray *photo) {
        if (photo.count>1) {
             self.imagview.image=(UIImage *)photo[0];
        }
        if (photo.count>1) {
            self.imageview1.image=(UIImage *)photo[1];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
