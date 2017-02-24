extension DataTest {

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoLastName : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "9d4ffb21-fbd0-49ff-924c-e8183a2823c3",
                            username:   "1487973745@15f09bde-8c4d-4089-ad7e-ff400e427e66.com",
                            password:   "7b3e441cc59b6918",
                            firstName:  "Alayna",
                            lastName:   "Jacobi",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
