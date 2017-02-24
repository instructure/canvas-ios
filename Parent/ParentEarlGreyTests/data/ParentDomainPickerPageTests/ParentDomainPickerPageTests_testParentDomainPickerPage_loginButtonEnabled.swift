extension DataTest {

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButtonEnabled : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "11724a6b-3d3e-4341-aad6-a9917c0ea7bc",
                            username:   "1487973751@d4014674-a782-42c4-a42a-5a7d7632a17a.com",
                            password:   "2cf0fba68dcfe43c",
                            firstName:  "Zora",
                            lastName:   "Legros",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
