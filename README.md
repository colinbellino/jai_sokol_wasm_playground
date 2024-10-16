# JAI Sokol WASM example

This is a small project to demo how to use Jai + Sokol and output to WASM.

Notes:
- Jai only supports WASM64 at the moment, so we need the [Memory64](https://github.com/WebAssembly/memory64/blob/main/proposals/memory64/Overview.md) extension for now. It's available as a feature flag in [some browsers](https://webassembly.org/features/#table-row-memory64).
- I'm (unfortunately) using [emscripten](https://emscripten.org) to compile the final wasm file so everything is still clunky.
- Sokol-jai: https://github.com/colinbellino/sokol-jai

## How to build?
- Run `jai first.jai`, which should output in the `dist/` folder.
- Serve the `dist/` folder with any server you want (any tool that can app serve static assets should work).
- Open in a browser. (http://127.0.0.1:8080 for example)