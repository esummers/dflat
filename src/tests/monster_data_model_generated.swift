import Dflat
import FlatBuffers

public enum MyGame {

public enum Sample {

public enum Color: Int8, DflatFriendlyValue {
  case red = 0
  case green = 1
  case blue = 2
  public static func < (lhs: Color, rhs: Color) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public enum Equipment: Equatable {
  case weapon(_: Weapon)
}

public struct Vec3: Equatable {
  var x: Float32
  var y: Float32
  var z: Float32
  public init(x: Float32 = 0.0, y: Float32 = 0.0, z: Float32 = 0.0) {
    self.x = x
    self.y = y
    self.z = z
  }
  public init(_ obj: FlatBuffers_Generated.MyGame.Sample.Vec3) {
    self.x = obj.x
    self.y = obj.y
    self.z = obj.z
  }
}

public struct Weapon: Equatable {
  var name: String?
  var damage: Int16
  public init(name: String? = nil, damage: Int16 = 0) {
    self.name = name
    self.damage = damage
  }
  public init(_ obj: FlatBuffers_Generated.MyGame.Sample.Weapon) {
    self.name = obj.name
    self.damage = obj.damage
  }
}

public final class Monster: Dflat.Atom, Equatable {
  public static func == (lhs: Monster, rhs: Monster) -> Bool {
    guard lhs.pos == rhs.pos else { return false }
    guard lhs.mana == rhs.mana else { return false }
    guard lhs.hp == rhs.hp else { return false }
    guard lhs.name == rhs.name else { return false }
    guard lhs.inventory == rhs.inventory else { return false }
    guard lhs.color == rhs.color else { return false }
    guard lhs.weapons == rhs.weapons else { return false }
    guard lhs.equipped == rhs.equipped else { return false }
    guard lhs.equips == rhs.equips else { return false }
    guard lhs.colors == rhs.colors else { return false }
    guard lhs.path == rhs.path else { return false }
    return true
  }
  let pos: Vec3?
  let mana: Int16
  let hp: Int16
  let name: String
  let inventory: [UInt8]
  let color: Color
  let weapons: [Weapon]
  let equipped: Equipment?
  let equips: [Equipment]
  let colors: [Color]
  let path: [Vec3]
  public init(name: String, pos: Vec3? = nil, mana: Int16 = 150, hp: Int16 = 100, inventory: [UInt8] = [], color: Color = .blue, weapons: [Weapon] = [], equipped: Equipment? = nil, equips: [Equipment] = [], colors: [Color] = [], path: [Vec3] = []) {
    self.pos = pos
    self.mana = mana
    self.hp = hp
    self.name = name
    self.inventory = inventory
    self.color = color
    self.weapons = weapons
    self.equipped = equipped
    self.equips = equips
    self.colors = colors
    self.path = path
  }
  public init(_ obj: FlatBuffers_Generated.MyGame.Sample.Monster) {
    self.pos = obj.pos.map { Vec3($0) }
    self.mana = obj.mana
    self.hp = obj.hp
    self.name = obj.name!
    self.inventory = obj.inventory
    self.color = Color(rawValue: obj.color.rawValue) ?? .blue
    var __weapons = [Weapon]()
    for i: Int32 in 0..<obj.weaponsCount {
      guard let o = obj.weapons(at: i) else { break }
      __weapons.append(Weapon(o))
    }
    self.weapons = __weapons
    switch obj.equippedType {
    case .none_:
      self.equipped = nil
    case .weapon:
      self.equipped = obj.equipped(type: FlatBuffers_Generated.MyGame.Sample.Weapon.self).map { .weapon(Weapon($0)) }
    }
    var __equips = [Equipment]()
    for i: Int32 in 0..<obj.equipsCount {
      guard let ot = obj.equipsType(at: i) else { break }
      switch ot {
      case .none_:
        fatalError()
      case .weapon:
        guard let oe = obj.equips(at: i, type: FlatBuffers_Generated.MyGame.Sample.Weapon.self) else { break }
        __equips.append(.weapon(Weapon(oe)))
      }
    }
    self.equips = __equips
    var __colors = [Color]()
    for i: Int32 in 0..<obj.colorsCount {
      guard let o = obj.colors(at: i) else { break }
      __colors.append(Color(rawValue: o.rawValue) ?? .red)
    }
    self.colors = __colors
    var __path = [Vec3]()
    for i: Int32 in 0..<obj.pathCount {
      guard let o = obj.path(at: i) else { break }
      __path.append(Vec3(o))
    }
    self.path = __path
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: bb))
  }
}

}

// MARK: - MyGame

}

// MARK: - Sample
