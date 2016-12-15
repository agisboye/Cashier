import PackageDescription

let package = Package(
    name: "Cashier",
    targets: [
        // Framework
        Target(name: "Cashier"),
    ],
    dependencies: [

        // JSON enum wrapper around Foundation JSON
//        .Package(url: "https://github.com/vapor/json.git", majorVersion: 1),

    ],
    exclude: [

    ]
)
