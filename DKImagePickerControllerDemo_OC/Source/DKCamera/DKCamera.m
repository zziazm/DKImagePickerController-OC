//
//  DKCamera.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/7/4.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKCamera.h"

@implementation NSBundle(DKCameraExtension)

+ (NSBundle *)cameraBundle{
    NSString * assetPath = [NSBundle bundleForClass:[DKCameraResource class]].resourcePath;
    
    return [NSBundle bundleWithPath:[assetPath stringByAppendingPathComponent:@"DKCameraResource.bundle"]];
}

@end

@implementation DKCameraResource

+ (UIImage *)imageForResource:(NSString *)name{
    NSBundle * bundle = [NSBundle cameraBundle];
    NSString * imagePath = [bundle pathForResource:name ofType:@"png" inDirectory:@"Images"];
    
    UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
    return  image;
}

+ (UIImage *)cameraCancelImage{
    return [self imageForResource:@"camera_cancel"];
}

+ (UIImage *)cameraFlashOnImage{
    return [self imageForResource:@"camera_flash_on"];
}

+ (UIImage *)cameraFlashAutoImage{
    return [self imageForResource:@"camera_flash_auto"];
}

+ (UIImage *)cameraFlashOffImage{
    return [self imageForResource:@"camera_flash_off"];
}

+ (UIImage *)cameraSwitchImage{
    return [self imageForResource:@"camera_switch"];
}

@end


@interface DKCamera ()
@property (nonatomic, assign) CGFloat beginZoomScale;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) BOOL isStopped;

#warning weak
@property (nonatomic, weak) AVCaptureStillImageOutput * stillImageOutput;
@end

@implementation DKCamera

+ (void)checkCameraPermission:(void(^)(BOOL granted))handler{
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
        handler(YES);
    }else if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(granted);
            });
        }];
    }else{
        handler(NO);
    }
}
+ (BOOL)isAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
- (instancetype)init{
    if (self = [super init]) {
        _allowsRotate = NO;
        _showsCameraControls = YES;
        _contentView = [UIView new];
        _captureSession = [AVCaptureSession new];
        _beginZoomScale = 1.0;
        _zoomScale = 1.0;
        _defaultCaptureDevice = DKCameraDeviceSourceRearType;
        _motionManager = [CMMotionManager new];
        _isStopped = NO;
    }
    return self;
}
- (void)setShowsCameraControls:(BOOL)showsCameraControls{
    if (_showsCameraControls != showsCameraControls) {
        _showsCameraControls = showsCameraControls;
        self.contentView.hidden = !showsCameraControls;
    }
}
- (void)setCameraOverlayView:(UIView *)cameraOverlayView{
    if (_cameraOverlayView != cameraOverlayView) {
        _cameraOverlayView = cameraOverlayView;
        [self.view addSubview:_cameraOverlayView];
    }
    
    
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    _flashMode = flashMode;
    [self updateFlashButton];
    [self updateFlashMode];
    [self updateFlashModeToUserDefautls:self.flashMode];
    
    
}
- (void)updateFlashModeToUserDefautls:(AVCaptureFlashMode)flashMode{
    [[NSUserDefaults standardUserDefaults] setObject:@(flashMode) forKey:@"DKCamera.flashMode"];
}
- (void)updateFlashMode{
    if (self.currentDevice && self.currentDevice.isFlashAvailable && [self.currentDevice isFlashModeSupported:self.flashMode]) {
        [self.currentDevice lockForConfiguration:nil];
        self.currentDevice.flashMode = self.flashMode;
        [_currentDevice unlockForConfiguration];
    }
}

- (void)updateFlashButton{
    UIImage * flashImage = [self flashImage:self.flashMode];
    [self.flashButton setImage:flashImage forState:UIControlStateNormal];
    [self.flashButton sizeToFit];
    
}


- (UIImage *)flashImage:(AVCaptureFlashMode)flashModel{
    UIImage * image;
    switch (flashModel) {
        case AVCaptureFlashModeAuto:
            image = [DKCameraResource cameraFlashAutoImage];
            break;
        case AVCaptureFlashModeOn:
            image = [DKCameraResource cameraFlashOnImage];
            break;
        case AVCaptureFlashModeOff:
            image = [DKCameraResource cameraFlashOffImage];
        default:
            break;
    }
    return image;
}
- (UIButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [UIButton new];
        [_flashButton addTarget:self action:@selector(switchFlashMode) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _flashButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDevices];
    // Do any additional setup after loading the view.
}

- (void)setupDevices{
    NSArray<AVCaptureDevice *> * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.captureDeviceRear = device;
        }
        if (device.position == AVCaptureDevicePositionFront) {
            self.captureDeviceFront = device;
        }
    }
    
    switch (self.defaultCaptureDevice) {
        case DKCameraDeviceSourceFrontType:
            self.currentDevice = self.captureDeviceFront?:self.captureDeviceRear;
            break;
        case DKCameraDeviceSourceRearType:
            self.currentDevice = self.captureDeviceRear?:self.captureDeviceFront;
        default:
            break;
    }
}

- (void)startSession{
    self.isStopped = NO;
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stopSession{
    [self pauseSession];
    [self.captureSession stopRunning];
}
- (void)pauseSession{
    self.isStopped = YES;
    [self updateSession:NO];
}

- (void)updateSession:(BOOL)isEnable{
    if (!self.isStopped || (self.isStopped && isEnable)) {
        self.previewLayer.connection.enabled = isEnable;
    }
}

- (void)dismiss{
    if (self.didCancel) {
        self.didCancel();
    }
}


- (void)takePicture{
   AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied) {
        return;
    }
    
    if (self.stillImageOutput && !self.stillImageOutput.isCapturingStillImage) {
        self.captureButton.enabled = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
           AVCaptureConnection * connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if (connection) {
                connection.videoOrientation = [DKCamera toAVCaptureVideoOrientation:self.currentOrientation];
                connection.videoScaleAndCropFactor = self.zoomScale;
                [_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                    if (!error) {
                      NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        
                        UIImage * takenImage = [UIImage imageWithData:imageData];
                        if (self.didFinishCapturingImage && imageData && takenImage) {
                            CGRect outputRect = [self.previewLayer metadataOutputRectOfInterestForRect:self.previewLayer.bounds];
                            
                            CGImageRef takenCGImage = takenImage.CGImage;
                            CGFloat width = CGImageGetWidth(takenCGImage);
                            CGFloat height = CGImageGetHeight(takenCGImage);
                            
                            CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);
                            
                            CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
                            
                            UIImage * cropTakenImage = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:takenImage.imageOrientation];
                            self.captureButton.enabled = YES;
                            
                            
                        }
                    }else{
                        NSLog(@"error while capturing still image %@", error.localizedDescription);
                    }
                    
                    
                }];
            }
        });
    }
}

- (void)handleZoom:(UIPinchGestureRecognizer *)gesture{
    
}


+ (AVCaptureVideoOrientation)toAVCaptureVideoOrientation:(UIDeviceOrientation)orientation{
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
            
        default:
            return AVCaptureVideoOrientationPortrait;
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
