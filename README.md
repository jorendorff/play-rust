# play-rust - A local Rust playground for emacs

This package makes `M-x play-rust` start a new Rust project and drop you right
into `main.rs`.

It also sets `compile-command` so that `M-x compile` knows that you probably
want to do `cargo run`. (It'll suggest `cargo test` intead if you've added a
test, just like <https://play.rust-lang.org>. And if your file has neither `fn
main` nor a test, it'll offer `cargo check`.)

If you delete the `fn main` from your playground, `M-x compile` will quietly
rename your Rust file from `main.rs` to `lib.rs` (to keep `rustc` from
complaining that you don't have a `fn main`).


### Installation

Grab the source, open `play-rust.el`, and do `M-x package-install-from-buffer`.

### Future directions

*   Basics:

    *   Eliminate the "`main.rs` is not part of any project. Select action:"
        speed bump.

    *   Make `compile` run the `cargo` command in the project root directory;
        we currently run it in `src` and I think that's why `next-error`
        doesn't find the right file when there are compilation errors.

    *   Keep `compile`'s DWIM code activated if the user has done certain kinds
        of command-line edits that we can parse and understand, e.g. adding
        `+nightly` or `--release`. (Currently, out of caution, we bail out if
        `compile-command` does not match our last suggestion exactly.)

    *   Suggest `+nightly` if the buffer contains `#![feature`.

    *   Prevent `lsp-mode` from getting very angry-faced when the user deletes
        `fn main`, until the next `compile`.

*   Auto-populate Cargo.toml dependencies on compilation (e.g. if I use
    `rand::random`, don't force me to edit `Cargo.toml`)

*   Ability to publish to play.rust-lang.org for sharing,
    copying the link to your clipboard and/or opening it in a browser

*   Support for keeping old playgrounds lying around:

    *   Menu of playgrounds, using first line of `main.rs` (should put a
        comment on that line when first opening the file, maybe, as a hint ...
        for playgrounds where nobody bothered to edit the first line, perhaps
        show the first line of the file that is unique across playgrounds)

    *   GC `target` directories that haven't been used for a while

    *   Full text search of playgrounds

*   Consider adding a minor mode, under rust-mode, so we can steal some
    features from `rust-playground`:

    - bind `C-c C-c` to a `compile` that skips the compile-command prompt

    - toggle between `Cargo.toml` and `main.rs` with `C-c b`

    - delete the current playground and close all buffers with `C-c k`

    I don't know what any of these bindings do in `rust-mode`.

*   Submit to ELPA
