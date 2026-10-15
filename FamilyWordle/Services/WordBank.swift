import Foundation

/// Local dictionary. `answers` is the daily rotation — append new words, do not reorder,
/// or every household's puzzle for a given date will change.
/// `extras` are accepted guesses that are not used as the secret word.
enum WordBank {
    static let answers: [String] = [
        "about", "above", "after", "again", "agree", "ahead", "album", "alive", "allow", "alone",
        "along", "angel", "apple", "apply", "arena", "aroma", "arrow", "awake", "award", "bacon",
        "baker", "beach", "begin", "being", "below", "berry", "birth", "black", "blank", "blaze",
        "bless", "block", "bloom", "board", "bonus", "boost", "bound", "brain", "brave", "bread",
        "break", "brick", "brief", "bring", "broad", "brown", "brush", "build", "bunch", "cabin",
        "candy", "carry", "catch", "cause", "chain", "chair", "chalk", "charm", "chart", "chase",
        "cheap", "check", "cheer", "chess", "chest", "child", "chill", "choir", "clean", "clear",
        "click", "cliff", "climb", "clock", "close", "cloth", "cloud", "clown", "coach", "coast",
        "coral", "couch", "count", "court", "cover", "craft", "cream", "creek", "crisp", "cross",
        "crowd", "crown", "crust", "dance", "diary", "dream", "dress", "drink", "drive", "early",
        "earth", "eight", "elbow", "enjoy", "enter", "equal", "event", "every", "exact", "extra",
        "faith", "fancy", "feast", "field", "final", "first", "flame", "flash", "fleet", "float",
        "flood", "floor", "flour", "focus", "force", "found", "frame", "fresh", "front", "frost",
        "fruit", "funny", "glass", "globe", "glory", "glove", "grace", "grade", "grain", "grand",
        "grape", "grass", "great", "green", "greet", "grill", "group", "grown", "guard", "guess",
        "guest", "guide", "happy", "heart", "heavy", "hello", "honey", "honor", "horse", "hotel",
        "house", "human", "humor", "hurry", "image", "jelly", "jewel", "joint", "jolly", "juice",
        "jumbo", "label", "large", "later", "laugh", "learn", "lemon", "level", "light", "limit",
        "local", "lodge", "logic", "lucky", "lunch", "magic", "major", "maple", "march", "match",
        "maybe", "mayor", "melon", "merry", "metal", "meter", "might", "model", "money", "month",
        "moral", "mouse", "mouth", "movie", "music", "night", "noble", "noise", "north", "novel",
        "nurse", "ocean", "offer", "often", "olive", "onion", "opera", "orbit", "order", "other",
        "outer", "owner", "paint", "paper", "party", "pasta", "peace", "peach", "pearl", "penny",
        "phase", "phone", "photo", "piano", "piece", "pilot", "pitch", "pizza", "place", "plain",
        "plane", "plant", "plate", "plaza", "point", "porch", "pound", "power", "press", "price",
        "pride", "prime", "print", "prize", "proof", "proud", "pulse", "puppy", "queen", "quick",
        "quiet", "radio", "raise", "reach", "ready", "relax", "river", "roast", "robot", "rocky",
        "rough", "round", "royal", "ruler", "salad", "salsa", "sauce", "scale", "scene", "scent",
        "scope", "score", "scout", "sense", "serve", "seven", "shade", "shake", "shape", "share",
        "sharp", "sheep", "sheet", "shelf", "shell", "shine", "shirt", "shore", "short", "shout",
        "sight", "silly", "since", "sixth", "skate", "skill", "skirt", "sleep", "slice", "slide",
        "small", "smart", "smell", "smile", "snack", "solar", "solid", "solve", "sound", "south",
        "space", "spark", "speak", "speed", "spell", "spend", "spice", "spicy", "spoon", "sport",
        "spray", "stack", "stage", "stair", "stamp", "stand", "start", "state", "steak", "steam",
        "steel", "stick", "still", "stone", "store", "storm", "story", "stove", "straw", "study",
        "sugar", "sunny", "super", "sweet", "swift", "table", "taste", "teach", "thank", "theme",
        "there", "thick", "thing", "think", "third", "those", "three", "throw", "tiger", "tight",
        "timer", "toast", "today", "token", "topic", "total", "touch", "tough", "towel", "tower",
        "track", "trail", "train", "treat", "trend", "trick", "truck", "truly", "trust", "truth",
        "tulip", "uncle", "under", "union", "unity", "until", "upper", "usual", "value", "video",
        "visit", "vital", "vivid", "vocal", "voice", "wagon", "watch", "water", "wheat", "wheel",
        "where", "which", "while", "white", "whole", "world", "worry", "worth", "would", "write",
        "young", "youth", "zebra"
    ]

    static let extras: [String] = [
        "adieu", "aisle", "alien", "align", "alley", "allot", "alloy", "amuse", "ankle", "antic",
        "apart", "audio", "avoid", "basic", "beard", "bench", "blade", "blame", "cable", "camel",
        "canoe", "cargo", "carve", "cater", "cedar", "claim", "class", "clerk", "cling", "clone",
        "could", "crane", "crate", "crawl", "creak", "creed", "crept", "cried", "crumb", "cubic",
        "curly", "curry", "cycle", "daddy", "daily", "daisy", "dealt", "debut", "delay", "delta",
        "denim", "dense", "depth", "digit", "diner", "dizzy", "donor", "donut", "doubt", "dough",
        "dozen", "draft", "drain", "drake", "drama", "drawn", "dried", "drift", "drill", "drove",
        "dwarf", "eager", "eagle", "eaten", "eater", "eerie", "elect", "elite", "empty", "enact",
        "entry", "error", "essay", "evict", "exist", "fable", "fairy", "false", "fault", "favor",
        "fence", "ferry", "fever", "fiber", "fifty", "fight", "finch", "flair", "flake", "flaky",
        "flank", "flare", "flask", "flesh", "flick", "fling", "flint", "flora", "floss", "fluid",
        "flute", "foggy", "folio", "folly", "forge", "forth", "forty", "forum", "foyer", "frail",
        "frank", "fried", "frill", "frown", "fudge", "fully", "gamut", "gauge", "gaunt", "gecko",
        "genre", "giant", "given", "glade", "glare", "gleam", "glide", "gloom", "gloss", "goose",
        "gorge", "gourd", "graft", "grail", "grant", "graph", "grasp", "grate", "gravy", "graze",
        "greed", "grief", "grime", "grind", "groom", "gross", "grove", "guild", "habit", "hairy",
        "handy", "hardy", "harsh", "hatch", "haven", "hazel", "heard", "heath", "heave", "hedge",
        "hefty", "heron", "hilly", "hinge", "hippo", "hobby", "holly", "homer", "horde", "hound",
        "hover", "howdy", "humid", "hunch", "husky", "icily", "icing", "ideal", "idiom", "igloo",
        "imply", "index", "inept", "inert", "infer", "inner", "input", "intro", "irony", "issue",
        "ivory", "jaunt", "jazzy", "jerky", "jetty", "joker", "joust", "judge", "juicy", "kayak",
        "khaki", "kiosk", "kitty", "knack", "kneel", "knife", "knock", "known", "koala", "labor",
        "laden", "lance", "lanky", "lapse", "lasso", "latch", "lathe", "latte", "layer", "leafy",
        "leaky", "leapt", "lease", "leash", "least", "leave", "ledge", "legal", "leggy", "lemur",
        "lever", "lilac", "limbo", "linen", "liner", "lingo", "liver", "llama", "lofty", "login",
        "loose", "lover", "lower", "loyal", "lucid", "lunar", "lunge", "lyric", "madam", "madly",
        "maize", "maker", "mango", "mania", "manor", "marry", "marsh", "mason", "maxim", "meaty",
        "medal", "media", "medic", "melee", "mercy", "merge", "merit", "metro", "midst", "milky",
        "mimic", "miner", "minor", "minus", "mirth", "mixer", "mocha", "modem", "moist", "molar",
        "moose", "mossy", "motel", "motif", "motor", "motto", "mound", "mount", "mourn", "mover",
        "mower", "muddy", "mulch", "munch", "mural", "mushy", "musky", "naive", "nanny", "nasal",
        "naval", "needy", "nerdy", "nerve", "never", "newer", "newly", "niche", "niece", "ninja",
        "ninth", "nomad", "notch", "nudge", "nutty", "nylon", "occur", "older", "omega", "onset",
        "opine", "optic", "organ", "otter", "ought", "outdo", "ovary", "oxide", "ozone", "pagan",
        "paler", "panel", "panic", "pansy", "parka", "paste", "pasty", "patch", "patio", "pause",
        "payer", "pecan", "pedal", "penal", "perch", "peril", "perky", "petal", "petty", "picky",
        "piggy", "pinch", "piney", "pinky", "piper", "pixel", "pixie", "plaid", "plank", "plead",
        "pleat", "pluck", "plumb", "plume", "plump", "plush", "poise", "poker", "polar", "polka",
        "poppy", "poser", "pouch", "prank", "prick", "prism", "probe", "prone", "prong", "prose",
        "prove", "prowl", "prune", "psalm", "pudgy", "puffy", "punch", "pupil", "purge", "purse",
        "quack", "quail", "quake", "quart", "query", "quest", "queue", "quill", "quilt", "quirk",
        "quite", "quota", "quote", "radar", "rainy", "rally", "ranch", "range", "rapid", "ratio",
        "raven", "razor", "react", "realm", "rebel", "recap", "refer", "regal", "reign", "relay",
        "relic", "renew", "repay", "repel", "reply", "reset", "reuse", "rhyme", "rider", "ridge",
        "right", "rigid", "rinse", "ripen", "risen", "risky", "rival", "rivet", "robin", "rodeo",
        "rogue", "roomy", "roost", "rouge", "rouse", "route", "rover", "rowdy", "rower", "ruddy",
        "rugby", "rumor", "rural", "rusty", "sadly", "safer", "saint", "sally", "salon", "salty",
        "sandy", "satin", "sauna", "savor", "savvy", "scalp", "scamp", "scant", "scare", "scarf",
        "scary", "scold", "scone", "scoop", "scorn", "scour", "scowl", "scrap", "scrub", "sedan",
        "seize", "serif", "serum", "setup", "sever", "sewer", "shack", "shady", "shaft", "shaky",
        "shall", "shame", "shank", "shard", "shark", "shave", "shawl", "shear", "sheen", "sheer",
        "sheik", "shift", "shiny", "shock", "shoot", "shorn", "shove", "shown", "shrew", "shrub",
        "shrug", "shyly", "siege", "sigma", "silky", "sinew", "siren", "sixty", "skier", "skull",
        "skunk", "slack", "slang", "slant", "slash", "slate", "sleek", "sleet", "slept", "slick",
        "slime", "sling", "slink", "slope", "sloth", "slump", "slush", "smack", "smash", "smear",
        "smelt", "smirk", "smith", "smock", "smoke", "smoky", "snail", "snake", "snare", "snarl",
        "sneak", "snipe", "snore", "snout", "snowy", "soapy", "sober", "soggy", "sonar", "sonic",
        "sooty", "sorry", "sower", "spade", "spare", "spawn", "spear", "speck", "spelt", "spent",
        "spiel", "spike", "spill", "spine", "spire", "spite", "split", "spoil", "spoke", "spook",
        "spool", "spore", "spout", "spree", "squad", "squat", "staff", "stain", "stake", "stale",
        "stalk", "stall", "stare", "stark", "stash", "stead", "steal", "steed", "steep", "steer",
        "stern", "stiff", "stilt", "sting", "stink", "stock", "stoic", "stoke", "stole", "stomp",
        "stony", "stood", "stool", "stoop", "stork", "stout", "strap", "stray", "strip", "stuck",
        "stuff", "stump", "stunt", "style", "suave", "suite", "sulky", "sumac", "surer", "surge",
        "surly", "sushi", "swamp", "swarm", "swear", "sweat", "sweep", "swell", "swept", "swing",
        "swirl", "swish", "swoon", "swoop", "sword", "swore", "sworn", "swung", "syrup", "tabby",
        "taboo", "tacit", "tacky", "taunt", "tawny", "tease", "teddy", "teeth", "tempo", "tenet",
        "tenor", "tense", "tenth", "terry", "testy", "their", "these", "theta", "thief", "thigh",
        "thong", "thorn", "threw", "throb", "thump", "thyme", "tiara", "tibia", "tidal", "tilde",
        "timid", "tipsy", "titan", "title", "toddy", "tonal", "tonic", "tooth", "topaz", "torch",
        "torso", "totem", "toxic", "trace", "tract", "trade", "trait", "tramp", "trash", "tread",
        "triad", "trial", "tribe", "trice", "tried", "trite", "troll", "troop", "trope", "trout",
        "trove", "truce", "trump", "trunk", "truss", "tryst", "tulle", "tunic", "turbo", "tutor",
        "twang", "tweak", "tweed", "twice", "twine", "twirl", "twist", "ultra", "umbra", "uncut",
        "undue", "unify", "unite", "unlit", "unmet", "untie", "unwed", "upset", "urban", "usage",
        "usher", "utter", "vague", "valid", "valor", "valve", "vapor", "vault", "vegan", "venom",
        "venue", "verge", "verse", "vicar", "vigil", "vigor", "villa", "vinyl", "viola", "viper",
        "viral", "visor", "vista", "vixen", "vodka", "vogue", "voila", "voter", "vowel", "wacky",
        "wafer", "wager", "waist", "waive", "waltz", "waste", "waver", "weary", "weave", "wedge",
        "weedy", "weigh", "weird", "whack", "whale", "wharf", "whelp", "whiff", "whine", "whirl",
        "whisk", "whoop", "whose", "widen", "wider", "widow", "width", "wield", "wince", "windy",
        "wiser", "wispy", "witty", "woken", "woman", "women", "woody", "wooly", "woozy", "wordy",
        "worse", "worst", "wound", "woven", "wrath", "wreak", "wreck", "wrest", "wring", "wrist",
        "wrong", "wrote", "yacht", "yearn", "yeast", "yield", "zesty"
    ]

    /// Built once. Duplicates between the two lists collapse here.
    static let allowed: Set<String> = Set(answers + extras)

    static func contains(_ word: String) -> Bool {
        allowed.contains(word.lowercased())
    }

    /// Same calendar day, same word, in the device's local time zone.
    /// A family in one living room shares midnight; the index does not depend on a server.
    static func dailyAnswer(on date: Date = .now) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.startOfDay(for: date)
        let epoch = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)) ?? start
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: epoch), to: start).day ?? 0
        let count = answers.count
        let index = ((days % count) + count) % count
        return answers[index]
    }

    static func practiceAnswer(excluding current: String? = nil) -> String {
        let banned = current?.lowercased()
        let pool = answers.filter { $0 != banned }
        return pool.randomElement() ?? answers[0]
    }

    static func dayKey(for date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
