import com.github.c64lib.retroassembler.domain.AssemblerType

plugins {
    id("com.github.c64lib.retro-assembler") version "1.6.0"
    id("com.github.hierynomus.license") version "0.16.1"
}

retroProject {
    dialect = AssemblerType.KickAssembler
    dialectVersion = "5.25"
    libDirs = arrayOf(".ra/deps/c64lib", "build/charpad", "build/spritepad", "build/goattracker")

    libFromGitHub("c64lib/common", "0.3.0")
    libFromGitHub("c64lib/chipset", "0.3.0")
}

license {
    header = file("LICENSE")
    excludes(listOf(".ra"))
    include("**/*.asm")
    mapping("asm", "SLASHSTAR_STYLE")
}

tasks.register<com.hierynomus.gradle.license.tasks.LicenseFormat>("licenseFormatAsm") {
    source = fileTree(".") {
        include("**/*.asm")
        exclude(".ra")
        exclude("build")
    }
}
tasks.register<com.hierynomus.gradle.license.tasks.LicenseCheck>("licenseAsm") {
    source = fileTree(".") {
        include("**/*.asm")
        exclude(".ra")
        exclude("build")
    }
}
tasks["licenseFormat"].dependsOn("licenseFormatAsm")


preprocess {

    // goattracker {
    //   getInput().set(file("song.sng"))
    //   getUseBuildDir().set(true)
    //   music {
    //     output = file("song.sid")
    //     bufferedSidWrites = true
    //     sfxSupport = true
    //     storeAuthorInfo = true
    //     playerMemoryLocation = 0xF5
    //   }
    // }

    // charpad {
    //   getInput().set(file("playfield.ctm"))
    //   getUseBuildDir().set(true)
    //   outputs {
    //     meta {
    //       dialect = "KickAssembler"
    //       output = file("playfield-meta.asm")
    //     }
    //     charset {
    //       output = file("playfield-charset.bin")
    //     }
    //   }
    // }

    // spritepad {
    //   getInput().set(file("sprites.spd"))
    //   getUseBuildDir().set(true)
    //   outputs {
    //     sprites {
    //       output = file("sprites.bin")
    //     }
    //   }
    // }
}
