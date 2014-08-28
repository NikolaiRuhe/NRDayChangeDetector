#import <Foundation/Foundation.h>


extern NSString *NRCurrentCalendarDayDidChange;


// NRDayChangeDetector detects changes of the current calendar day and sends a notification.
//
// It uses the system's current calendar (as selected by the user). NRDayChangeDetector
// is smart enough to detect changes because of daylight saving time, setting the system
// clock, changing the timezone, and after system sleep.
//
// To use it in your app just start it and register for its single notification:
//
//	  [NRDayChangeDetector startDetectingDayChanges];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(dayDidChange:)
//                                                 name:NRCurrentCalendarDayDidChange
//                                               object:nil]

@interface NRDayChangeDetector : NSObject

+ (void)startDetectingDayChanges;

@end
