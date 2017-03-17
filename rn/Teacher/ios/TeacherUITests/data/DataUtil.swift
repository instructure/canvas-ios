class DataUtil {

  enum DataUtil: Error {
    case testNameMissingFromDataMap
  }

  static func getData<T>(_ testClass:T, _ testMethod:String = #function) throws -> DataProvider {
    let testName = "\(type(of: testClass)).\(testMethod)"

    let testData = DataMap.testDataMap[testName]

    if testData == nil {
      throw DataUtil.testNameMissingFromDataMap
    }

    return testData as! DataProvider
  }
}
