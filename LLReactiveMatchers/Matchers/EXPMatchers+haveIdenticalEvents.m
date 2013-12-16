#import "EXPMatchers+haveIdenticalEvents.h"

#import "LLSignalTestRecorder.h"
#import "LLReactiveMatchersHelpers.h"
#import "LLReactiveMatchersMessages.h"

EXPMatcherImplementationBegin(haveIdenticalEvents, (RACSignal *expected))

__block LLSignalTestRecorder *actualRecorder = nil;
__block LLSignalTestRecorder *expectedRecorder = nil;

void (^subscribe)(void) = ^{
    if(!actualRecorder) {
        actualRecorder = LLRMRecorderForObject(actual);
    }
    if(!expectedRecorder) {
        expectedRecorder = LLRMRecorderForObject(expected);
    }
};

prerequisite(^BOOL{
    return LLRMCorrectClassesForActual(actual);
});

match(^BOOL{
    subscribe();
    
    if(!actualRecorder.hasFinished || !expectedRecorder.hasFinished) {
        return NO;
    }
    
    return LLRMIdenticalValues(actualRecorder, expectedRecorder) && LLRMIdenticalFinishingStatus(actualRecorder, expectedRecorder) && LLRMIdenticalErrors(actualRecorder, expectedRecorder);
});

failureMessageForTo(^NSString *{
    if(!LLRMCorrectClassesForActual(actual)) {
        return [LLReactiveMatchersMessages actualNotSignal:actual];
    }
    if(!actualRecorder.hasFinished) {
        return [LLReactiveMatchersMessages actualNotFinished:actual];
    }
    if(!expectedRecorder.hasFinished) {
        return [LLReactiveMatchersMessages expectedNotFinished:expected];
    }
    if(!LLRMIdenticalValues(actualRecorder, expectedRecorder)) {
        return [NSString stringWithFormat:@"Values %@ are not the same as %@", EXPDescribeObject(actualRecorder.values), EXPDescribeObject(expectedRecorder.values)];
    }
    return [NSString stringWithFormat:@"Actual %@ does not have the same finishing event as %@", LLDescribeSignal(actual), LLDescribeSignal(expected)];
});

failureMessageForNotTo(^NSString *{
    if(!LLRMCorrectClassesForActual(actual)) {
        return [LLReactiveMatchersMessages actualNotSignal:actual];
    }
    return [NSString stringWithFormat:@"Actual %@ has all the same events as %@", LLDescribeSignal(actual), LLDescribeSignal(expected)];
});

EXPMatcherImplementationEnd
