extends Node

const vowels: Array[String] = ["a", "e", "i", "o", "u"]
## Returns "a" or "an" depending on the given phrase
func a_or_an_from(phrase: String) -> String:
	if len(phrase.strip_edges()) < 1:
		return ""
	var first_char = phrase.strip_edges()[0].to_lower()
	if first_char in vowels:
		return "an"
	else:
		return "a"
