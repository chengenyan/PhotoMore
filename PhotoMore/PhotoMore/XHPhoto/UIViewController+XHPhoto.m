//
//  UIViewController+XHPhoto.m

//  Copyright (c) 2016 XHPhoto (https://github.com/CoderZhuXH/XHPhoto)

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN

#import "UIViewController+XHPhoto.h"
#import "objc/runtime.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "WPhotoViewController.h"

#ifdef DEBUG
#define debugLog(...)    NSLog(__VA_ARGS__)
#else
#define debugLog(...)
#endif

static  BOOL canEdit = NO;

static  char blockKey;
static  char cheshangphotoKey;
static  char moreblockKey;
static  char maxstr;
@interface UIViewController()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,LGPhotoPickerViewControllerDelegate>

@property (nonatomic,copy)photoBlock photoBlock;
@property (nonatomic,copy)morephotoBlock morephotoBlock;
@property (nonatomic,copy)photoBlock cheshangphotoBlock;



@end

@implementation UIViewController (XHPhoto)

#pragma mark-set
-(void)setPhotoBlock:(photoBlock)photoBlock
{
    objc_setAssociatedObject(self, &blockKey, photoBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setCheshangphotoBlock:(photoBlock)cheshangphotoBlock{
      objc_setAssociatedObject(self, &cheshangphotoKey, cheshangphotoBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)setMorephotoBlock:(morephotoBlock)morephotoBlock
{
    objc_setAssociatedObject(self, &moreblockKey, morephotoBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setMaxnumerstr:(NSString *)maxnumerstr{
     objc_setAssociatedObject(self, &maxstr, maxnumerstr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark-get
- (photoBlock )photoBlock
{
    return objc_getAssociatedObject(self, &blockKey);
}
- (photoBlock )cheshangphotoBlock
{
    return objc_getAssociatedObject(self, &cheshangphotoKey);
}
-(NSString *)maxnumerstr{
     return objc_getAssociatedObject(self, &maxstr);
}

-(morephotoBlock)morephotoBlock
{
    return objc_getAssociatedObject(self, &moreblockKey);
}
-(void)showCanEdit:(BOOL)edit photo:(photoBlock)block chehangphoto:(photoBlock)cheshangblock{
    if(edit) canEdit = edit;
    self.photoBlock = block;
    self.cheshangphotoBlock=cheshangblock;
    UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"更换车行照片", @"更换头像", nil];
    sheet.tag = 8999;
    [sheet showInView:self.view];
    return;
}
-(void)showCanEdit:(BOOL)edit photo:(photoBlock)block
{
    if(edit) canEdit = edit;
    self.photoBlock = block;
    UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册中获取", nil];
    sheet.tag = 2599;
    [sheet showInView:self.view];
}
-(void)showCanEdit:(BOOL)edit photo:(photoBlock)block andmorephoto:(morephotoBlock)moreblock
{
    if(edit) canEdit = edit;
    self.morephotoBlock=moreblock;
    self.photoBlock = block;
    UIActionSheet *sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册中获取", nil];
    sheet.tag = 2699;
    [sheet showInView:self.view];
}
#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0 && actionSheet.tag==8999){
        //车行图片
        [self showCanEdit:YES photo:self.cheshangphotoBlock];
        return;
    }else if (buttonIndex==1 && actionSheet.tag==8999){
        //头像
        [self showCanEdit:YES photo:self.photoBlock];
        return;
    }
    if (actionSheet.tag==2599 ||actionSheet.tag==2699)
    {
        //权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied) {
            CGFloat kSystemMainVersion = [UIDevice currentDevice].systemVersion.floatValue;
            NSString *title = nil;
            NSString *photoType = buttonIndex==0?@"相机":@"相册";
            NSString *msg = [NSString stringWithFormat:@"还没有开启%@权限,请在系统设置中开启",photoType];
            NSString *cancelTitle = @"暂不";
            NSString *otherButtonTitles = @"去设置";
            
            if (kSystemMainVersion < 8.0) {
                title = [NSString stringWithFormat:@"%@权限未开启",photoType];
                msg = [NSString stringWithFormat:@"请在系统设置中开启%@服务\n(设置>隐私>%@>开启)",photoType,photoType];
                cancelTitle = @"知道了";
                otherButtonTitles = nil;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:otherButtonTitles, nil];
            alertView.tag = 2598;
            [alertView show];
            return;
        }
        //跳转到相机/相册页面
        if(buttonIndex==0){
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = canEdit;
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerController animated:YES completion:NULL];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该设备不支持相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }else if(buttonIndex==1&&actionSheet.tag==2599){
            UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = canEdit;
            //相册
            imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
            //    去除毛玻璃效果
            imagePickerController.navigationBar.translucent = NO;
            [self presentViewController:imagePickerController animated:YES completion:NULL];
            
        }else if(buttonIndex==1&&actionSheet.tag==2699){
//            WPhotoViewController *WphotoVC = [[WPhotoViewController alloc] init];
//            //选择图片的最大数
//            WphotoVC.selectPhotoOfMax = self.maxnumerstr.intValue;
//            DefineWeakSelf;
//            [WphotoVC setSelectPhotosBack:^(NSMutableArray *phostsArr) {
//                if(weakself.morephotoBlock)
//                {
//                    self.morephotoBlock(phostsArr);//被选中
//                }
//            }];
//            [self presentViewController:WphotoVC animated:YES completion:nil];
            
            LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:LGShowImageTypeImagePicker];
            pickerVc.status = PickerViewShowStatusCameraRoll;
            pickerVc.maxCount = self.maxnumerstr.intValue;   // 最多能选9张图片
            pickerVc.delegate = self;
            //    pickerVc.nightMode = YES;//夜间模式
//            self.showType = LGShowImageTypeImagePicker;
             [self presentViewController:pickerVc animated:YES completion:nil];
        }
    }
}
#pragma mark - LGPhotoPickerViewControllerDelegate

- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original{
     //assets的元素是LGPhotoAssets对象，获取image方法如下:
     NSMutableArray *thumbImageArray = [NSMutableArray array];
     NSMutableArray *originImage = [NSMutableArray array];
//     NSMutableArray *fullResolutionImage = [NSMutableArray array];
     for (LGPhotoAssets *photo in assets) {
     //缩略图
     [thumbImageArray addObject:photo.thumbImage];
     //原图
     [originImage addObject:photo.originImage];
     //全屏图
//     [fullResolutionImage addObject:fullResolutionImage];
     }
    if(self.morephotoBlock)
    {
       self.morephotoBlock(originImage);//被选中
    }
    NSInteger num = (long)assets.count;
    NSLog(@"%ld",(long)num);
   
}

#pragma mark - <UIAlertDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==2598)
    {
        if (buttonIndex == 1) {
            CGFloat kSystemMainVersion = [UIDevice currentDevice].systemVersion.floatValue;
            if (kSystemMainVersion >= 8.0) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
                debugLog(@"1.iOS8以后支持跳转到设置,设置完成后,系统会自启应用,刷新应用权限\n 2.由于系统自启应用,连接Xcode调试会crash,断开与Xcode连接,进行操作即可");
            }
        }
    }
}
#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image;
    //是否要裁剪
    if ([picker allowsEditing]){
        //编辑之后的图像
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else {

        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if(self.photoBlock)
    {
        self.photoBlock(image);
    }
}

/*
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
       
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}
*/
@end
