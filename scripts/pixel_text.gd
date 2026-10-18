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
	"\"": [0b01010, 0b01010, 0b00000, 0b00000, 0b00000, 0b00000, 0b00000],
	":": [0b00000, 0b00100, 0b00100, 0b00000, 0b00100, 0b00100, 0b00000],
	";": [0b00000, 0b00100, 0b00100, 0b00000, 0b00100, 0b00100, 0b01000],
	"(": [0b00010, 0b00100, 0b01000, 0b01000, 0b01000, 0b00100, 0b00010],
	")": [0b01000, 0b00100, 0b00010, 0b00010, 0b00010, 0b00100, 0b01000],
	"[": [0b01110, 0b01000, 0b01000, 0b01000, 0b01000, 0b01000, 0b01110],
	"]": [0b01110, 0b00010, 0b00010, 0b00010, 0b00010, 0b00010, 0b01110],
	"/": [0b00001, 0b00010, 0b00010, 0b00100, 0b01000, 0b01000, 0b10000],
	"–": [0b00000, 0b00000, 0b00000, 0b11111, 0b00000, 0b00000, 0b00000],
	"—": [0b00000, 0b00000, 0b00000, 0b11111, 0b00000, 0b00000, 0b00000],
	"ç": [0b00000, 0b00000, 0b01110, 0b10001, 0b10000, 0b10001, 0b00110],
}

## Accent marks drawn above a lowercase vowel, as two rows of five bits.
const ACCENT_MARKS: Dictionary = {
	"acute": [0b00110, 0b00100],
	"grave": [0b00100, 0b00110],
	"circumflex": [0b00100, 0b01010],
	"tilde": [0b01010, 0b00101],
}

## Lowercase accented characters, composed from a base glyph plus a mark: the
## mark fills the two usually-blank top rows and the base keeps its body.
const LOWER_ACCENTED: Dictionary = {
	"á": ["a", "acute"], "à": ["a", "grave"], "â": ["a", "circumflex"], "ã": ["a", "tilde"],
	"é": ["e", "acute"], "è": ["e", "grave"], "ê": ["e", "circumflex"],
	"í": ["i", "acute"], "ì": ["i", "grave"], "î": ["i", "circumflex"],
	"ó": ["o", "acute"], "ò": ["o", "grave"], "ô": ["o", "circumflex"], "õ": ["o", "tilde"],
	"ú": ["u", "acute"], "ù": ["u", "grave"], "û": ["u", "circumflex"],
}

## Uppercase accented characters, hand-drawn to squeeze the mark and the letter
## into the seven-row cell.
const UPPER_ACCENTED: Dictionary = {
	"Á": [0b00110, 0b00100, 0b01110, 0b10001, 0b11111, 0b10001, 0b10001],
	"É": [0b00110, 0b00100, 0b11111, 0b10000, 0b11110, 0b10000, 0b11111],
	"Í": [0b00110, 0b00100, 0b01110, 0b00100, 0b00100, 0b00100, 0b01110],
	"Ó": [0b00110, 0b00100, 0b01110, 0b10001, 0b10001, 0b10001, 0b01110],
	"Ú": [0b00110, 0b00100, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110],
	"Ã": [0b01010, 0b00101, 0b01110, 0b10001, 0b11111, 0b10001, 0b10001],
	"Õ": [0b01010, 0b00101, 0b01110, 0b10001, 0b10001, 0b10001, 0b01110],
	"Ç": [0b01110, 0b10001, 0b10000, 0b10000, 0b10001, 0b01110, 0b00110],
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
	if GLYPHS.has(character):
		return GLYPHS[character]
	if UPPER_ACCENTED.has(character):
		return UPPER_ACCENTED[character]
	if LOWER_ACCENTED.has(character):
		var spec: Array = LOWER_ACCENTED[character]
		var base: Array = GLYPHS[spec[0]]
		var mark: Array = ACCENT_MARKS[spec[1]]
		return [mark[0], mark[1], base[2], base[3], base[4], base[5], base[6]]
	var upper: String = character.to_upper()
	if GLYPHS.has(upper):
		return GLYPHS[upper]
	return GLYPHS["?"]


## Bakes a block of text into one texture: word-wrapped to [param max_width]
## output pixels, with an optional soft [param glow_color] halo and with any
## run wrapped in braces (`{like this}`) drawn in [param highlight_color]
## instead of [param base_color]. [param pixel_scale] blows every font pixel up
## into a square block, so the result stays crisp when drawn at 1:1.
##
## The solid glyph pixels are laid down after the whole glow, so the halo can
## never overwrite the letters and leave them looking translucent.
static func make_rich(
	text: String,
	base_color: Color,
	highlight_color: Color = Color(0, 0, 0, 0),
	glow_color: Color = Color(0, 0, 0, 0),
	max_width: int = 4096,
	pixel_scale: int = 1,
	line_spacing: int = 0
) -> ImageTexture:
	if text.is_empty():
		return null
	if pixel_scale < 1:
		pixel_scale = 1
	var lines: Array = []
	for paragraph in text.split("\n"):
		lines.append_array(_wrap(_styled_words(paragraph, base_color, highlight_color), max_width, pixel_scale))
	var line_height: int = GLYPH_HEIGHT * pixel_scale + line_spacing
	var width: int = 0
	for line in lines:
		width = maxi(width, _line_width(line, pixel_scale))
	if width <= 0:
		return null
	var height: int = lines.size() * line_height - line_spacing
	var image: Image = Image.create_empty(width, maxi(1, height), false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var gap: int = (GLYPH_WIDTH + TRACKING) * pixel_scale
	for row_index in lines.size():
		var pen_x: int = 0
		var pen_y: int = row_index * line_height
		for word in lines[row_index]:
			_draw_word(image, word, Vector2i(pen_x, pen_y), pixel_scale, glow_color)
			pen_x += _word_width(word, pixel_scale) + gap
	return ImageTexture.create_from_image(image)


## Splits a paragraph into words. A word is an array of `{text, color}` segments
## so a highlight may begin or end mid-word; because only spaces start a new
## word, punctuation stays glued to the word it touches.
static func _styled_words(paragraph: String, base_color: Color, highlight_color: Color) -> Array:
	var words: Array = []
	var word: Array = []
	var buffer: String = ""
	var highlight: bool = false
	var count: int = paragraph.length()
	for index in count + 1:
		var character: String = paragraph[index] if index < count else " "
		if character == " " or character == "\t":
			_append_segment(word, buffer, highlight, base_color, highlight_color)
			buffer = ""
			if not word.is_empty():
				words.append(word)
				word = []
		elif character == "{":
			_append_segment(word, buffer, highlight, base_color, highlight_color)
			buffer = ""
			highlight = true
		elif character == "}":
			_append_segment(word, buffer, highlight, base_color, highlight_color)
			buffer = ""
			highlight = false
		else:
			buffer += character
	return words


static func _append_segment(word: Array, buffer: String, highlight: bool, base_color: Color, highlight_color: Color) -> void:
	if buffer.is_empty():
		return
	word.append({"text": buffer, "color": highlight_color if highlight else base_color})


## The width one word occupies at the given scale.
static func _word_width(word: Array, pixel_scale: int) -> int:
	var width: int = 0
	for segment in word:
		width += measure(segment.text).x * pixel_scale
	return width


## Greedy word wrap driven by output-pixel widths.
static func _wrap(words: Array, max_width: int, pixel_scale: int) -> Array:
	var lines: Array = []
	var current: Array = []
	var current_width: int = 0
	var gap: int = (GLYPH_WIDTH + TRACKING) * pixel_scale
	for word in words:
		var word_width: int = _word_width(word, pixel_scale)
		if current.is_empty():
			current.append(word)
			current_width = word_width
		elif max_width > 0 and current_width + gap + word_width > max_width:
			lines.append(current)
			current = [word]
			current_width = word_width
		else:
			current.append(word)
			current_width += gap + word_width
	if not current.is_empty():
		lines.append(current)
	if lines.is_empty():
		lines.append([])
	return lines


static func _line_width(line: Array, pixel_scale: int) -> int:
	var gap: int = (GLYPH_WIDTH + TRACKING) * pixel_scale
	var width: int = 0
	for index in line.size():
		if index > 0:
			width += gap
		width += _word_width(line[index], pixel_scale)
	return width


## Draws one word: the whole glow halo first, then the solid glyph pixels on top.
static func _draw_word(image: Image, word: Array, origin: Vector2i, pixel_scale: int, glow_color: Color) -> void:
	var pixels: Array = _word_pixels(word, origin, pixel_scale)
	if glow_color.a > 0.0:
		for pixel in pixels:
			var position: Vector2i = pixel.pos
			_blit(image, position.x - pixel_scale, position.y, pixel_scale, glow_color)
			_blit(image, position.x + pixel_scale, position.y, pixel_scale, glow_color)
			_blit(image, position.x, position.y - pixel_scale, pixel_scale, glow_color)
			_blit(image, position.x, position.y + pixel_scale, pixel_scale, glow_color)
	for pixel in pixels:
		_blit(image, pixel.pos.x, pixel.pos.y, pixel_scale, pixel.color)


## Every lit pixel of a word, as `{pos, color}` in image coordinates.
static func _word_pixels(word: Array, origin: Vector2i, pixel_scale: int) -> Array:
	var pixels: Array = []
	var pen: int = origin.x
	for segment in word:
		var text: String = segment.text
		for index in text.length():
			var rows: Array = _rows_for(text[index])
			for row in GLYPH_HEIGHT:
				var bits: int = rows[row]
				for column in GLYPH_WIDTH:
					if bits & (1 << (GLYPH_WIDTH - 1 - column)):
						pixels.append({
							"pos": Vector2i(pen + column * pixel_scale, origin.y + row * pixel_scale),
							"color": segment.color,
						})
			pen += (GLYPH_WIDTH + TRACKING) * pixel_scale
	return pixels


static func _blit(image: Image, x: int, y: int, size: int, color: Color) -> void:
	for dy in size:
		for dx in size:
			var px: int = x + dx
			var py: int = y + dy
			if px >= 0 and py >= 0 and px < image.get_width() and py < image.get_height():
				image.set_pixel(px, py, color)