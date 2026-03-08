# Commands to initialize, run and destroy Terraform  

**Initialize terraform**
```bash
terraform init
```

**Formate file (correct indentation and all)**
```bash
terraform fmt
```
**Validate .tf file**
```bash
terraform validate
```

**Shows what is it going to do** 
```bash
terraform plan
```


**Apply terraform**
```bash
terraform apply
```

**Destroy terraform (everything)**
```bash
terraform destroy
```

**To destroy terraform without asking for yes/no (everything)**
```bash
terraform apply -auto-approve
```

**To destroy specific terraform**
```bash
terraform --target=aws_instance.my-instance-name
```












