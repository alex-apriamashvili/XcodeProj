import Basic
import Foundation

public class PBXGroup: PBXFileElement {

    // MARK: - Attributes

    /// Element children.
    public var childrenReferences: [PBXObjectReference]

    // MARK: - Init

    /// Initializes the group with its attributes.
    ///
    /// - Parameters:
    ///   - childrenReferences: group children.
    ///   - sourceTree: group source tree.
    ///   - name: group name.
    ///   - path: group relative path from `sourceTree`, if different than `name`.
    ///   - includeInIndex: should the IDE index the files in the group?
    ///   - wrapsLines: should the IDE wrap lines for files in the group?
    ///   - usesTabs: group uses tabs.
    ///   - indentWidth: the number of positions to indent blocks of code
    ///   - tabWidth: the visual width of tab characters
    public init(childrenReferences: [PBXObjectReference] = [],
                sourceTree: PBXSourceTree? = nil,
                name: String? = nil,
                path: String? = nil,
                includeInIndex: Bool? = nil,
                wrapsLines: Bool? = nil,
                usesTabs: Bool? = nil,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil) {
        self.childrenReferences = childrenReferences
        super.init(sourceTree: sourceTree,
                   path: path,
                   name: name,
                   includeInIndex: includeInIndex,
                   usesTabs: usesTabs,
                   indentWidth: indentWidth,
                   tabWidth: tabWidth,
                   wrapsLines: wrapsLines)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case children
    }

    public required init(from decoder: Decoder) throws {
        let objects = decoder.context.objects
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let childrenReferences: [String] = (try container.decodeIfPresent(.children)) ?? []
        self.childrenReferences = childrenReferences.map({ objectReferenceRepository.getOrCreate(reference: $0, objects: objects) })
        try super.init(from: decoder)
    }

    // MARK: - PlistSerializable

    override func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(type(of: self).isa))
        dictionary["children"] = .array(childrenReferences.map({ (fileReference) -> PlistValue in
            let fileElement: PBXFileElement? = try? fileReference.object()
            return .string(CommentedString(fileReference.value, comment: fileElement?.fileName()))
        }))

        return (key: CommentedString(reference,
                                     comment: name ?? path),
                value: .dictionary(dictionary))
    }
}

// MARK: - Public

/// Options passed when adding new groups.
public struct GroupAddingOptions: OptionSet {
    /// Raw value.
    public let rawValue: Int

    /// Initializes the options with the raw value.
    ///
    /// - Parameter rawValue: raw value.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Create group without reference to folder
    public static let withoutFolder = GroupAddingOptions(rawValue: 1 << 0)
}

public extension PBXGroup {
    /// Returns group with the given name contained in the given parent group.
    ///
    /// - Parameter groupName: group name.
    /// - Returns: group with the given name contained in the given parent group.
    public func group(named name: String) -> PBXGroup? {
        return childrenReferences
            .compactMap({ try? $0.object() as PBXGroup })
            .first(where: { $0.name == name })
    }

    /// Returns the file in the group with the given name.
    ///
    /// - Parameter name: file name.
    /// - Returns: file with the given name contained in the given parent group.
    public func file(named name: String) -> PBXFileReference? {
        return childrenReferences
            .compactMap({ try? $0.object() as PBXFileReference })
            .first(where: { $0.name == name })
    }

    /// Creates a group with the given name and returns it.
    ///
    /// - Parameters:
    ///   - groupName: group name.
    ///   - options: creation options.
    /// - Returns: created groups.
    @discardableResult
    public func addGroup(named groupName: String, options: GroupAddingOptions = []) throws -> [PBXGroup] {
        let objects = try self.objects()
        return groupName.components(separatedBy: "/").reduce(into: [PBXGroup](), { groups, name in
            let group = groups.last ?? self
            let newGroup = PBXGroup(childrenReferences: [], sourceTree: .group, name: name, path: options.contains(.withoutFolder) ? nil : name)
            group.childrenReferences.append(newGroup.reference)
            objects.addObject(newGroup)
            groups.append(newGroup)
        })
    }

    /// Adds file at the give path to the project or returns existing file and its reference.
    ///
    /// - Parameters:
    ///   - filePath: path to the file.
    ///   - sourceTree: file sourceTree, default is `.group`
    ///   - sourceRoot: path to project's source root.
    /// - Returns: new or existing file and its reference.
    @discardableResult
    public func addFile(
        at filePath: AbsolutePath,
        sourceTree: PBXSourceTree = .group,
        sourceRoot: AbsolutePath) throws -> PBXFileReference {
        let projectObjects = try objects()
        guard filePath.exists else {
            throw XcodeprojEditingError.unexistingFile(filePath)
        }
        let groupPath = try fullPath(sourceRoot: sourceRoot)

        if let existingFileReference = try projectObjects.fileReferences.first(where: {
            try filePath == $0.value.fullPath(sourceRoot: sourceRoot)
        }) {
            if !childrenReferences.contains(existingFileReference.key) {
                existingFileReference.value.path = groupPath.flatMap({ filePath.relative(to: $0) })?.asString
                childrenReferences.append(existingFileReference.key)
            }
        }

        let path: String?
        switch sourceTree {
        case .group:
            path = groupPath.map({ filePath.relative(to: $0) })?.asString
        case .sourceRoot:
            path = filePath.relative(to: sourceRoot).asString
        case .absolute:
            path = filePath.asString
        default:
            path = nil
        }
        let fileReference = PBXFileReference(
            sourceTree: sourceTree,
            name: filePath.lastComponent,
            explicitFileType: filePath.extension.flatMap(Xcode.filetype),
            lastKnownFileType: filePath.extension.flatMap(Xcode.filetype),
            path: path
        )
        let reference = projectObjects.addObject(fileReference)
        if !childrenReferences.contains(reference) {
            childrenReferences.append(reference)
        }
        return fileReference
    }
}
