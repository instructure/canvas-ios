//# MARK: - Custom EarlGrey file/line

import EarlGrey

extension EarlGreyImpl {
    // Use @nonobjc to fix A declaration cannot be both 'final' and 'dynamic' error
    @nonobjc public static var file: String = ""
    @nonobjc public static var line: UInt = 0

    public static func setFromFile(file: String, _ line: UInt) {
        self.file = file
        self.line = line
    }
}

// File & line must be explicitly passed because defaulting to #file and #line
// won't use the file and line number from the test.
public func grey_invokedFromFile(file: String, _ line: UInt) {
    EarlGreyImpl.setFromFile(file, line)
}

public func EarlGrey() -> EarlGreyImpl! {
    return EarlGreyImpl.invokedFromFile(EarlGreyImpl.file, lineNumber: EarlGreyImpl.line)
}

//# MARK: - Upstream EarlGrey code

//
// Copyright 2016 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// https://github.com/google/EarlGrey/blob/50fb3dca1cb47e8f7ef33ff26503a52c73ba864b/gem/lib/earlgrey/files/EarlGrey.swift

public func grey_allOfMatchers(args: AnyObject...) -> GREYMatcher! {
  return GREYAllOf.init(matchers: args)
}

public func grey_anyOfMatchers(args: AnyObject...) -> GREYMatcher! {
  return GREYAnyOf.init(matchers: args)
}

public func GREYAssert(@autoclosure expression: () -> BooleanType, reason: String) {
  GREYAssert(expression, reason, details: "Expected expression to be true")
}

public func GREYAssertTrue(@autoclosure expression: () -> BooleanType, reason: String) {
  GREYAssert(expression().boolValue,
             reason,
             details: "Expected the boolean expression to be true")
}

public func GREYAssertFalse(@autoclosure expression: () -> BooleanType, reason: String) {
  GREYAssert(!expression().boolValue,
             reason,
             details: "Expected the boolean expression to be false")
}

public func GREYAssertNotNil(@autoclosure expression: () -> Any?, reason: String) {
  GREYAssert(expression() != nil, reason, details: "Expected expression to be not nil")
}

public func GREYAssertNil(@autoclosure expression: () -> Any?, reason: String) {
  GREYAssert(expression() == nil, reason, details: "Expected expression to be nil")
}

public func GREYAssertEqual<T : Equatable>(@autoclosure left: () -> T?,
                            @autoclosure _ right: () -> T?, reason: String) {
  GREYAssert(left() == right(), reason, details: "Expected left term to be equal to right term")
}

public func GREYAssertNotEqual<T : Equatable>(@autoclosure left: () -> T?,
                               @autoclosure _ right: () -> T?, reason: String) {
  GREYAssert(left() != right(), reason, details: "Expected left term to not be equal to right term")
}

public func GREYFail(reason: String) {
  greyFailureHandler.handleException(GREYFrameworkException(name: kGREYAssertionFailedException,
    reason: reason),
                                     details: "")
}

public func GREYFail(reason: String, details: String) {
  greyFailureHandler.handleException(GREYFrameworkException(name: kGREYAssertionFailedException,
    reason: reason),
                                     details: details)
}

private func GREYAssert(@autoclosure expression: () -> BooleanType,
                                     _ reason: String, details: String) {
  GREYSetCurrentAsFailable()
  if !expression().boolValue {
    greyFailureHandler.handleException(GREYFrameworkException(name: kGREYAssertionFailedException,
      reason: reason),
                                       details: details)
  }
}

private func GREYSetCurrentAsFailable() {
  let greyFailureHandlerSelector =
    #selector(GREYFailureHandler.setInvocationFile(_:andInvocationLine:))
  if greyFailureHandler.respondsToSelector(greyFailureHandlerSelector) {
    greyFailureHandler.setInvocationFile!(#file, andInvocationLine: #line)
  }
}
