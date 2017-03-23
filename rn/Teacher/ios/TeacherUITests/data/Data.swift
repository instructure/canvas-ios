class Data : DataUtil {

  static func getNextTeacher<T>(_ testClass:T, _ testMethod:String = #function) -> CanvasUser {
    let data = try! getData(testClass, testMethod)
    let teacher = try! data.getNextTeacher()

    return teacher
  }

  static func getNextCourse<T>(_ testClass:T, _ testMethod:String = #function) -> Course {
    let data = try! getData(testClass, testMethod)
    let course = try! data.getNextCourse()

    return course
  }

  static func getAllCourses<T> (_ testClass:T, _ testMethod:String = #function) -> [Course] {
    let data = try! getData(testClass, testMethod)
    let allCourses = try! data.getAllCourses()

    return allCourses
  }

  static func getNextCourse<T>(favorite: Int, _ testClass:T, _ testMethod:String = #function) -> Course {
    let data = try! getData(testClass, testMethod)
    let course = try! data.getNextCourse(favorite: favorite)

    return course
  }

  static func getAllFavoriteCourses<T> (_ testClass:T, _ testMethod:String = #function) -> [Course] {
    let data = try! getData(testClass, testMethod)
    let allCourses = try! data.getAllFavoriteCourses()

    return allCourses
  }
}

// name space for tests
enum DataTest { }
