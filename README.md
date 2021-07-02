# play-rust - A local Rust playground for emacs

This package makes `M-x play-rust` start a new Rust project and drop you right
into `main.rs`.

It also sets `compile-command` so that `M-x compile` knows that you probably
want to do `cargo run`.


### Future directions

*   Make compilation work even if you've deleted `main`, perhaps by silently
    renaming the file and buffer to `lib.rs`.

*   Auto-populate Cargo.toml dependencies on compilation (e.g. if I use
    `rand::random`, don't force me to edit `Cargo.toml`)

*   Menu of playgrounds, using first line of `main.rs` (should put a comment on
    that line when first opening the file, maybe, as a hint ... for playgrounds
    where nobody bothered to edit the first line, perhaps show the first line
    of the file that is unique across playgrounds)

*   GC `target` directories that haven't been used for a while

*   Full text search of playgrounds

*   Ability to publish to play.rust-lang.org for sharing,
    copying the link to your clipboard and/or opening it in a browser

*   benchmark support?

*   consider adding a minor mode, under rust-mode, so we can steal some
    features from `rust-playground`:

    - bind `C-c C-c` to a `compile` that skips the compile-command prompt

    - toggle between `Cargo.toml` and `main.rs` with `C-c b`

    - delete the current playground and close all buffers with `C-c k`

    I don't know what any of these bindings do in `rust-mode`.

*   submit to ELPA
