extension DataTest {

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButton : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "14e84d7d-1220-4a7a-961b-269f80fee697",
                            username:   "1487973751@8434bd6e-96f7-40d4-bd59-464d0acb7fb0.com",
                            password:   "ce7e4e1cbb94745a",
                            firstName:  "Ruby",
                            lastName:   "Legros",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
