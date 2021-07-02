;;; play-rust.el --- Another local Rust playground.

;; Copyright (C) 2021 play-rust maintainers

;; Author: Jason Orendorff <jason.orendorff@gmail.com>, Jim Blandy
;; Version: 0.1
;; Keywords: rust, playground
;; URL: http://github.com/jorendorff/play-rust
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Easily create and build a Rust project, for quick testing.
;;
;; Use `play-rust` to create a new Rust project under `~/.play-rust`
;; (or a directory you choose; see `play-rust-dir`)
;; and open `main.rs`.
;;
;; In a play-rust buffer, using `compile` interactively will suggest `cargo
;; run`, or `cargo test` if there are tests present.

;;; Code:

(defgroup play-rust nil "Play-rust group."
  :prefix "play-rust-")

(defcustom play-rust-dir "~/.play-rust"
  "Parent directory under which playground directories are created."
  :risky t
  :type 'directory
  :group 'play-rust
  :package-version '(play-rust . "0.1"))

(defcustom play-rust-cargo-command "cargo"
  "Command to run Cargo."
  :risky t
  :type 'string
  :group 'play-rust
  :package-version '(play-rust . "0.1"))

(defun play-rust--new-project-dir ()
  "Create and return a new project directory."
  (let* ((parent-dir (expand-file-name play-rust-dir))
         (date-str (format-time-string "play-%Y-%m-%d"))
         (candidate-dir (expand-file-name date-str parent-dir)))
    (unless (file-directory-p parent-dir)
      (make-directory parent-dir 'and-its-parents))
    (let (suffix-number)
      (while (condition-case nil (make-directory candidate-dir)
               (file-already-exists t))
        (setq suffix-number (1+ (or suffix-number 0))
              candidate-dir (expand-file-name (format "%s-%d" date-str suffix-number) parent-dir)))
      candidate-dir)))

(defvar-local play-rust--last-compile-command nil
  "Last command play-rust selected for the current buffer.")

(defun play-rust ()
  (interactive)
  (let ((project-dir (play-rust--new-project-dir)))
    (with-temp-buffer
      (setq default-directory project-dir)
      (when (not (zerop (call-process play-rust-cargo-command nil (current-buffer) nil "init")))
        (error "cargo init failed: %s" (buffer-string))))
    (find-file (expand-file-name "src/main.rs" project-dir))
    ;; Enable compile advice in this buffer.
    (setq play-rust--last-compile-command nil)
    (play-rust--maybe-select-compile-command)
    (re-search-forward "println!" nil t)))

;; Add advice around `compile' to suggest "cargo run" etc.

(defun play-rust--compile-suggest ()
  "Find a reasonable `cargo` command to try to run, based on the
content of the current buffer. Also rename the file if needed
(see `play-rust--maybe-rename-file')."
  (let*
      ((has-test
        (save-excursion
          (goto-char (point-min))
          (re-search-forward "#\\s-*\\[\\s-*test\\s-*\\]" nil t)))
       (has-main
        (save-excursion
          (goto-char (point-min))
          (re-search-forward "\\_<fn\\s-+main\\_>" nil t))))
    (play-rust--maybe-rename-file has-main)
    (concat play-rust-cargo-command
            " "
            (cond (has-test "test") (has-main "run") (t "check"))
            " ")))

(defun play-rust--maybe-rename-file (has-main)
  "If `has-main' is nil, quietly try to rename the file and
buffer to `lib.rs`, so `cargo` will build it as a library. If
`has-main' is non-nil, rename back to `main.rs`.

Needed because, if the user deletes `fn main`, we must build the
file as a library (building it as an application won't work, no
matter what `cargo` command you use)."
  (let*
      ((current (buffer-file-name))
       (target (expand-file-name (if has-main "main.rs" "lib.rs") (file-name-directory current))))
    (unless (string-equal current target)
      (condition-case nil
          (progn (rename-file current target)
                 (set-visited-file-name target))
        (file-already-exists nil)))))

(defun play-rust--maybe-select-compile-command ()
  "If in a play-rust buffer, set `compile-command' to some `cargo` command line.

Out of caution, if `compile-command` has changed from whatever
was last suggested, e.g. if the user added command-line options
like `--release`, then this does nothing."
  (when (and (local-variable-p 'play-rust--last-compile-command)
             (or (not play-rust--last-compile-command)
                 (string-equal (string-trim compile-command)
                               (string-trim play-rust--last-compile-command))))
    (setq play-rust--last-compile-command (play-rust--compile-suggest))
    (set (make-local-variable 'compile-command) play-rust--last-compile-command)))

(defun play-rust--compile-advice (orig &rest args)
  "Compile the playground, possibly using a contextually generated cargo command."
  (interactive
   (lambda (spec)
     (play-rust--maybe-select-compile-command)
     (advice-eval-interactive-spec spec)))
  (apply orig args))

(advice-add 'compile :around #'play-rust--compile-advice)

;;; play-rust.el ends here
