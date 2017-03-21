struct Parent {
    let parentId: String
    let username: String
    let password: String
    let firstName: String
    let lastName: String
    let students: [CanvasUser]
    let thresholds: [AlertThreshold]
    let alerts: [Alert]
}
