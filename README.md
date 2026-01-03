# Pdfsplit

`pdfsplit` is a Ruby CLI tool that splits a multi-page PDF into smaller PDF files with a fixed number of pages per part.

- Cross-platform: Linux / Windows (with Ruby installed)
- No external PDF utilities required (no `pdftk`, `qpdf`, etc.)
- Uses the **HexaPDF** gem to handle PDF files

---

## Features

- Splits `input.pdf` into files like `input_part001.pdf`, `input_part002.pdf`, ...
- Part size is configured via `--pages N`
- Output directory is configured via `--out DIR` (defaults to current directory `.`)
- `--help`, `--version`
- Clear error messages and proper exit codes (0 = success, 1 = error)

---

## Requirements

- Ruby (3.1+ recommended)
- Bundler

> On Linux you may need system development packages (headers/libs) to build native extensions if Bundler fails while installing dependencies.

---

## Installation (from the repository)

Clone the repository and install dependencies:

```bash
bundle install
```

## Usage

### Split a PDF into parts of N pages

```bash
bundle exec pdfsplit input.pdf --pages 10
```

Outputs will be created in the current directory:

- `input_part001.pdf`
- `input_part002.pdf`
- ...

### Specify an output directory

```bash
bundle exec pdfsplit input.pdf --pages 10 --out out
```

Files will be created in `out/`.

### Help

```bash
bundle exec pdfsplit --help
```

### Version

```bash
bundle exec pdfsplit --version
```

---

## Output naming

Given an input file `input.pdf`, the tool writes:

- `input_part001.pdf`
- `input_part002.pdf`
- `input_part003.pdf`
- ...

---

## Errors & behavior

- Missing input file → exit 1 + Usage
- Missing --pages / --pages <= 0 → exit 1 + Usage
- More than one input file provided → exit 1 + Usage
- Input file does not exist → exit 1 + OS error message
- Input is not a valid PDF → exit 1 + Error: invalid PDF
- --out points to an existing file → exit 1 + Error: --out must be a directory
- Output directory is not writable → exit 1 + OS error message

---

## Development

Run tests:

```bash
bundle exec rspec
```

Install the gem locally (to test it as an installed gem):

```bash
bundle exec rake install
```

Open an interactive console (Bundler-generated helper):

```bash
bin/console
```

---

## License

MIT License

