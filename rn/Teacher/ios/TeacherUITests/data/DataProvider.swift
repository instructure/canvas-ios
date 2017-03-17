import Foundation

enum DataProviderError: Error {
  case noMoreTeachers
}

class DataProvider {
  var teachers = [CanvasUser]()

  func getNextTeacher() throws -> CanvasUser {
    if (teachers.count <= 0) {
      throw DataProviderError.noMoreTeachers
    }

    return teachers.removeFirst()
  }
}
