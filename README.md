# packman-exploration
Example/demo of packman function (de-)serialization, contains small working examples for manual linking and transformation of serialized thunks for relinked modules.

## Manual linking

Demonstrates linker inputs for a small example containing module and lib references. Static linking works, dynamic does not.

## Relinking + Transformation

Idea: serialize a thunk with one program, transport relevant object code files of that program, relink it with a main accepting that serialized code, executing it.
Problem: packman serialization serializes pointers which will be different for the second problem. A quick+dirty transformation step in between demonstrates, how the serialized thunk can be transformed to overcome this. Data serialization will probably not work as of now. This is not the way to finalize this solution anyway, should be done in packman itself (removes the need for some artistic conversions etc.).

Note: requires a patched packman, removing the sanity check (same binary hash) (submodule reference)

