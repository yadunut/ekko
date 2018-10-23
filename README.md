# Ekko

The C++ compiler(?) for school projects.

## Getting Started

Symlink the ekko.rb to bin

```bash
ln -s -F {path_to_repo}/ekko.rb /usr/local/bin/ekko
```

To run, `ekko <filename.cpp>`. This will compile `filename.cpp`, resolve its dependencies on local files

1. Look through filename.cpp to find `#include "deps.h"`
2. compile with `g++ filename.cpp deps.cpp`, etc.
3. Compiles to tempdir and deletes files after running

## Prerequisites

Ruby is required

## Contributing / Issues


## Authors

- Yadunand Prem
