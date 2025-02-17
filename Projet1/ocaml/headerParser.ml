open Bigarray

(* Utilitaire : Lire un entier 8 bits *)
let read_byte ic =
  input_byte ic

(* Utilitaire : Lire un entier 32 bits en little-endian *)
let read_int32 ic =
  let b1 = input_byte ic in
  let b2 = input_byte ic in
  let b3 = input_byte ic in
  let b4 = input_byte ic in
  Int32.logor (Int32.shift_left (Int32.of_int b4) 24)
    (Int32.logor (Int32.shift_left (Int32.of_int b3) 16)
       (Int32.logor (Int32.shift_left (Int32.of_int b2) 8)
          (Int32.of_int b1)))

(* Utilitaire : Lire une chaîne binaire de longueur fixée *)
let read_string ic len =
  let buf = Bytes.create len in
  really_input ic buf 0 len;
  Bytes.to_string buf

(* Structure du header *)
type lua_header = {
  signature : string;
  version : int;
  format : int;
  endianness : int;
  int_size : int;
  size_t_size : int;
  instruction_size : int;
  lua_number_size : int;
  number_format : int;
  test_number : int32;
}

(* Fonction pour parser le header *)
let parse_lua_header ic =
  let signature = read_string ic 4 in
  if signature <> "\x1bLua" then failwith "Invalid Lua signature";

  let version = read_byte ic in
  let format = read_byte ic in
  let endianness = read_byte ic in
  let int_size = read_byte ic in
  let size_t_size = read_byte ic in
  let instruction_size = read_byte ic in
  let lua_number_size = read_byte ic in
  let number_format = read_byte ic in
  let test_number = read_int32 ic in

  { signature; version; format; endianness; int_size;
    size_t_size; instruction_size; lua_number_size;
    number_format; test_number }

(* Exemple d'utilisation *)
let () =
  let ic = open_in_bin "luac.out" in
  let header = parse_lua_header ic in
  close_in ic;
  
  Printf.printf "Lua Version: %d.%d\n" (header.version / 16) (header.version mod 16);
  Printf.printf "Endianness: %s\n" (if header.endianness = 1 then "Little" else "Big");
  Printf.printf "Int size: %d bytes\n" header.int_size;
  Printf.printf "Number format: %d\n" header.number_format;