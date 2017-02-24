extension DataTest {

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButtonDisabledWhenNoPassword : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "323b47d2-a320-4e89-9098-59f2cec6a309",
                            username:   "1487973750@aefc3d46-5ab9-4860-b2da-533b92e4b8da.com",
                            password:   "a48906a210fa1b68",
                            firstName:  "Emilia",
                            lastName:   "Ziemann",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
