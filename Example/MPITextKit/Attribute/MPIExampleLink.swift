//
//  MPIExampleLink.swift
//  MPITextKit_Example
//
//  Created by Tpphha on 2020/4/23.
//  Copyright © 2020 美图网. All rights reserved.
//

import UIKit
import MPITextKit

public enum MPIExampleLinkType: Int, CustomDebugStringConvertible {
    case unknown
    case url
    case hashtag
    case mention
    
    public var debugDescription: String {
        get {
            switch self {
                case .unknown:
                    return "unknown"
                case .url:
                    return "url"
                case .hashtag:
                    return "hashtag"
                case .mention:
                    return "mention"
            }
        }
    }
}

public class MPIExampleLink: MPITextLink {
     
    var linkType: MPIExampleLinkType
    
    override init() {
        self.linkType = .unknown
        super.init()
    }
    
    public override var hash: Int {
        get {
//            return super.hash ^ NSNumber.init(value: self.linkType.rawValue).hash
            var hasher = Hasher.init()
            hasher.combine(super.hash)
            hasher.combine(self.linkType)
            let hash = hasher.finalize()
            return hash
        }
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if !super.isEqual(object) {
            return false
        }

        guard let other = object as! MPIExampleLink? else {
            return false
        }

        return self.linkType == other.linkType
    }
    
}
