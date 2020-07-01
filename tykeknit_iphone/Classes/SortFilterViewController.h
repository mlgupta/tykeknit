//
//  SortFilterViewController.h
//  SpotWorld
//
//  Created by Abhinav Singh on 30/09/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortFilterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	NSArray *arr_Categories;
	UITableView *theTableView;
	NSMutableArray *arr_SelectedCat;
	
	NSMutableArray *arr_neighbourHoods;
	NSMutableArray *arr_SelectedNeighbours;
}

@property(nonatomic,retain) NSMutableArray *arr_SelectedNeighbours;
@property(nonatomic,retain) NSMutableArray *arr_neighbourHoods;

@property(nonatomic,retain) NSArray *arr_Categories;
@property(nonatomic,retain) NSMutableArray *arr_SelectedCat;

@property(nonatomic,retain) IBOutlet UITableView *theTableView;

- (NSMutableDictionary*) getSortDictionary;
@end
