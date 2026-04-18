# OPS-xDSL-MLIR

This is  fork OPS (Oxford Parallel library for Structured mesh solvers) using a custom built compilation pipeline using xDSL and MLIR.

[![Build Status](https://gitlab.com/op-dsl-ci/ops-ci/badges/develop/pipeline.svg)](https://gitlab.com/op-dsl-ci/ops-ci) 
[![Documentation Status](https://readthedocs.org/projects/ops-dsl/badge/?version=latest)](https://ops-dsl.readthedocs.io/en/latest/?badge=latest)


The key changes are can be found as follows:

- `ops-translator/ops_translator/ops_dialect/`: 
  - `ops_dialect.py` - the OPS dialect operations
  - `lower_*.py` - a lowering pass for the OPS dialect
  - `ops_types.py` - C struct layout for OPS arguments as LLVM structs
  - `generate_ir.py` - Functions to generate the starting IR for lowering
- `ops-translator/ops_translator/__main__.py` - Code ran when the OPS translator runs. Main changes are in the `codegen` function

- `ops_translator/ops-translator/cpp/parser.py` - Use of constant evaluator mechanism to parse compile time details
- `ops_translator/ops-translator/cpp/translator/program.py` - Modified the translation phase for the parallel loop calls in the source file.

- `ops-translator/`:
  - `kernel_config.py` - Contains objects and methods to store kernel details 
  - `kernel_parser.py` - Parses and generates MLIR operations from kernel functions 
  - `pipeline.py` - A pipeline class with standard methods for running xDSL and MLIR passes 
  - `pipelines.py` - Specific pipeline classes for different lowering strategies (seq, openmp, gpu_nvvm)
  - `strategy.py` - Classes to represent chosen lowering strategies (analogous to the previously used `Target` classes)
- `example-ir/`: Examples of generated IR for each step through the lowering passes



## License 
OPS is released as an open-source project under the BSD 3-Clause License. See the file called [LICENSE](https://github.com/OP-DSL/OPS/blob/master/LICENSE) for more information.

