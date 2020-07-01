#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TableCellImageView.h"
@protocol CallOutMapAnnotationDelegate
@required
- (void) calloutButtonClickedOfIndex:(NSMutableDictionary*)dict_index;
@end


@interface CalloutMapAnnotationView : MKAnnotationView {
	MKAnnotationView *_parentAnnotationView;
	MKMapView *_mapView;
	CGRect _endFrame;
	UIView *_contentView;
	CGFloat _yShadowOffset;
	CGPoint _offsetFromParent;
	CGFloat _contentHeight;
	NSMutableDictionary *dict_data;
	NSString *userName;
	id <CallOutMapAnnotationDelegate> delegate;
	//
	TableCellImageView *img_kidPic;
	UILabel *lbl_name;
	UILabel *lbl_wannaHang;
	UILabel *lbl_age;
	UILabel *lbl_gender;
	UIButton *btn_Details;
	UILabel *lbl_address;
}

@property (nonatomic, retain) MKAnnotationView *parentAnnotationView;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, retain) NSMutableDictionary *dict_data;
@property (nonatomic) CGPoint offsetFromParent;
@property (nonatomic) CGFloat contentHeight;
@property (nonatomic, retain) id delegate;
- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;

@end
