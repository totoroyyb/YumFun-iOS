//
//  Notifiable.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/27.
//

import Foundation

@propertyWrapper
struct Notifiable<T: Codable>: Codable {
    var value: T
    
    let documentId: String?
    let key: String
    
    init(wrappedValue: T, _ key: String, _ documentId: String?) {
        self.value = wrappedValue
        self.key = key
        self.documentId = documentId
    }
    
    var wrappedValue: T {
        get { value }
        set {
            guard let validId = documentId,
                  let validNewData = try? newValue.toFirebaseDict() else {
                print("Failed to parse data or get valid document id.")
                return
            }
            
            Recipe.update(named: validId, with: [key: validNewData]) { (err) in
                if let err = err {
                    print("Failed to update value: \(err)")
                }
            }
        }
    }
}

@propertyWrapper struct Capitalized: Codable {
    var wrappedValue: String {
        didSet { wrappedValue = wrappedValue.capitalized }
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.capitalized
    }
}
