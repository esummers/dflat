import Dflat

extension NotExpr: SQLiteExpr where T: SQLiteExpr {
  public func buildWhereQuery(availableIndexes: Set<String>, query: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    query.append("NOT (")
    unary.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
    query.append(")")
  }
  public func bindWhereQuery(availableIndexes: Set<String>, query: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    unary.bindWhereQuery(availableIndexes: availableIndexes, query: query, parameterCount: &parameterCount)
    // TODO:
  }
}
