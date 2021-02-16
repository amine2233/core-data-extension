//
//
//  Created by Amine Bensalah on 16/02/2021.
//

import Foundation

public enum CoreDataStackError: Error {
    case loadResource
    case managerObjectModel
    case migrationUrlNotFound
    case migration(Error)
}
