import LogicKit

let zero = Value (0)

func succ (_ of: Term) -> Map {
    return ["succ": of]
}

func toNat (_ n : Int) -> Term {
    var result : Term = zero
    for _ in 1...n {
        result = succ (result)
    }
    return result
}

struct Position : Equatable, CustomStringConvertible {
    let x : Int
    let y : Int

    var description: String {
        return "\(self.x):\(self.y)"
    }

    static func ==(lhs: Position, rhs: Position) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

}


// rooms are numbered:
// x:1,y:1 ... x:n,y:1
// ...             ...
// x:1,y:m ... x:n,y:m
func room (_ x: Int, _ y: Int) -> Term {
  return Value (Position (x: x, y: y))
}

func doors (from: Term, to: Term) -> Goal {
  return
     (from === room(2,1) && to === room(1,1))
  || (from === room(3,1) && to === room(2,1))
  || (from === room(4,1) && to === room(3,1))
  || (from === room(1,2) && to === room(1,1))
  || (from === room(1,2) && to === room(2,2))
  || (from === room(2,2) && to === room(3,2))
  || (from === room(3,2) && to === room(4,2))
  || (from === room(3,2) && to === room(3,3))
  || (from === room(4,2) && to === room(4,3))
  || (from === room(4,2) && to === room(4,1))
  || (from === room(1,3) && to === room(1,2))
  || (from === room(2,3) && to === room(1,3))
  || (from === room(2,3) && to === room(2,2))
  || (from === room(1,4) && to === room(1,3))
  || (from === room(2,4) && to === room(2,3))
  || (from === room(3,4) && to === room(2,4))
  || (from === room(3,4) && to === room(3,3))
  || (from === room(4,4) && to === room(3,4))
}

func entrance (location: Term) -> Goal {
    return (location === room(1,4)) || (location === room(4,4))
}

func exit (location: Term) -> Goal {
    return (location === room(1,1)) || (location === room(4,3))
}

func minotaur (location: Term) -> Goal {
    return (location === room(3,2))
}

func path (from: Term, to: Term, through: Term) -> Goal {
    // basic case two connected doors so through is empty
    //then we recursively build a path until we arrive at the basic case
    //verifying the path
    return (through === List.empty &&  doors(from: from, to: to)) ||
          delayed ( fresh {x in fresh {
                      y in ((through === List.cons(x, y)) && doors(from: from, to: x) &&
                      path(from: x, to: to, through: y))
                  }})
  }

func battery_check(through: Term, level: Term) -> Goal{
  return (through === List.empty && delayed(fresh {x in level === succ(x)})) //the basic case no path and more than one level
   || 
  delayed (fresh {x in fresh {y in fresh { z in
    //we iterate until we still have levels and we still have rooms
    // z === succ(t) verifies that we still have power in the battery
    through === List.cons(x,y) && level === succ(z) && battery_check(through: y,level : z)
  }}})
}

func battery (through: Term, level: Term) -> Goal {
    // we ietrate and see if we have enough battery per room we traverse
    return delayed (fresh {x in
      ((level === succ(x)) && battery_check(through: through,level: x))
    })
}

func Meetminotaur(through: Term) -> Goal{
  //one of the winning conditions is if we meet the minotaur in the chosehn path at all
  return (delayed (fresh {
    x in fresh {y in (
      minotaur(location: through) || through === List.cons(x,y) && (minotaur(location: x) || Meetminotaur(through: y))
    )}
  }))
}

func winning (through: Term, level: Term) -> Goal {

    // to win first we need to have enough battery we need the minotaur  to be
    //part of the path and that there the through or the path exists
return battery(through: through, level: level) && Meetminotaur(through: through) &&
  delayed(fresh { x in fresh { y in path(from: x,to : y, through: through) &&
  entrance(location: x) && exit(location: y) }})
}
