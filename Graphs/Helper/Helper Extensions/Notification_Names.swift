//
//  Notification_Names.swift
//  Graphs
//
//  Created by Owen Hildreth on 9/30/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation


extension Notification.Name {
    
    
    /** Notification Name for when the Parser Settings on a Node or Data Item is changed
     
     UserInfo Keys : Values
     - dataItemIDs : [DataItem.ID].  Key to an array of impacted DataItems through their .id property
     - oldParserSettingID : ParserSettings.ID.  Key to the previously used  Parser Settings ID for that Node/DataItem
     - newParserSettingID : ParserSettings.ID.  Key to the  new Parser Settings ID for that Node/DataItem
     **/
    static var parserOnNodeOrDataItemDidChange = Notification.Name("parserOnDataItemDidChange")
    
    
    /** Notification Name for when a property of a Parser Setting Changes
     
     UserInfo Keys : Values
     - parserSettingsIDs : [ParserSettings.ID].  Key to the Parser Settings that was changed.  
     
     */
    
    static var parserSettingPropertyDidChange = Notification.Name("parserSettingPropertyDidChange")
    
    
    /** Notification Name for when the Graph Template on a Node or Data Item is changed
     
     UserInfo Keys : Values
     - dataItemIDs : [DataItem.ID].  Key to an array of impacted DataItems through their .id property
     - oldGraphTemplateID : GraphTemplate.ID.  Key to the previously used  Graph Template ID for that Node/DataItem
     - newGraphTemplateID : GraphTemplate.ID.  Key to the  new Graph Template ID for that Node/DataItem
     */
    static var graphTemplateDidChange = Notification.Name("graphTemplateOnDataItemsDidChange")
    
    
    static var selectedDataItemDidChange = Notification.Name("selectedDataItemDidChange")
    
    static var exportSelectionAsDataGraphFiles = Notification.Name("exportSelectionAsDataGraphFiles")
    
    static var exportParserSettings = Notification.Name("exportParserSettings")
}


extension Notification {
    
    struct UserInfoKey {
        static var dataItemIDs = "dataItemIDs"
        static var nodeIDs = "nodeIDs"
        
        static var graphTemplateIDs = "graphTemplateIDs"
        static var oldGraphTemplateID = "oldGraphTemplateID"
        static var newGraphTemplateID = "newGraphTemplateID"
        
        static var parserSettingsIDs = "parserSettingsIDs"
        static var oldParserSettingLocalID = "oldParserSettingLocalID"
        static var newParserSettingLocalID = "newParserSettingLocalID"
        
        
    }
}
