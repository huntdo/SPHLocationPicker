//
//  ExampleAutoCompleteTableViewDataSource.m
//  SPHLocationPicker
//
//  Created by Karl Monaghan on 05/07/2013.
//  Copyright (c) 2013 SkillPages Holdings. All rights reserved.
//

#import "ExampleAutoCompleteTableViewDataSource.h"

#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"

@interface ExampleAutoCompleteTableViewDataSource()
@property (strong, nonatomic) SPGooglePlacesAutocompleteQuery *searchQuery;
@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) NSMutableArray *filteredList;
@end

@implementation ExampleAutoCompleteTableViewDataSource
- (id)init
{
    self = [super init];
    if (self)
    {
        self.searchQuery = [SPGooglePlacesAutocompleteQuery new];
        self.searchQuery.radius = 100.0f;
        
        self.filteredList = @[].mutableCopy;
    }
    
    return self;
}

- (void)updateSearchTerm:(NSString *)term withLocation:(CLLocationCoordinate2D)location onFinished:(successResponseBlock)successBlock
{
    if ([term length])
    {
        self.searchQuery.location = location;
        self.searchQuery.input = term;
        
        __block ExampleAutoCompleteTableViewDataSource *blockSelf = self;
        
        [self.searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
            if (error) {
                SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
            } else {
                [blockSelf.filteredList removeAllObjects];
                
                for (SPGooglePlacesAutocompletePlace *place in places)
                {
                    NSLog(@"%@", place);
                    
                    blockSelf.places = places;
                    [blockSelf.filteredList addObject:place.name];
                }
                
                successBlock();
            }
        }];
    }
}

- (void)placemarkForRow:(NSIndexPath *)indexPath
{
    [self.places[indexPath.row] resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placemark"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placemark"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumScaleFactor = 0.75f;
	}
    
	cell.textLabel.text = self.filteredList[indexPath.row];
	
	return cell;
}
@end