extension DataTest {

  class GettingStartedPageTests_testGettingStartedPage_displaysPageObjects : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "92c075c5-775c-40b0-a215-43b3f160f7f5",
                            username:   "1487973749@df2f22e2-dc20-4b74-9de2-834035b9c915.com",
                            password:   "64d9dc8bee410586",
                            firstName:  "Dakota",
                            lastName:   "Wolff",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
