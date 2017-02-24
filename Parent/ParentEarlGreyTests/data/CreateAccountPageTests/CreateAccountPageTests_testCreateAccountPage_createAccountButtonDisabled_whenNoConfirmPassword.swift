extension DataTest {

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoConfirmPassword : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "70767e9d-18ab-4f64-a5e9-7bcff5ea22f8",
                            username:   "1487973746@5bb29ccc-3051-4f51-a2ea-2ba41d98d49d.com",
                            password:   "0d03f433db36c6f8",
                            firstName:  "Stefanie",
                            lastName:   "Lindgren",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
