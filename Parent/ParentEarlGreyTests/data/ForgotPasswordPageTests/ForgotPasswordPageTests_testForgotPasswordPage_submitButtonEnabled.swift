extension DataTest {

  class ForgotPasswordPageTests_testForgotPasswordPage_submitButtonEnabled : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "05c55d03-7097-4841-bd6b-025eec6f3dc5",
                            username:   "1487973749@32da05fd-357d-4bbe-a266-8d1fd27ed633.com",
                            password:   "b3f080c615ffd06c",
                            firstName:  "Danny",
                            lastName:   "Schmidt",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
