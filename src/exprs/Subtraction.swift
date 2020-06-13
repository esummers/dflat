import FlatBuffers

public struct SubtractionExpr<L: Expr, R: Expr>: Expr where L.ResultType == R.ResultType, L.ResultType: AdditiveArithmetic {
  public typealias ResultType = L.ResultType
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    let lval = left.evaluate(object: object)
    let rval = right.evaluate(object: object)
    return (lval.result - rval.result, lval.unknown || rval.unknown)
  }
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    if left.canUsePartialIndex(availableIndexes) == .full && right.canUsePartialIndex(availableIndexes) == .full {
      return .full
    }
    return .none
  }
  public var useScanToRefine: Bool { left.useScanToRefine || right.useScanToRefine }
}

public func - <L, R>(left: L, right: R) -> SubtractionExpr<L, R> where L.ResultType == R.ResultType, L.ResultType: AdditiveArithmetic {
  return SubtractionExpr(left: left, right: right)
}

public func - <L, R>(left: L, right: R) -> SubtractionExpr<L, ValueExpr<R>> where L.ResultType == R, R: AdditiveArithmetic {
  return SubtractionExpr(left: left, right: ValueExpr(right))
}

public func - <L, R>(left: L, right: R) -> SubtractionExpr<ValueExpr<L>, R> where L: AdditiveArithmetic, L == R.ResultType {
  return SubtractionExpr(left: ValueExpr(left), right: right)
}
