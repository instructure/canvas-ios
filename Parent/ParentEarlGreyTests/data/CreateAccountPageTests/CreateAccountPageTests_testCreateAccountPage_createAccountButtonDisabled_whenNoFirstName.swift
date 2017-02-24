extension DataTest {

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoFirstName : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "9d5b2e87-8765-45c7-813d-5109049e21d2",
                            username:   "1487973745@64ea90e8-9036-401f-8b26-2ad9d256777b.com",
                            password:   "6c310f66759d7992",
                            firstName:  "Zita",
                            lastName:   "Blick",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
