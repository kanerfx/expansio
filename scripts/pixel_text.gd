class_name PixelText
extends RefCounted
## A tiny built-in 5x7 bitmap font baked into an [ImageTexture] at runtime.
##
## The project has no pixel font asset, and an image generator cannot spell
## reliably at this size, so the glyphs live here as data. Use it for any world
## text that has to match the game's chunky pixel look.

const GLYPH_WIDTH := 5
const GLYPH_HEIGHT := 7
## Blank columns inserted between glyphs.
const TRACKING := 1

## Each glyph is seven rows. The low five bits of a row are its pixels, with
## the most significant bit on the left. Unknown characters fall back to "?".
const GLYPHS: Dictionary = {
	" ": [0b00000, 0b00000, 0b00000, 0b00000, 0b00000, 0b00000, 0b00000],
	"A": [0b01110, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001],
	"B": [0b11110, 0b10001, 0b10001, 0b11110, 0b10001, 0b10001, 0b11110],
	"C": [0b01110, 0b10001, 0b10000, 0b10000, 0b10000, 0b10001, 0b01110],
	"D": [0b11110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b11110],
	"E": [0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b11111],
	"F": [0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b10000],
	"G": [0b01110, 0b10001, 0b10000, 0b10111, 0b10001, 0b10001, 0b01111],
	"H": [0b10001, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001],
	"I": [0b01110, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110],
	"J": [0b00111, 0b00010, 0b00010, 0b00010, 0b00010, 0b10010, 0b01100],
	"K": [0b10001, 0b10010, 0b10100, 0b11000, 0b10100, 0b10010, 0b10001],
	"L": [0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b11111],
	"M": [0b10001, 0b11011, 0b10101, 0b10101, 0b10001, 0b10001, 0b10001],
	"N": [0b10001, 0b11001, 0b10101, 0b10011, 0b10001, 0b10001, 0b10001],
	"O": [0b01110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110],
	"P": [0b11110, 0b10001, 0b10001, 0b11110, 0b10000, 0b10000, 0b10000],
	"Q": [0b01110, 0b10001, 0b10001, 0b10001, 0b10101, 0b10010, 0b01101],
	"R": [0b11110, 0b10001, 0b10001, 0b11110, 0b10100, 0b10010, 0b10001],
	"S": [0b01111, 0b10000, 0b10000, 0b01110, 0b00001, 0b00001, 0b11110],
	"T": [0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100],
	"U": [0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110],
	"V": [0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01010, 0b00100],
	"W": [0b10001, 0b10001, 0b10001, 0b10101, 0b10101, 0b11011, 0b10001],
	"X": [0b10001, 0b10001, 0b01010, 0b00100, 0b01010, 0b10001, 0b10001],
	"Y": [0b10001, 0b10001, 0b01010, 0b00100, 0b00100, 0b00100, 0b00100],
	"Z": [0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b10000, 0b11111],
	"a": [0b00000, 0b00000, 0b01110, 0b00001, 0b01111, 0b10001, 0b01111],
	"b": [0b10000, 0b10000, 0b11110, 0b10001, 0b10001, 0b10001, 0b11110],
	"c": [0b00000, 0b00000, 0b01110, 0b10001, 0b10000, 0b10001, 0b01110],
	"d": [0b00001, 0b00001, 0b01111, 0b10001, 0b10001, 0b10001, 0b01111],
	"e": [0b00000, 0b00000, 0b01110, 0b10001, 0b11111, 0b10000, 0b01110],
	"f": [0b00110, 0b01001, 0b01000, 0b11100, 0b01000, 0b01000, 0b01000],
	"g": [0b00000, 0b01111, 0b10001, 0b10001, 0b01111, 0b00001, 0b01110],
	"h": [0b10000, 0b10000, 0b11110, 0b10001, 0b10001, 0b10001, 0b10001],
	"i": [0b00100, 0b00000, 0b01100, 0b00100, 0b00100, 0b00100, 0b01110],
	"j": [0b00010, 0b00000, 0b00110, 0b00010, 0b00010, 0b10010, 0b01100],
	"k": [0b10000, 0b10000, 0b10010, 0b10100, 0b11000, 0b10100, 0b10010],
	"l": [0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110],
	"m": [0b00000, 0b00000, 0b11010, 0b10101, 0b10101, 0b10101, 0b10101],
	"n": [0b00000, 0b00000, 0b11110, 0b10001, 0b10001, 0b10001, 0b10001],
	"o": [0b00000, 0b00000, 0b01110, 0b10001, 0b10001, 0b10001, 0b01110],
	"p": [0b00000, 0b11110, 0b10001, 0b10001, 0b11110, 0b10000, 0b10000],
	"q": [0b00000, 0b01111, 0b10001, 0b10001, 0b01111, 0b00001, 0b00001],
	"r": [0b00000, 0b00000, 0b10110, 0b11001, 0b10000, 0b10000, 0b10000],
	"s": [0b00000, 0b00000, 0b01111, 0b10000, 0b01110, 0b00001, 0b11110],
	"t": [0b01000, 0b01000, 0b11100, 0b01000, 0b01000, 0b01001, 0b00110],
	"u": [0b00000, 0b00000, 0b10001, 0b10001, 0b10001, 0b10011, 0b01101],
	"v": [0b00000, 0b00000, 0b10001, 0b10001, 0b10001, 0b01010, 0b00100],
	"w": [0b00000, 0b00000, 0b10001, 0b10101, 0b10101, 0b10101, 0b01010],
	"x": [0b00000, 0b00000, 0b10001, 0b01010, 0b00100, 0b01010, 0b10001],
	"y": [0b00000, 0b10001, 0b10001, 0b10001, 0b01111, 0b00001, 0b01110],
	"z": [0b00000, 0b00000, 0b11111, 0b00010, 0b00100, 0b01000, 0b11111],
	"0": [0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110],
	"1": [0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110],
	"2": [0b01110, 0b10001, 0b00001, 0b00010, 0b00100, 0b01000, 0b11111],
	"3": [0b11111, 0b00010, 0b00100, 0b00010, 0b00001, 0b10001, 0b01110],
	"4": [0b00010, 0b00110, 0b01010, 0b10010, 0b11111, 0b00010, 0b00010],
	"5": [0b11111, 0b10000, 0b11110, 0b00001, 0b00001, 0b10001, 0b01110],
	"6": [0b00110, 0b01000, 0b10000, 0b11110, 0b10001, 0b10001, 0b01110],
	"7": [0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b01000, 0b01000],
	"8": [0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110],
	"9": [0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b00010, 0b01100],
	".": [0b00000, 0b00000, 0b00000, 0b00000, 0b00000, 0b01100, 0b01100],
	",": [0b00000, 0b00000, 0b00000, 0b00000, 0b00110, 0b00110, 0b00100],
	"!": [0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00000, 0b00100],
	"?": [0b01110, 0b10001, 0b00001, 0b00110, 0b00100, 0b00000, 0b00100],
	"-": [0b00000, 0b00000, 0b00000, 0b11111, 0b00000, 0b00000, 0b00000],
	"'": [0b00100, 0b00100, 0b00000, 0b00000, 0b00000, 0b00000, 0b00000],
	":": [0b00000, 0b00100, 0b00100, 0b00000, 0b00100, 0b00100, 0b00000],
}


## Pixel size the string would occupy at 1:1, in font pixels.
static func measure(text: String) -> Vector2i:
	var count: int = text.length()
	if count <= 0:
		return Vector2i.ZERO
	return Vector2i(count * GLYPH_WIDTH + (count - 1) * TRACKING, GLYPH_HEIGHT)


## Bakes a string into a texture, one font pixel per image pixel. Returns null
## for an empty string.
static func make_texture(text: String, color: Color) -> ImageTexture:
	var size: Vector2i = measure(text)
	if size.x <= 0 or size.y <= 0:
		return null
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var pen: int = 0
	for index in text.length():
		var rows: Array = _rows_for(text[index])
		for row in GLYPH_HEIGHT:
			var bits: int = rows[row]
			for column in GLYPH_WIDTH:
				if bits & (1 << (GLYPH_WIDTH - 1 - column)):
					image.set_pixel(pen + column, row, color)
		pen += GLYPH_WIDTH + TRACKING
	return ImageTexture.create_from_image(image)


static func _rows_for(character: String) -> Array:
	var rows: Variant = GLYPHS.get(character)
	if rows == null:
		rows = GLYPHS.get(character.to_upper())
	if rows == null:
		rows = GLYPHS.get("?")
	return rows