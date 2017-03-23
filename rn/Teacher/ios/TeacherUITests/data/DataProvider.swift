import Foundation

enum DataProviderError: Error {
  case noMoreTeachers
  case noMoreCourses
  case noMoreFavorites
  case favoriteCourseNotFound
}

class DataProvider {
  var teachers = [CanvasUser]()
  var courses = [Course]()
  var favorites = [Int]()

  func getNextTeacher() throws -> CanvasUser {
    if (teachers.count <= 0) {
      throw DataProviderError.noMoreTeachers
    }

    return teachers.removeFirst()
  }

  func getNextCourse() throws -> Course {
    if (courses.count <= 0) {
      throw DataProviderError.noMoreCourses
    }

    return courses.removeFirst()
  }

  func getNextCourse(favorite: Int) throws -> Course {
    if (courses.count <= 0) {
      throw DataProviderError.noMoreCourses
    }

    guard let index = (courses.index {$0.id == favorite}) else {
      throw DataProviderError.favoriteCourseNotFound
    }

    return courses.remove(at: index)
  }

  func getAllCourses() throws -> [Course] {
    if (courses.count <= 0) {
      throw DataProviderError.noMoreCourses
    }

    let allCourses = courses
    courses.removeAll()
    return allCourses
  }

  func getNextFavoriteCourse() throws -> Course {
    if (favorites.count <= 0) {
      throw DataProviderError.noMoreFavorites
    }

    return try! getNextCourse(favorite: favorites.removeFirst())
  }

  func getAllFavoriteCourses() throws -> [Course] {
    if (favorites.count <= 0) {
      throw DataProviderError.noMoreFavorites
    }

    var allCourses = [Course]()
    for favorite in favorites {
      allCourses.append(try! getNextCourse(favorite: favorite))
    }

    favorites.removeAll()
    return allCourses
  }
}
