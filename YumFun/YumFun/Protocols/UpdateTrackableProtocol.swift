//
//  UpdateTrackableProtocol.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Not used for now.
protocol UpdateTrackable {
    var lastUpdated: Timestamp? { get set }
}
