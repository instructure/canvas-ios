class Data : DataUtil {

  static func getNextTeacher<T>(_ testClass:T, _ testMethod:String = #function) -> CanvasUser {
    let data = try! getData(testClass, testMethod)

    let teacher = try! data.getNextTeacher()

    return teacher
  }
}

// name space for tests
enum DataTest { }
