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

    let a =
    int.random(0xFF_FF_FF_FF)
    |> int.to_base16
    |> string.pad_left(8, "0")

    let b =
    int.random(0xFF_FF_FF_FF)
    |> int.bitwise_and(0xFF_FF_0F_FF)
    |> int.bitwise_or(0x00_00_40_00)
    |> int.to_base16
    |> string.pad_left(8, "0")

    let c =
    int.random(0xFF_FF_FF_FF)
    |> int.bitwise_and(0x3F_FF_FF_FF)
    |> int.bitwise_or(0x80_00_00_00)
    |> int.to_base16
    |> string.pad_left(8, "0")

    let d =
    int.random(0xFF_FF_FF_FF)
    |> int.to_base16
    |> string.pad_left(8, "0")

  let concatened = a <> b <> c <> d

  format_uuid(concatened)
}
