//
//  DataModel_importingURLs.swift
//  Images-LectureDevelopment
//
//  Created by Owen Hildreth on 3/5/24.
//

import Foundation



// MARK: - Importing URLs
extension DataController {
    
    // UPDATE to call the DataModelDelegate to let it know how the data model has changed
    func importURLs(_ urls: [URL], intoNode parentNode: Node?) throws  {
        // No need to do anything if there aren't any URLs in the array
        if urls.isEmpty {throw ImportError.noURLsToImport}
        
        // Import Files first because we want to exit scope if the user is trying to import a
        let files = urls.filter( { !$0.isDirectory})
        

        if files.count != 0 && parentNode == nil {
            throw ImportError.cannotImportFileWithoutANode
        }
        
        // ADD
        var newDataItems: [DataItem] = []
        
        // UPDATE
        if let parentNode {
            for nextFile in files {
                // UPDATE
                if let newImageItem = importFile(nextFile, intoNode: parentNode) {
                    newDataItems.append(newImageItem)
                }
            }
        }
        
        
        let directories = urls.filter( { $0.isDirectory } )
        
        // ADD
        var newNodes: [Node] = []
        
        for nextDirectory in directories {
            // UPDATE
            if let newNode = importDirectory(nextDirectory, intoNode: parentNode) {
                newNodes.append(newNode)
            }
        }
        
        fetchData()
        
        // ADD
        delegate?.newData(nodes: newNodes, andImages: newDataItems)
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
        let newNode = Node(url: url, parent: parentNode)
        
        modelContext.insert(newNode)
        
        if let parentNode {
            if parentNode.subNodes != nil {
                parentNode.subNodes?.append(newNode)
            } else {
                parentNode.subNodes = []
                parentNode.subNodes?.append(newNode)
            }
        }
        
        
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
                case .fileDoesNotExist:
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
        
        // modelContext is no longer optional.
        // REMOVE
        // guard let localModelContext = modelContext else {return}
        
        // Check that the url exists and it is a file
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: url.path) else {
            print("File does not exist at: \(url)")
            
            // UPDATE
            return nil
        }
        
        
        if url.isDirectory {
            print("Trying to add a url as an image")
            
            // UPDATE
            return nil
        }
        
        
        guard let allowedExtensions = UserDefaults.standard.object(forKey: UserDefaults.allowedImageFileExtensions) as? [String] else {
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
        
        let newItem = DataItem(url: url, node: parentNode)
        
        modelContext.insert(newItem)
        
        newItem.node = parentNode
        
        
        // ADD
        return newItem
    }
}






