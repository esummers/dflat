import Dflat
import SQLiteDflat
import SQLite3
import FlatBuffers

// MARK - SQLiteValue for Enumerations

extension MyGame.SampleV2.Color: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension MyGame.SampleV2.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    switch self {
    case .weapon(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .orb(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .empty(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    }
  }
  var _type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Equipment {
    switch self {
    case .weapon(_):
      return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Equipment.weapon
    case .orb(_):
      return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Equipment.orb
    case .empty(_):
      return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Equipment.empty
    }
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Equipment {
    self.map { $0._type } ?? .none_
  }
}

extension MyGame.SampleV2.Vec3 {
  func toRawMemory() -> UnsafeMutableRawPointer {
    return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.createVec3(x: self.x, y: self.y, z: self.z)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Vec3 {
  func toRawMemory() -> UnsafeMutableRawPointer? {
    self.map { $0.toRawMemory() }
  }
}

extension MyGame.SampleV2.Empty {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Empty.endEmpty(&flatBufferBuilder, start: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Empty.startEmpty(&flatBufferBuilder))
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Empty {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV2.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.createWeapon(&flatBufferBuilder, offsetOfName: __name, damage: self.damage)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV2.Orb {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let __color = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Color(rawValue: self.color.rawValue) ?? .red
    return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.createOrb(&flatBufferBuilder, offsetOfName: __name, color: __color)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Orb {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV2.Monster {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __pos = self.pos.toRawMemory()
    let __name = flatBufferBuilder.create(string: self.name)
    let __color = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Color(rawValue: self.color.rawValue) ?? .blue
    let __inventory = flatBufferBuilder.createVector(self.inventory)
    var __weapons = [Offset<UOffset>]()
    for i in self.weapons {
      __weapons.append(i.to(flatBufferBuilder: &flatBufferBuilder))
    }
    let __vector_weapons = flatBufferBuilder.createVector(ofOffsets: __weapons)
    let __equippedType = self.equipped._type
    let __equipped = self.equipped.to(flatBufferBuilder: &flatBufferBuilder)
    var __colors = [zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Color]()
    for i in self.colors {
      __colors.append(zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Color(rawValue: i.rawValue) ?? .red)
    }
    let __vector_colors = flatBufferBuilder.createVector(__colors)
    var __path = [UnsafeMutableRawPointer]()
    for i in self.path {
      __path.append(i.toRawMemory())
    }
    let __vector_path = flatBufferBuilder.createVector(structs: __path, type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Vec3.self)
    let __wearType = self.wear._type
    let __wear = self.wear.to(flatBufferBuilder: &flatBufferBuilder)
    return zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.createMonster(&flatBufferBuilder, structOfPos: __pos, mana: self.mana, hp: self.hp, offsetOfName: __name, color: __color, vectorOfInventory: __inventory, vectorOfWeapons: __vector_weapons, equippedType: __equippedType, offsetOfEquipped: __equipped, vectorOfColors: __vector_colors, vectorOfPath: __vector_path, wearType: __wearType, offsetOfWear: __wear)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Monster {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

// MARK - ChangeRequest

extension MyGame.SampleV2.Monster: SQLiteDflat.SQLiteAtom {
  public static var table: String { "mygame__samplev2__monster" }
  public static var indexFields: [String] { ["mana", "hp", "equipped__type", "equipped__Orb__name", "wear__Orb__name"] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__samplev2__monster (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, __pk1 INTEGER, p BLOB, UNIQUE(__pk0, __pk1))", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__samplev2__monster__mana (rowid INTEGER PRIMARY KEY, mana INTEGER)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE INDEX IF NOT EXISTS index__mygame__samplev2__monster__mana ON mygame__samplev2__monster__mana (mana)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__samplev2__monster__hp (rowid INTEGER PRIMARY KEY, hp INTEGER)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE INDEX IF NOT EXISTS index__mygame__samplev2__monster__hp ON mygame__samplev2__monster__hp (hp)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__samplev2__monster__equipped__type (rowid INTEGER PRIMARY KEY, equipped__type INTEGER)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE INDEX IF NOT EXISTS index__mygame__samplev2__monster__equipped__type ON mygame__samplev2__monster__equipped__type (equipped__type)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__samplev2__monster__equipped__Orb__name (rowid INTEGER PRIMARY KEY, equipped__Orb__name TEXT)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE UNIQUE INDEX IF NOT EXISTS index__mygame__samplev2__monster__equipped__Orb__name ON mygame__samplev2__monster__equipped__Orb__name (equipped__Orb__name)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__samplev2__monster__wear__Orb__name (rowid INTEGER PRIMARY KEY, wear__Orb__name TEXT)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE UNIQUE INDEX IF NOT EXISTS index__mygame__samplev2__monster__wear__Orb__name ON mygame__samplev2__monster__wear__Orb__name (wear__Orb__name)", nil, nil, nil)
    sqlite.clearIndexStatus(for: Self.table)
  }
  public static func insertIndex(_ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer) -> Bool {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return false }
    switch field {
    case "mana":
      guard let insert = sqlite.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__mana (rowid, mana) VALUES (?1, ?2)") else { return false }
      rowid.bindSQLite(insert, parameterId: 1)
      let retval = MyGame.SampleV2.Monster.mana.evaluate(object: .table(table))
      if retval.unknown {
        sqlite3_bind_null(insert, 2)
      } else {
        retval.result.bindSQLite(insert, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(insert) else { return false }
    case "hp":
      guard let insert = sqlite.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__hp (rowid, hp) VALUES (?1, ?2)") else { return false }
      rowid.bindSQLite(insert, parameterId: 1)
      let retval = MyGame.SampleV2.Monster.hp.evaluate(object: .table(table))
      if retval.unknown {
        sqlite3_bind_null(insert, 2)
      } else {
        retval.result.bindSQLite(insert, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(insert) else { return false }
    case "equipped__type":
      guard let insert = sqlite.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__equipped__type (rowid, equipped__type) VALUES (?1, ?2)") else { return false }
      rowid.bindSQLite(insert, parameterId: 1)
      let retval = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .table(table))
      if retval.unknown {
        sqlite3_bind_null(insert, 2)
      } else {
        retval.result.bindSQLite(insert, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(insert) else { return false }
    case "equipped__Orb__name":
      guard let insert = sqlite.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__equipped__Orb__name (rowid, equipped__Orb__name) VALUES (?1, ?2)") else { return false }
      rowid.bindSQLite(insert, parameterId: 1)
      let retval = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .table(table))
      if retval.unknown {
        sqlite3_bind_null(insert, 2)
      } else {
        retval.result.bindSQLite(insert, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(insert) else { return false }
    case "wear__Orb__name":
      guard let insert = sqlite.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__wear__Orb__name (rowid, wear__Orb__name) VALUES (?1, ?2)") else { return false }
      rowid.bindSQLite(insert, parameterId: 1)
      let retval = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .table(table))
      if retval.unknown {
        sqlite3_bind_null(insert, 2)
      } else {
        retval.result.bindSQLite(insert, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(insert) else { return false }
    default:
      break
    }
    return true
  }
}

extension MyGame.SampleV2 {

public final class MonsterChangeRequest: Dflat.ChangeRequest {
  private var _o: Monster?
  public static var atomType: Any.Type { Monster.self }
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var pos: Vec3?
  public var mana: Int16
  public var hp: Int16
  public var name: String
  public var color: Color
  public var inventory: [UInt8]
  public var weapons: [Weapon]
  public var equipped: Equipment?
  public var colors: [Color]
  public var path: [Vec3]
  public var wear: Equipment?
  public init(type: ChangeRequestType) {
    _o = nil
    _type = type
    _rowid = -1
    pos = nil
    mana = 150
    hp = 100
    name = ""
    color = .blue
    inventory = []
    weapons = []
    equipped = nil
    colors = []
    path = []
    wear = nil
  }
  public init(type: ChangeRequestType, _ o: Monster) {
    _o = o
    _type = type
    _rowid = o._rowid
    pos = o.pos
    mana = o.mana
    hp = o.hp
    name = o.name
    color = o.color
    inventory = o.inventory
    weapons = o.weapons
    equipped = o.equipped
    colors = o.colors
    path = o.path
    wear = o.wear
  }
  public static func changeRequest(_ o: Monster) -> MonsterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.name, o.color])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
    return u.map { MonsterChangeRequest(type: .update, $0) }
  }
  public static func creationRequest(_ o: Monster) -> MonsterChangeRequest {
    let creationRequest = MonsterChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> MonsterChangeRequest {
    return MonsterChangeRequest(type: .creation)
  }
  public static func upsertRequest(_ o: Monster) -> MonsterChangeRequest {
    guard let changeRequest = Self.changeRequest(o) else {
      return Self.creationRequest(o)
    }
    return changeRequest
  }
  public static func deletionRequest(_ o: Monster) -> MonsterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.name, o.color])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
    return u.map { MonsterChangeRequest(type: .deletion, $0) }
  }
  var _atom: Monster {
    let atom = Monster(name: name, color: color, pos: pos, mana: mana, hp: hp, inventory: inventory, weapons: weapons, equipped: equipped, colors: colors, path: path, wear: wear)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      let indexSurvey = toolbox.connection.indexSurvey(Monster.indexFields, table: Monster.table)
      guard let insert = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster (__pk0, __pk1, p) VALUES (?1, ?2, ?3)") else { return nil }
      name.bindSQLite(insert, parameterId: 1)
      color.bindSQLite(insert, parameterId: 2)
      let atom = self._atom
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(insert, 3, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      guard SQLITE_DONE == sqlite3_step(insert) else { return nil }
      _rowid = sqlite3_last_insert_rowid(toolbox.connection.sqlite)
      if indexSurvey.full.contains("mana") {
        guard let i0 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__mana (rowid, mana) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i0, parameterId: 1)
        let r0 = MyGame.SampleV2.Monster.mana.evaluate(object: .object(atom))
        if r0.unknown {
          sqlite3_bind_null(i0, 2)
        } else {
          r0.result.bindSQLite(i0, parameterId: 2)
        }
        guard SQLITE_DONE == sqlite3_step(i0) else { return nil }
      }
      if indexSurvey.full.contains("hp") {
        guard let i1 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__hp (rowid, hp) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i1, parameterId: 1)
        let r1 = MyGame.SampleV2.Monster.hp.evaluate(object: .object(atom))
        if r1.unknown {
          sqlite3_bind_null(i1, 2)
        } else {
          r1.result.bindSQLite(i1, parameterId: 2)
        }
        guard SQLITE_DONE == sqlite3_step(i1) else { return nil }
      }
      if indexSurvey.full.contains("equipped__type") {
        guard let i2 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__equipped__type (rowid, equipped__type) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i2, parameterId: 1)
        let r2 = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .object(atom))
        if r2.unknown {
          sqlite3_bind_null(i2, 2)
        } else {
          r2.result.bindSQLite(i2, parameterId: 2)
        }
        guard SQLITE_DONE == sqlite3_step(i2) else { return nil }
      }
      if indexSurvey.full.contains("equipped__Orb__name") {
        guard let i3 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__equipped__Orb__name (rowid, equipped__Orb__name) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i3, parameterId: 1)
        let r3 = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
        if r3.unknown {
          sqlite3_bind_null(i3, 2)
        } else {
          r3.result.bindSQLite(i3, parameterId: 2)
        }
        guard SQLITE_DONE == sqlite3_step(i3) else { return nil }
      }
      if indexSurvey.full.contains("wear__Orb__name") {
        guard let i4 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster__wear__Orb__name (rowid, wear__Orb__name) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i4, parameterId: 1)
        let r4 = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
        if r4.unknown {
          sqlite3_bind_null(i4, 2)
        } else {
          r4.result.bindSQLite(i4, parameterId: 2)
        }
        guard SQLITE_DONE == sqlite3_step(i4) else { return nil }
      }
      _type = .none
      atom._rowid = _rowid
      return .inserted(atom)
    case .update:
      guard let o = _o else { return nil }
      let atom = self._atom
      guard atom != o else {
        _type = .none
        return .identity(atom)
      }
      let indexSurvey = toolbox.connection.indexSurvey(Monster.indexFields, table: Monster.table)
      guard let update = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster (__pk0, __pk1, p, rowid) VALUES (?1, ?2, ?3, ?4)") else { return nil }
      name.bindSQLite(update, parameterId: 1)
      color.bindSQLite(update, parameterId: 2)
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(update, 3, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      _rowid.bindSQLite(update, parameterId: 4)
      guard SQLITE_DONE == sqlite3_step(update) else { return nil }
      if indexSurvey.full.contains("mana") {
        let or0 = MyGame.SampleV2.Monster.mana.evaluate(object: .object(o))
        let r0 = MyGame.SampleV2.Monster.mana.evaluate(object: .object(atom))
        if or0.unknown != r0.unknown || or0.result != r0.result {
          guard let u0 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster__mana (rowid, mana) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u0, parameterId: 1)
          let r0 = MyGame.SampleV2.Monster.mana.evaluate(object: .object(atom))
          if r0.unknown {
            sqlite3_bind_null(u0, 2)
          } else {
            r0.result.bindSQLite(u0, parameterId: 2)
          }
          guard SQLITE_DONE == sqlite3_step(u0) else { return nil }
        }
      }
      if indexSurvey.full.contains("hp") {
        let or1 = MyGame.SampleV2.Monster.hp.evaluate(object: .object(o))
        let r1 = MyGame.SampleV2.Monster.hp.evaluate(object: .object(atom))
        if or1.unknown != r1.unknown || or1.result != r1.result {
          guard let u1 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster__hp (rowid, hp) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u1, parameterId: 1)
          let r1 = MyGame.SampleV2.Monster.hp.evaluate(object: .object(atom))
          if r1.unknown {
            sqlite3_bind_null(u1, 2)
          } else {
            r1.result.bindSQLite(u1, parameterId: 2)
          }
          guard SQLITE_DONE == sqlite3_step(u1) else { return nil }
        }
      }
      if indexSurvey.full.contains("equipped__type") {
        let or2 = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .object(o))
        let r2 = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .object(atom))
        if or2.unknown != r2.unknown || or2.result != r2.result {
          guard let u2 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster__equipped__type (rowid, equipped__type) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u2, parameterId: 1)
          let r2 = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .object(atom))
          if r2.unknown {
            sqlite3_bind_null(u2, 2)
          } else {
            r2.result.bindSQLite(u2, parameterId: 2)
          }
          guard SQLITE_DONE == sqlite3_step(u2) else { return nil }
        }
      }
      if indexSurvey.full.contains("equipped__Orb__name") {
        let or3 = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(o))
        let r3 = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
        if or3.unknown != r3.unknown || or3.result != r3.result {
          guard let u3 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster__equipped__Orb__name (rowid, equipped__Orb__name) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u3, parameterId: 1)
          let r3 = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
          if r3.unknown {
            sqlite3_bind_null(u3, 2)
          } else {
            r3.result.bindSQLite(u3, parameterId: 2)
          }
          guard SQLITE_DONE == sqlite3_step(u3) else { return nil }
        }
      }
      if indexSurvey.full.contains("wear__Orb__name") {
        let or4 = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(o))
        let r4 = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
        if or4.unknown != r4.unknown || or4.result != r4.result {
          guard let u4 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster__wear__Orb__name (rowid, wear__Orb__name) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u4, parameterId: 1)
          let r4 = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
          if r4.unknown {
            sqlite3_bind_null(u4, 2)
          } else {
            r4.result.bindSQLite(u4, parameterId: 2)
          }
          guard SQLITE_DONE == sqlite3_step(u4) else { return nil }
        }
      }
      _type = .none
      return .updated(atom)
    case .deletion:
      guard let deletion = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster WHERE rowid=?1") else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      if let d0 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster__mana WHERE rowid=?1") {
        _rowid.bindSQLite(d0, parameterId: 1)
        sqlite3_step(d0)
      }
      if let d1 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster__hp WHERE rowid=?1") {
        _rowid.bindSQLite(d1, parameterId: 1)
        sqlite3_step(d1)
      }
      if let d2 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster__equipped__type WHERE rowid=?1") {
        _rowid.bindSQLite(d2, parameterId: 1)
        sqlite3_step(d2)
      }
      if let d3 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster__equipped__Orb__name WHERE rowid=?1") {
        _rowid.bindSQLite(d3, parameterId: 1)
        sqlite3_step(d3)
      }
      if let d4 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster__wear__Orb__name WHERE rowid=?1") {
        _rowid.bindSQLite(d4, parameterId: 1)
        sqlite3_step(d4)
      }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}

}

// MARK - MyGame.SampleV2
