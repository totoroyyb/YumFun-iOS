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

fileprivate let failedGetRecipeIdInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to get recipe id", value: "Recipe is nil", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to get recipe id", value: "Recipe is nil", comment: "")
]

fileprivate let failedGetSessionIdInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to get collab session id", value: "Session id is nil", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to get collab session id", value: "Session id is nil", comment: "")
]

fileprivate let failedParseInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to parse object into Firebase format", value: "Failed to parse", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to parse object into Firebase format", value: "Failed to parse", comment: "")
]


struct CoreError {
    static let currUserNoDataError = NSError(domain: "FailedToFetchData", code: 0, userInfo: currUserNoDataInfo)

    static let failedCompressImageError = NSError(domain: "FailedToConvertImage", code: 0, userInfo: failedCompressImageInfo)
    
    static let failedGetRecipeIdError = NSError(domain: "FailedGetRecipeId", code: 0, userInfo: failedGetRecipeIdInfo)
    
    static let failedGetSessionIdError = NSError(domain: "FailedGetSessionId", code: 0, userInfo: failedGetSessionIdInfo)
    
    static let failedParseError = NSError(domain: "FailedParse", code: 0, userInfo: failedParseInfo)
}
