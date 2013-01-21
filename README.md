## Forml mode

An emacs mode for the awesome [forml](https://github.com/texodus/forml) language implemented by @texodus.

## Features

### Editing inlined javascript

forml-mode allows you to edit sections of inlined javascript in a new
buffer using javascript mode for the full experience of editing
javascript in emacs. Use `C-c C-j` to start editing a javascript
section in a new buffer. Save the buffer (`C-c C-s`) to copy the new
content back to the original buffer.

Note that if you're not inside a javascript string, a new section will
be created for you (i.e. ``` `` ``` will be inserted) and when you're
done editing the javascript will be copied in that new section.

### Enable flymake

Forml mode comes with flymake setup and ready to use. To enable
flymake add the following to your .emacs file:

```lisp
(custom-set-variables
 '(forml-mode-flymake t))
```

If `forml` isn't on your path you'll have to add the following instead:

```lisp
(custom-set-variables
 '(forml-mode-flymake t)
 '(forml-mode-forml-path "path to forml"))
``````

where "path to forml" is the path to the `forml` binary.

## TODO

1. Better indentation, something like haskell mode or coffeescript mode.
