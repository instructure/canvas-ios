extension DataTest {

class DomainPickerTests_testDomainPicker_domainFieldAllowsInput : DataProvider {
  override init() {
    super.init()

        var courses = [
            Course(
                id: 2110209,
                name: "Bachelor of Law c4ab5e7c5cf82b66",
                courseCode: "EG 2305",
                assignments: []) ]

            var favorite_ids = [
                2110209,
        ]

        teachers.append(CanvasUser(
            id: 7918341,
            domain: "mobileqa.test.instructure.com",
            loginId: "1489774682@aa0c7aa6-8c0d-4ed4-89d7-0e04ff19c9f8.com",
            password: "8dccf52bd144df0a",
            name: "Christina Satterfield",
            courses: courses,
            courseFavorites: favorite_ids));
    }
  }
}
