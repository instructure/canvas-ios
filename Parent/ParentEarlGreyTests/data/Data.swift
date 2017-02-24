class Data : DataUtil {

  static func getNextParent<T>(_ testClass:T, _ testMethod:String = #function) -> Parent{
    let data = try! getData(testClass, testMethod)

    let parent = try! data.getNextParent()

    return parent
  }
}

// name space for tests
enum DataTest { }
