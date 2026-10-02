//
//  main.swift
//  MyApp
//
//  Created by Talshyn Rakhatkyzy on 02.10.2026.
//

func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}


let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]


let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]


let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")


enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine


    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

print("1.1 decks")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}


enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red


    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = min(mass / 500, 3)
        return AlarmLevel(rawValue: steps) ?? .green
    }
}

print("1.2 alarm levels")
print(AlarmLevel.level(forTotalMass: 0))      // green
print(AlarmLevel.level(forTotalMass: 940))    // yellow
print(AlarmLevel.level(forTotalMass: 4000))   // red
print(AlarmLevel.level(forTotalMass: 1500))   // red



enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}


func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)

    if parts.count == 3 && parts[0] == "crate" {
        if let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
    } else if parts.count == 3 && parts[0] == "container" {
        if let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
    } else if parts.count == 4 && parts[0] == "livestock" {
        if let count = Int(parts[2]), let perUnit = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
        }
    }


    return .unknown(raw: line)
}

print("2.2 parseEntry")
print(parseEntry("crate:101:120"))
print(parseEntry("container:KZ-ALM-7:340"))
print(parseEntry("livestock:lab mice:12:2"))
print(parseEntry("crate:104:abc"))
print(parseEntry(""))

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var manifest: [ManifestEntry] = []
for line in rawManifest {
    manifest.append(parseEntry(line))
}

var totalMass = 0
var unknownCount = 0
for entry in manifest {
    totalMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}

print("2.3 mass")
print("mass of a crate: \(mass(of: .crate(id: 1, massKg: 50)))")
print("mass of livestock: \(mass(of: .livestock(species: "test", count: 4, massPerUnitKg: 3)))")
print("total mass: \(totalMass) kg")
print("unknown lines: \(unknownCount)")

let A = totalMass



struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        guard amount > 0 else { return }
        oxygen = max(oxygen - amount, 0)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

print("3.1 CrewSnapshot")
var testCrew = CrewSnapshot.rookie(named: "Rookie")
print(testCrew)
testCrew.breathe(30)
testCrew.move(to: .engine)
print(testCrew)
testCrew.breathe(500)
print("oxygen can't go below 0: \(testCrew.oxygen)")
testCrew.reviveInMedbay()
print(testCrew)


func makeRoster(from records: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var result: [CrewSnapshot] = []
    for record in records {
        guard let deck = Deck(rawValue: record.deck) else {
            print("Warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
            continue
        }
        result.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
    return result
}

let crewRoster: [CrewSnapshot] = makeRoster(from: crewData)

print("3.2 roster")
for member in crewRoster {
    print(member)
}

let checkRoster = makeRoster(from: [(name: "Ghost", deck: "garage", oxygen: 50),
                                    (name: "Real", deck: "lab", oxygen: 50)])
print("check roster has \(checkRoster.count) member(s)")

func findCrew(_ name: String) -> CrewSnapshot? {
    for member in crewRoster {
        if member.name == name {
            return member
        }
    }
    return nil
}


func hurtCopy(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.breathe(30)
    print("   inside hurtCopy: local copy has \(local.oxygen)")
}

func hurtInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(30)
}

print("3.3 value semantics")

var original = CrewSnapshot.rookie(named: "Demo")

print("1) copy")
var copyOfOriginal = original
print("   before: original = \(original.oxygen), copy = \(copyOfOriginal.oxygen)")
copyOfOriginal.breathe(40)
print("   after:  original = \(original.oxygen), copy = \(copyOfOriginal.oxygen)")

print("2) plain function")
print("   before: original = \(original.oxygen)")
hurtCopy(original)
print("   after:  original = \(original.oxygen)")

print("3) inout function")
print("   before: original = \(original.oxygen)")
hurtInPlace(&original)
print("   after:  original = \(original.oxygen)")



final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?


    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }


    deinit {
        print("   deinit: pod \(id) is gone")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant == nil && chargeLevel >= 20 {
            occupant = crew
            return true
        }
        return false
    }

    func fire() -> CrewSnapshot? {
        guard let person = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return person
    }
}


let pod = TeleportPod(id: "P-1", chargeLevel: 100)
print("4.2 charge ledger")
print("start: charge = \(pod.chargeLevel)")

let names = ["Timur", "Dana", "Nurlan"]
for name in names {
    if let person = findCrew(name) {
        let loaded = pod.load(person)
        let fired = pod.fire()
        print("\(name): loaded = \(loaded), fired = \(fired?.name ?? "nobody"), charge = \(pod.chargeLevel)")
    }
}

let emptyShot = pod.fire()
print("empty pod: fired = \(emptyShot?.name ?? "nobody"), charge = \(pod.chargeLevel)")

let C = pod.chargeLevel


let lowPod = TeleportPod(id: "LOW", chargeLevel: 10)
if let someone = findCrew("Dana") {
    print("load into low pod: \(lowPod.load(someone))")
    let busyPod = TeleportPod(id: "BUSY", chargeLevel: 100)
    print("first load: \(busyPod.load(someone))")              
    print("second load: \(busyPod.load(someone))")            
}


print("4.3 reference semantics")
let podOne = TeleportPod(id: "P-2", chargeLevel: 100)
let podTwo = podOne
print("   before: podOne = \(podOne.chargeLevel), podTwo = \(podTwo.chargeLevel)")
podTwo.chargeLevel = 30
print("   after:  podOne = \(podOne.chargeLevel), podTwo = \(podTwo.chargeLevel)")

var snapOne = CrewSnapshot.rookie(named: "Same")
var snapTwo = snapOne
print("   before: snapOne = \(snapOne.oxygen), snapTwo = \(snapTwo.oxygen)")
snapTwo.oxygen = 30
print("   after:  snapOne = \(snapOne.oxygen), snapTwo = \(snapTwo.oxygen)")
// snapOne.oxygen = snapOne.oxygen
 
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int] = [:]

    var hullIntegrity: Int = 100 {
        willSet {
            print("   hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            }
            if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    
    lazy var fullDiagnostics: String = {
        print("   Running full scan")
        return "\(self.callSign) | hull \(self.hullIntegrity)% | oxygen total \(self.totalOxygen)"
    }()

    
    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.count == 0 {
                return 0
            }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("   skipped reading for unknown deck '\(reading.deck)'")
                continue
            }
            oxygenByDeck[deck] = reading.oxygen
        }
    }
}

print("5.1 Station")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
print("total oxygen: \(station.totalOxygen)")

let B = station.averageOxygen
print("average oxygen at start-up: \(B)")

print("lazy test: station created, diagnostics not touched yet")
print("first access:")
print("   \(station.fullDiagnostics)")
print("second access:")
print("   \(station.fullDiagnostics)")


let spareStation = Station(callSign: "SPARE", readings: [(deck: "lab", oxygen: 50),
                                                         (deck: "cargo", oxygen: 20)])
print("spare station average: \(spareStation.averageOxygen)")
spareStation.averageOxygen = 80
print("after setter: \(spareStation.averageOxygen), total \(spareStation.totalOxygen)")
print("(no scan message for SPARE, because its diagnostics were never read)")


print("5.2 hull clamp")
station.hullIntegrity = 130
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = -40
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = 55
print("hull = \(station.hullIntegrity)")



var fixedRoster = crewRoster
print("Report 1 fixed")
print("before: \(fixedRoster[0].oxygen)")
for i in 0..<fixedRoster.count {
    fixedRoster[i].oxygen -= 10
}
print("after: \(fixedRoster[0].oxygen)")


let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: podA.id, chargeLevel: podA.chargeLevel)
podB.chargeLevel = 0
print("Report 2 fixed")
print("podA = \(podA.chargeLevel), podB = \(podB.chargeLevel)")


struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
logbook.add("pod fired")
logbook.add("hull checked")
print("Report 3 fixed")
print("logbook has \(logbook.entries.count) entries")


var editableSnapshot = CrewSnapshot.rookie(named: "Dana")
editableSnapshot.oxygen = 40
let podB2 = TeleportPod(id: "B", chargeLevel: 50)
podB2.chargeLevel = 10
print("Report 4 fixed")
print("snapshot oxygen = \(editableSnapshot.oxygen), podB2 charge = \(podB2.chargeLevel)")




final class FlightRecorder {
    private var entries: [String] = []

    private(set) var isSealed = false

    internal var entryCount: Int {
        return entries.count
    }

    internal var transcript: String {
        return numberedLines().joined(separator: "\n")
    }

    internal func add(_ entry: String) {
        if isSealed {
            print("   recorder is sealed, entry rejected: \(entry)")
            return
        }
        entries.append(entry)
    }

    internal func seal() {
        isSealed = true
    }

    fileprivate func numberedLines() -> [String] {
        var lines: [String] = []
        var number = 1
        for entry in entries {
            lines.append("\(number). \(entry)")
            number += 1
        }
        return lines
    }
}


func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.numberedLines()
    return "AUDIT: \(lines.count) lines, sealed = \(recorder.isSealed)\n" + lines.joined(separator: "\n")
}

print("Level 7 FlightRecorder")
let recorder = FlightRecorder()
recorder.add("teleporter online")
recorder.add("crew transferred")
print("entries: \(recorder.entryCount)")
print(recorder.transcript)
recorder.seal()
recorder.add("this must be rejected")
print("entries after seal: \(recorder.entryCount), sealed = \(recorder.isSealed)")
print(auditTranscript(of: recorder))


let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")
print("Bonus: lifetime")
var keeper: TeleportPod?
print("before the block")
do {
    let lostPod = TeleportPod(id: "LOST", chargeLevel: 50)
    let keptPod = TeleportPod(id: "KEPT", chargeLevel: 50)
    keeper = keptPod
    print("inside the block: \(lostPod.id) and \(keptPod.id) exist")
}
print("after the block")

print("keeper still has: \(keeper?.id ?? "nothing")")
keeper = nil

print("after keeper = nil")


func comparePods(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "same pod (one object, two references)"
    }
    if first.id == second.id && first.chargeLevel == second.chargeLevel {
        return "two different pods with equal contents"
    }
    return "two different pods"
}

let identityPod = TeleportPod(id: "X", chargeLevel: 70)
let identityAlias = identityPod
let identityTwin = TeleportPod(id: "X", chargeLevel: 70)
print(comparePods(identityPod, identityAlias))
print(comparePods(identityPod, identityTwin))
print(comparePods(identityPod, podOne))
