//
//  ParameterEncodingTests.swift
//
//  Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import XCTest

@testable import TooLegit
import SoAutomated

class ParameterEncodingTestCase: XCTestCase {
    let url = URL(string: "https://example.com/")!
}

// MARK: -

class URLParameterEncodingTestCase: ParameterEncodingTestCase {
    let encoding: ParameterEncoding = .url

    // MARK: Tests - Parameter Types

    func testURLParameterEncodeEmptyDictionaryParameter() {
        // Given
        let parameters: [String: AnyObject] = [:]

        // When
        let url = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertNil(url.query, "query should be nil")
    }

    func testURLParameterEncodeOneStringKeyStringValueParameter() {
        // Given
        let parameters = ["foo": "bar"]

        // When
        let url = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(url.query ?? "", "foo=bar", "query is incorrect")
    }

    func testURLParameterEncodeOneStringKeyStringValueParameterAppendedToQuery() {
        // Given
        var URLComponents = Foundation.URLComponents(url: self.url, resolvingAgainstBaseURL: false)!
        URLComponents.query = "baz=qux"

        let parameters = ["foo": "bar"]

        // When
        let URL = encoding.URLWithURL(URLComponents.url!, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "baz=qux&foo=bar", "query is incorrect")
    }

    func testURLParameterEncodeTwoStringKeyStringValueParameters() {
        // Given
        let parameters = ["foo": "bar", "baz": "qux"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "baz=qux&foo=bar", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyIntegerValueParameter() {
        // Given
        let parameters = ["foo": 1]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyDoubleValueParameter() {
        // Given
        let parameters = ["foo": 1.1]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo=1.1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyBoolValueParameter() {
        // Given
        let parameters = ["foo": true]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyArrayValueParameter() {
        // Given
        let parameters = ["foo": ["a", 1, true]]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo%5B%5D=a&foo%5B%5D=1&foo%5B%5D=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyDictionaryValueParameter() {
        // Given
        let parameters = ["foo": ["bar": 1]]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo%5Bbar%5D=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyNestedDictionaryValueParameter() {
        // Given
        let parameters = ["foo": ["bar": ["baz": 1]]]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo%5Bbar%5D%5Bbaz%5D=1", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyNestedDictionaryArrayValueParameter() {
        // Given
        let parameters = ["foo": ["bar": ["baz": ["a", 1, true]]]]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        let expectedQuery = "foo%5Bbar%5D%5Bbaz%5D%5B%5D=a&foo%5Bbar%5D%5Bbaz%5D%5B%5D=1&foo%5Bbar%5D%5Bbaz%5D%5B%5D=1"
        XCTAssertEqual(URL.query ?? "", expectedQuery, "query is incorrect")
    }

    // MARK: Tests - All Reserved / Unreserved / Illegal Characters According to RFC 3986

    func testThatReservedCharactersArePercentEscapedMinusQuestionMarkAndForwardSlash() {
        // Given
        let generalDelimiters = ":#[]@"
        let subDelimiters = "!$&'()*+,;="
        let parameters = ["reserved": "\(generalDelimiters)\(subDelimiters)"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        let expectedQuery = "reserved=%3A%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D"
        XCTAssertEqual(URL.query ?? "", expectedQuery, "query is incorrect")
    }

    func testThatReservedCharactersQuestionMarkAndForwardSlashAreNotPercentEscaped() {
        // Given
        let parameters = ["reserved": "?/"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "reserved=?/", "query is incorrect")
    }

    func testThatUnreservedNumericCharactersAreNotPercentEscaped() {
        // Given
        let parameters = ["numbers": "0123456789"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "numbers=0123456789", "query is incorrect")
    }

    func testThatUnreservedLowercaseCharactersAreNotPercentEscaped() {
        // Given
        let parameters = ["lowercase": "abcdefghijklmnopqrstuvwxyz"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "lowercase=abcdefghijklmnopqrstuvwxyz", "query is incorrect")
    }

    func testThatUnreservedUppercaseCharactersAreNotPercentEscaped() {
        // Given
        let parameters = ["uppercase": "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "uppercase=ABCDEFGHIJKLMNOPQRSTUVWXYZ", "query is incorrect")
    }

    func testThatIllegalASCIICharactersArePercentEscaped() {
        // Given
        let parameters = ["illegal": " \"#%<>[]\\^`{}|"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        let expectedQuery = "illegal=%20%22%23%25%3C%3E%5B%5D%5C%5E%60%7B%7D%7C"
        XCTAssertEqual(URL.query ?? "", expectedQuery, "query is incorrect")
    }

    // MARK: Tests - Special Character Queries

    func testURLParameterEncodeStringWithAmpersandKeyStringWithAmpersandValueParameter() {
        // Given
        let parameters = ["foo&bar": "baz&qux", "foobar": "bazqux"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo%26bar=baz%26qux&foobar=bazqux", "query is incorrect")
    }

    func testURLParameterEncodeStringWithQuestionMarkKeyStringWithQuestionMarkValueParameter() {
        // Given
        let parameters = ["?foo?": "?bar?"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "?foo?=?bar?", "query is incorrect")
    }

    func testURLParameterEncodeStringWithSlashKeyStringWithQuestionMarkValueParameter() {
        // Given
        let parameters = ["foo": "/bar/baz/qux"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "foo=/bar/baz/qux", "query is incorrect")
    }

    func testURLParameterEncodeStringWithSpaceKeyStringWithSpaceValueParameter() {
        // Given
        let parameters = [" foo ": " bar "]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "%20foo%20=%20bar%20", "query is incorrect")
    }

    func testURLParameterEncodeStringWithPlusKeyStringWithPlusValueParameter() {
        // Given
        let parameters = ["+foo+": "+bar+"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "%2Bfoo%2B=%2Bbar%2B", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyPercentEncodedStringValueParameter() {
        // Given
        let parameters = ["percent": "%25"]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(URL.query ?? "", "percent=%2525", "query is incorrect")
    }

    func testURLParameterEncodeStringKeyNonLatinStringValueParameter() {
        // Given
        let parameters = [
            "french": "français",
            "japanese": "日本語",
            "arabic": "العربية",
            "emoji": "😃"
        ]

        // When
        let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)

        // Then
        let expectedParameterValues = [
            "arabic=%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9",
            "emoji=%F0%9F%98%83",
            "french=fran%C3%A7ais",
            "japanese=%E6%97%A5%E6%9C%AC%E8%AA%9E"
        ]

        let expectedQuery = expectedParameterValues.joined(separator: "&")
        XCTAssertEqual(URL.query ?? "", expectedQuery, "query is incorrect")
    }

    func testURLParameterEncodeStringForRequestWithPrecomposedQuery() {
        // Given
        let url = URL(string: "https://example.com/movies?hd=[1]")!
        let parameters = ["page": "0"]

        // When
        let newURL = encoding.URLWithURL(url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(newURL.query ?? "", "hd=%5B1%5D&page=0", "query is incorrect")
    }

    func testURLParameterEncodeStringWithPlusKeyStringWithPlusValueParameterForRequestWithPrecomposedQuery() {
        // Given
        let url = URL(string: "https://example.com/movie?hd=[1]")!
        let parameters = ["+foo+": "+bar+"]

        // When
        let newURL = encoding.URLWithURL(url, method: .GET, encodingParameters: parameters)

        // Then
        XCTAssertEqual(newURL.query ?? "", "hd=%5B1%5D&%2Bfoo%2B=%2Bbar%2B", "query is incorrect")
    }

    // MARK: Tests - Varying HTTP Methods

    func testThatURLParameterEncodingEncodesGETParametersInURL() {
        attempt {
            // Given
            let parameters = ["foo": 1, "bar": 2]

            // When
            let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)
            let contentType = encoding.contentType(.GET)
            let HTTPBody = try encoding.body(.GET, encodingParameters: parameters)

            // Then
            XCTAssertEqual(URL.query ?? "", "bar=2&foo=1", "query is incorrect")
            XCTAssertNil(contentType, "contentType should be nil")
            XCTAssertNil(HTTPBody, "HTTPBody should be nil")
        }
    }

    func testThatURLParameterEncodingEncodesPOSTParametersInHTTPBody() {
        attempt {
            // Given
            let parameters = ["foo": 1, "bar": 2]

            // When
            let contentType = encoding.contentType(.POST)
            let HTTPBody = try encoding.body(.POST, encodingParameters: parameters)

            // Then
            XCTAssertEqual(
                contentType ?? "",
                "application/x-www-form-urlencoded; charset=utf-8",
                "Content-Type should be application/x-www-form-urlencoded"
            )
            XCTAssertNotNil(HTTPBody, "HTTPBody should not be nil")

            if let
                HTTPBody = HTTPBody,
                let decodedHTTPBody = String(data: HTTPBody, encoding: String.Encoding.utf8)
            {
                XCTAssertEqual(decodedHTTPBody, "bar=2&foo=1", "HTTPBody is incorrect")
            } else {
                XCTFail("decoded http body should not be nil")
            }
        }
    }

    func testThatURLEncodedInURLParameterEncodingEncodesPOSTParametersInURL() {
        attempt {
            // Given
            let parameters = ["foo": 1, "bar": 2]

            // When
            let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)
            let contentType = encoding.contentType(.GET)
            let HTTPBody = try encoding.body(.GET, encodingParameters: parameters)

            // Then
            XCTAssertEqual(URL.query ?? "", "bar=2&foo=1", "query is incorrect")
            XCTAssertNil(contentType, "Content-Type should be nil")
            XCTAssertNil(HTTPBody, "HTTPBody should be nil")
        }
    }
}

// MARK: -

class JSONParameterEncodingTestCase: ParameterEncodingTestCase {
    // MARK: Properties

    let encoding: ParameterEncoding = .json

    // MARK: Tests

    func testJSONParameterEncodeEmptyParameters() {
        attempt {
            // Given
            let parameters: [String: AnyObject] = [:]

            // When
            let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)
            let contentType = encoding.contentType(.GET)
            let HTTPBody = try encoding.body(.GET, encodingParameters: parameters)

            // Then
            XCTAssertNil(URL.query, "query should be nil")
            XCTAssertEqual("application/json", contentType, "Content-Type should be nil")
            XCTAssertNil(HTTPBody, "HTTPBody should be nil")
        }
    }

    func testJSONParameterEncodeComplexParameters() {
        attempt {
            // Given
            let parameters = [
                "foo": "bar",
                "baz": ["a", 1, true],
                "qux": [
                    "a": 1,
                    "b": [2, 2],
                    "c": [3, 3, 3]
                ]
            ] as [String : Any]

            // When
            let URL = encoding.URLWithURL(self.url, method: .GET, encodingParameters: parameters)
            let contentType = encoding.contentType(.GET)
            let HTTPBody = try encoding.body(.GET, encodingParameters: parameters)

            // Then
            XCTAssertNil(URL.query, "query should be nil")
            XCTAssertNotNil(contentType, "Content-Type should not be nil")
            XCTAssertEqual(
                contentType ?? "",
                "application/json",
                "Content-Type should be application/json"
            )
            XCTAssertNotNil(HTTPBody, "HTTPBody should not be nil")

            if let HTTPBody = HTTPBody {
                do {
                    let JSON = try JSONSerialization.jsonObject(with: HTTPBody, options: .allowFragments)

                    if let JSON = JSON as? NSObject {
                        XCTAssertEqual(JSON, parameters as NSObject, "HTTPBody JSON does not equal parameters")
                    } else {
                        XCTFail("JSON should be an NSObject")
                    }
                } catch {
                    XCTFail("JSON should not be nil")
                }
            } else {
                XCTFail("JSON should not be nil")
            }
        }
    }
}
