//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    var isOK: Bool { statusCode == Self.OK_200 }
}
