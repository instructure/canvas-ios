extension DataTest {

  class SettingsPageTests_testSettingsPage_displaysPageObjects : DataProvider {
    override init() {
      super.init()

      var students = [CanvasUser]()
      students.append(CanvasUser(
        id:        7901561,
        domain:   "mobileqa.test.instructure.com",
        loginId:  "1487973752@5e63cd3c-ea75-4ab5-ad00-143ce9864863.com",
        password: "311dbef54542c302",
        name:     "Sage Weimann"))

      parents.append(Parent(parentId: "bb764fad-156f-49ca-8dc7-f1424c64e1b9",
                            username:   "1487973752@20df7a43-1085-4399-a11a-c4ec17424014.com",
                            password:   "b2d4f4bcae69e401",
                            firstName:  "Samson",
                            lastName:   "Lang",
                            students:   [students[0]],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
