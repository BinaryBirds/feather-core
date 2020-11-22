//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 11. 20..
//

public extension Application {
    
    struct Config {

        fileprivate struct KeyValueStorage: Codable {
            
            static var url: URL { URL(fileURLWithPath: Application.Paths.resources + "config.json") }

            static var current: [String: String] {
                do {
                    let data = try Data(contentsOf: url)
                    return try JSONDecoder().decode([String: String].self, from: data)
                }
                catch {
                    return [:]
                }
            }

            static func save(_ dict: [String: String]) {
                do {
                    let data = try JSONEncoder().encode(dict)
                    try data.write(to: Self.url)
                }
                catch {
                    fatalError(error.localizedDescription)
                }
            }
        }

        public static func get(_ key: String) -> String? {
            return KeyValueStorage.current[key]
        }

        public static func set(_ key: String, value: String) {
            var dict = KeyValueStorage.current
            dict[key] = value
            KeyValueStorage.save(dict)
        }

        public static func unset(_ key: String) {
            var dict = KeyValueStorage.current
            dict.removeValue(forKey: key)
            KeyValueStorage.save(dict)
        }
        
        public static var timezone: TimeZone {
            if let tzValue = Application.Config.get("site.timezone"), let tz = TimeZone(identifier: tzValue) {
                return tz
            }
            return .autoupdatingCurrent
        }

        public static var locale: Locale {
            if let localeValue = Application.Config.get("site.locale") {
                return Locale(identifier: localeValue)
            }
            return .autoupdatingCurrent
        }
        
        public static var clientlocale: Bool {
            if let localeValue = Application.Config.get("site.clientlocale"), let usebrowswerlocale = Bool(localeValue) {
                return usebrowswerlocale
            }
            return false
        }
        
        public static func dateFormatter(dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> DateFormatter {
            let formatter = DateFormatter()
            formatter.timeZone = Application.Config.timezone
            formatter.locale =  Application.Config.locale
            formatter.dateStyle = dateStyle
            formatter.timeStyle = timeStyle
            return formatter
        }
    }
}
