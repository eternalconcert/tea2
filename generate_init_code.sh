#!/bin/bash
# Generate C++ header file with embedded sys.t content

INPUT_FILE="stdlib/sys.t"
OUTPUT_FILE="src/init_code.h"

if [ ! -f "$INPUT_FILE" ]; then
    echo "const char* INIT_CODE = \"\";" > "$OUTPUT_FILE"
    exit 0
fi

# Use Python for reliable escaping
python3 << 'PYTHON_EOF'
import sys
import re

input_file = "stdlib/sys.t"
output_file = "src/init_code.h"

try:
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Escape backslashes first, then quotes, then newlines
    content = content.replace('\\', '\\\\')
    content = content.replace('"', '\\"')
    content = content.replace('\n', '\\n')
    
    header = f'''// Auto-generated from stdlib/sys.t - do not edit manually
#ifndef INIT_CODE_H
#define INIT_CODE_H

const char* INIT_CODE = "{content}";

#endif
'''
    
    with open(output_file, 'w') as f:
        f.write(header)
    
    print(f"Generated {output_file} from {input_file}")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
PYTHON_EOF

