extension DataTest {

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButtonDisabledWhenNoEmail : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "23a8da2b-5625-4e9b-98ee-2fb616ab71a1",
                            username:   "1487973751@e50cfd77-71f1-4343-a095-acd15946624d.com",
                            password:   "69d258cd83fe2aee",
                            firstName:  "Josh",
                            lastName:   "Cruickshank",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
