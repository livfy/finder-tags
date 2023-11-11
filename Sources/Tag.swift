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
    var tags: [String] {
        get {
            do {
                var rsrc: AnyObject?
                try self.getResourceValue(&rsrc, forKey: .tagNamesKey)
                if let tagNamesKey = rsrc as? [String] {
                    return tagNamesKey
                }
            } catch {
                print(error)
            }
            return []
        }
        set(tagNames) {
            do {
                try self.setResourceValue(tagNames, forKey: .tagNamesKey)
            } catch {
                print(error)
            }
        }
    }
    
    
    func setTags(_ tagNames: [String]) throws {
        try self.setResourceValue(tagNames, forKey: .tagNamesKey)
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
            let tagNames = inputURL.tags
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
            let tags = inputURL.tags + addOptions.tagNames
            try inputURL.setTags(tags)
            print("Set tags \(inputURL.tags) to \(inputURL.relativeString)")
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
            
            var tags = inputURL.tags
            tags.removeAll(where: { addOptions.tagNames.contains($0) })
            
            try inputURL.setTags(tags)
            print("Removed tags")
            print("Current tags: \(tags)")
        }
    }
}
