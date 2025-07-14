# Yorn: The Command-Line Journal

[](https://www.google.com/search?q=https://www.gnu.org/licenses/gpl-3.0)

**Yorn** is a powerful, git-based command-line tool for creating and managing journals, which we call "yornals." It's designed for developers, writers, and anyone who loves working in the terminal. By leveraging git for version control, every entry and change is tracked, giving you a complete history of your thoughts and work.

## Table of Contents

- Core Concepts
- Installation
- Getting Started
- Command Usage
  - Creating Yornals
  - Adding & Editing Entries
  - Querying & Viewing Entries
  - Deleting Entries & Yornals
- Advanced Examples
- Configuration
- Development
- License

## Core Concepts

- **Yornal**: A journal, which is essentially a collection of entries. A yornal can be a simple file (a "box" yornal) or a directory structure organized by time (year, month, day, etc.).
- **Entry**: A single journal entry. It's a text file whose "date" is determined by its path and filename within the yornal structure.
- **Version Control**: Yorn initializes your yornal repository as a Git repository, automatically committing changes when you create, edit, or delete entries. This means you have a full, revertible history of your journals.

## Installation

### From RubyGems

```bash
gem install yorn
```

### From Source

1.  Clone the repository:

    ```bash
    git clone https://github.com/emanrdesu/yorn.git
    cd yorn
    ```

2.  Build and install the gem locally:

    ```bash
    gem build yorn.gemspec
    gem install yorn-*.gem
    ```

## Getting Started

1.  **Initialize your yornal repository.** This creates the main directory where all your yornals will be stored. By default, this is `~/.yornal`, but you can change it by setting the `YORNAL_PATH` environment variable.

    ```bash
    yorn --init
    ```

2.  **Create your first yornal.** Let's create a yearly yornal named `work-log`.

    ```bash
    yorn --create work-log --type year
    ```

3.  **Add your first entry.** This command will open your default text editor (`$EDITOR`) to create an entry for the current date and time.

    ```bash
    yorn work-log
    ```

## Command Usage

The basic command structure is `yorn <yornal-name> [options]`.

### Creating Yornals

#### `--create <yornal-name>`

Creates a new yornal.

- **Example:** `yorn --create personal-thoughts`

#### `--type <type>`

Specifies the type of yornal to create. Defaults to `box`.

- **Types**: `box`, `year`, `month`, `day`, `hour`, `minute`
- **Example:** `yorn --create project-updates --type month`

### Adding & Editing Entries

#### `--add <date>`

Adds a new entry for a specific date.

- **Syntax**: `$year[/$month[/$day[/$hour[/$minute]]]]`
- **Example:** `yorn work-log --add 2025/07/14`

#### `--edit <spec>`

Selects an entry relative to others for editing.

- **Syntax**: `loc[±$n | ±$k[±$i.dateAttr]*]` where `loc` is `head`, `tail`, or `middle`.
- **Example (edit the 3rd from last entry):** `yorn work-log --edit tail-2`

### Querying & Viewing Entries

#### `--query <pattern>`

The primary way to filter and select entries by date.

- **Syntax**: `$year[/$month[/$day...]]` where each part can be an integer, a range (`1-5`), a list (`1,3,5`), or a wildcard (`@`).
- **Example (all entries from August of any year):** `yorn work-log --query @/aug`

#### `--last [$n | timeSpan]`

Selects the last `$n` entries or entries from a given timespan.

- **Example (entries from the last 3 months):** `yorn work-log --last 3.month`

#### `--first [$n | timeSpan]`

Selects the first `$n` entries or entries from a given timespan.

- **Example (the first 5 entries):** `yorn work-log --first 5`

#### `--match <word>`

Filters selected entries to those containing a specific word (case-insensitive).

- **Example:** `yorn work-log --query @ --match "meeting"`

#### `--regex <regex>`

Filters selected entries by a Ruby regular expression.

- **Example (entries containing only numbers):** `yorn work-log --query @ --regex "^\d+$"`

#### `--print [delimiter]`

Prints the content of selected entries. Defaults to a multi-newline delimiter.

- **Example (print entries separated by a line):** `yorn work-log --print "---"`

#### `--print-path [delimiter]`

Prints the paths of selected entries. This is the default action for multiple matched entries.

### Deleting Entries & Yornals

#### `--delete`

When used with a selection of entries, deletes them (with confirmation).

- **Example:** `yorn work-log --last 1 --delete`

When used with a yornal name and no other flags, deletes the entire yornal.

- **Example:** `yorn personal-thoughts --delete`

#### `--yes`

Assume "yes" to all confirmation prompts, like deletion. Use with caution.

- **Example:** `yorn work-log --last 1 --delete --yes`

## Advanced Examples

**Find all entries from 2024 in your 'notes' yornal that mention "ruby" and open the most recent one in your editor:**

```bash
yorn notes --query 2024 --match "ruby" --last 1
```

**Print the content of the first 3 entries from January 2025:**

```bash
yorn notes --query 2025/jan --first 3 --print
```

**Delete all entries from last year without being prompted for confirmation:**

```bash
yorn notes --last 1.year --delete --yes
```

## Configuration

### `YORNAL_PATH`

Set this environment variable to change the location of the main yornal repository.

```bash
export YORNAL_PATH="/path/to/my/journals"
```

### `$EDITOR` / `$PAGER`

Yorn respects these standard environment variables for choosing which text editor and pager to use.

## Development

After cloning the repo, run this command to install dependencies:

```bash
gem install optimist emanlib
```

## License

The gem is available as open source under the terms of the **GNU General Public License v3.0**. Please see the `LICENSE` file for more details.
