//
//  main.swift
//  MyApp
//
//  Created by Talshyn Rakhatkyzy on 09.10.2026.
//


let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]


let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")


final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        charge = charge.charged(by: amount)
    }
}

let cell = PowerCell(charge: 150)
print("start: \(cell.level())")
print("spend 0: \(cell.spend(0)), level \(cell.level())")
print("spend -5: \(cell.spend(-5)), level \(cell.level())")
print("spend 30: \(cell.spend(30)), level \(cell.level())")
print("spend 500: \(cell.spend(500)), level \(cell.level())")
cell.recharge(by: -10)
print("recharge -10: \(cell.level())")
cell.recharge(by: 80)
print("recharge 80: \(cell.level())")
print("PowerCell(charge: -20): \(PowerCell(charge: -20).level())")


class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a seam"
    }
}

class ScannerDrone: Drone {
    // powerCost stays 10 from Drone
    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

func buildFleet(_ records: [(kind: String, id: String, charge: Int)]) -> [Drone] {
    var result: [Drone] = []
    for record in records {
        guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
            print("Warning: unknown drone kind '\(record.kind)' for \(record.id), skipped")
            continue
        }
        result.append(drone)
    }
    return result
}

let fleet: [Drone] = buildFleet(fleetData)
print("Fleet: \(fleet.count) drones")
for drone in fleet {
    print(drone.statusLine)
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    guard rounds > 0 else { return 0 }
    var total = 0
    for _ in 0..<rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let workUnits = runShift(fleet, rounds: 3)
print("Work units: \(workUnits)")

var totalCharge = 0
var readyDrones = 0
for drone in fleet {
    print(drone.statusLine)
    totalCharge += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        readyDrones += 1
    }
}
print("Total charge left: \(totalCharge)")
print("Drones ready for one more task: \(readyDrones)")

let A = workUnits
let B = totalCharge
let C = readyDrones


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why no mutating: Drone is a class, self is a reference, so its methods can
// change state anyway. mutating only exists for value types.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: chargeLevel) }

    mutating func recharge(by amount: Int) {
        chargeLevel = chargeLevel.charged(by: amount)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

var testSensor = SensorModule(id: "test", chargeLevel: 90)
testSensor.recharge(by: 50)
print("Sensor after recharge 50: \(testSensor.chargeLevel)")
testSensor.recharge(by: -5)
print("Sensor after recharge -5: \(testSensor.chargeLevel)")

let testDrone = CargoDrone(id: "C-test", cell: PowerCell(charge: 10))
testDrone.recharge(by: 30)
print("Drone after recharge 30: \(testDrone.cell.level())")

// 4.3
// [Drone] could never hold the sensors: SensorModule is a struct, and a struct
// can't inherit from a class, but both can conform to the same protocol.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== Diagnostics: \(components.count) components ===\n"
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    // The Health Rule, the only place in the file
    func healthCode(forCharge charge: Int) -> Int {
        if charge < 20 {
            return 2
        } else if charge < 50 {
            return 1
        }
        return 0
    }
}

// 5.2
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(forCharge: signalStrength) }

    func diagnose() -> String {
        "[LEGACY HARDWARE] \(name) | signal \(signalStrength) | code \(statusCode) | check by hand"
    }
}

components.append(beacon)
print(diagnosticsReport(components))

var statusSum = 0
for component in components {
    statusSum += component.statusCode
}
print("Sum of status codes: \(statusSum)")

let D = statusSum

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        var bar = ""
        for position in 0..<10 {
            bar += position < filled ? "#" : "."
        }
        return bar
    }

    // recharge rule shared by PowerCell and SensorModule:
    // ignore non-positive amounts, never above 100
    func charged(by amount: Int) -> Int {
        guard amount > 0 else { return self }
        return Swift.min(self + amount, 100)
    }
}

print(42.powerBar)
print((-5).powerBar)
print(250.powerBar)


// MARK: Level 6 · Incident Reports

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// Report 1
// Expected: a new drone that produces 30 work units.
// Actual: doesn't compile: "overriding declaration requires an 'override' keyword".
// Rule: when a subclass replaces a parent's method, it must say override,
// so you can't replace a method by accident.
// Fix:
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}
let patch = PatchDrone(id: "P-1", cell: PowerCell(charge: 50))
print("Report 1 fixed: \(patch.runOnce()), charge \(patch.cell.level())")

// Report 2
// Expected: a welder that produces 999 units.
// Actual: doesn't compile, two errors: WelderDrone is final, so it can't be
// subclassed, and runOnce() is final, so it can't be overridden.
// Rule: final forbids subclassing (on a class) and overriding (on a method).
// Fix: subclass Drone and change only the cost and the work, not the ritual.
final class HeavyWelder: Drone {
    override var powerCost: Int { 50 }
    override func performTask() -> Int { 100 }
}
let heavy = HeavyWelder(id: "H-1", cell: PowerCell(charge: 60))
print("Report 2 fixed: \(heavy.runOnce()), then \(heavy.runOnce())")

// Report 3
// Expected: prints the welder's message.
// Actual: doesn't compile: "value of type 'Drone' has no member 'weldSeam'".
// Rule: the compiler only allows what the static type (Drone) has, even if
// the object is really a WelderDrone at runtime.
// Fix: ask at runtime with a conditional cast.
// as? returns an optional because the cast can fail: the Drone might be a
// scanner or cargo drone, and then there is no welder to return.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print("Report 3 fixed: \(welder.weldSeam())")
}
for drone in fleet {
    if let welder = drone as? WelderDrone {
        print("Report 3, fleet: \(welder.weldSeam())")
    }
}

// Report 4
// Expected: "thruster T-1". Actual: compiles and prints "generic component".
// Rule: label() is not a requirement of the protocol, it only lives in the
// extension. When called through the protocol type ([Labelled]) Swift uses
// static dispatch and picks the extension's version. Only requirements are
// dispatched dynamically to the real type.
// Fix (one line): add label() to the protocol.
protocol Labelled {
    var componentID: String { get }
    func label() -> String
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 fixed: \(parts[0].label())")


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// 1a. Runtime: the base method crashes if a subclass forgot to override it.
class RuntimeAbstractDrone {
    func performTask() -> Int {
        fatalError("RuntimeAbstractDrone is abstract, override performTask()")
    }
}
// RuntimeAbstractDrone().performTask()
// compiles, but crashes when it runs: Fatal error: RuntimeAbstractDrone is abstract...

// 1b. Compile time: make the base type a protocol. A protocol can't be created
// directly, and a type that forgets performTask() doesn't compile.
// let plain = FleetDrone()
// error: 'any FleetDrone' cannot be constructed because it has no accessible initializers

// 2. Protocol-based fleet
protocol FleetDrone {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension FleetDrone {
    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    // not a requirement, so a conforming type can't replace it through the
    // protocol type: works like final
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// named WelderUnit because WelderDrone (the class) already exists in this file
struct WelderUnit: FleetDrone {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id) welded a seam" }
}

struct ScannerUnit: FleetDrone {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 10 }
    func performTask() -> Int { 15 }
}

let protocolFleet: [FleetDrone] = [
    WelderUnit(id: "W-1", cell: PowerCell(charge: 80)),
    ScannerUnit(id: "S-1", cell: PowerCell(charge: 45))
]
var protocolWork = 0
for drone in protocolFleet {
    protocolWork += drone.runOnce()
    print(drone.statusLine)
}
print("Protocol fleet work: \(protocolWork)")

// 3. Comparison
// The class version shares stored properties (id, cell) and init once in Drone,
// and final protects runOnce for sure. The protocol version is lighter, works
// with structs and can't be created directly, but every type repeats id and cell.
// For this station I'd keep the class: drones are real machines with identity,
// and if they had to share mutable state (one battery, one log) a reference type
// is what you need. With structs that state would have to live in a class anyway,
// like PowerCell does here.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    mutating means "this method can change self". In a struct self is a value
    and is constant inside normal methods, so the struct must ask for
    permission with mutating. In a class self is a reference: methods can
    always change the object's properties, so there is nothing to mark.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance: shares stored properties and an init. id and cell are
    declared once in Drone, and subclasses can call super (ScannerDrone's
    statusLine). A protocol can't store anything.
    Protocols: work for classes, structs and enums at the same time, and can
    be added to a type you can't edit (LegacyBeacon). A struct can never
    inherit from a class.

 3. What does `final` prevent, and what did it protect in runOnce()?
    final on a class: no subclasses. final on a method: no override.
    In runOnce() it protects the order "pay first, then work": a subclass
    can't override runOnce to skip spending power and produce work for free
    (like HeavyWelder in Report 2 tried to).

 4. In Report 4, why did the protocol extension's method win?
    label() was not in the protocol, only in the extension. Calls through
    the protocol type are resolved at compile time for non-requirements,
    so Swift picked the extension's version and never looked at Thruster.
    After adding label() to the protocol, it becomes a requirement and is
    dispatched dynamically to the real type.
*/
