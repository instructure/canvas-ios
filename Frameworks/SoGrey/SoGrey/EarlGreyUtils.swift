//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import EarlGrey

// Set screenshot folder so that app reset doesn't delete the contents.
public func grey_setConfiguration() throws {
  enum DocumentError: Error {
    case NoDocumentDirectory
    case FailedToCreateDirectory
  }

  guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      throw DocumentError.NoDocumentDirectory
  }

  let screenshotDir = documentDir.appendingPathComponent("earlgrey_screenshots").path

  do {
    try FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true, attributes: nil)
  } catch {
    throw DocumentError.FailedToCreateDirectory
  }

  GREYConfiguration.sharedInstance().setValue(screenshotDir, forConfigKey: kGREYConfigKeyArtifactsDirLocation)
}

// Don't set line number in EarlGreyUtils.
// Must be invoked via the calling method inside the page object.


// Must use wrapper class to force pass by reference in block.
// inout params won't work. http://stackoverflow.com/a/28252105
open class Element {
  var text = ""
}

/*
 *  Example Usage:
 *
 *  let element = Element()
 *
 *  domainField.performAction(grey_replaceText("hello.there"))
 *             .performAction(grey_getText(element))
 *
 *  GREYAssertTrue(element.text != "", reason: "get text failed")
 */
public func grey_getText(_ elementCopy: Element) -> GREYActionBlock {
  return GREYActionBlock.action(withName: "get text", constraints: grey_respondsToSelector(#selector(getter: UILabel.text))) { element, errorOrNil -> Bool in
        let elementObject = element as? NSObject
        let text = elementObject?.perform(#selector(getter: UILabel.text), with: nil)?.takeRetainedValue() as? String
        
        elementCopy.text = text ?? ""
        return true
    }
}

// Use to report errors on the correct file/line
public func grey_invokedFromFile(_ file:StaticString, _ line:UInt) {
  EarlGreyImpl.invoked(fromFile: file.description, lineNumber: line)
}

