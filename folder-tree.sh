#!/bin/bash

echo "Creating the main project directory: gcp-nexus-infra/"
mkdir -p gcp-nexus-infra

cd gcp-nexus-infra || exit

echo "Creating root .tf files..."
touch main.tf variables.tf terraform.tfvars outputs.tf

echo "Creating modules directory and sub-directories..."
mkdir -p modules/{networking,iam,gke,storage}

# An array of the module names
modules=("networking" "iam" "gke" "storage")

for module in "${modules[@]}"; do
    echo "Creating files for module: $module"
    touch "modules/$module/main.tf"
    touch "modules/$module/variables.tf"
    touch "modules/$module/outputs.tf"
done

echo "✅ Terraform project structure created successfully!"
ls -R