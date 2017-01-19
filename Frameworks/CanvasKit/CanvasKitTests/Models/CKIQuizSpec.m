
//
//  CKIQuizSpec.m
//  CanvasKit
//
//  Created by Miles Wright on 10/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Helpers.h"
#import "CKIISO8601DateMatcher.h"

#import "CKIQuiz.h"

SPEC_BEGIN(CKIQuizSpec)

registerMatchers(@"CKI");

describe(@"A quiz", ^{
    
    context(@"when created from quiz.json", ^{
        NSDictionary *json = loadJSONFixture(@"quiz");
        CKIQuiz *quiz = [CKIQuiz modelFromJSONDictionary:json];

        it(@"gets id", ^{
            [[quiz.id should] equal:@"5"];
        });
        it(@"gets title", ^{
            [[quiz.title should] equal:@"Hamlet Act 3 Quiz"];
        });
        it(@"gets html url", ^{
            NSURL *url = [NSURL URLWithString:@"http://canvas.example.edu/courses/1/quizzes/2"];
            [[quiz.htmlURL should] equal:url];
        });
        it(@"gets mobile url", ^{
            NSURL *url = [NSURL URLWithString:@"http://canvas.example.edu/courses/1/quizzes/2?persist_healdess=1&force_user=1"];
            [[quiz.mobileURL should] equal:url];
        });
        it(@"gets description", ^{
            [[quiz.description should] equal:@"This is a quiz on Act 3 of Hamlet"];
        });
        it(@"gets quiz type", ^{
            [[quiz.quizType should] equal:@"assignment"];
        });
        it(@"gets assignment group id", ^{
            [[quiz.assignmentGroupID should] equal:@"3"];
        });
        it(@"gets time limit minutes", ^{
            [[theValue(quiz.timeLimitMinutes) should] equal:theValue(5)];
        });
        it(@"gets shuffle answers", ^{
            [[theValue(quiz.shuffleAnswers) should] beFalse];
        });
        it(@"gets hide results", ^{
            [[quiz.hideResults should] equal:@"always"];
        });
        it(@"gets show correct answers", ^{
            [[theValue(quiz.showCorrectAnswers) should] beTrue];
        });
        it(@"gets scoring policy", ^{
            [[quiz.scoringPolicy should] equal:@"keep_highest"];
        });
        it(@"gets allowed attempts", ^{
            [[theValue(quiz.allowedAttempts) should] equal:theValue(3)];
        });
        it(@"gets one question at a time", ^{
            [[theValue(quiz.oneQuestionAtATime) should] beFalse];
        });
        it(@"gets question count", ^{
            [[theValue(quiz.questionCount) should] equal:theValue(12)];
        });
        it(@"gets points possible", ^{
            [[theValue(quiz.pointsPossible) should] equal:theValue(20)];
        });
        it(@"gets cant go back", ^{
            [[theValue(quiz.cantGoBack) should] beFalse];
        });
        it(@"gets access code", ^{
            [[quiz.accessCode should] equal:@"2beornot2be"];
        });
        it(@"gets ip filter", ^{
            [[quiz.ipFilter should] equal:@"123.123.123.123"];
        });
        it(@"gets due at date", ^{
            [[quiz.dueAt should] equalISO8601String:@"2013-01-23T23:59:00-07:00"];
        });
        it(@"gets published", ^{
            [[theValue(quiz.published) should] beTrue];
        });
    });
});

SPEC_END
