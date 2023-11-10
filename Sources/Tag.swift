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

@main
struct Tag: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for managing finder tags",
        subcommands: [List.self],
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
            let tagNames = try URL(fileURLWithPath: options.path).resourceValues(forKeys: [.tagNamesKey]).tagNames ?? []
            
            for name in tagNames {
                print(name)
            }
        }
    }
}
