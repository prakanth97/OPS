import re

from typing import List, Dict

from ops import Const, OpsError
from store import Program
from util import SourceBuffer, Rewriter, findIdx

# Augment source program to use generated kernel hosts
def translateProgram(source: str, program: Program, app_consts: List[Const], loop_to_function_name: Dict[str, str], force_soa: bool = False) -> str:
    buffer = SourceBuffer(source)

    # 1. Update const calls
    for const in program.consts:
        buffer.apply(
            const.loc.line -1,
            lambda line: re.sub(r"ops_decl_const\s*\(", f"ops_decl_const2(", line)
        )


    # 2. Update loop calls
    for loop in program.loops:
        function_name = loop_to_function_name[loop]
        
        # Get the starting line
        start_line = loop.loc.line - 1
        original_line = buffer.get(start_line)
        
        # Check if the call spans multiple lines (no semicolon on first line)
        full_call = original_line
        current_line = start_line
        
        while ');' not in full_call:
            current_line += 1
            if current_line >= len(buffer.rawLines):
                print(f"Warning: Could not find end of call for loop at line {loop.loc.line}")
                break
            full_call += " " + buffer.get(current_line).strip()
        
        # Now full_call contains the complete function call
        end_line = current_line
        
        # Extract the call arguments
        before, after = full_call.split("ops_par_loop", 1)
        after = re.sub(rf"{loop.kernel}\s*,\s*", "", after, count=1)
        
        # Parse the arguments
        args_match = re.search(r'\((.*?)\);', after, re.DOTALL)
        if not args_match:
            print(f"Warning: Could not parse arguments for loop at line {loop.loc.line}")
            continue
        
        args_str = args_match.group(1)
        args = [arg.strip() for arg in split_args(args_str)]
        
        if len(args) < 4:
            print(f"Warning: Not enough arguments for loop at line {loop.loc.line}")
            continue
        
        name_arg = args[0]
        block_arg = args[1]
        dim_arg = args[2]
        range_arg = args[3]
        ops_args = args[4:]
        
        # Generate transformed code
        indent = len(before) - len(before.lstrip())
        indent_str = " " * indent
        
        transformed = f"{indent_str}{{\n"
        transformed += f"{indent_str}\tint dim = {dim_arg};\n"
        
        # Handle range argument - if its an array literal, extract it
        if range_arg.strip().startswith('{'):
            transformed += f"{indent_str}\tint range[] = {range_arg};\n"
            range_ref = "range"
        else:
            range_ref = range_arg

        # Handle block argument - check if it's a function call or variable
        if 'ops_decl_block' in block_arg or '(' in block_arg:
            transformed += f"{indent_str}\tops_block block_temp = {block_arg};\n"
            block_ref = "&block_temp"
        else:
            block_ref = f"&{block_arg}"

        # Create
        ops_arg_refs = []
        for i, ops_arg in enumerate(ops_args):

            if '(' in ops_arg:
                transformed += f"{indent_str}\tops_arg temp_arg{i} = {ops_arg};\n"
                ops_arg_refs.append(f"&temp_arg{i}")
            else:
                ops_arg_refs.append(f"&{ops_arg.strip()}")
        
        ops_arg_refs = ", ".join(f"&temp_arg{i}" for i in range(len(ops_args)))
        transformed += f"{indent_str}\t{function_name}({name_arg}, {block_ref}, &dim, {range_ref}, {ops_arg_refs});\n"
        transformed += f"{indent_str}}}\n"
        
        # Replace all lines from start_line to end_line with transformed code
        buffer.update(start_line, transformed)
        for line_num in range(start_line + 1, end_line + 1):
            buffer.remove(line_num)  # Changed from delete to remove

    # 3. Update headers
    index = buffer.search(r'\s*#include\s+("|<)\s*ops_seq(_v2)?\.h\s*("|>)') + 2

    buffer.insert(index, '/* ops_par_loop declarations */\n')
    buffer.insert(index, 'extern "C" {\n')

    for loop in program.loops:
        function_name = loop_to_function_name[loop]
        
        prototype = f'void {function_name}(char const *, ops_block*, int*, int*{", ops_arg*" * len(loop.args)});\n'
        buffer.insert(index, prototype)

    buffer.insert(index, '}\n')

    # 4. Update ops_init
    buffer.insert(0, '\nvoid ops_init_backend();\n')

    if buffer.search(r'\s* ops_init\('):
        index = buffer.search(r'\s* ops_init\(') + 1
        buffer.insert(index, '\tops_init_backend();\n')

    # 5. Find the Global declarations of constant and add relevant OpenACC pragmas
    # Add #pragma acc declare create() near main declarations of variable (no need to place near extern declarations)
    # Add #pragma acc update device() near initialization of those variables
#    dynamic_const = []
#    for const in app_consts:
#        name, typ = const.name, repr(const.typ)
#        pattern1 = rf'\s*\b{typ}\b(?:(?!;).)*\b{name}\b'
#        pattern2 = rf'\s*extern \s*\b{typ}\b(?:(?!;).)*\b{name}\b'
#        # Check if main declaration of global is present in file, skip for extern declarations
#        if buffer.search2(pattern1) is not None and buffer.search2(pattern2) is None:
#            index = buffer.search2(pattern1)
#            #print(f"found {name}")
#            if const.dim.isdigit() and int(const.dim)==1:
#                buffer.insert(index+1, f'#pragma acc declare create({const.ptr})')
#            else:
#                rawline = buffer.get(index)
#                match = re.search(r'.*{name}\s+\[.*\]', rawline)
#                if match:
#                    # if static allocation
#                    buffer.insert(index+1, f'#pragma acc declare create({const.ptr}[0:{const.dim}])')
#                else:
#                    # if global pointer
#                    #print(f"Please make sure ops_decl_const call for {const.ptr} is in same file where it is declared as pointer globally (not where it is extern)")
#                    buffer.insert(index+1, f'#pragma acc declare create({const.ptr})')
#                    dynamic_const.append(name)


    # Find all ops_decl_const calls and add update directives
#    pattern3 = r'ops_decl_const\s*\('
#    indexes = buffer.search_all(pattern3)
#    for index in indexes:
#        rawline = buffer.get(index)
#        pattern = r'ops_decl_const\s*\(\s*"([^"]+)"'
#        match = re.search(pattern, rawline)
#        if match:
#            name = match.group(1)
#            for const in app_consts:
#                if name.strip().lower() == const.name.strip().lower():
#                    dim, ptr = const.dim, const.ptr
#                    if dim.isdigit() and int(dim) == 1:
#                        buffer.insert(index+1, f'#pragma acc update device({ptr})')
#                    else:
#                        # TODO : Assuming main global declaration and ops_decl_const call is in same file
#                        if name in dynamic_const:
#                            buffer.insert(index+1, f'#pragma acc enter data create({ptr}[0:{const.dim}])')
#                        buffer.insert(index+1, f'#pragma acc update device({ptr}[0:{dim}])')
#        else:
#            raise OpsError(f"Unable to extract name from ops_decl_const line: {rawline}")

    # 6. Translation
    new_source = buffer.translate()

    # 7. Substitude the ops_seq.h/ops_seq_v2.h with ops_lib_core.h
    new_source = re.sub(r'#include\s+("|<)\s*ops_seq(_v2)?\.h\s*("|>)', '#include "ops_lib_core.h"', new_source)

    # 8. check if SOA is set
    def replacer(match):
        s = match.group(0)
        if s.startswith("/"):
            return ""
        else:
            return s

    pattern_comment = re.compile(r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
                                 re.DOTALL | re.MULTILINE,
                                )

    pattern = r'(#define\s*OPS_SOA|OPS_soa\s*=\s*1\s*;)'
    matches = re.findall(pattern, re.sub(pattern_comment, replacer, new_source), re.IGNORECASE)

    if len(matches) == 2 and not program.soa_val:
        program.soa_val = True

    # Return new updated source
    return new_source

def split_args(args_str):
    """Split arguments by comma, respecting nested parentheses and curly braces"""
    args = []
    current = ""
    depth = 0
    brace_depth = 0
    
    for char in args_str:
        if char == ',' and depth == 0 and brace_depth == 0:
            args.append(current.strip())
            current = ""
        else:
            if char == '(':
                depth += 1
            elif char == ')':
                depth -= 1
            elif char == '{':
                brace_depth += 1
            elif char == '}':
                brace_depth -= 1
            current += char
    
    if current.strip():
        args.append(current.strip())
    
    return args