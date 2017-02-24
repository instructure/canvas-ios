extension DataTest {

  class SettingsPageTests_testSettingsPage_displaysHelpMenu : DataProvider {
    override init() {
      super.init()

      var students = [CanvasUser]()
      students.append(CanvasUser(
        id:        7901562,
        domain:   "mobileqa.test.instructure.com",
        loginId:  "1487973754@40d4dafc-6c6c-4310-903b-a717a81389ac.com",
        password: "2771952c15aa7538",
        name:     "Meredith Runolfsson"))

      parents.append(Parent(parentId: "9cb66078-b9b8-4eba-aa16-032396f3a4f5",
                            username:   "1487973753@f7d55b5d-6c07-4b8e-b05b-a5752e3169f3.com",
                            password:   "4df2ac9f36083a27",
                            firstName:  "London",
                            lastName:   "Dickinson",
                            students:   [students[0]],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
