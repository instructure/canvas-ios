extension DataTest {

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoPassword : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "3bcc7e87-86e7-419d-92a8-9200016d91fd",
                            username:   "1487973746@1890780e-4a3c-47b8-bffa-5dd0abf04b95.com",
                            password:   "65a614e0c28258a1",
                            firstName:  "Reina",
                            lastName:   "Gibson",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
