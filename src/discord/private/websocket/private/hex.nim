proc nibbleFromChar(c: char): int =
  case c
  of '0'..'9': result = (ord(c) - ord('0'))
  of 'a'..'f': result = (ord(c) - ord('a') + 10)
  of 'A'..'F': result = (ord(c) - ord('A') + 10)
  else: discard 255

proc decodeHex*(str: string): string =
  var length = len(str) div 2
  var bytes: seq[char] = newSeq[char](length)
  var i = 0
  while i < (length):
    bytes[i] = chr((nibbleFromChar(str[2 * i]) shl 4) or nibbleFromChar(str[2 * i + 1]))
    inc(i)
  return cast[string](bytes)

proc nibbleToChar(nibble: int): char =
  const byteMap = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']
  const byteMapLen = len(byteMap)
  try:
    if nibble < byteMapLen:
      return byteMap[nibble];
  except ValueError:
    echo "Hex string character out of range for valid hex char"

proc encodeHex*(str: string): string =
  var length = (len(str))
  var bytes: seq[char] = newSeq[char](length * 2)
  var i = 0
  while i < length:
    var a = ord(str[i]) shr 4
    var b = ord(str[i]) and ord(0x0f)
    bytes[i * 2] = nibbleToChar(a)
    bytes[i * 2 + 1] = nibbleToChar(b)
    inc(i)
  return cast[string](bytes)
