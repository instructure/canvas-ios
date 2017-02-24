extension DataTest {

  class GettingStartedPageTests_testGettingStartedPage_logout : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "2a5c8048-a092-4ef9-bf94-86e0125e808d",
                            username:   "1487973750@894111bb-59ba-4346-a8c6-b001737a8f84.com",
                            password:   "180f52df39ee0a9e",
                            firstName:  "Lillian",
                            lastName:   "Kuhic",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
