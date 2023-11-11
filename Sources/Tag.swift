import ArgumentParser
import Foundation

enum TagColor: Int {
    case none
    case grey
    case green
    case purple
    case blue
    case yellow
    case red
    case orange
}

func color(of tagName: String) -> TagColor {
    TagColor.none
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

@main
struct Tag: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for managing finder tags",
        subcommands: [List.self, Add.self, Remove.self],
        defaultSubcommand: List.self)
}

extension Tag {
    struct Options: ParsableArguments {
        @Argument(help: "Path")
        var path: String
    }
    
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "List tags.")
        @OptionGroup var options: Tag.Options
        
        mutating func run() throws {
            let inputURL = NSURL(fileURLWithPath: options.path)
            let tagNames = try inputURL.getTags()
            print(tagNames)
        }
    }
    
    struct Add: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Add tags.")
        
        struct Options: ParsableArguments {
            @Argument(help: "List of tags to add.")
            var tagNames: [String]
        }
        
        @OptionGroup var tagOptions: Tag.Options
        @OptionGroup var addOptions: Add.Options
        
        mutating func run() throws {
            let inputURL = NSURL(fileURLWithPath: tagOptions.path)
            // TODO: Avoid adding duplicate tags
            let currentTags = try inputURL.getTags()
            let newTags = currentTags + addOptions.tagNames

            try inputURL.setTags(newTags)
            print("Set tags \(newTags) to \(inputURL.relativeString)")
        }
    }
    
    struct Remove: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Remove tags.")
        
        struct Options: ParsableArguments {
            @Argument(help: "List of tags to remove.")
            var tagNames: [String]
        }
        
        @OptionGroup var tagOptions: Tag.Options
        @OptionGroup var addOptions: Add.Options
        
        mutating func run() throws {
            let inputURL = NSURL(fileURLWithPath: tagOptions.path)
            
            var tags = try inputURL.getTags()
            tags.removeAll(where: { addOptions.tagNames.contains($0) })
            
            try inputURL.setTags(tags)
            print("Removed tags")
            print("Current tags: \(tags)")
        }
    }
}
