import Foundation

enum DataProviderError: Error {
  case noMoreParents
}

class DataProvider {
  var parents = [Parent]()

  func getNextParent() throws -> Parent {
    if (parents.count <= 0) {
      throw DataProviderError.noMoreParents
    }

    return parents.removeFirst()
  }
}
