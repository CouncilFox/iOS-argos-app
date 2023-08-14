//
//  FirmwareDownloadDialogView.m
//  PlutoController
//
//  Created by Drona Aviation on 06/02/19.
//  Copyright © 2019 Drona Aviation. All rights reserved.
//

#import "FirmwareFlasher.h"
#import "FirmwareDownloadDialogView.h"

@interface FirmwareDownloadDialogView()

@property (strong, nonatomic) IBOutlet UIView *firmwareDownloadDialogView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControlMagis;
@property (strong, nonatomic) IBOutlet UIButton *btnDownload;

@end

@implementation FirmwareDownloadDialogView

FirmwareFlasher *firmwareFlasher;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

-(void) customInit
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.1];
    visualEffectView.frame = self.bounds;
    [self addSubview:visualEffectView];
    
    [[NSBundle mainBundle] loadNibNamed:@"FirmwareDownloadDialog" owner:self options:nil];
    
    [self addSubview:self.firmwareDownloadDialogView];
    
    self.firmwareDownloadDialogView.frame = CGRectMake(0, 0, self.frame.size.width * 0.73f, self.frame.size.height * 0.65f);
    self.firmwareDownloadDialogView.center = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.45f);
    
    self.firmwareDownloadDialogView.layer.cornerRadius = 7;
    self.firmwareDownloadDialogView.layer.masksToBounds = true;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [self.segmentControlMagis setTitleTextAttributes:attributes
                                            forState:UIControlStateNormal];
    [self.segmentControlMagis setTitleTextAttributes:attributes
                                            forState:UIControlStateSelected];
    
    CGRect outline = CGRectMake(self.segmentControlMagis.bounds.origin.x, self.segmentControlMagis.bounds.origin.y, self.segmentControlMagis.bounds.size.width * 0.5f, self.segmentControlMagis.bounds.size.height);
    
    CAShapeLayer *maskLayerWhiteRightDvc = [CAShapeLayer layer];
    maskLayerWhiteRightDvc.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight  cornerRadii: CGSizeMake(5, 5)].CGPath;
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *borderLayerWhiteRightDvc = [CAShapeLayer layer];
    borderLayerWhiteRightDvc.frame       = self.segmentControlMagis.subviews[0].bounds;
    borderLayerWhiteRightDvc.path        = borderPath.CGPath;
    borderLayerWhiteRightDvc.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteRightDvc.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteRightDvc.lineWidth   = 1.0f;
    
    CAShapeLayer *maskLayerWhiteLeftDvc = [CAShapeLayer layer];
    maskLayerWhiteLeftDvc.path = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: CGSizeMake(5, 5)].CGPath;
    UIBezierPath *borderPath1 = [UIBezierPath bezierPathWithRoundedRect: outline byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *borderLayerWhiteLeftDvc = [CAShapeLayer layer];
    borderLayerWhiteLeftDvc.frame       = self.segmentControlMagis.subviews[0].bounds;
    borderLayerWhiteLeftDvc.path        = borderPath1.CGPath;
    borderLayerWhiteLeftDvc.strokeColor = [UIColor whiteColor].CGColor;
    borderLayerWhiteLeftDvc.fillColor   = [UIColor clearColor].CGColor;
    borderLayerWhiteLeftDvc.lineWidth   = 1.0f;
    
    self.segmentControlMagis.subviews[1].layer.mask = maskLayerWhiteRightDvc;
    [[self.segmentControlMagis.subviews[1] layer] addSublayer:borderLayerWhiteRightDvc];
    self.segmentControlMagis.subviews[0].layer.mask = maskLayerWhiteLeftDvc;
    [[self.segmentControlMagis.subviews[0] layer] addSublayer:borderLayerWhiteLeftDvc];
    
    _btnDownload.layer.cornerRadius = 18;
    _btnDownload.clipsToBounds = YES;
    [_btnDownload.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnDownload layer] setBorderWidth:5.0f];
    [_btnDownload setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
}

- (IBAction)closeFirmwareDownloadDialog:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)btnDownloadClicked:(id)sender {
    
    if(nil != firmwareFlasher) {
        if(!_segmentControlMagis.selectedSegmentIndex)
            [firmwareFlasher downloadFirmware:@"https://www.dronaaviation.com/wp-content/uploads/magis/MAGIS-1-0-0.hex" and:@"MAGIS-v3R"];
        else
            [firmwareFlasher downloadFirmware:@"https://www.dronaaviation.com/wp-content/uploads/magis/MAGIS-X-1-1-0.hex" and:@"MAGIS-X"];
    }
    
    [self removeFromSuperview];
}

-(void) setFirmwareViewController : (FirmwareFlasher *) viewController {
    firmwareFlasher = viewController;
}

@end
