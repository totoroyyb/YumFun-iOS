//
//  Error.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/27.
//

import Foundation

// - MARK: ALL ERRORS
fileprivate let currUserNoDataInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: "")
]

fileprivate let failedCompressImageInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to Compress Image", value: "Cannot convert image to data", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Unknow compression error", value: "Cannot convert image to data", comment: "")
]


struct CoreError {
    static let currUserNoDataError = NSError(domain: "FailedToFetchData", code: 0, userInfo: currUserNoDataInfo)

    static let failedCompressImageError = NSError(domain: "FailedToConvertImage", code: 0, userInfo: failedCompressImageInfo)
}
