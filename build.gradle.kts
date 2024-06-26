import com.github.c64lib.retroassembler.domain.AssemblerType

plugins {
    id("com.github.c64lib.retro-assembler") version "1.7.6"
    id("com.github.hierynomus.license") version "0.16.1"
}

retroProject {
    dialect = AssemblerType.KickAssembler
    dialectVersion = "5.25"
    libDirs = arrayOf(".ra/deps/c64lib")

    libFromGitHub("c64lib/common", "0.5.1")
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
