//
//  DataController_NewObjects.swift
//  Graphs
//
//  Created by Owen Hildreth on 6/28/24.
//  Copyright © 2024 Owen Hildreth. All rights reserved.
//

import Foundation
import SwiftData
import OSLog

extension DataController {
    
  
    
    
    // MARK: - Importing General URLs
    func importURLs(_ urls: [URL], intoNode parentNode: Node?) throws  {
        
        
        
        // No need to do anything if there aren't any URLs in the array
        if urls.isEmpty {throw ImportError.noURLsToImport}
        
        
        // Get the contenst of the original URL and sort into directories and files
        var directories: [URL] = []
        var files: [URL] = []
        var graphURLs: [URL] = []
        var parserURLs: [URL] = []
        
        for nextURL in urls {
            let type = URL.URLType(withURL: nextURL)
            
            switch type {
            case .dgraph: graphURLs.append(nextURL)
            case .gparser: parserURLs.append(nextURL)
            case .directory: directories.append(nextURL)
            case .file: files.append(nextURL)
            case .fileOrDirectoryDoesNotExist: continue
            }
        }
        
        /*
         if files.count != 0 && parentNode == nil {
             throw ImportError.cannotImportFileWithoutANode
         }
         */
        
        
        var newDataItems: [DataItem] = []
        
        var targetNode: Node? = nil
        
        if parentNode != nil {
            targetNode = parentNode
        } else if selectedNodes.count == 1 {
            targetNode = selectedNodes.first
        }
        
        // Data Items must be imported into a node.
        if let targetNode  {
            for nextFile in files {
                if let newDataItem = importFile(nextFile, intoNode: targetNode) {
                    newDataItems.append(newDataItem)
                }
            }
        }
        
        
        
        var newNodes: [Node] = []
        
        for nextDirectory in directories {
            // UPDATE
            if let newNode = importDirectory(nextDirectory, intoNode: parentNode) {
                newNodes.append(newNode)
            }
        }
        
        
        var newGraphTemplates: [GraphTemplate] = []
        for nextGraphURL in graphURLs {
            if let newGraphTemplate = importGraphTemplate(withURL: nextGraphURL, intoNode: targetNode) {
                newGraphTemplates.append(newGraphTemplate)
            }
        }
        
        
        var newParsers: [ParserSettings] = []
        for nextParserURL in parserURLs {
            
            if let newParser = importParser(from: nextParserURL, intoNode: targetNode)  {
                newParsers.append(newParser)
            }
        }
        
        fetchData()
        
        delegate?.newObjects(nodes: newNodes, dataItems: newDataItems, graphTemplates: newGraphTemplates, parserSettings: newParsers)
    }
    
    
    private func importDirectory(_ url: URL, intoNode parentNode: Node?) -> Node? {
        
        // Check that url exists and is a directory
        let fm = FileManager.default
        var isDir = ObjCBool(false)
        
        
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else {
            
            Logger.dataController.info("File does not exist")
            return nil
        }

        
        let type = URL.URLType(withURL: url)
        
        if type == .file {
            Logger.dataController.info("Error.  importDirectory should only be seeing directories\n\(url)\n is not a directory")
            return nil
        }
        
        // Create Node and Insert into context
        let newNode = Node(url: url)
        
        modelContext.insert(newNode)
        
        newNode.postModelContextInsertInitialization(parentNode)
        
        
        /*
         // Get the contenst of the original URL and sort into directories and files
         var subdirectories: [URL] = []
         var files: [URL] = []
         var graphTemplates: [URL] = []
         var parseFiles: [URL] = []
         
         
         if let contentURLs = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey]) {
             for nextURL in contentURLs {
                 
                 let nextType = URL.URLType(withURL: nextURL)
                 
                 switch nextType {
                 case .directory:
                     subdirectories.append(nextURL)
                 case .file:
                     files.append(nextURL)
                 case .dgraph: graphTemplates.append(nextURL)
                 case .gparser: parseFiles.append(nextURL)
                 case .fileOrDirectoryDoesNotExist:
                     continue
                 }
             }
         }
         
         
         for nextGraphTemplateURL in graphTemplates {
             _ = self.importGraphTemplate(withURL: nextGraphTemplateURL, intoNode: newNode)
         }
         
         for nextParerURL in parseFiles {
             _ = self.importParser(from: nextParerURL, intoNode: newNode)
         }
         
         // Add any files directly owned by the directory into the new Node
         for nextFile in files {
             _ = self.importFile(nextFile, intoNode: newNode)
         }
         
         
         // Recusively transform any subdirectores into subnodes
         for nextDirectory in subdirectories {
             _ = self.importDirectory(nextDirectory, intoNode: newNode)
         }
         */
        
        
        if let contentURLs = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey]) {
            try? self.importURLs(contentURLs, intoNode: newNode)
        }
        
        
        
        return newNode
    }
    
    
    private func importFile(_ url: URL, intoNode parentNode: Node) -> DataItem? {
        
        // Check that the url exists and it is a file
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: url.path) else {
            Logger.dataController.info("importFile: File does not exist at: \(url)")
            return nil
        }
        
        if url.urlType != .file {
            Logger.dataController.info("importFile Error: trying to import: \(url) as a DataItem")
            return nil
        }
        
        
        
        guard let allowedExtensions = UserDefaults.standard.object(forKey: UserDefaults.allowedDataFileExtensions) as? [String] else {
            Logger.dataController.info("\(url.pathExtension) is not an allowed extensions")
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
 
        delegate?.newObjects(nodes: [newNode], dataItems: [], graphTemplates: [], parserSettings: [])
    }
    
    
    // MARK: - Graph Template
    func importGraphTemplate(withURL url: URL, intoNode node: Node? = nil) -> GraphTemplate? {
        
        guard let newGraphTemplate = GraphTemplate(url: url) else { return nil}
       
        modelContext.insert(newGraphTemplate)
        
        newGraphTemplate.postModelContextInsertInitialization(node)
        
        fetchGraphTemplates()
                
        delegate?.newGraphTemplate(newGraphTemplate)
        
        return newGraphTemplate
    }
    
    
    
    
    
    
    // MARK: - ParserSettings
    func createNewParserSetting(intoNode node: Node? = nil) -> ParserSettings {
        let newParserSettings = ParserSettings()
        
        modelContext.insert(newParserSettings)
        
        newParserSettings.postModelContextInsertInitialization(node)
        
        fetchParserSettings()
        
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
            
            fetchParserSettings()
            
            delegate?.newParserSetting(newParserSettings)
            
            return newParserSettings
            
        } catch  {
            Logger.dataController.info("\(error)")
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
        
        fetchGraphTemplates()
        
        delegate?.newGraphTemplate(duplicateGraphTemplate)
        
        return duplicateGraphTemplate
    }
    
    
    func duplicate(_ parserSettings: ParserSettings) -> ParserSettings {
        
        var staticSettings = parserSettings.parserSettingsStatic
        
        staticSettings.localID = UUID()
        
        staticSettings.name += " - Copy"
        
        let duplicatedParserSettings = ParserSettings(from: staticSettings)
        
        modelContext.insert(duplicatedParserSettings)
        
        fetchParserSettings()
        
        delegate?.newParserSetting(duplicatedParserSettings)
        
        return duplicatedParserSettings
    }
}
