//
//  DataController_NewObjects.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Connor Barnes. All rights reserved.
//

import Foundation
import SwiftData

extension DataController {
    
  
    
    
    // MARK: - Importing General URLs
    func importURLs(_ urls: [URL], intoNode parentNode: Node?) throws  {
        // No need to do anything if there aren't any URLs in the array
        if urls.isEmpty {throw ImportError.noURLsToImport}
        
        // Import Files first because we want to exit scope if the user is trying to import a
        let files = urls.filter( { !$0.isDirectory})
        

        if files.count != 0 && parentNode == nil {
            throw ImportError.cannotImportFileWithoutANode
        }
        
        var newDataItems: [DataItem] = []
        
        // Data Items must be imported into a node.
        if let parentNode {
            for nextFile in files {
                if let newDataItem = importFile(nextFile, intoNode: parentNode) {
                    newDataItems.append(newDataItem)
                }
            }
        }
        
        
        let directories = urls.filter( { $0.isDirectory } )
        
        var newNodes: [Node] = []
        
        for nextDirectory in directories {
            // UPDATE
            if let newNode = importDirectory(nextDirectory, intoNode: parentNode) {
                newNodes.append(newNode)
            }
        }
        
        fetchData()
        
        delegate?.newData(nodes: newNodes, andDataItems: newDataItems)
    }
    
    
    private func importDirectory(_ url: URL, intoNode parentNode: Node?) -> Node? {
        
        // Check that url exists and is a director
        let fm = FileManager.default
        var isDir = ObjCBool(false)
        
        
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else {
            print("File does not exist")
            
            // UPDATE
            return nil
        }

        
        let type = URL.URLType(withURL: url)
        
        if type == .file {
            print("Error.  importDirectory should only be seeing directories")
            print("\(url)\n is not a directory")
            
            // UPDATE
            return nil
        }
        
        // Create Node and Insert into context
        let newNode = Node(url: url)
        
        modelContext.insert(newNode)
        
        newNode.postModelContextInsertInitialization(parentNode)
        
        
        // TODO: Cleanup
        // Moved to postModelContextInsertInitialization
        // newNode.setParent(parentNode)
        /*
         if let parentNode {
             if parentNode.subNodes != nil {
                 parentNode.subNodes?.append(newNode)
             } else {
                 parentNode.subNodes = []
                 parentNode.subNodes?.append(newNode)
             }
         }
         */
        
        
        
        // Get the contenst of the original URL and sort into directories and filesg
        var subdirectories: [URL] = []
        var files: [URL] = []
        
        
        if let contentURLs = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey]) {
            for nextURL in contentURLs {
                
                let nextType = URL.URLType(withURL: nextURL)
                
                switch nextType {
                case .directory:
                    subdirectories.append(nextURL)
                case .file:
                    files.append(nextURL)
                case .fileOrDirectoryDoesNotExist:
                    continue
                }
            }
        }
        
        
        // Add any files directly owned by the directory into the new Node
        for nextFile in files {
            _ = self.importFile(nextFile, intoNode: newNode)
        }
        
        
        // Recusively transform any subdirectores into subnodes
        for nextDirectory in subdirectories {
            _ = self.importDirectory(nextDirectory, intoNode: newNode)
        }
        
        
        return newNode
    }
    
    
    private func importFile(_ url: URL, intoNode parentNode: Node) -> DataItem? {
        
        // Check that the url exists and it is a file
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: url.path) else {
            print("File does not exist at: \(url)")
            
            return nil
        }
        
        
        if url.isDirectory {
            print("Trying to add a url as a dataItem")
            
            return nil
        }
        
        
        if url.pathExtension == URL.dataGraphFileExtension {
            _ = importGraphTemplate(withURL: url, intoNode: parentNode)
            return nil
        }
        
        
        if url.pathExtension == URL.parserSettingsFileExtension {
            _ = createNewParserSetting(intoNode: parentNode)
            return nil
        }
        
        
        guard let allowedExtensions = UserDefaults.standard.object(forKey: UserDefaults.allowedDataFileExtensions) as? [String] else {
            print("Error needed, no allowed extensions")
            
            // UPDATE
            return nil
        }
        
        // Make the comparison case insensitive to make it easier on the user when adding file extensions in the Preferences
        if (allowedExtensions.contains(where: {$0.caseInsensitiveCompare(url.pathExtension) == .orderedSame }) == false) {
            // Filetype is not allowed to be imported
            
            // UPDATE
            return nil
        }
        
        let newItem = DataItem(url: url)
        
        modelContext.insert(newItem)
        
        newItem.postModelContextInsertInitialization(parentNode)

        return newItem
    }
    
    
    // MARK: - Adding Nodes
    func createEmptyNode(withParent parent: Node?) {
        let newNode = Node(url: nil)
        
        modelContext.insert(newNode)
        
        newNode.postModelContextInsertInitialization(parent)
        
        try? modelContext.save()
        
         
        fetchData()
 
        delegate?.newData(nodes: [newNode], andDataItems: [])
    }
    
    
    // MARK: - Graph Template
    func importGraphTemplate(withURL url: URL, intoNode node: Node? = nil) -> GraphTemplate? {
        
        guard let newGraphTemplate = GraphTemplate(url: url) else { return nil}
       
        modelContext.insert(newGraphTemplate)
        
        newGraphTemplate.postModelContextInsertInitialization(node)
                
        delegate?.newGraphTemplate(newGraphTemplate)
        
        return newGraphTemplate
    }
    
    
    
    // MARK: - ParserSettings
    func createNewParserSetting(intoNode node: Node? = nil) -> ParserSettings {
        let newParserSettings = ParserSettings()
        
        modelContext.insert(newParserSettings)
        
        newParserSettings.postModelContextInsertInitialization(node)
        
        fetchData()
        
        delegate?.newParserSetting(newParserSettings)
        
        return newParserSettings
    }
    
    
    func importParser(from url: URL, intoNode parentNode: Node?) -> ParserSettings? {
        
        if url.pathExtension != URL.parserSettingsFileExtension {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            let decoder = JSONDecoder()
            
            let newParserSettingsStatic = try decoder.decode(ParserSettingsStatic.self, from: data)
            
            let newParserSettings = ParserSettings(from: newParserSettingsStatic)
            
            modelContext.insert(newParserSettings)
            
            newParserSettings.postModelContextInsertInitialization(parentNode)
            
            fetchData()
            
            delegate?.newParserSetting(newParserSettings)
            
            return newParserSettings
            
        } catch  {
            print(error)
            return nil
        }
    }

}


// MARK: - Duplicating Objects
extension DataController {
    func duplicate(_ graphTemplate: GraphTemplate) -> GraphTemplate? {
        let name = graphTemplate.name + " Copy"
        let url = graphTemplate.url
        
        guard let duplicateGraphTemplate = GraphTemplate(name: name, url: url) else { return nil }
        
        modelContext.insert(duplicateGraphTemplate)
        
        fetchData()
        
        delegate?.newGraphTemplate(duplicateGraphTemplate)
        
        return duplicateGraphTemplate
    }
    
    
    func duplicate(_ parserSettings: ParserSettings) -> ParserSettings? {
        do {
            let encoder = JSONEncoder()
            
            var staticSettings = parserSettings.parserSettingsStatic
            
            staticSettings.localID = UUID()
            
            let transientData = try encoder.encode(staticSettings)
            
            let decoder = JSONDecoder()
            
            let duplicatedParserSettingsStatic = try decoder.decode(ParserSettingsStatic.self, from: transientData)
            
            let duplicatedParserSettings = ParserSettings(from: duplicatedParserSettingsStatic)
            
            modelContext.insert(duplicatedParserSettings)
            
            fetchData()
            
            delegate?.newParserSetting(duplicatedParserSettings)
            
            return duplicatedParserSettings

        } catch  {
            print(error)
            
            return nil
        }
        
    }
}
