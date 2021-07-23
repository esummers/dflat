import Foundation
import InflectorKit

@testable import ApolloCodegenLib

extension String {
  func firstLowercased() -> String {
    prefix(1).lowercased() + dropFirst()
  }
  func firstUppercased() -> String {
    prefix(1).uppercased() + dropFirst()
  }
}

// This is a method that mimics https://github.com/blakeembrey/change-case/blob/master/packages/pascal-case/src/index.ts
// https://github.com/apollographql/apollo-tooling/blob/master/packages/apollo-codegen-swift/src/codeGeneration.ts uses
// this method for operation class name, hence, without it, we may end up with mismatch class names.
func pascalCase(input: String) -> String {
  let camelCase1 = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])
  let camelCase2 = try! NSRegularExpression(pattern: "([A-Z])([A-Z][a-z])", options: [])
  let textRange = NSRange(input.startIndex..<input.endIndex, in: input)
  var breakpoints = [String.Index]()
  let camelCase1Matches = camelCase1.matches(in: input, options: [], range: textRange)
  for match in camelCase1Matches {
    let range = Range(match.range(at: 1), in: input)!
    breakpoints.append(range.upperBound)
  }
  let camelCase2Matches = camelCase2.matches(in: input, options: [], range: textRange)
  for match in camelCase2Matches {
    let range = Range(match.range(at: 1), in: input)!
    breakpoints.append(range.upperBound)
  }
  breakpoints.sort(by: <)
  var sequences = [String]()
  for (i, breakpoint) in breakpoints.enumerated() {
    if i == 0 {
      sequences.append(String(input[input.startIndex..<breakpoint]))
    } else {
      sequences.append(String(input[breakpoints[i - 1]..<breakpoint]))
    }
  }
  if let last = breakpoints.last {
    sequences.append(String(input[last..<input.endIndex]))
  } else {
    sequences.append(input)
  }
  let stripCase = try! NSRegularExpression(pattern: "[^A-Za-z0-9]+", options: [])
  // This mimics: https://github.com/blakeembrey/change-case/blob/master/packages/no-case/src/index.ts#L19
  let finalSequences: [String] = sequences.flatMap({ input -> [String] in
    let range = NSRange(input.startIndex..<input.endIndex, in: input)
    let matches = stripCase.matches(in: input, options: [], range: range)
    var substrings = [String]()
    var lastUpperBound: String.Index? = nil
    for match in matches {
      let range = Range(match.range(at: 0), in: input)!
      if let lastUpperBound = lastUpperBound {
        substrings.append(String(input[lastUpperBound..<range.lowerBound]))
      } else {
        substrings.append(String(input[input.startIndex..<range.lowerBound]))
      }
      lastUpperBound = range.upperBound
    }
    if let last = matches.last {
      let range = Range(last.range(at: 0), in: input)!
      substrings.append(String(input[range.upperBound..<input.endIndex]))
    } else {
      substrings.append(input)
    }
    return substrings
  }).filter { $0.count > 0 }
  // This mimics: https://github.com/blakeembrey/change-case/blob/master/packages/pascal-case/src/index.ts#L18
  let composedString = finalSequences.enumerated().map({ (i, sequence) -> String in
    let prefix = sequence.prefix(1)
    let dropFirstLowercased = sequence.dropFirst().lowercased()
    if i > 0 && prefix >= "0" && prefix <= "9" {
      return "_" + prefix + dropFirstLowercased
    }
    return prefix.uppercased() + dropFirstLowercased
  }).joined(separator: "")
  // Final part, mimics: https://github.com/apollographql/apollo-tooling/blob/master/packages/apollo-codegen-swift/src/helpers.ts#L420
  // Skips prefix _ and suffix _ (don't remove these)
  var finalComposedString = composedString
  if let firstIndex = (input.firstIndex { $0 != "_" }) {
    finalComposedString = input[input.startIndex..<firstIndex] + finalComposedString
  }
  if let lastIndex = (input.lastIndex { $0 != "_" }) {
    finalComposedString += input[input.index(after: lastIndex)..<input.endIndex]
  }
  return finalComposedString
}

let bundle = Bundle(for: ApolloCodegenFrontend.self)
if let resourceUrl = bundle.resourceURL,
  let bazelResourceJsUrl = bundle.url(
    forResource: "ApolloCodegenFrontend.bundle", withExtension: "js",
    subdirectory: "codegen.runfiles/apollo-ios/Sources/ApolloCodegenLib/Frontend/dist")
{
  let standardDistUrl = resourceUrl.appendingPathComponent("dist")
  try? FileManager.default.createDirectory(at: standardDistUrl, withIntermediateDirectories: true)
  let standardJsUrl = standardDistUrl.appendingPathComponent("ApolloCodegenFrontend.bundle.js")
  try? FileManager.default.linkItem(at: bazelResourceJsUrl, to: standardJsUrl)
}

let codegenFrontend = try ApolloCodegenFrontend()

let schemaPath = CommandLine.arguments[1]
var documentPaths = [String]()
var entities = [String]()
var outputDir: String? = nil
var primaryKey: String = "id"
enum CommandOptions {
  case document
  case entity
  case output
  case primaryKey
}
var options = CommandOptions.document
for argument in CommandLine.arguments[2...] {
  if argument == "--entity" {
    options = .entity
  } else if argument == "-o" {
    options = .output
  } else if argument == "--primary-key" {
    options = .primaryKey
  } else {
    switch options {
    case .document:
      documentPaths.append(argument)
    case .entity:
      entities.append(argument)
    case .output:
      outputDir = argument
    case .primaryKey:
      primaryKey = argument
    }
  }
}

let schema = try codegenFrontend.loadSchema(from: URL(fileURLWithPath: schemaPath))

var documents = [GraphQLDocument]()
for documentPath in documentPaths {
  let document = try codegenFrontend.parseDocument(from: URL(fileURLWithPath: documentPath))
  documents.append(document)
}

let document = try codegenFrontend.mergeDocuments(documents)

let validationErrors = try codegenFrontend.validateDocument(schema: schema, document: document)
guard validationErrors.isEmpty else {
  print(validationErrors)
  exit(-1)
}

// Record available fields from the queries. This will help to cull any fields that exists in the schema but not
// used anywhere in the query.

func findObjectFields(
  objectFields: inout [String: Set<String>], entities: Set<String>,
  selectionSet: CompilationResult.SelectionSet, marked: Bool
) {
  let typeName = selectionSet.parentType.name
  let marked = marked || entities.contains(typeName)
  for selection in selectionSet.selections {
    switch selection {
    case let .field(field):
      if marked {
        objectFields[typeName, default: Set<String>()].insert(field.name)
      }
      if let selectionSet = field.selectionSet {
        findObjectFields(
          objectFields: &objectFields, entities: entities, selectionSet: selectionSet,
          marked: marked)
      }
    case let .inlineFragment(inlineFragment):
      findObjectFields(
        objectFields: &objectFields, entities: entities, selectionSet: inlineFragment.selectionSet,
        marked: marked)
    case let .fragmentSpread(fragmentSpread):
      findObjectFields(
        objectFields: &objectFields, entities: entities,
        selectionSet: fragmentSpread.fragment.selectionSet, marked: marked)
      break
    }
  }
}

var objectFields = [String: Set<String>]()
let compilationResult = try codegenFrontend.compile(schema: schema, document: document)
for operation in compilationResult.operations {
  findObjectFields(
    objectFields: &objectFields, entities: Set(entities), selectionSet: operation.selectionSet,
    marked: false)
}

func flatbuffersType(_ graphQLType: GraphQLType, rootType: GraphQLNamedType) -> String {
  let scalarTypes: [String: String] = [
    "Int": "int", "Float": "double", "Boolean": "bool", "ID": "string", "String": "string",
  ]
  switch graphQLType {
  case .named(let namedType):
    if namedType == rootType {
      return "string"
    } else {
      return scalarTypes[namedType.name] ?? namedType.name
    }
  case .nonNull(let graphQLType):
    return flatbuffersType(graphQLType, rootType: rootType)
  case .list(let itemType):
    return "[\(flatbuffersType(itemType, rootType: rootType))]"
  }
}

// First, generate the flatbuffers schema file. One file per entity.

func generateEnumType(_ enumType: GraphQLEnumType) -> String {
  var fbs = ""
  fbs += "enum \(enumType.name): int {\n"
  let values = enumType.values
  for value in values {
    fbs += "  \(value.name.lowercased()),\n"
  }
  fbs += "}\n"
  return fbs
}

func generateObjectType(_ objectType: GraphQLObjectType, rootType: GraphQLNamedType) -> String {
  var existingFields = objectFields[objectType.name]!
  for interfaceType in objectType.interfaces {
    existingFields.formUnion(objectFields[interfaceType.name]!)
  }
  var fbs = ""
  let isRoot = rootType == objectType
  fbs += "table \(objectType.name) {\n"
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name != primaryKey else {
      if isRoot {
        fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType)) (primary);\n"
      }
      continue
    }
    fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType));\n"
  }
  fbs += "}\n"
  return fbs
}

func generateInterfaceType(_ interfaceType: GraphQLInterfaceType, rootType: GraphQLNamedType)
  -> String
{
  let implementations = try! schema.getImplementations(interfaceType: interfaceType)
  // For interfaces with multiple implementations, we first have all fields in the interface into the flatbuffers
  // and then having a union type that encapsulated into InterfaceSubtype and can be accessed through subtype field.
  var fbs = ""
  let isRoot = rootType == interfaceType
  if implementations.objects.count > 0 {
    fbs += isRoot ? "union Subtype {\n" : "union \(interfaceType.name)Subtype {\n"
    for object in implementations.objects {
      fbs += "  \(object.name),\n"
    }
    fbs += "}\n"
  }
  if isRoot {
    // Remove the extra namespace.
    fbs += "namespace;\n"
  }
  fbs += "table \(interfaceType.name) {\n"
  if implementations.objects.count > 0 {
    fbs +=
      isRoot
      ? "  subtype: \(interfaceType.name).Subtype;\n" : "  subtype: \(interfaceType.name)Subtype;\n"
  }
  let fields = interfaceType.fields.values.sorted(by: { $0.name < $1.name })
  let existingFields = objectFields[interfaceType.name]!
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name == primaryKey else { continue }
    if isRoot {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType)) (primary);\n"
    } else {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType));\n"
    }
  }
  fbs += "}\n"
  return fbs
}

func namedType(_ graphQLType: GraphQLType) -> GraphQLNamedType {
  switch graphQLType {
  case .named(let namedType):
    return namedType
  case .nonNull(let graphQLType):
    return namedType(graphQLType)
  case .list(let itemType):
    return namedType(itemType)
  }
}

func referencedTypes(
  rootType: GraphQLNamedType, set: inout Set<String>, _ array: inout [GraphQLNamedType]
) {
  if let interfaceType = rootType as? GraphQLInterfaceType {
    let implementations = try! schema.getImplementations(interfaceType: interfaceType)
    for objectType in implementations.objects {
      array.append(objectType)
      guard !set.contains(objectType.name) else { continue }
      set.insert(objectType.name)
      referencedTypes(rootType: objectType, set: &set, &array)
    }
  } else if let objectType = rootType as? GraphQLObjectType {
    let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
    var existingFields = objectFields[objectType.name]!
    for interfaceType in objectType.interfaces {
      existingFields.formUnion(objectFields[interfaceType.name]!)
    }
    for field in fields {
      guard existingFields.contains(field.name) else { continue }
      let fieldType = namedType(field.type)
      guard fieldType is GraphQLInterfaceType || fieldType is GraphQLObjectType else {
        if fieldType is GraphQLEnumType {
          set.insert(fieldType.name)
          array.append(fieldType)
        }
        continue
      }
      array.append(fieldType)
      guard !set.contains(fieldType.name) else { continue }
      set.insert(fieldType.name)
      referencedTypes(rootType: fieldType, set: &set, &array)
    }
  }
}

func generateFlatbuffers(_ rootType: GraphQLInterfaceType) -> String {
  var array = [GraphQLNamedType]()
  var set = Set<String>()
  set.insert(rootType.name)
  referencedTypes(rootType: rootType, set: &set, &array)
  set.removeAll()
  set.insert(rootType.name)
  var fbs = "namespace \(rootType.name);\n"
  for entityType in array.reversed() {
    guard !set.contains(entityType.name) else { continue }
    set.insert(entityType.name)
    if let interfaceType = entityType as? GraphQLInterfaceType {
      fbs += generateInterfaceType(interfaceType, rootType: rootType)
    } else if let objectType = entityType as? GraphQLObjectType {
      fbs += generateObjectType(objectType, rootType: rootType)
    } else if let enumType = entityType as? GraphQLEnumType {
      fbs += generateEnumType(enumType)
    }
  }
  fbs += generateInterfaceType(rootType, rootType: rootType)
  fbs += "root_type \(rootType.name);\n"
  return fbs
}

func generateFlatbuffers(_ rootType: GraphQLObjectType) -> String {
  var array = [GraphQLNamedType]()
  var set = Set<String>()
  set.insert(rootType.name)
  referencedTypes(rootType: rootType, set: &set, &array)
  set.removeAll()
  set.insert(rootType.name)
  var fbs = "namespace \(rootType.name);\n"
  for entityType in array.reversed() {
    guard !set.contains(entityType.name) else { continue }
    set.insert(entityType.name)
    if let interfaceType = entityType as? GraphQLInterfaceType {
      fbs += generateInterfaceType(interfaceType, rootType: rootType)
    } else if let objectType = entityType as? GraphQLObjectType {
      fbs += generateObjectType(objectType, rootType: rootType)
    } else if let enumType = entityType as? GraphQLEnumType {
      fbs += generateEnumType(enumType)
    }
  }
  fbs += generateObjectType(rootType, rootType: rootType)
  fbs += "root_type \(rootType.name);\n"
  return fbs
}

func isBaseType(_ graphQLType: GraphQLType) -> Bool {
  switch graphQLType {
  case .named(let type):
    return ["Int", "Float", "String", "Boolean", "ID"].contains(type.name)
  case .nonNull(let ofType):
    return isBaseType(ofType)
  case .list(_):
    return false
  }
}

func isIDType(_ graphQLType: GraphQLType) -> Bool {
  switch graphQLType {
  case .named(let type):
    return ["ID"].contains(type.name)
  case .nonNull(let ofType):
    return isIDType(ofType)
  case .list(_):
    return false
  }
}

enum FieldKeyPosition: Equatable {
  case noKey
  case inField
  case inInlineFragment(String)
  case inFragmentSpread(String, Bool)
}

func isOptionalFragments(fragmentType: GraphQLCompositeType, objectType: GraphQLCompositeType)
  -> Bool
{
  // If the object type is interface while fragment is not, that means we may have empty object for
  // a given interface, hence, this fragment can be optional.
  return !(fragmentType is GraphQLInterfaceType) && (objectType is GraphQLInterfaceType)
}

func primaryKeyPosition(objectType: GraphQLCompositeType, selections: [CompilationResult.Selection])
  -> FieldKeyPosition
{
  for selection in selections {
    switch selection {
    case let .field(field):
      if field.name == primaryKey && isIDType(field.type) {
        return .inField
      }
    case .inlineFragment(_), .fragmentSpread(_):
      break
    }
  }
  for selection in selections {
    switch selection {
    case .field(_), .inlineFragment(_):
      break
    case let .fragmentSpread(fragmentSpread):
      let fragmentType = fragmentSpread.fragment.selectionSet.parentType
      for selection in fragmentSpread.fragment.selectionSet.selections {
        if case let .field(field) = selection {
          if field.name == primaryKey && isIDType(field.type) {
            return .inFragmentSpread(
              fragmentSpread.fragment.name,
              isOptionalFragments(fragmentType: fragmentType, objectType: objectType))
          }
        }
      }
    }
  }
  return .noKey
}

func generateInterfaceInits(
  _ interfaceType: GraphQLInterfaceType,
  rootType: GraphQLNamedType, fullyQualifiedName: [String],
  selections: [CompilationResult.Selection]
) -> String {
  let isRoot = rootType == interfaceType
  var inits =
    !isRoot
    ? "extension \(rootType.name).\(interfaceType.name) {\n" : "extension \(interfaceType.name) {\n"
  if isRoot {
    inits += "  public convenience init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
  } else {
    inits += "  public init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
  }
  let primaryKeyPosition = primaryKeyPosition(objectType: interfaceType, selections: selections)
  switch primaryKeyPosition {
  case .inField:
    inits += "    self.init(\(primaryKey): obj.\(primaryKey), subtype: .init(obj))\n"
  case let .inFragmentSpread(name, _):
    inits +=
      "    self.init(\(primaryKey): obj.fragments.\(name.firstLowercased()).\(primaryKey), subtype: .init(obj))\n"
  case .noKey, .inInlineFragment(_):
    fatalError("Shouldn't generate interface for no primary key entities")
  }
  inits += "  }\n"
  inits += "}\n"
  let implementations = try! schema.getImplementations(interfaceType: interfaceType)
  guard implementations.objects.count > 0 else { return inits }
  inits +=
    !isRoot
    ? "extension \(rootType.name).\(interfaceType.name)Subtype {\n"
    : "extension \(interfaceType.name).Subtype {\n"
  inits += "  public init?(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
  inits += "    switch obj.__typename {\n"
  for object in implementations.objects {
    inits += "    case \"\(object.name)\":\n"
    inits += "      self = .\(object.name.firstLowercased())(.init(obj))\n"
  }
  inits += "    default:\n"
  inits += "      return nil\n"
  inits += "    }\n"
  inits += "  }\n"
  inits += "}\n"
  for object in implementations.objects {
    inits += generateObjectInits(
      object, rootType: rootType, fullyQualifiedName: fullyQualifiedName, selections: selections)
  }
  return inits
}

func generateObjectInits(
  _ objectType: GraphQLObjectType,
  rootType: GraphQLNamedType, fullyQualifiedName: [String],
  selections: [CompilationResult.Selection]
) -> String {
  let isRoot = rootType == objectType
  var inits =
    !isRoot
    ? "extension \(rootType.name).\(objectType.name) {\n" : "extension \(objectType.name) {\n"
  if isRoot {
    inits += "  public convenience init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
  } else {
    inits += "  public init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
  }
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  var existingFields = objectFields[objectType.name]!
  for interfaceType in objectType.interfaces {
    existingFields.formUnion(objectFields[interfaceType.name]!)
  }
  var existingSelections = [String: FieldKeyPosition]()
  var fieldPrimaryKeyPosition = [String: FieldKeyPosition]()
  for selection in selections {
    switch selection {
    case let .field(field):
      // Always replace it to inField
      existingSelections[field.name] = .inField
      if let selectionSet = field.selectionSet {
        fieldPrimaryKeyPosition[field.name] = primaryKeyPosition(
          objectType: selectionSet.parentType, selections: selectionSet.selections)
      }
    case let .inlineFragment(inlineFragment):
      let inlineFragmentType = inlineFragment.selectionSet.parentType
      guard inlineFragmentType == objectType else {
        continue
      }
      let selectionSet = inlineFragment.selectionSet
      for selection in selectionSet.selections {
        switch selection {
        case let .field(field):
          existingSelections[field.name] = .inInlineFragment(inlineFragmentType.name)
        case .inlineFragment(_), .fragmentSpread(_):
          break
        }
      }
    case let .fragmentSpread(fragmentSpread):
      let fragment = fragmentSpread.fragment
      let selectionSet = fragment.selectionSet
      let fragmentType = selectionSet.parentType
      for selection in selectionSet.selections {
        switch selection {
        case let .field(field):
          existingSelections[field.name] = .inFragmentSpread(
            fragmentSpread.fragment.name,
            isOptionalFragments(fragmentType: fragmentType, objectType: objectType))
        case .inlineFragment(_), .fragmentSpread(_):
          break
        }
      }
    }
  }
  var fieldAssignments = [String]()
  for field in fields {
    guard existingFields.contains(field.name),
      let fieldKeyPosition = existingSelections[field.name]
    else {
      continue
    }
    let prefix: String
    switch fieldKeyPosition {
    case .inField, .noKey:
      prefix = ""
    case let .inInlineFragment(name):
      prefix = ".as\(name)?"
    case let .inFragmentSpread(name, optional):
      prefix = ".fragments.\(name.firstLowercased())\(optional ? "?" : "")"
    }
    guard field.name != primaryKey else {
      if isRoot {
        fieldAssignments.append("\(field.name): obj.\(field.name)")
      }
      continue
    }
    if namedType(field.type) == rootType {
      guard let primaryKeyPosition = fieldPrimaryKeyPosition[field.name],
        primaryKeyPosition != .noKey
      else { continue }
      switch field.type {
      case .named(_):
        fieldAssignments.append("\(field.name): obj\(prefix).\(field.name)?.\(primaryKey)")
      case .nonNull(_):
        fieldAssignments.append("\(field.name): obj\(prefix).\(field.name).\(primaryKey)")
      case .list(_):
        fieldAssignments.append(
          "\(field.name): obj\(prefix).\(field.name)?.compactMap { $0?.\(primaryKey) } ?? []")
      }
    } else if isBaseType(field.type) {
      fieldAssignments.append("\(field.name): obj\(prefix).\(field.name)")
    } else {
      fieldAssignments.append("\(field.name): .init(obj\(prefix).\(field.name))")
    }
  }
  inits += "    self.init(\(fieldAssignments.joined(separator: ", ")))\n"
  inits += "  }\n"
  inits += "}\n"
  return inits
}

func generateInits(
  entities: Set<String>, fullyQualifiedName: [String],
  selectionSet: CompilationResult.SelectionSet
) -> [String: [[String]: String]] {
  let entityName = selectionSet.parentType.name
  let hasEntity = entities.contains(entityName)
  let hasPrimaryKey: Bool
  switch primaryKeyPosition(
    objectType: selectionSet.parentType, selections: selectionSet.selections)
  {
  case .noKey, .inInlineFragment(_):  // Cannot be a primary key if it only exists in inlineFragment (which requires optional).
    hasPrimaryKey = false
  case .inField:
    hasPrimaryKey = true
  case .inFragmentSpread(_, let optional):
    hasPrimaryKey = !optional  // Only treat this as primary key if it is not optional from the fragment.
  }
  var entityInits = [String: [[String]: String]]()
  for selection in selectionSet.selections {
    switch selection {
    case let .field(field):
      if let selectionSet = field.selectionSet {
        let newEntityInits = generateInits(
          entities: entities,
          fullyQualifiedName: fullyQualifiedName + [field.name.firstUppercased().singularized()],
          selectionSet: selectionSet)
        entityInits.merge(newEntityInits) { $0.merging($1) { data, _ in data } }
      }
    case let .inlineFragment(inlineFragment):
      let newEntityInits = generateInits(
        entities: entities, fullyQualifiedName: fullyQualifiedName,
        selectionSet: inlineFragment.selectionSet)
      entityInits.merge(newEntityInits) { $0.merging($1) { data, _ in data } }
    case let .fragmentSpread(fragmentSpread):
      let newEntityInits = generateInits(
        entities: entities, fullyQualifiedName: [fragmentSpread.fragment.name],
        selectionSet: fragmentSpread.fragment.selectionSet)
      entityInits.merge(newEntityInits) { $0.merging($1) { data, _ in data } }
    }
  }
  guard hasPrimaryKey && hasEntity, let entityType = try? schema.getType(named: entityName)
  else { return entityInits }
  if let interfaceType = entityType as? GraphQLInterfaceType {
    if entityInits[entityName]?[fullyQualifiedName] == nil {
      entityInits[entityName, default: [[String]: String]()][fullyQualifiedName] =
        generateInterfaceInits(
          interfaceType, rootType: entityType, fullyQualifiedName: fullyQualifiedName,
          selections: selectionSet.selections)
    }
  } else if let objectType = entityType as? GraphQLObjectType {
    if entityInits[entityName]?[fullyQualifiedName] == nil {
      entityInits[entityName, default: [[String]: String]()][fullyQualifiedName] =
        generateObjectInits(
          objectType, rootType: entityType, fullyQualifiedName: fullyQualifiedName,
          selections: selectionSet.selections)
    }
  } else {
    fatalError("Entity type has to be either an interface type or object type.")
  }
  return entityInits
}

var entityInits = [String: [[String]: String]]()
for operation in compilationResult.operations {
  let firstName: String
  switch operation.operationType {
  case .query:
    firstName = pascalCase(input: operation.name) + "Query"
  case .mutation:
    firstName = pascalCase(input: operation.name) + "Mutation"
  case .subscription:
    firstName = pascalCase(input: operation.name) + "Subscription"
  }
  print("-- operation: \(operation.name)")
  let newEntityInits = generateInits(
    entities: Set(entities), fullyQualifiedName: [firstName, "Data"],
    selectionSet: operation.selectionSet)
  entityInits.merge(newEntityInits) { $0.merging($1) { data, _ in data } }
}

for entity in entities {
  let entityType = try schema.getType(named: entity)
  if let interfaceType = entityType as? GraphQLInterfaceType {
    let fbs = generateFlatbuffers(interfaceType)
    let outputPath = "\(outputDir!)/\(entity)_generated.fbs"
    try! fbs.write(
      to: URL(fileURLWithPath: outputPath), atomically: false, encoding: String.Encoding.utf8)
  } else if let objectType = entityType as? GraphQLObjectType {
    let fbs = generateFlatbuffers(objectType)
    let outputPath = "\(outputDir!)/\(entity)_generated.fbs"
    try! fbs.write(
      to: URL(fileURLWithPath: outputPath), atomically: false, encoding: String.Encoding.utf8)
  } else {
    fatalError("Root type has to be either an interface type or object type.")
  }
  if let inits = entityInits[entity] {
    let sourceCode: String = inits.values.reduce("") { $0 + $1 }
    let outputPath = "\(outputDir!)/\(entity)_inits_generated.swift"
    try! sourceCode.write(
      to: URL(fileURLWithPath: outputPath), atomically: false, encoding: String.Encoding.utf8)
  }
}