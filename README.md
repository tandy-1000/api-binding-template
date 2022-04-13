## So you want to make REST API bindings in Nim...

### Features:
- Never write boiler plate again.
- Out of the box support for native C / C++ and JS backend.
- Has [jsony](https://github.com/treeform/jsony/) hooks to ease working with snake_case APIs.
- Uses `fastsync` pragma from [asyncutils](https://github.com/tandy-1000/asyncutils) to enable sync / async with reduced code duplication.

### Used to build:
- [listenbrainz-nim](https://gitlab.com/tandy1000/listenbrainz-nim)
- [lastfm-nim](https://gitlab.com/tandy1000/lastfm-nim)
- [matrix-nim-sdk](https://github.com/dylhack/matrix-nim-sdk)
