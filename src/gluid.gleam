import gleam/io
import gleam/int
import gleam/string

fn split_to_chunks(src: String, chunk_size: Int) -> List(String) {
  case string.length(src) {
    len if len >= chunk_size -> {
      let head = string.slice(src, 0, chunk_size)
      let tail = string.slice(src, chunk_size, len - chunk_size)
      [head, ..split_to_chunks(tail, chunk_size)]
    }
    _ -> []
  }
}

fn binary_pprint(src: Int) -> String {
  src
  |> int.to_base2
  |> string.pad_left(32, "0")
  |> split_to_chunks(4)
  |> string.join(" ")
}

fn format_uuid(src: String) -> String {
  string.slice(src, 0, 8)
  <> "-"
  <> string.slice(src, 8, 4)
  <> "-"
  <> string.slice(src, 12, 4)
  <> "-"
  <> string.slice(src, 16, 4)
  <> "-"
  <> string.slice(src, 20, 12)
}

pub fn guidv4() -> String {
  // Original doc: https://www.cryptosys.net/pki/uuid-rfc4122.html

  // 16 random bytes -> let's chunk it into 4 * 4 bytes
  // named: A, B, C, D

  //                  A                 |                 B                  |
  //                  C                 |                 D                  |
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
  // 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

  // Adjust certain bits according to RFC 4122 section 4.4 as follows:
  // set the four most significant bits of the 7th byte to 0100'B, so the high nibble is "4"
  // set the two most significant bits of the 9th byte to 10'B, so the high nibble will be one of "8", "9", "A", or "B" (see Note 1).

  // From the RFC:
  // - the 7th byte is the 3rd byte of B
  // - the 9th byte is the 1st byte of C

  // set A
  let randoma = int.random(0xFFFFFFFF)
  let a =
    int.to_base16(randoma)
    |> string.pad_left(8, "0")

  // set B
  let randomb = int.random(0xFFFFFFFF)
  let clear_mask = int.bitwise_not(int.bitwise_shift_left(0xF, 12))
  // 0000 1111 1111 1111
  let randomb = int.bitwise_and(randomb, clear_mask)
  let value_mask = int.bitwise_shift_left(0x4, 12)
  // 0100 0000 0000 0000
  // ^^^^
  let randomb = int.bitwise_or(randomb, value_mask)
  let b =
    int.to_base16(randomb)
    |> string.pad_left(8, "0")

  // set C
  let randomc = int.random(0xFFFFFFFF)
  let clear_mask = int.bitwise_not(int.bitwise_shift_left(0x3, 30))
  // 0011_1111 1111_1111 1111_1111 1111_1111
  let randomc = int.bitwise_and(randomc, clear_mask)
  let value_mask = int.bitwise_shift_left(0x2, 30)
  // 1000_0000 0000_0000 0000_0000 0000_0000
  // ^^
  let randomc = int.bitwise_or(randomc, value_mask)
  let c =
    int.to_base16(randomc)
    |> string.pad_left(8, "0")

  let randomd = int.random(0xFFFFFFFF)
  let d =
    randomd
    |> int.to_base16
    |> string.pad_left(8, "0")

  let concatened = a <> b <> c <> d

  format_uuid(concatened)
}
