# hmpps-delius-iaps-packer

Packer build for a Windows 2012 R2 server that hosts 2 interface services that form the IAPS solution:

- NDelius Interface
- IM Interface

The build uses a combination of batch and powershell scripts to install and configure the required components:

- .Net 3.5
- vcredist packages
- Oracle database client (ODBC Connections)
- Oracle SQLDeveloper tool
- X.509 Certificates
- NDelius Interface
- IM Interface


## GitHub Actions

An action to delete the branch after merge has been added.
Also an action that will tag when branch is merged to master
See https://github.com/anothrNick/github-tag-action

```
Bumping

Manual Bumping: Any commit message that includes #major, #minor, or #patch will trigger the respective version bump. If two or more are present, the highest-ranking one will take precedence.

Automatic Bumping: If no #major, #minor or #patch tag is contained in the commit messages, it will bump whichever DEFAULT_BUMP is set to (which is minor by default).

Note: This action will not bump the tag if the HEAD commit has already been tagged.
```