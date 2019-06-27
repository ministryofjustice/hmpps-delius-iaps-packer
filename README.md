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
