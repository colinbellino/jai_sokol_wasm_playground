mergeInto(LibraryManager.library, {
  $UTF8ToString__sig: 'ip', // Override the signature of UTF8ToString to use BigInt instead of Number

  wasm_write_string: (s_count, s_data, log_flag) => {
    function js_string_from_jai_string(pointer, length) {
      const text_decoder = new TextDecoder();
      const u8 = new Uint8Array(wasmMemory.buffer)
      const bytes = u8.subarray(Number(pointer), Number(pointer) + Number(length));
      return text_decoder.decode(bytes);
    }

    const string = js_string_from_jai_string(s_data, s_count);

    switch (log_flag) {
      case /* ERROR */   0x1: { console.error(string); } break;
      case /* WARNING */ 0x2: { console.warn(string); } break;
      case /* CONTENT */ 0x4: { console.info(`%c${string}`, "color: #3949ab;"); } break;
      default:                { console.log(string); }
    }
    // Module.print(string);
  },

  wasm_debug_break: () => {
    debugger;
  },
});