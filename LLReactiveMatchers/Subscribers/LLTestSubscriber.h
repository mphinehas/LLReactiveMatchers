//
//  LLTestSubscriber.h
//  LLReactiveMatchers
//
//  Created by Lawrence Lomax on 6/12/2013.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LLTestSubscriber : RACReplaySubject

+ (instancetype) subscribeWithSignal:(RACSignal *)signal;

@property (nonatomic, readonly) RACSignal *signal;

@property (nonatomic, strong, readonly) NSMutableArray *valuesReceived;
@property (nonatomic, assign) BOOL hasCompleted;
@property (nonatomic, assign) BOOL hasError;

@end

@interface RACSignal (EXPRACSubscriber)

- (LLTestSubscriber *) events;

@end