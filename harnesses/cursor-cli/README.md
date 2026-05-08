# [Cursor CLI](https://cursor.com/docs/cli/overview)

Sets up the Cursor CLI configuration.

We centralize here the configuration for the harness specific features of the Cursor editor too.

- `permissions.json`
- `hooks.json`
- ...

The Cursor editor doesn't allow us to change the config path, so we force the cursor-cli to use the same path as the editor for configuration (see [`./exports.sh`](./harnesses/cursor-cli/exports.sh))

## Known Issues

The cursor cli overwrites the symlink of the configuration file. So any changes made to the configuration file will be lost in an apply.

Check the diffs before applying changes to the configuration file with the utility script [`./config-diff.sh`](./harnesses/cursor-cli/diff.sh)
