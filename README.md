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

### Smart commenting

Those of you who use emacs will probably know about this feature from other modes.
It is added for those who are new to Emacs and using it to write some Forml code.

#### Continue a comment on the next line

You can use the combination `M-j` to continue a comment (that's getting long)
on the next line.

#### Comment a region

Mark the region by going to the start and hitting `C-spc` then go to the end
and hit `C-spc` then use the combination `C-;` to toggle the comments
for the entire block.

### Adding a comment at the end of a line

Use `M-j` to add a comment at the end of the current line.

#### Fill a comment

If you have a comment that's too long you can mark the entire line and using
`M-q` to split the comment to multiple lines.

## TODO

1. Better indentation, something like haskell mode or coffeescript mode.
