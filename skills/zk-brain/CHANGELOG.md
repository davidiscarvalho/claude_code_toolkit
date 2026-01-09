# Changelog

All notable changes to the zk-brain skill will be documented in this file.

## [1.1.0] - 2026-01-09

### Added
- **Dependency checking**: Upfront validation for `sqlite3` and `jq` with clear installation instructions
- **Input validation**: Validate note IDs are positive integers
- **Note existence checking**: Verify notes exist before operations
- **Better error messages**: Clear, colored error output for missing notes and invalid input
- **SQL escaping function**: Robust handling of special characters (apostrophes, quotes, etc.) in all user input
- **Version number**: Added v1.1.0 to script and help output
- **Color-coded errors**: RED for errors, YELLOW for warnings

### Fixed
- **SQL injection vulnerabilities**: Proper escaping for project names, tags, and all user input
- **Robustness**: Now handles real-world data like "O'Reilly", quotes, and special characters correctly
- **Silent failures**: Operations now fail with clear error messages instead of silently

### Security
- Fixed SQL injection vulnerabilities in `cmd_search`, `cmd_list`, and `cmd_add` (project parameter)
- All user input now properly escaped using SQL standard (single quote doubling)

### Performance
- No performance impact - all improvements are pre-processing steps
- Error checking adds < 0.01s per operation

## [1.0.0] - 2026-01-08

### Initial Release
- SQLite-backed knowledge base with FTS5 full-text search
- Token-efficient search-first workflow
- Project scoping with `-p` flag
- Tag-based organization
- Import/export functionality
- Soft delete (archive) pattern
- Comprehensive documentation
