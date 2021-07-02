# play-rust - A local Rust playground for emacs

This package makes `M-x play-rust` start a new Rust project and drop you right
into `main.rs`.

It also sets `compile-command` so that `M-x compile` knows that you probably want to do `cargo rust`.

TODO:

*   Auto-populate Cargo.toml dependencies on compilation (e.g. if I use
    `rand::random`, don't force me to edit `Cargo.toml`)

*   menu of playgrounds, using first line of `main.rs` (should put a comment on
    that line when first opening the file, maybe, as a hint ... for playgrounds
    where nobody bothered to edit the first line, perhaps show the first line
    of the file that is unique across playgrounds)

*   GC `target` directories that haven't been used for a while

*   full text search of playgrounds

*   ability to publish to play.rust-lang.org for sharing,
    copying the link to your clipboard and/or opening it in a browser

*   benchmark support?
