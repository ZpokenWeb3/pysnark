#!/bin/bash

PYTHON_SCRIPT="model.py"

echo "Select proof method:"
echo "1) Groth16 with libsnarkgg (no Solidity verifier)"
echo "2) Groth16 with snarkjs (with Solidity verifier option)"
read -p "Enter choice [1 or 2]: " CHOICE

if [ "$CHOICE" -eq 1 ]; then
    echo "Running Groth16 proof with libsnarkgg backend..."
    PYSNARK_BACKEND=libsnarkgg python3 "$PYTHON_SCRIPT"
    python3 -m pysnark.libsnark.tosnarkjsgg
    snarkjs groth16 verify verification_key.json public.json proof.json

elif [ "$CHOICE" -eq 2 ]; then
    echo "Running Groth16 proof with snarkjs backend..."
    PYSNARK_BACKEND=snarkjs python3 "$PYTHON_SCRIPT"

    echo "Generating power of tau..."
    snarkjs powersoftau new bn128 12 pot.ptau -v
    snarkjs powersoftau prepare phase2 pot.ptau pott.ptau -v
    
    echo "Creating zkey and exporting verification key..."
    snarkjs zkey new circuit.r1cs pott.ptau circuit.zkey
    snarkjs zkey export verificationkey circuit.zkey verification_key.json

    echo "Generating proof..."
    snarkjs groth16 prove circuit.zkey witness.wtns proof.json public.json
    snarkjs groth16 verify verification_key.json public.json proof.json

    echo "Exporting Solidity verifier..."
    snarkjs zkey export solidityverifier circuit.zkey verifier.sol
    snarkjs zkey export soliditycalldata public.json proof.json

else
    echo "Invalid choice. Please select 1 or 2."
    exit 1
fi

echo "Process completed."
