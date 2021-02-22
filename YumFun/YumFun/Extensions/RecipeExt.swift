//
//  CodableExt.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import Foundation
import FirebaseFirestore

extension Encodable {
    /**
     Parse a `Recipe` object to `Data` with `JSONEncoder`
     !!! Do not use this parse function to parse data and push to the cloud. This function is just for local testing purpose. Also Do not use this function to parse a object from Firestore,
     
     ## Formatter Default Settings
        - Pretty Print is enabled
        - Date encode uses `ISO8601`
     
     ## Note
     You need to handle the exception.
     */
    func toJson() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    /**
     Parse a `Recipe` object to a dictionary representation
     !!! Do not use this parse function to parse data and push to the cloud. This function is just for local testing purpose.
     */
    func toDict() throws -> [String : Any]? {
        let jsonData = try self.toJson()
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        return jsonObject as? [String : Any]
    }
    
    /**
     Parse a `Recipe` object to a dictionary representation which Firestore can interpret.
     */
    func toFirebaseDict() throws -> [String : Any] {
        let encoder = Firestore.Encoder()
        return try encoder.encode(self)
    }
    
    /**
     Parse a `Recipe` object to a json string representation
     !!! Do not use this parse function to parse data and push to the cloud. This function is just for local testing purpose.
     
     ## Note
     This function doesn't throw. If it returns `NIL`, then it means parsing failed. It can be caused by parsing to json data, or parsing from json data to string.
     */
    func toJsonStr() -> String? {
        let jsonData = try? self.toJson()
        
        guard let json = jsonData else {
            print("Failed to parse to json data.")
            return nil
        }
        
        return String(data: json, encoding: .utf8)
    }
}
