# Commands to initialize and run Terraform  

Initialize terraform
```bash
terraform init
```

formate file (correct indentation and all)
```bash
terraform fmt
```
validate .tf file
```bash
terraform validate
```

shows what is it going to do 
```bash
terraform plan
```


apply terraform
```bash
terraform apply
```

destroy terraform (everything)
```bash
terraform destroy
```

to destroy terraform without asking for yes/no (everything)
```bash
terraform apply -auto-approve
```

to destroy specific terraform 
```bash
terraform --target=aws_instance.my-instance-name
```












