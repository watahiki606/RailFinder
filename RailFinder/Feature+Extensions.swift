import Turf

extension Feature {
    var stationName: String? {
        if let jsonValue = properties?["N02_005"], case let .string(value) = jsonValue {
            return value
        }
        return nil
    }
}
