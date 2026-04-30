# description-dep-types

Pattern: `description-dep-types`
Plugin: `r-packrat`
Packrat version: 0.9.2
R version: 4.3.2
Generated: 2026-04-30

## Feature exercised

Tests whether Mend cross-references `DESCRIPTION` against `packrat/packrat.lock` to correctly
classify locked packages by their dependency type: `Imports` (runtime), `Suggests` (dev/test,
should be excluded from runtime tree or tagged `group: dev`), `LinkingTo` (C++ headers — a
real installed package that must appear in the tree), and `Depends: R (>= x)` (engine
constraint that must NOT appear as a package node in any tree).

## Expected dependency tree

### Packages and their DESCRIPTION classification

| Package      | DESCRIPTION field | Expected in runtime tree | Expected group |
|--------------|-------------------|--------------------------|----------------|
| ggplot2      | Imports           | YES — direct             | main           |
| jsonlite     | Imports           | YES — direct             | main           |
| Rcpp         | LinkingTo         | YES — direct             | main           |
| testthat     | Suggests          | NO (or group: dev)       | dev            |
| knitr        | Suggests          | NO (or group: dev)       | dev            |
| R (>= 4.0.0) | Depends (engine)  | MUST BE ABSENT           | n/a            |

### Transitives included in lockfile (ggplot2 dependency chain)

`ggplot2` → `scales`, `rlang`, `gtable`, `colorspace`, `farver`, `glue`, `isoband`,
`labeling`, `lifecycle`, `MASS`, `mgcv`, `munsell`, `nlme`, `pillar`, `tibble`, `vctrs`,
`withr`, `fansi`, `utf8`, `pkgconfig`, `magrittr`

### Dependency type classifications

- `Imports` (ggplot2, jsonlite) — runtime dependencies; must appear with `scope: runtime`
  and `group: main`. All their transitives also appear in the runtime tree.
- `LinkingTo` (Rcpp) — C++ header package; it is a real installable CRAN package, not a
  meta-dependency. Must appear with `scope: runtime` and `group: main` (or equivalent).
  This exercises the known failure mode where Mend silently drops `LinkingTo` packages.
- `Suggests` (testthat, knitr) — development/test packages; must either be absent from
  the tree entirely, or if Mend reports them, they must carry `group: dev` and
  `scope: development`. They must NOT appear in the runtime/main tree. Their transitive
  dependencies (brio, callr, desc, etc.) must also not leak into the runtime tree.
- `Depends: R (>= 4.0.0)` — R engine version constraint; must not appear as a package
  node in Mend's dependency tree under any circumstances. This is a known failure mode
  where R-naive parsers treat "R" as a package name.

### Versions (all CRAN)

- ggplot2 3.4.4
- jsonlite 1.8.8
- Rcpp 1.0.12
- testthat 3.2.1
- knitr 1.45
- scales 1.3.0
- rlang 1.1.3

## Failure modes this probe exercises

1. `Suggests` packages (testthat, knitr) leaking into runtime tree — if Mend does not
   read `DESCRIPTION` dep-type fields, all locked packages land in the runtime tree.
2. `Depends: R (>= 4.0.0)` treated as a package dependency — if Mend parses the
   `Depends:` field without filtering the `R` engine token, it creates a spurious "R"
   package node.
3. `LinkingTo: Rcpp` silently dropped from tree — if Mend treats `LinkingTo` as a
   non-runtime classification and excludes it, Rcpp (a real C++ headers package) is
   missing from the tree and its CVEs become invisible.

## Resolver notes

The upstream UA R resolver file (resolvers/r.md) was not publicly accessible at the time
this probe was generated (all fetch attempts returned 404 — see PACKRAT_COVERAGE_PLAN.md
§8). The following resolver behaviour is therefore inferred, not confirmed:

- It is unknown whether Mend reads `packrat/packrat.lock` statically or attempts a
  `packrat::restore()` pre-step. This probe is designed for static lockfile parsing.
- It is unknown whether `resolveAllDependencies: false` in `.whitesource` is required to
  suppress `Suggests` packages. The probe does not emit a `.whitesource` config — observe
  actual Mend output and add one if Suggests packages leak into the runtime tree.
- It is unknown whether `dependencyType: "DEV"` or `group: "dev"` is the correct Mend
  schema field for Suggests packages.

## whitesource config

No `.whitesource` file is emitted for this probe. The `r` key for
`scanSettings.versioning` is unconfirmed. Add `.whitesource` with
`scanSettings.versioning.r: "4.3.2"` if the scanner does not auto-detect the R version
from the lockfile `RVersion:` header.
