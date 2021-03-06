//
//  YapDatabaseReadTransaction+ChatSecure.swift
//  ChatSecure
//
//  Created by David Chiles on 10/27/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

import Foundation
import YapDatabase.YapDatabaseSecondaryIndex

public extension YapDatabaseReadTransaction {
    
    public func enumerateMessages(id id:String, block:(message:OTRMessageProtocol,stop:UnsafeMutablePointer<ObjCBool>) -> Void) {
        guard let secondaryIndexTransaction = self.ext(DatabaseExtensionName.SecondaryIndexName.name()) as? YapDatabaseSecondaryIndexTransaction else {
            return
        }
        
        let queryString = "Where \(OTRYapDatabseMessageIdSecondaryIndexColumnName) = ?"
        let query = YapDatabaseQuery(string: queryString, parameters: [id])
        
        secondaryIndexTransaction.enumerateKeysMatchingQuery(query) { (collection, key, stop) -> Void in
            if let message = self.objectForKey(key, inCollection: collection) as? OTRMessageProtocol {
                block(message: message, stop: stop)
            }
        }
    }
    
    /** The jid here is the full jid not real jid or nickname */
    public func enumerateRoomOccupants(jid jid:String, block:(occupant:OTRXMPPRoomOccupant, stop:UnsafeMutablePointer<ObjCBool>) -> Void) {
        guard let secondaryIndexTransaction = self.ext(DatabaseExtensionName.SecondaryIndexName.name()) as? YapDatabaseSecondaryIndexTransaction else {
            return
        }
        
        let queryString = "Where \(OTRYapDatabseRoomOccupantJIdSecondaryIndexColumnName) = ?"
        let query = YapDatabaseQuery(string: queryString, parameters: [jid])
        
        secondaryIndexTransaction.enumerateKeysMatchingQuery(query) { (collection, key, stop) -> Void in
            if let occupant = self.objectForKey(key, inCollection: collection) as? OTRXMPPRoomOccupant {
                block(occupant: occupant, stop: stop)
            }
        }
    }
    
    public func numberOfUnreadMessages() -> UInt {
        guard let secondaryIndexTransaction = self.ext(DatabaseExtensionName.SecondaryIndexName.name()) as? YapDatabaseSecondaryIndexTransaction else {
            return 0
        }
        
        let queryString = "Where \(OTRYapDatabaseUnreadMessageSecondaryIndexColumnName) = 0"
        let query = YapDatabaseQuery(string: queryString, parameters: [])
        
        var count:UInt = 0
        secondaryIndexTransaction.getNumberOfRows(&count, matchingQuery: query)
        return count
    }
}