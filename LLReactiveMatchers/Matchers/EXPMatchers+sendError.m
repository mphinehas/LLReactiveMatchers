#import "EXPMatchers+sendError.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "LLReactiveMatchersMessages.h"
#import "LLReactiveMatchersHelpers.h"

EXPMatcherImplementationBegin(sendError, (NSError *expected))

__block BOOL hasErrored = NO;
__block BOOL hasCompleted = NO;
__block BOOL hasSubscribed = NO;
__block NSError *errorReceived = nil;

void (^subscribe)(void) = ^{
    if(!hasSubscribed) {
        [self.rac_deallocDisposable addDisposable:
         [actual subscribeError:^(NSError *error) {
            @synchronized(actual) {
                hasErrored = YES;
                errorReceived = error;
            }
        } completed:^{
            @synchronized(actual) {
                hasCompleted = YES;
            }
        }]];
        
        hasSubscribed = YES;
    }
};

prerequisite(^BOOL{
    return LLRMCorrectClassesForActual(actual);
});

match(^BOOL{
    subscribe();
    return hasErrored && LLRMIdenticalErrors(errorReceived, expected);
});

failureMessageForTo(^NSString *{
    if(!LLRMCorrectClassesForActual(actual)) {
        return [LLReactiveMatchersMessages actualNotSignal:actual];
    }
    if(!(hasCompleted || hasErrored)) {
        return [LLReactiveMatchersMessages actualNotFinished:actual];
    }
    if(!hasErrored) {
        return [NSString stringWithFormat:@"Signal %@ did not finish in error", LLDescribeSignal(actual)];
    }
    
    return [NSString stringWithFormat:@"Actual %@ does not have the same error as %@", LLDescribeSignal(actual), EXPDescribeObject(expected)];
});

failureMessageForNotTo(^NSString *{
    if(!LLRMCorrectClassesForActual(actual)) {
        return [LLReactiveMatchersMessages actualNotSignal:actual];
    }
    
    return [NSString stringWithFormat:@"Actual %@ has the same error as %@", LLDescribeSignal(actual), EXPDescribeObject(expected)];
});

EXPMatcherImplementationEnd
