import com.github.c64lib.retroassembler.domain.AssemblerType

plugins {
    id("com.github.c64lib.retro-assembler") version "1.7.6"
    id("com.github.hierynomus.license") version "0.16.1"
}

retroProject {
    dialect = AssemblerType.KickAssembler
    dialectVersion = "5.25"
    libDirs = arrayOf(".ra/deps/c64lib", "build/charpad")

    libFromGitHub("c64lib/chipset", "0.5.0")
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

tasks.register<Exec>("build-crt") {
    dependsOn("build")
    group = "build"
    description = "links the whole game as a CRT cart image"
    commandLine("cartconv", "-t", "md", "-i", "examples/slideshow/slideshow-crt.bin", "-o", "examples/slideshow/slideshow-crt.crt", "-l", "$8000")
}


preprocess {
    for (id in 0..4) {
        charpad {
            getInput().set(file("examples/slideshow/ctm/screen-$id.ctm"))
            getUseBuildDir().set(true)
            outputs {
                charset {
                    output = file("screen-$id-charset.bin")
                }
                charsetColours {
                    output = file("screen-$id-colours.bin")
                }
                charsetScreenColours {
                    output = file("screen-$id-screen-colours.bin")
                }
                meta {
                    output = file("screen-$id-metadata.asm")
                    dialect = AssemblerType.KickAssembler
                }
            }
        }
    }
}
