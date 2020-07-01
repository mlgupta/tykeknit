//
//  InvitersProfileViewController.m
//  TykeKnit
//
//  Created by Ver on 22/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#define PHOTO_INDENT 74.0

#import "InvitersProfileViewController.h"
#import "CustomTableViewCell.h"
#import "Global.h"
#import "UIImage+Helpers.h"

@implementation InvitersProfileViewController

@synthesize theTableView,dict_Data;

- (void)viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleView];
	self.theTableView.backgroundColor = [UIColor clearColor];
	
	self.dict_Data = [[NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connectionRequests" ofType:@"plist"]] objectAtIndex:1];
	[super viewDidLoad];
}

- (void) backPressed : (id) sender {
	
	[self popViewController];
}
/*
 - (NSString*) getCellLabelForSection : (int)section {
 
 NSString *str_Label = nil;
 if (section == 0) 
 str_Label = @"imageInfo";
 else if(section == 1)
 str_Label = @"parentInfo";
 else {
 int kidCount = [[self.dict_Data objectForKey:@"kids_list"] count];
 str_Label = @"kidsInfo";
 if(section == kidCount+2)
 str_Label = @"acceptInfo";
 else if (section == kidCount+3)
 str_Label = @"rejectInfo";			
 }
 return str_Label;
 }
 */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	//The minimum no of sections required are 4
	return 5;// + [[self.dict_Data objectForKey:@"kids_list"] count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	//	NSString *strLabel = [self getCellLabelForSection:section];
	
	if (section==2) 
		return [[self.dict_Data objectForKey:@"kids_list"] count];
	if (section==0 || section==3|| section==4) 
		return 1;
	else if (section==1)
		return 3;
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 ) 
		return 63;
	else if(indexPath.section == 2) 
		return 70;
	else
		return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section==2){
		UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,40)];
		
		UILabel *headerForSection = [[[UILabel alloc]initWithFrame:CGRectMake(12, 18, 100, 17)] autorelease];
		[headerForSection setBackgroundColor:[UIColor clearColor]];
		headerForSection.font = [UIFont boldSystemFontOfSize:15];
		headerForSection.text = @"Kids Info";
		headerForSection.textColor = [UIColor darkGrayColor];
		[view_ForHeader addSubview:headerForSection];
		return [view_ForHeader autorelease];
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if (section==2) 
		return 40.0;
	else return 10.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.section==0) {

		NSString *CellIdentifier = @"InfoCell";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

		cell.content.cellStyle = CustomTableViewCellStyleHorizontalLine;
		cell.content.startPoint = CGPointMake(74, 32);
		cell.indentationLevel = 1;
		cell.indentationWidth = 74;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
		
		UIView *vi_photoShadow = [[UIView alloc] initWithFrame:CGRectMake(9.0, 0, 64, 64)];
		vi_photoShadow.tag = 1;
		CALayer *sublayer = vi_photoShadow.layer;
		sublayer.backgroundColor = [UIColor clearColor].CGColor;
		sublayer.shadowOffset = CGSizeMake(0, 3);
		sublayer.shadowRadius = 5.0;
		sublayer.shadowColor = [UIColor blackColor].CGColor;
		sublayer.shadowOpacity = 1;
		sublayer.borderColor = [UIColor blackColor].CGColor;
		sublayer.borderWidth = 2.0;
		sublayer.cornerRadius = 5.0;
		
		UIButton *photoImageView = [UIButton buttonWithType:UIButtonTypeCustom];
		photoImageView.tag = 2;
		photoImageView.frame = CGRectMake(0.0, 0, 64.0, 64.0);
		[photoImageView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.5].CGColor];
		[photoImageView.layer setBorderWidth:2.0];
		[photoImageView.layer setCornerRadius:5.0];
		photoImageView.layer.masksToBounds = YES;
		[photoImageView addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
		[photoImageView setBackgroundImage:[UIImage imageNamed:@"userimage.png"] forState:UIControlStateNormal];
		[photoImageView setClipsToBounds:YES];
		[vi_photoShadow addSubview:photoImageView];
		//			[photoImageView release];
		
		CGRect frame = cell.frame;
		vi_photoShadow.frame = CGRectMake(frame.origin.x-1.0, frame.origin.y-1.0, 64.0, 64.0);
		[cell.contentView addSubview:vi_photoShadow];
		[vi_photoShadow release];
			
		UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(90, 7, 150, 20)];
		lblFirstName.tag = 3;
		lblFirstName.backgroundColor = [UIColor clearColor];
		lblFirstName.font = [UIFont boldSystemFontOfSize:13];
		[cell.contentView addSubview:lblFirstName];
		[lblFirstName release];
			
		UILabel *lblDegree = [[UILabel alloc] initWithFrame:CGRectMake(90, 35, 150, 20)];
		lblDegree.tag = 4;
		lblDegree.text = @"Last Name";
		lblDegree.backgroundColor = [UIColor clearColor];
		lblDegree.font = [UIFont boldSystemFontOfSize:13];
		[cell.contentView addSubview:lblDegree];
		[lblDegree release];
			
	}
	//		UIView *vi_photoShadow = (UIView *)[cell viewWithTag:1];
	UIButton *photoImageView = (UIButton *)[cell viewWithTag:2];
	UILabel *lblFirstName = (UILabel *)[cell viewWithTag:3];
	UILabel *lblDegree = (UILabel *)[cell viewWithTag:4];
		
	[photoImageView setBackgroundImage:[UIImage imageNamed:@"userimage.png"] forState:UIControlStateNormal];
	[lblFirstName setText:[self.dict_Data objectForKey:@"name"]];
		[lblDegree setText:[self.dict_Data objectForKey:@"degree"]];
	
	//	[cell.contentView insertSubview:photoImageView atIndex:0 ];
	return cell;
		
	}
	else if (indexPath.section==1) {
		
		NSString *CellIdentifier = @"parentInfo";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.content.startPoint = CGPointMake(102, 0);
			cell.content.cellStyle = CustomTableViewCellStyleVerticalLine;
			UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(215, 2, 40, 37)];
			imageView.backgroundColor = [UIColor clearColor];
			imageView.tag = 11;
			[cell.contentView addSubview:imageView];
			[imageView release];
 
			UILabel *lblCell = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 85, 20)];
			lblCell.tag =12;
			lblCell.backgroundColor = [UIColor clearColor];
			lblCell.textAlignment = UITextAlignmentRight;
			lblCell.font = [UIFont boldSystemFontOfSize:12];
			[cell.contentView addSubview:lblCell];
			[lblCell release];
			
			UILabel *lbl_Value = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 270, 20)];
			lbl_Value.tag = 13;
			lbl_Value.backgroundColor = [UIColor clearColor];
			lbl_Value.textAlignment = UITextAlignmentLeft;
			lbl_Value.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:lbl_Value];
			[lbl_Value release];
			 
		}
		
		UILabel *lblCell = (UILabel *)[cell viewWithTag:12];
		UILabel *lbl_Value = (UILabel *)[cell viewWithTag:13];
		switch (indexPath.row) {
			case 0:
				lblCell.text = @"Email id";
				lbl_Value.text =[NSString stringWithFormat:@"%@",[self.dict_Data objectForKey:@"email"]];
				break;
			case 1:
				lblCell.text = @"Contact No";
				lbl_Value.text =[NSString stringWithFormat:@"%@",[self.dict_Data objectForKey:@"contactNo"]];
				break;
			case 2:
				lblCell.text = @"Location";
				lbl_Value.text =[NSString stringWithFormat:@"%@",[self.dict_Data objectForKey:@"city"]];
				break;
		}
		return cell;
	}
	else if (indexPath.section==2) {
		NSString *CellIdentifier = @"kidsInfo";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[CustomTableViewCell alloc] initWithStyle:CustomTableViewCellStyleVerticalLine reuseIdentifier:CellIdentifier] autorelease];
			cell.content.startPoint = CGPointMake(102, 0);
			
			UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
			imageView.backgroundColor = [UIColor grayColor];
			imageView.tag = 21;
			[cell.contentView addSubview:imageView];
			[imageView release];
			
			UILabel *lbl_Name = [[UILabel alloc]initWithFrame:CGRectMake(80, 5, 100, 15)];
			lbl_Name.tag = 22;
			lbl_Name.backgroundColor = [UIColor clearColor];
			lbl_Name.font = [UIFont boldSystemFontOfSize:12];
			[cell.contentView addSubview:lbl_Name];
			[lbl_Name release];
			
			UILabel *lbl_Age = [[UILabel alloc]initWithFrame:CGRectMake(80, 21, 100,15)];
			lbl_Age.tag = 23;
			lbl_Age.backgroundColor = [UIColor clearColor];
			lbl_Age.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:lbl_Age];
			[lbl_Age release];
			
			UILabel *lbl_Gender = [[UILabel alloc]initWithFrame:CGRectMake(80, 37, 100, 15)];
			lbl_Gender.tag = 24;
			lbl_Gender.backgroundColor = [UIColor clearColor];
			lbl_Gender.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:lbl_Gender];
			[lbl_Gender release];
		}
		
		UIImageView *imageView = (UIImageView *)[cell viewWithTag:21];
		UILabel *lbl_Name = (UILabel *)[cell viewWithTag:22];
		UILabel *lbl_Age = (UILabel *)[cell viewWithTag:23];
		UILabel *lbl_Gender = (UILabel *)[cell viewWithTag:24];
		
		imageView.image = [UIImage imageNamed:@"child.png"];
		lbl_Name.text = [[[self.dict_Data objectForKey:@"kids_list"] objectAtIndex:indexPath.row]objectForKey:@"kid_name"];
		lbl_Age.text = [NSString stringWithFormat:@"Age : %@",[[[self.dict_Data objectForKey:@"kids_list"] objectAtIndex:indexPath.row]objectForKey:@"kid_age"]];
		lbl_Gender.text =[NSString stringWithFormat:@"Gender : %@",[[[self.dict_Data objectForKey:@"kids_list"] objectAtIndex:indexPath.row]objectForKey:@"kid_gender"]];
		return cell;
	}
	else if (indexPath.section==3) {
		NSString *CellIdentifier = @"AcceptSection";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[CustomTableViewCell alloc] initWithStyle:CustomTableViewCellStyleVerticalLine reuseIdentifier:CellIdentifier] autorelease];
			
			UIView *backiew = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
			backiew.backgroundColor = [UIColor clearColor];
			cell.backgroundView = backiew;
			
			UIButton *btnRequest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[btnRequest setFrame:CGRectMake(2, 2, 254, 40)];
			btnRequest.tag = 21;
			[btnRequest addTarget:self action:@selector(requestClicked:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btnRequest];;
		}
		
		UIButton *btnAccept = (UIButton *)[cell viewWithTag:21];
		[btnAccept setTitle:@"Accept" forState:UIControlStateNormal];
		return cell;
	}
	else if (indexPath.section==4) {
		NSString *CellIdentifier = @"rejectSection";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[CustomTableViewCell alloc] initWithStyle:CustomTableViewCellStyleVerticalLine reuseIdentifier:CellIdentifier] autorelease];
			
			UIView *backiew = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
			backiew.backgroundColor = [UIColor clearColor];
			cell.backgroundView = backiew;
			
			UIButton *btnRequest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[btnRequest setFrame:CGRectMake(2, 2, 254, 40)];
			[btnRequest addTarget:self action:@selector(requestClicked:) forControlEvents:UIControlEventTouchUpInside];
			btnRequest.tag = 21;
			[cell.contentView addSubview:btnRequest];
		}
		
		UIButton *btnReject = (UIButton *)[cell viewWithTag:21];
		[btnReject setTitle:@"Reject" forState:UIControlStateNormal];
			return cell;
	}

	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0)	{
		
		if ([cell.backgroundView class] != [UIView class]) {
			
			UIGraphicsBeginImageContext(cell.backgroundView.bounds.size);
			[cell.backgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			UIImage *shrunkenBackgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20.0 topCapHeight:round((backgroundImage.size.height - 1.0)/2.0)];
			
			UIView *replacementBackgroundView = [[UIView alloc] initWithFrame:cell.backgroundView.frame];
			replacementBackgroundView.autoresizesSubviews;
			//			replacementBackgroundView.backgroundColor = [UIColor redColor];
			
			UIImageView *indentedView = [[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_INDENT, 0, replacementBackgroundView.bounds.size.width - PHOTO_INDENT,  replacementBackgroundView.bounds.size.height)];
			indentedView.image = shrunkenBackgroundImage;
			indentedView.contentMode = UIViewContentModeRedraw;
			indentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			indentedView.contentStretch = CGRectMake(0.2, 0, 0.5, 1);
			[replacementBackgroundView addSubview:indentedView];
			[indentedView release];
			
			cell.backgroundView = replacementBackgroundView;
		}
		
		if ([cell.selectedBackgroundView class] != [UIView class]) {
			
			UIGraphicsBeginImageContext(cell.selectedBackgroundView.bounds.size);
			[cell.selectedBackgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			UIImage *shrunkenBackgroundImage = [backgroundImage stretchableImageWithHorizontalCapWith:20.0 verticalCapWith:round((backgroundImage.size.height - 1.0)/2.0)];
			
			UIView *replacementBackgroundView = [[UIView alloc] initWithFrame:cell.backgroundView.frame];
			replacementBackgroundView.autoresizesSubviews;
			
			UIImageView *indentedView = [[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_INDENT, 0, replacementBackgroundView.bounds.size.width - PHOTO_INDENT,  replacementBackgroundView.bounds.size.height)];
			indentedView.image = shrunkenBackgroundImage;
			indentedView.contentMode = UIViewContentModeRedraw;
			indentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			indentedView.contentStretch = CGRectMake(0.2, 0, 0.5, 1);
			[replacementBackgroundView addSubview:indentedView];
			[indentedView release];
			
			cell.selectedBackgroundView = replacementBackgroundView;
			
		}
		
		/*
		 // naughty: we could add the photo directy to the tableView's content here
		 CGRect frame = cell.frame;
		 photoImageView.frame = CGRectMake(9.0, frame.origin.y, 64.0, 64.0);
		 [tableView addSubview:photoImageView];
		 
		 // head sticker
		 UIImageView *heartView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
		 heartView.frame = CGRectMake(photoImageView.frame.origin.x + 40.0, photoImageView.frame.origin.y + 45.0, heartView.frame.size.width, heartView.frame.size.height);
		 [tableView addSubview:heartView];
		 [heartView release];
		 */	 
	}
	
//	[self drawFooter];
}



-(void) requestClicked:(id) sender{
	[self popViewController];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
