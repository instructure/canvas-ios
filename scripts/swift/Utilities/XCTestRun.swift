//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// from `man 5 xcodebuild.xctestrun`
class XCTestRun: Codable {

    /// The top-level TestPlan dictionary contains metadata about the test plan
    /// which was used to construct this xctestrun file. It is provided for
    /// informational purposes and to allow distinguishing between xctestrun
    /// files if multiple were generated from a single scheme. The keys in this
    /// dictionary are not used when performing tests.
    var TestPlan: TestPlan
    class TestPlan: Codable {
        /// The name of the test plan this xctestrun file was generated from.
        var Name: String

        /// Whether the test plan this xctestrun file was generated from is the
        /// default in the scheme.
        var IsDefault: Bool
    }

    /// The top-level TestConfigurations array contains the list of test
    /// configurations to use when testing. Each entry is a dictionary
    /// containing metadata and a list of test targets to include.
    var TestConfigurations: [TestConfiguration]
    class TestConfiguration: Codable {
        /// The name of the configuration. This name should be unique among the
        /// dictionaries in the TestConfigurations array.
        var Name: String

        /// An array containing the list of test targets to include in the test
        /// configuration. Each test target is a dictionary containing
        /// information about how to test a particular test bundle, and can
        /// contain many different parameters, as described below.
        var TestTargets: [TestTarget]
    }

    class TestTarget: Codable {
        // The following parameters are mandatory during basic commands:

        /// The name of the test target, without the file extension of its build
        /// product.
        var BlueprintName: String

        /// A path to the test bundle to be tested. The xcodebuild tool will
        /// expand the following placeholder strings in the path:
        ///      __TESTROOT__
        ///      __TESTHOST__
        var TestBundlePath: String

        /// A path to the test host. For framework tests, this should be a path
        /// to the xctest command line tool. For application hosted tests, this
        /// should be a path the application host. For UI tests, this should be
        /// a path to the test runner application that the UI test target
        /// produces. The xcodebuild tool will expand the following placeholder
        /// strings in the path:
        ///      __TESTROOT__
        ///      __PLATFORMS__
        var TestHostPath: String

        /// A path to the target application for UI tests. The parameter is
        /// mandatory for UI tests only. The xcodebuild tool will expand the
        /// following placeholder strings in the path:
        ///      __TESTROOT__
        var UITargetAppPath: String?

        // These parameters are optional for all commands:

        /// The environment variables from the scheme test action that
        /// xcodebuild will provide to the test host process.
        var EnvironmentVariables: [String: String]?

        /// The command line arguments from the scheme test action that
        /// xcodebuild will provide to the test host process.
        var CommandLineArguments: [String]?

        /// The environment variables that xcodebuild will provide to the target
        /// application during UI tests.
        var UITargetAppEnvironmentVariables: [String: String]?

        /// The command line arguments that xcodebuild will provide to the
        /// target application during UI tests.
        var UITargetAppCommandLineArguments: [String]?

        /// A path to a performance test baseline that xcodebuild will provide
        /// to the tests. The xcodebuild tool will expand the following
        /// placeholder strings in the path:
        ///      __TESTBUNDLE__
        var BaselinePath: String?

        /// Whether or not a test failure should be reported for performance
        /// test cases which do not have a baseline.
        var TreatMissingBaselinesAsFailures: Bool?

        /// An array of test identifiers that xcodebuild should exclude from the
        /// test run. Identifiers for both Swift and Objective-C tests are:
        ///            Test-Class-Name[/Test-Method-Name]
        /// To exclude all the tests in a class Example.m, the identifier is
        /// just "Example". To exclude one specific test in the class, the
        /// identifier is "Example/testExample".
        var SkipTestIdentifiers: [String]?

        /// An array of test identifiers that xcodebuild should include in the
        /// test run. All other tests will be excluded from the test run. The
        /// format for the identifiers is described above.
        var OnlyTestIdentifiers: [String]?

        /// Whether or not the Main Thread Checker should be enabled for apps
        /// launched during UI tests.
        var UITargetAppMainThreadCheckerEnabled: Bool?

        /// Whether or not localizable strings data should be gathered for apps
        /// launched during UI tests.
        var GatherLocalizableStringsData: Bool?

        /// List of paths to the build products of this target and all of its
        /// dependencies. Used to determine the bundle identifiers for apps
        /// during UI tests.
        var DependentProductPaths: [String]?

        /// The module name of this test target, as specified by the target's
        /// PRODUCT_MODULE_NAME build setting in Xcode.
        var ProductModuleName: String?

        /// How long automatic UI testing screenshots should be kept. Should be
        /// one of the following string values:
        ///
        ///      keepAlways
        ///      Always keep attachments, even for tests that succeed.
        ///
        ///      deleteOnSuccess
        ///      Keep attachments for tests that fail, and discard them for
        ///      tests that succeed.
        ///
        ///      keepNever
        ///      Always discard attachments, regardless of whether the test
        ///      succeeds or fails.
        var SystemAttachmentLifetime: String?

        /// How long custom file attachments should be kept. Should be one of
        /// the string values specified in the SystemAttachmentLifetime section.
        var UserAttachmentLifetime: String?

        /// Whether or not the tests in this test target should be run in
        /// parallel using multiple test runner processes.
        var ParallelizationEnabled: Bool?

        /// The order in which tests should be run. By default, tests are run in
        /// alphabetical order and this field may be omitted, but tests may be
        /// run in a randomized order by specifying this setting with the string
        /// value "random".
        var TestExecutionOrdering: String?

        /// Language identifier code for the language which tests should be run
        /// using.
        var TestLanguage: String?

        /// Region identifier code for the region which tests should be run
        /// using.
        var TestRegion: String?

        // The following are for advanced commands that control how xcodebuild
        // installs test artifacts onto test destinations:

        /// An optional flag to indicate that xcodebuild should look on the
        /// destination for test artifacts. When this flag is set, xcodebuild
        /// will not install test artifacts to the destination during testing.
        /// TestBundlePath, TestHostPath, and UITargetAppPath should be excluded
        /// when this flag is set. Instead, xcodebuild requires the following
        /// parameters.
        var UseDestinationArtifacts: Bool?

        /// A bundle identifier for the test host on the destination. This
        /// parameter is mandatory when UseDestinationArtifacts is set.
        var TestHostBundleIdentifier: String?

        /// A path to the test bundle on the destination. This parameter is
        /// mandatory when UseDestinationArtifacts is set. The xcodebuild tool
        /// will expand the following placeholder strings in the path:
        ///
        ///       __TESTHOST__
        var TestBundleDestinationRelativePath: String?

        /// A bundle identifier for the UI target application on the
        /// destination. This parameter is mandatory when
        /// UseDestinationArtifacts is set.
        var UITargetAppBundleIdentifier: String?

        // This last parameter is mandatory for all-commands and is needed to
        // configure the test host environment:

        /// Additional testing environment variables that xcodebuild will
        /// provide to the TestHostPath process. The xcodebuild tool will expand
        /// the following placeholder strings in the dictionary values:
        ///
        ///      __TESTBUNDLE__
        ///      __TESTHOST__
        ///      __TESTROOT__
        ///      __PLATFORMS__
        ///      __SHAREDFRAMEWORKS__
        var TestingEnvironmentVariables: [String: String]

        // Undocumented
        var ClangProfileDataDirectoryPath: String?
        var IsAppHostedTestBundle: Bool?
        var TestTimeoutsEnabled: Bool?
        var BundleIdentifiersForCrashReportEmphasis: [String]?
        var ToolchainsSettingValue: [String]?
        var IsUITestBundle: Bool?
        var IsXCTRunnerHostedTestBundle: Bool?

    }

     /// The top-level CodeCoverageBuildableInfos array contains the list of
     /// targets for which code coverage information should be gathered while
     /// testing. Each entry is a dictionary containing metadata about the
     /// target. See the description of each field in the dictionary below.
    var CodeCoverageBuildableInfos: [CodeCoverageBuildableInfo]?
    class CodeCoverageBuildableInfo: Codable {
        /// The name of the target's product, including any file extension. For
        /// example, "AppTests.xctest".
        var Name: String

        /// The buildable identifier of the target from the project, formatted
        /// as:
        ///
        ///       <Target-Identifier>:<Buildable-Identifier>
        ///
        /// For example, "123456ABCDEF:primary".
        var BuildableIdentifier: String

        /// Whether or not the target should be included in the code coverage
        /// report.
        var IncludeInReport: Bool

        /// Whether or not the target is a static archive library.
        var IsStatic: Bool

        /// List of file paths to the variants of this target's build product.
        /// The xcodebuild tool will expand the following placeholder strings in
        /// the path:
        ///
        ///       __TESTROOT__
        ///
        /// Although each target for code coverage only has a single binary
        /// build product, this list may contain multiple entries because there
        /// may be multiple test configurations in the xctestrun file (per the
        /// top-level TestConfigurations array) and those configurations may
        /// have resulted in multiple build variants. Thus, each entry in this
        /// list represents a unique variant of the target's build product.
        var ProductPaths: [String]

        /// List of architectures for the variants of this target's build
        /// product.
        ///
        /// Each architecture entry in this list describes the binary build
        /// product at the corresponding index of the ProductPaths array. There
        /// may be multiple entries in this list if the specified test
        /// configurations resulted in multiple build variants, see ProductPaths
        /// for more details.
        var Architectures: [String]

        /// List of file paths of the source files in the target whose code
        /// coverage should be measured. Any prefix which is common to all
        /// entries in this list should be removed from each entry and specified
        /// in the SourceFilesCommonPathPrefix field, so that the entries
        /// consist of only the portion of the file path after the common path
        /// prefix.
        var SourceFiles: [String]

        /// A file path prefix which all the source file entries in SourceFiles
        /// have in common. This prefix is applied to each entry in SourceFiles
        /// to determine the full path of each source file when generating the
        /// code coverage report.
        var SourceFilesCommonPathPrefix: String?

        /// List of identifiers of Xcode toolchains to use when generating the
        /// code coverage report.
        var Toolchains: [String]
    }

    /// The top-level __xctestrun_metadata__ dictionary contains special
    /// metadata about the format of the xctestrun file. It currently contains
    /// only one field:
    var __xctestrun_metadata__: Metadata
    class Metadata: Codable {
        /// The version of the xctestrun file format. Currently equal to 2. This
        /// must be specified in order for xcodebuild to interpret the xctestrun
        /// file correctly for the version indicated.
        var FormatVersion = 2
    }
}
