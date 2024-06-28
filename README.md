# Magic-Desk-CRT

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/c64lib/magic-desk-crt/tree/main.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/gh/c64lib/magic-desk-crt/tree/main)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/c64lib/magic-desk-crt/tree/develop.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/gh/c64lib/magic-desk-crt/tree/develop)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The Magic-Desk-CRT project is designed to facilitate the loading of data from Commodore 64 (C64) cartridges that utilize the Magic Desk format. This format is a popular method for distributing C64 software, allowing for multiple programs to be stored on a single cartridge. The project provides a set of assembly libraries and examples to work with Magic Desk formatted cartridges, making it easier for developers to create or manipulate C64 software in this format.

## Purpose

The primary purpose of the Magic-Desk-CRT project is to provide a comprehensive toolkit for dealing with Magic Desk cartridges on the C64. This includes functionalities for loading data from cartridges into the C64's memory, handling different banks of a cartridge, and setting up the environment for the loaded programs to run correctly.

The library is designed to be used with KickAssembler, a popular cross-assembler for the Commodore 64. It provides macros and assembly files that can be easily integrated into KickAssembler projects, making it convenient for developers to work with Magic Desk cartridges.

Please note that the Magic-Desk-CRT project is a part of the c64lib project, which aims to provide a collection of libraries and tools for C64 development. Contributions and feedback are welcome to help improve the project and make it more useful for the C64 community.

## Key Components

- **Bootstrap**: The bootstrap component (`lib/bootstrap.asm`) initializes the C64 system and prepares it for loading data from the cartridge. It sets up the necessary hardware registers and memory configurations.

- **Loader**: The loader component (`lib/loader.asm`) is responsible for the actual loading of data from the cartridge into the C64's memory. It handles bank switching and ensures that data is loaded to the correct memory locations.

## Usage Instructions

1. **Setting Up**: Include the bootstrap and loader assembly files in your project. These files are located in the `lib` directory. If you use `Retro Build Tool`, you can easily include this library as a dependency to your project.

2. **Initialization**: Use the `createMagicDeskBootstrap` macro to initialize the bootstrap process. You will need to specify parameters such as the loader code size, source address, and target address. The bootstrap code must be placed at the beginning of the BANK 0, that is, the first bank of the cartridge image. The goal of the bootstrap code is to copy the rest of the BANK 0 under desired location and jump there at the end. The rest of the BANK 0 should contain a custom loader code responsible for selecting and loading desired other banks under relevant target memory location. The bootstrap code is designed not to contain any self modyfing code nor variables and require 3 additional two-byte writable memory location (two of them on a zero page). These memory locations can be specified as macro parameters.

3. **Loading Data**: To load data from the cartridge, use the `createMagicDeskLoader` macro. This sets up the loader with jump table labels for setting the target memory address and loading data.

4. **Examples**: The `examples` folder contains sample projects demonstrating how to use the library to load data from Magic Desk cartridges. These examples provide a practical guide to getting started with your own projects.

## About Magic Desk Format

The Magic Desk format is a cartridge format for the Commodore 64 that allows for multiple programs to be stored and accessed from a single cartridge. It utilizes bank switching to expand the available storage beyond the C64's native memory limits, enabling a rich and diverse software library to be distributed on a single cartridge.

For more information on the Magic Desk format and how to utilize it in your projects, refer to the examples provided in this repository.
