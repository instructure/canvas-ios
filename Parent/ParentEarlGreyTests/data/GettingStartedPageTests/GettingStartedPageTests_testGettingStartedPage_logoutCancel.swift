extension DataTest {

  class GettingStartedPageTests_testGettingStartedPage_logoutCancel : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "40a83262-c0c0-4bea-9d39-f6c36c7b3760",
                            username:   "1487973750@2d647629-eae5-4503-b64a-2374cf71ce21.com",
                            password:   "ba6867aae9e8667f",
                            firstName:  "Domenick",
                            lastName:   "Dach",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
