#import "FavoritesProxy.h"

@implementation FavoritesProxy



-(void)initializeProxy {
	[super initializeProxy];
    self.myFavoritesArray = [NSMutableArray new];
    NSError *error;
    NSArray *favoritesArray = [MTLJSONAdapter modelsOfClass:[RoutePoint class]
                                              fromJSONArray: [self readFavoritesFromFile]
                                                      error:&error];
    if (!error) {
        [self.myFavoritesArray addObjectsFromArray:favoritesArray];
    }
}

- (NSArray*)readFavoritesFromFile{
    
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(
                                    NSDocumentDirectory,
                                    NSUserDomainMask,
                                    YES)
                          objectAtIndex:0];
    NSString* fileName = @"favorites.json";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager]
            createFileAtPath:fileAtPath contents:nil attributes:nil];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:@[]
                        options:NSJSONWritingPrettyPrinted error:nil];
        
        [data writeToFile:fileAtPath atomically:YES];
    }
    
    NSArray *favorites;
    
    if (fileAtPath) {
        NSData *partyData = [[NSData alloc] initWithContentsOfFile:fileAtPath];
        NSError *error;
        favorites = [NSJSONSerialization JSONObjectWithData:partyData
                                                    options:0
                                                      error:&error];
        
        if (error) {
            NSLog(@"Something went wrong! %@", error.localizedDescription);
            return nil;
        }
    } else {
        return nil;
    }
    return favorites;
}
- (void) addToFavorites:(RoutePoint *)point{
    if ([self.myFavoritesArray includes:point]) {
        
        return;
    }
    [self.myFavoritesArray addObject:point];

    [self saveFavoritesToFile];
    
}
- (void) removeFavoriteItemAtIndex:(NSInteger)index{
    [self.myFavoritesArray removeObjectAtIndex:index];
    [self saveFavoritesToFile];
}

- (void) saveFavoritesToFile{
    NSArray *favArray = [MTLJSONAdapter JSONArrayFromModels:self.myFavoritesArray
                                                      error:nil];
    
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(
                                                              NSDocumentDirectory,
                                                              NSUserDomainMask,
                                                              YES)
                          objectAtIndex:0];
    
    NSString* fileName = @"favorites.json";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath
                                                contents:nil
                                              attributes:nil];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:favArray
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    
    [data writeToFile:fileAtPath atomically:YES];

}
@end