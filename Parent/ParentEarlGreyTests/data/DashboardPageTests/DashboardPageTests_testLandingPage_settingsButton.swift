extension DataTest {

  class DashboardPageTests_testLandingPage_settingsButton : DataProvider {
    override init() {
      super.init()

      var students = [CanvasUser]()
      students.append(CanvasUser(
        id:        7901560,
        domain:   "mobileqa.test.instructure.com",
        loginId:  "1487973747@7c11c3d6-2a32-4526-a21b-bf2e4748f0d2.com",
        password: "cef9af094668a09c",
        name:     "Paige Lebsack"))

      parents.append(Parent(parentId: "794f6149-b60e-4bf8-8daf-b11344909787",
                            username:   "1487973746@55d31c62-ad1c-408c-9923-ccfdf6ad5d7e.com",
                            password:   "976b81b4119fb38b",
                            firstName:  "Jon",
                            lastName:   "Stark",
                            students:   [students[0]],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
