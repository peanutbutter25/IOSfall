//
//  ass3.swift
//  MyApp
//
//  Created by Talshyn Rakhatkyzy on 20.09.2026.
//

typealias Reading = (sensor: String, value: Int)

func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")


func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueText) = splitOnce(raw, by: ":"),
          sensor.isEmpty == false,
          let value = Int(valueText),
          value >= 0 || sensor == "TEMP"
    else { return nil }
    return (sensor: sensor, value: value)
}

print("1.1 parseReading")
print(parseReading("O2:87") as Any)     // Optional((sensor: "O2", value: 87))
print(parseReading("TEMP:-12") as Any)  // Optional((sensor: "TEMP", value: -12))
print(parseReading("RAD:-1") as Any)    // nil
print(parseReading(":55") as Any)       // nil
print(parseReading("O2:") as Any)       // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid, invalidCount)
}

let parsed = parseLog(rawLog)
print("1.2 parseLog")
print("valid: \(parsed.valid.count), invalid: \(parsed.invalidCount)")
print(parseLog(["O2:1", "bad"]))
print(parseLog([]))

let A = parsed.invalidCount


func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}


let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
let tempReadings = select(parsed.valid) { $0.sensor == "TEMP" }
print("2.1 select / values")
print("O2 values: \(values(of: o2Readings))")
print("TEMP values: \(values(of: tempReadings))")


func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for v in values {
        if v < minValue { minValue = v }
        if v > maxValue { maxValue = v }
        sum += v
    }
    return (minValue, maxValue, Double(sum) / Double(values.count))
}


func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("2.2 stats")
print(stats(3, 8, 1) as Any)
print(stats() as Any)
print(stats(of: [10, 20]) as Any)
print(stats(of: []) as Any)

let o2Stats = stats(of: values(of: o2Readings))
let B = Int(o2Stats?.average ?? 0)

// 2.3 · The Closure Ladder
let ladder1 = parsed.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let ladder2 = parsed.valid.sorted(by: { a, b in
    return a.value > b.value
})
let ladder3 = parsed.valid.sorted(by: { a, b in a.value > b.value })
let ladder4 = parsed.valid.sorted(by: { $0.value > $1.value })
let ladder5 = parsed.valid.sorted { $0.value > $1.value }

// Reading is a tuple, so arrays of it are not Equatable: compare by hand.
func sameReadings(_ x: [Reading], _ y: [Reading]) -> Bool {
    guard x.count == y.count else { return false }
    for i in 0..<x.count {
        if x[i].sensor != y[i].sensor || x[i].value != y[i].value {
            return false
        }
    }
    return true
}

print("2.3 Closure Ladder")
print("sorted: \(values(of: ladder1))")
print("1 == 2: \(sameReadings(ladder1, ladder2))")
print("1 == 3: \(sameReadings(ladder1, ladder3))")
print("1 == 4: \(sameReadings(ladder1, ladder4))")
print("1 == 5: \(sameReadings(ladder1, ladder5))")



func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

print("3.1 chooseProtocol")
print(chooseProtocol(for: 10)(10))  // 15
print(chooseProtocol(for: 30)(30))  // 27
print(chooseProtocol(for: 20)(20))  // 20

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (temp, steps, temp >= 18 && temp <= 24)
}

print("3.2 runUntilStable")
print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))
print(runUntilStable(from: 20))


let coldest = stats(of: values(of: tempReadings))?.min ?? 0
let C = runUntilStable(from: coldest).steps



func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}


func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    }
    return "\(member.name): \(level)% OK"
}

print("4.2 status (before transfer)")
for member in crew {
    print(status(of: member))
}


@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let freeSpace = max(0, 100 - target)
    let available = max(0, source)
    let moved = min(amount, available, freeSpace)
    source -= moved
    target += moved
    return moved
}

print("4.3 transferOxygen")
var testA = 50
var testB = 90
let movedTest = transferOxygen(from: &testA, to: &testB, amount: 30)
print("moved \(movedTest): A=\(testA), B=\(testB)")
var testC = 5
var testD = 0
transferOxygen(from: &testC, to: &testD, amount: -4)
print("negative amount: C=\(testC), D=\(testD)")

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Lab Hab: moved \(moved)")
} else {
    print("Transfer impossible: a module has no tank")
}

let D = hab.oxygenTank?.level ?? 0

print("status (after transfer)")
for member in crew {
    print(status(of: member))
}

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let ordered = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in ordered {
        result.append(member.name)
    }
    return result
}

print("4.4 evacuationOrder")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))

print(evacuationOrder("Nurlan", "Timur", roster: roster))


func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name   // return immediately: this is the FIRST one
        }
    }
    return nil
}

print("lvl 5 tests")
for member in crew {
    print(reportOxygen(for: member))   // no crash for Dana and Nurlan
}


let badModule1 = Module(name: "Bay1", oxygenTank: Tank(level: 5))
let badModule2 = Module(name: "Bay2", oxygenTank: Tank(level: 10))
let testCrew = [
    CrewMember(name: "First",  role: "Test", priority: 1, module: badModule1),
    CrewMember(name: "Nobody", role: "Test", priority: 2, module: nil),
    CrewMember(name: "Second", role: "Test", priority: 3, module: badModule2)
]
let critical = firstCritical(in: testCrew)
print("firstCritical -> \(critical ?? "nobody")")
print("test passed: \(critical == "First")")
print("nobody critical -> \(firstCritical(in: crew) ?? "nobody")")


let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")




func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}

print("Bonus: makeAlarm")
let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))

