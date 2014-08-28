#import <Foundation/Foundation.h>


extern NSString *NRCurrentCalendarDayDidChange;

@interface NRDayChangeDetector : NSObject

+ (void)startDetectingDayChanges;

@end
