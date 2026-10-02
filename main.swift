//
//  main.swift
//  MyApp
//
//  Created by Talshyn Rakhatkyzy on 20.09.2026.
//
import Foundation

var firstName: String = "Talshyn"
var lastName: String = "Rakhatkyzy"
var birthYear: Int = 2006
var isStudent: Bool = true
var height: Double = 1.65
var city: String = "Almaty"
var university: String = "KBTU"
var favoriteColor: String = "blue"

let currentYear: Int = 2026
let age: Int = currentYear - birthYear

var hobby: String = "painting"
var numberOfHobbies: Int = 4
var favoriteNumber: Int = 9
var isHobbyCreative: Bool = true

var futureGoals: String = "become a professional iOS developer"
var 🎯 = "build my own app"
var mood = "😊"

var lifeStory = "My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). "
lifeStory += "I am \(isStudent ? "currently a student" : "not a student") at \(university) in \(city). "
lifeStory += "I am \(height) meters tall, and my favorite color is \(favoriteColor). "
lifeStory += "I enjoy \(hobby), which is \(isHobbyCreative ? "a creative" : "not a creative") hobby. "
lifeStory += "I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber). "
lifeStory += "In the future, I want to \(futureGoals) and \(🎯). \(mood)"

print(lifeStory)
