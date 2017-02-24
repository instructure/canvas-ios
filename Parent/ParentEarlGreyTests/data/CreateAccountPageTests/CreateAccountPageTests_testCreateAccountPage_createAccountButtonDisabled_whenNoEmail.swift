extension DataTest {

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoEmail : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "e7c7c1f3-1f4b-44de-a56b-e812ae066c96",
                            username:   "1487973745@92da4e3e-650b-4de9-bfa4-69238cdc4f49.com",
                            password:   "e3d902268f371f15",
                            firstName:  "May",
                            lastName:   "Jacobs",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
