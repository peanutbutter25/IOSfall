import Foundation

/// One favorite dish shown on the roulette card.
struct Favorite {
    let imageName: String   // name of the image in Assets.xcassets
    let title: String
    let description: String
}

extension Favorite {
    /// Category: food. Exactly 10 favorites.
    static let all: [Favorite] = [
        Favorite(imageName: "beshbarmak",
                 title: "Beshbarmak",
                 description: "Kazakhstan's national dish: tender boiled meat over thin sheets of dough with onion sauce. Best shared with family."),
        Favorite(imageName: "plov",
                 title: "Plov",
                 description: "Rice cooked in a kazan with lamb, yellow carrots and whole garlic. Smoky, rich and even better the next day."),
        Favorite(imageName: "manty",
                 title: "Manty",
                 description: "Big steamed dumplings filled with juicy minced meat and onion. Served with sour cream and spicy chili sauce."),
        Favorite(imageName: "baursaks",
                 title: "Baursaks",
                 description: "Golden fried dough pillows, crispy outside and fluffy inside. Perfect with tea, honey or jam."),
        Favorite(imageName: "shashlik",
                 title: "Shashlik",
                 description: "Marinated meat grilled over charcoal on long skewers and served with pickled onion. The taste of summer."),
        Favorite(imageName: "pizza",
                 title: "Pepperoni Pizza",
                 description: "Thin crust, tomato sauce, melted mozzarella and spicy pepperoni. The perfect choice for a movie night."),
        Favorite(imageName: "sushi",
                 title: "Sushi",
                 description: "Fresh salmon nigiri and maki rolls with wasabi and soy sauce. Light, clean and beautiful on the plate."),
        Favorite(imageName: "ramen",
                 title: "Ramen",
                 description: "Hot rich broth with springy noodles, a soft-boiled egg and chashu pork. Warms you up on a cold day."),
        Favorite(imageName: "burger",
                 title: "Cheeseburger",
                 description: "Juicy beef patty, cheddar, lettuce and tomato in a toasted sesame bun. Simple and always satisfying."),
        Favorite(imageName: "icecream",
                 title: "Ice Cream",
                 description: "Vanilla, strawberry and chocolate scoops in a crunchy waffle cone. The best dessert after any meal.")
    ]
}
