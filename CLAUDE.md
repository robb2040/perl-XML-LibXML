# CLAUDE.md

## Project Overview

XML::LibXML is a Perl XS binding to the Gnome libxml2 C library, providing a full DOM, XPath, SAX, RelaxNG/Schema validation, and streaming Reader interface for XML processing. It is a mature CPAN distribution.

## Build and Test

```bash
perl Makefile.PL          # Configure (detects libxml2 via Alien::Libxml2)
make                      # Compile XS/C code
make test                 # Run test suite (~80 test files)
make install              # Install module + register SAX parsers
make docs                 # Regenerate POD from docs/libxml.dbk (requires xsltproc)
```

**Build options:**
- `XMLPREFIX=/path` — use a custom libxml2 installation
- `SKIP_SAX_INSTALL=1` — skip SAX parser registration during install

**System dependencies:** libxml2 development headers (e.g. `libxml2-dev` on Debian/Ubuntu).

## Architecture

```
LibXML.pm + lib/XML/LibXML/*.pm   (Perl API)
        ↓
LibXML.xs / Devel.xs              (XS binding layer)
        ↓
dom.c, perl-libxml-mm.c,          (C wrappers: DOM ops, memory mgmt,
 perl-libxml-sax.c, xpath.c)       SAX handlers, XPath helpers)
        ↓
libxml2                           (system C library)
```

### Key source files

| File | Role |
|------|------|
| `LibXML.pm` | Main module — parser creation, config, proxy node registry, constants |
| `LibXML.xs` | XS bindings — DOM, parsing, XPath, SAX, Reader, error handling |
| `dom.c` / `dom.h` | DOM wrapper functions (node ops, namespace reconciliation) |
| `perl-libxml-mm.c` / `.h` | ProxyNode memory management, UTF-8 conversion, ref counting |
| `perl-libxml-sax.c` / `.h` | SAX event handler dispatch to Perl callbacks |
| `xpath.c` / `xpath.h` | XPath context management, function/variable registration |
| `typemap` | XS type mappings between C and Perl types |

### Key Perl modules (`lib/XML/LibXML/`)

- `Reader.pm` — streaming XML reader (requires libxml2 >= 2.6.21)
- `SAX.pm`, `SAX/*.pm` — SAX parser interface (requires XML::SAX)
- `XPathContext.pm` — advanced XPath with registered functions/variables
- `Error.pm` — structured error/exception handling
- `NodeList.pm` — node collection with iterator support
- `Common.pm` — shared encoding utilities and constants

## Testing

- Framework: `Test::More` with `Test::Count` annotations (`# TEST` markers)
- Test data lives in `t/` (test scripts) and `test/` (XML fixtures, schemas, DTDs)
- Helper modules in `t/lib/` (TestHelpers.pm, Counter.pm, etc.)
- Tests must **not** access external network resources
- Developer/release tests (pod, kwalitee, trailing-space) run when `AUTHOR_TESTING=1`

## Compatibility

- **Perl:** 5.8.1+ required
- **libxml2:** 2.6.16+ required; features conditionally compiled based on version:
  - `HAVE_SCHEMAS` (>= 2.5.10) — RelaxNG and XML Schema
  - `HAVE_READER_SUPPORT` / `WITH_SERRORS` (>= 2.6.21) — Reader API, structured errors
- **Threads:** optional support via `:threads_shared` import tag

## Coding Conventions

### C code (from HACKING.txt)
- 4-space indent, no tabs
- Opening braces on separate line
- snake_case identifiers; type names end in `_t`, struct names in `_struct`
- No declarations after statements
- Always use braces for if/while blocks

### Perl code
- Avoid `unless`, `until` — use `if !` / `if not`
- Avoid trailing statement modifiers

### General
- Update `MANIFEST` and `Changes` for all changes
- External DTD/entity loading is disabled by default (security)

## CI

GitHub Actions (`.github/workflows/ci.yml`):
- **author-testing** — full release tests on Ubuntu (`make docs`, `make disttest`)
- **linux** — matrix across Perl 5.8 through devel via perldocker containers
- **macOS** — system Perl compatibility check

## Dependencies

**Runtime:** Alien::Libxml2 (>= 0.14), XML::SAX (>= 0.11), XML::SAX::Base, XML::NamespaceSupport (>= 1.07)
**Build:** Alien::Base::Wrapper, ExtUtils::MakeMaker
