import ArgumentParser
import Foundation

@main
struct Tag: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for managing finder tags",
        subcommands: [List.self, Add.self, Remove.self],
        defaultSubcommand: Add.self)
}

extension Tag {
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "List tags for a file or folder.")
        @Option(name: [.customShort("p"), .long], help: "Path to a folder or file")
        var path: String?
        
        mutating func run() throws {
            let inputURL = NSURL(fileURLWithPath: path ?? FileManager.default.currentDirectoryPath)
            let tagNames = try inputURL.getTags()
            if (tagNames.isEmpty) {
                print("\"\(inputURL.lastPathComponent ?? "")\" has no tags.")
            } else {
                print(tagNames.joined(separator: ", "))
            }
        }
    }
    
    struct Add: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Add tags to a file or folder.")
        
        @Option(name: [.short, .customLong("tag")], help: "List of tags.")
        var tagNames: [String]

        @Option(name: [.customShort("p"), .long], help: "Path to a folder for file")
        var path: String?
        
        mutating func run() throws {
            let inputURL = NSURL(fileURLWithPath: path ?? FileManager.default.currentDirectoryPath)
            
            var tags = try inputURL.getTags()

            // Avoid adding duplicate tags
            for tag in tagNames {
                if (!tags.contains(tag)) {
                    tags.append(tag)
                }
            }

            try inputURL.setTags(tags)
            print("Added \(tagNames.joined(separator: ", ")) tag(s) to \"\(inputURL.lastPathComponent ?? "")\".")
        }
    }
    
    struct Remove: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Remove tags from a file or folder.")
        @Option(name: [.short, .customLong("tag")], help: "List of tags.")
        var tagNames: [String]

        @Option(name: [.customShort("p"), .long], help: "Path to a folder for file")
        var path: String?
        
        mutating func run() throws {
            let inputURL = NSURL(fileURLWithPath: path ?? FileManager.default.currentDirectoryPath)
            
            var tags = try inputURL.getTags()
            // Only remove tags that exist
            tags.removeAll(where: { tagNames.contains($0) })
            
            try inputURL.setTags(tags)
            print("Removed \(tagNames.joined(separator: ", ")) tag(s) from \"\(inputURL.lastPathComponent ?? "")\".")
        }
    }
}

extension NSURL {
    func setTags(_ tagNames: [String]) throws {
        try self.setResourceValue(tagNames, forKey: .tagNamesKey)
    }

    func getTags() throws -> [String] {
        let attributes = try self.resourceValues(forKeys: [.tagNamesKey])
        let tagNames = attributes.first?.value as? [String]
        return tagNames ?? [];
    }
}
