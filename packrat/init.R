#### -- Packrat Autoloader (version 0.9.2) -- ####
packrat_manager <- local({
  rver <- getRversion()
  if (file.exists(".Rprofile") && !grepl("packrat", readLines(".Rprofile", warn = FALSE)[1])) {
    # do not double-source
  }
  invisible(NULL)
})

local({
  # packrat bootstrap stub — detection signal only, not executable
  pkgdir <- file.path("packrat", "lib", R.version$platform,
                      paste(R.version$major, R.version$minor, sep = "."))
  if (suppressWarnings(require("packrat", lib.loc = pkgdir, quietly = TRUE))) {
    packrat::on()
  }
  invisible(NULL)
})
