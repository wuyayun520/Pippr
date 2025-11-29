#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnderIntensityInfo : NSObject

@property (nonatomic) int transitionModeType;

+ (instancetype) underIntensityInfoWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) threadStateBound;

- (NSMutableDictionary *) transitionAmongTier;

- (int) transitionContainMediator;

- (NSMutableSet *) requestCycleLocation;

- (NSMutableArray *) declarativeOptimizerLocation;

@end

NS_ASSUME_NONNULL_END
        