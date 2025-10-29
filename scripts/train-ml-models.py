#!/usr/bin/env python3
"""
APEX Arbitrage System - ML Model Training Script
This script bootstraps the training of machine learning models
"""

import os
import sys


def main():
    print("=" * 50)
    print("APEX Arbitrage System - ML Model Training")
    print("=" * 50)
    print()
    
    # Check if python/model directory exists
    model_dir = os.path.join("python", "model")
    if not os.path.exists(model_dir):
        print(f"Error: {model_dir} directory not found")
        print("Please ensure the project structure is set up correctly")
        sys.exit(1)
    
    train_script = os.path.join(model_dir, "train.py")
    if not os.path.exists(train_script):
        print(f"Error: {train_script} not found")
        print("Training script is not available")
        sys.exit(1)
    
    print(f"Found training script: {train_script}")
    print()
    print("Starting model training...")
    print("This may take some time depending on your hardware...")
    print()
    
    # Change to the model directory and run the training script
    os.chdir(model_dir)
    
    # Import and run the training script
    try:
        import train
        if hasattr(train, 'main'):
            train.main()
        else:
            print("Training script does not have a main() function")
            print("Please run the training script directly")
    except ImportError as e:
        print(f"Error importing training script: {e}")
        print("Please ensure all dependencies are installed")
        sys.exit(1)
    except Exception as e:
        print(f"Error during training: {e}")
        sys.exit(1)
    
    print()
    print("=" * 50)
    print("Model Training Complete!")
    print("=" * 50)


if __name__ == "__main__":
    main()
