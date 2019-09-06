import Foundation
@testable import Parent

extension APIAlertThreshold {
    public static func make(
    	id: String = "<id>",
    	observer_id: String = "<observerID>",
    	user_id: String = "<user_id>",
    	alert_type: String = "<alert_type>",
    	threshold: String? = "<threshold>"
    ) -> APIAlertThreshold {
        return APIAlertThreshold(
			id: id,
			observer_id: observer_id,
			user_id: user_id,
			alert_type: alert_type,
			threshold: threshold
        )
    }
}
