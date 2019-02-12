# Kitty-cat virus scan builder
This project builds the virus scanner zip that is uploaded to the lambdas.

## Pre-reqs
* This works on Windows only. 
* Install terraform (https://www.terraform.io/downloads.html)
* Install npm (https://www.npmjs.com/get-npm)

## Building the zip
First time only: run `terraform init`.

Go to AWS workbench -> EC2 -> Key Pairs.

Either create a new key and download it, or select a key that you have already downloaded. Copy that key (with .pem extension) to this directory.
Run `npm run-script build`.
You will be prompted for a key. 

> `var.privateKey`
> `  Enter a value:`

Type in the name of the key that you downloaded (without the .pem extension). It is important that the name of the local file and the name of the key on AWS match.

This will take about 10 minutes. When it is complete you will see the IP address of the instance where the zip has been created.

`Finished. Now FTP into 123.45.67.89 with the user 'ec2-user' and the public key MyKey.pem`

Use a FTP tool (e.g. https://mobaxterm.mobatek.net/download.html) to log into this instance. Use the IP address shown, ec2-user as the user and use the public key. The scan.zip file will be in the home directory. Download this.

To cleanup run `npm run-script teardown` and re-enter your key name when prompted.
