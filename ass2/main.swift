//
//  main.swift
//  MyApp
//
//  Created by Talshyn Rakhatkyzy on 20.09.2026.
//
import Foundation


let fruits = ["Apple", "Banana", "Orange", "Mango", "Strawberry"]

print("Easy Task 1:")
print(fruits[2])


var favoriteNumbers: Set = [7, 13, 21, 42]

favoriteNumbers.insert(100)

print("\nEasy Task 2:")
print(favoriteNumbers)


let programmingLanguages = [
    "Python": 1991,
    "Java": 1995,
    "Swift": 2014
]

print("\nEasy Task 3:")
print(programmingLanguages["Swift"]!)


var colors = ["Red", "Blue", "Green", "Yellow"]

colors[1] = "Purple"

print("\nEasy Task 4:")
print(colors)


let firstSet: Set = [1, 2, 3, 4]
let secondSet: Set = [3, 4, 5, 6]

let intersection = firstSet.intersection(secondSet)

print("\nMedium Task 1:")
print(intersection)


var students = [
    "Aidar": 85,
    "Aruzhan": 92,
    "Dias": 78
]

students.updateValue(95, forKey: "Aidar")

print("\nMedium Task 2:")
print(students)



let firstArray = ["apple", "banana"]
let secondArray = ["cherry", "date"]

let mergedArray = firstArray + secondArray

print("\nMedium Task 3:")
print(mergedArray)



var countries = [
    "Kazakhstan": 20_000_000,
    "USA": 340_000_000,
    "Japan": 124_000_000
]

countries["Germany"] = 84_000_000

print("\nHard Task 1:")
print(countries)


let firstAnimals: Set = ["cat", "dog"]
let secondAnimals: Set = ["dog", "mouse"]

let unionSet = firstAnimals.union(secondAnimals)
let finalSet = unionSet.subtracting(secondAnimals)

print("\nHard Task 2:")
print(finalSet)


let studentGrades = [
    "Aidar": [85, 90, 78],
    "Aruzhan": [95, 88, 92],
    "Dias": [76, 84, 80]
]

print("\nHard Task 3:")
print(studentGrades["Aidar"]![1])


