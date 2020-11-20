# Structurizr-cli Action

This action allows you to run `structurizr-cli`.

## Usage

To use the action simply create an `structurizr-cli.yml` (or choose custom `*.yml` name) in the `.github/workflows/` directory.

For example:

```yaml
name: sctructurizr-cli  # feel free to pick your own name

on: [push, pull_request]

jobs:
  structurizr-cli:
    runs-on: ubuntu-latest
    name: Run structurizr-cli
    steps:

      - name: Checkout
        uses: actions/checkout@v2

      - name: Run structurizr-cli action
        uses: actions/structurizr-cli-action
        id: test
        with:
          id: # required
          key: # required
          secret: # required
          workspace: # required
```

## License

The Dockerfile and associated scripts and documentation in this project are released under the [MIT](license).

## Credits

The initial GitHub action has been created by [Maksim Milykh](https://github.com/aidmax).
